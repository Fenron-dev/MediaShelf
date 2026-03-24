import 'dart:io';

import 'package:path/path.dart' as p;

import '../../core/constants.dart';
import '../../core/mime_resolver.dart';
import '../../domain/models/scan_result.dart';
import '../database/app_database.dart';
import '../scanner/library_scanner.dart';
import '../thumbnailer/thumbnailer.dart';

/// Metadata about an open library.
class LibraryInfo {
  const LibraryInfo({
    required this.path,
    required this.name,
  });

  final String path;

  /// Display name — last path component.
  final String name;
}

/// Manages the lifecycle of a MediaShelf library:
/// initialising the directory structure, opening the database, and
/// orchestrating scans + thumbnail generation.
class LibraryRepository {
  LibraryRepository();

  AppDatabase? _db;
  AppDatabase get db {
    assert(_db != null, 'Call openLibrary() or initLibrary() first');
    return _db!;
  }

  LibraryInfo? _info;
  LibraryInfo? get currentLibrary => _info;

  // ── Init / Open ──────────────────────────────────────────────────────────

  /// Creates a new library at [path].
  ///
  /// Creates the `.mediashelf/` and `thumbnails/` directories, then opens the
  /// Drift database (which runs `onCreate` migrations on first use).
  Future<LibraryInfo> initLibrary(String path) async {
    final mediashelfDir = Directory(p.join(path, kMediashelfDir));
    final thumbsDir = Directory(p.join(path, kMediashelfDir, kThumbDir));
    await mediashelfDir.create(recursive: true);
    await thumbsDir.create(recursive: true);

    _db?.close();
    _db = AppDatabase(p.join(path, kMediashelfDir, kDbFilename));
    // Open the DB once to trigger onCreate migrations
    await _db!.customSelect('SELECT 1').get();

    _info = LibraryInfo(path: path, name: p.basename(path));
    return _info!;
  }

  /// Opens an existing library at [path].
  ///
  /// Throws [ArgumentError] if the path does not contain a `.mediashelf/`
  /// directory with a valid database.
  Future<LibraryInfo> openLibrary(String path) async {
    final dbFile = File(p.join(path, kMediashelfDir, kDbFilename));
    if (!dbFile.existsSync()) {
      throw ArgumentError(
        'No MediaShelf library found at "$path".\n'
        'Expected: ${dbFile.path}',
      );
    }

    _db?.close();
    _db = AppDatabase(dbFile.path);
    await _db!.customSelect('SELECT 1').get();

    _info = LibraryInfo(path: path, name: p.basename(path));
    return _info!;
  }

  void closeLibrary() {
    _db?.close();
    _db = null;
    _info = null;
  }

  // ── Scan ─────────────────────────────────────────────────────────────────

  /// Runs a full library scan and returns the result.
  ///
  /// [onProgress] receives progress updates during the scan.
  /// [onThumbnailsStarted] is called once with the total thumbnail count.
  /// [onThumbnailGenerated] is called for each generated thumbnail.
  Future<ScanResult> scanLibrary({
    void Function(int processed, int total)? onProgress,
    void Function(int total)? onThumbnailsStarted,
    void Function(String thumbPath)? onThumbnailGenerated,
  }) async {
    final libraryPath = _info?.path;
    if (libraryPath == null) throw StateError('No library open');

    ScanResult? scanResult;

    await for (final msg in startScan(libraryPath)) {
      if (msg is ScanProgressMessage) {
        onProgress?.call(msg.processed, msg.total);
      } else if (msg is ScanCompleteMessage) {
        scanResult = msg.result;
      } else if (msg is ScanErrorMessage) {
        throw Exception('Scan failed: ${msg.error}');
      }
    }

    // Generate thumbnails for new/changed assets
    await _generateMissingThumbnails(
      libraryPath: libraryPath,
      onStarted: onThumbnailsStarted,
      onGenerated: onThumbnailGenerated,
    );

    return scanResult ?? const ScanResult(
      added: 0,
      updated: 0,
      missing: 0,
      total: 0,
      elapsed: Duration.zero,
    );
  }

  Future<void> _generateMissingThumbnails({
    required String libraryPath,
    void Function(int total)? onStarted,
    void Function(String)? onGenerated,
  }) async {
    // Get all 'ok' assets that don't have a thumbnail yet
    final rows = await db.customSelect(
      'SELECT id, path, extension, mime_type, content_hash'
      " FROM assets WHERE status = 'ok' AND content_hash IS NOT NULL",
    ).get();

    final jobs = <ThumbJob>[];
    for (final row in rows) {
      final hash = row.read<String>('content_hash');
      final thumbFile = File(thumbPath(libraryPath, hash));
      if (!thumbFile.existsSync()) {
        final ext = row.readNullable<String>('extension') ?? '';
        jobs.add(ThumbJob(
          libraryPath: libraryPath,
          assetId: row.read<String>('id'),
          absFilePath: p.join(libraryPath, row.read<String>('path')),
          mimeType: row.readNullable<String>('mime_type') ??
              mimeTypeFromExtension(ext),
          contentHash: hash,
        ));
      }
    }

    if (jobs.isNotEmpty) onStarted?.call(jobs.length);
    await for (final path in generateThumbnailBatch(jobs)) {
      onGenerated?.call(path);
    }
  }
}
