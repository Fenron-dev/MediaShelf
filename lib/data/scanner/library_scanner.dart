import 'dart:io';
import 'dart:isolate';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/mime_resolver.dart';
import '../../domain/models/scan_result.dart';

// Extensions to skip during scan (same as Nexus Explorer)
const _skipExtensions = {'db', 'db-shm', 'db-wal', 'json', 'lnk'};

/// Message sent from the main isolate to the scanner isolate.
class _ScanMessage {
  const _ScanMessage({required this.libraryPath, required this.sendPort});
  final String libraryPath;
  final SendPort sendPort;
}

/// Messages sent back from the scanner isolate.
sealed class ScanIsolateMessage {}

class ScanProgressMessage extends ScanIsolateMessage {
  ScanProgressMessage({required this.processed, required this.total});
  final int processed;
  final int total;
}

class ScanCompleteMessage extends ScanIsolateMessage {
  ScanCompleteMessage({required this.result});
  final ScanResult result;
}

class ScanErrorMessage extends ScanIsolateMessage {
  ScanErrorMessage({required this.error});
  final String error;
}

/// Launches the library scan in a background [Isolate].
///
/// Yields progress updates, then a final [ScanCompleteMessage] or
/// [ScanErrorMessage]. The stream closes automatically when the scan ends.
Stream<ScanIsolateMessage> startScan(String libraryPath) async* {
  final receivePort = ReceivePort();
  await Isolate.spawn(
    _scanIsolateEntry,
    _ScanMessage(libraryPath: libraryPath, sendPort: receivePort.sendPort),
    debugName: 'MediaShelf.Scanner',
  );

  await for (final msg in receivePort) {
    if (msg is ScanIsolateMessage) {
      yield msg;
      if (msg is ScanCompleteMessage || msg is ScanErrorMessage) {
        receivePort.close();
        break;
      }
    }
  }
}

// ── Isolate entry point ──────────────────────────────────────────────────────

void _scanIsolateEntry(_ScanMessage message) {
  try {
    final result = _performScan(message.libraryPath, message.sendPort);
    message.sendPort.send(ScanCompleteMessage(result: result));
  } catch (e, st) {
    message.sendPort.send(ScanErrorMessage(error: '$e\n$st'));
  }
}

ScanResult _performScan(String libraryPath, SendPort send) {
  final mediashelfDir = p.join(libraryPath, kMediashelfDir);
  final dbPath = p.join(mediashelfDir, kDbFilename);

  final db = sqlite3.open(dbPath);
  try {
    db.execute('PRAGMA journal_mode=WAL');
    db.execute('PRAGMA foreign_keys=ON');
    db.execute('PRAGMA busy_timeout=5000');
    db.execute('PRAGMA synchronous=NORMAL');

    final stopwatch = Stopwatch()..start();
    final now = DateTime.now().millisecondsSinceEpoch;
    var added = 0;
    var updated = 0;
    var missing = 0;
    var total = 0;

    // Collect IDs that were already missing before this scan
    final alreadyMissing = <String>{};
    for (final row in db.select("SELECT id FROM assets WHERE status = 'missing'")) {
      alreadyMissing.add(row['id'] as String);
    }

    // Mark all 'ok' assets as 'missing'
    db.execute("UPDATE assets SET status = 'missing' WHERE status = 'ok'");

    // Collect all non-hidden files first (enables accurate progress %)
    final libRoot = Directory(libraryPath);
    final allFiles = libRoot
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((f) {
          // Skip anything inside .mediashelf/
          final rel = p.relative(f.path, from: libraryPath);
          return !rel.startsWith(kMediashelfDir);
        })
        .toList();

    final fileCount = allFiles.length;
    var processed = 0;

    for (final file in allFiles) {
      final absPath = file.path;
      final ext = p.extension(absPath).replaceFirst('.', '').toLowerCase();

      processed++;

      if (_skipExtensions.contains(ext)) continue;

      // Relative path with forward slashes (Nexus-compatible)
      final relPath = p.relative(absPath, from: libraryPath)
          .replaceAll(r'\', '/');
      final filename = p.basename(absPath);
      final mimeType = mimeTypeFromExtension(ext);

      late final FileStat stat;
      try {
        stat = file.statSync();
      } catch (_) {
        continue;
      }

      final size = stat.size;
      final fileModifiedAt = stat.modified.millisecondsSinceEpoch;

      // ── Check if already indexed by path ──
      final existingRows = db.select(
        'SELECT id, size, file_modified_at FROM assets WHERE path = ?',
        [relPath],
      );

      if (existingRows.isNotEmpty) {
        final row = existingRows.first;
        final existingId = row['id'] as String;
        final existingSize = (row['size'] as int?) ?? 0;
        final existingMtime = (row['file_modified_at'] as int?) ?? 0;

        final changed = existingSize != size || existingMtime != fileModifiedAt;
        if (changed) {
          final hash = _md5File(absPath);
          db.execute(
            "UPDATE assets SET status='ok', size=?, content_hash=?,"
            ' file_modified_at=?, indexed_at=? WHERE id=?',
            [size, hash, fileModifiedAt, now, existingId],
          );
          updated++;
        } else {
          db.execute(
            "UPDATE assets SET status='ok', indexed_at=? WHERE id=?",
            [now, existingId],
          );
        }
      } else {
        // ── Not found by path — compute hash and check for move ──
        final hash = _md5File(absPath);
        final movedRows = db.select(
          "SELECT id FROM assets WHERE content_hash = ? AND status = 'missing' LIMIT 1",
          [hash],
        );

        if (movedRows.isNotEmpty) {
          // File was moved externally — update path
          final movedId = movedRows.first['id'] as String;
          db.execute(
            "UPDATE assets SET path=?, filename=?, status='ok',"
            ' size=?, file_modified_at=?, indexed_at=? WHERE id=?',
            [relPath, filename, size, fileModifiedAt, now, movedId],
          );
          db.execute(
            'INSERT INTO activity_log'
            ' (event_type, asset_id, asset_path, asset_filename, occurred_at)'
            " VALUES ('restored', ?, ?, ?, ?)",
            [movedId, relPath, filename, now],
          );
          updated++;
        } else {
          // New file — insert
          final id = const Uuid().v4();
          final extension = ext.isEmpty ? null : ext;
          db.execute(
            'INSERT INTO assets'
            ' (id, path, filename, extension, size, mime_type, content_hash,'
            "  status, file_modified_at, indexed_at)"
            " VALUES (?, ?, ?, ?, ?, ?, ?, 'ok', ?, ?)",
            [id, relPath, filename, extension, size, mimeType, hash,
              fileModifiedAt, now],
          );
          db.execute(
            'INSERT INTO activity_log'
            ' (event_type, asset_id, asset_path, asset_filename, occurred_at)'
            " VALUES ('added', ?, ?, ?, ?)",
            [id, relPath, filename, now],
          );
          added++;
        }
      }

      total++;

      // Send progress every 50 files
      if (processed % 50 == 0) {
        send.send(ScanProgressMessage(processed: processed, total: fileCount));
      }
    }

    // ── Log newly-missing assets ──
    for (final row in db.select(
      "SELECT id, path, filename FROM assets WHERE status = 'missing'",
    )) {
      final id = row['id'] as String;
      missing++;
      if (!alreadyMissing.contains(id)) {
        db.execute(
          'INSERT INTO activity_log'
          ' (event_type, asset_id, asset_path, asset_filename, occurred_at)'
          " VALUES ('missing', ?, ?, ?, ?)",
          [id, row['path'], row['filename'], now],
        );
      }
    }

    stopwatch.stop();
    return ScanResult(
      added: added,
      updated: updated,
      missing: missing,
      total: total,
      elapsed: stopwatch.elapsed,
    );
  } finally {
    db.dispose();
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Computes the MD5 hex digest of a file by reading it in 64 KB chunks.
/// Safe to call from any isolate (pure Dart).
String _md5File(String path) {
  final file = File(path);
  final raf = file.openSync();
  final output = _DigestSink();
  final input = md5.startChunkedConversion(output);
  const chunkSize = 65536;
  try {
    List<int> chunk;
    do {
      chunk = raf.readSync(chunkSize);
      if (chunk.isNotEmpty) input.add(chunk);
    } while (chunk.length == chunkSize);
  } finally {
    raf.closeSync();
  }
  input.close();
  return output.result;
}

class _DigestSink implements Sink<Digest> {
  String result = '';
  @override
  void add(Digest data) => result = data.toString();
  @override
  void close() {}
}
