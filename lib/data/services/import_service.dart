import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../../domain/models/import_result.dart';
import '../../core/mime_resolver.dart';

// ── ImportService ─────────────────────────────────────────────────────────────

/// Handles all file-import logic:
/// 1. [analyze] — collects source files, computes MD5s, classifies each file.
/// 2. [execute] — copies files and optionally creates a collection mirror.
class ImportService {
  const ImportService({
    required this.libraryPath,
    required this.assetsDao,
    required this.collectionsDao,
  });

  final String libraryPath;
  final AssetsDao assetsDao;
  final CollectionsDao collectionsDao;

  // ── Phase 1: analyse ─────────────────────────────────────────────────────

  /// Collects [sourcePaths] (files or directories), strips [stripPrefix] from
  /// each absolute source path, and classifies every file as:
  /// - [ImportPlan.toCopy] — new, destination path is free
  /// - [ImportPlan.toRename] — destination taken, will be auto-renamed
  /// - [ImportPlan.duplicates] — same MD5 as an existing asset at a *different* path
  Future<ImportPlan> analyze(
    List<String> sourcePaths,
    String stripPrefix,
  ) async {
    // Collect all files recursively
    final allFiles = <File>[];
    for (final sp in sourcePaths) {
      final entity = FileSystemEntity.typeSync(sp);
      if (entity == FileSystemEntityType.file) {
        allFiles.add(File(sp));
      } else if (entity == FileSystemEntityType.directory) {
        allFiles.addAll(
          Directory(sp)
              .listSync(recursive: true, followLinks: false)
              .whereType<File>(),
        );
      }
    }

    final toCopy = <ImportItem>[];
    final toRename = <ImportItem>[];
    final duplicates = <DuplicateInfo>[];

    // Normalise strip prefix: ensure it ends with separator
    final normPrefix = stripPrefix.endsWith(p.separator)
        ? stripPrefix
        : '$stripPrefix${p.separator}';

    for (final file in allFiles) {
      final absPath = file.path;

      // Derive relative destination path inside library
      String rel;
      if (normPrefix.isNotEmpty && absPath.startsWith(normPrefix)) {
        rel = absPath.substring(normPrefix.length);
      } else {
        rel = p.basename(absPath);
      }
      // Normalise to forward slashes
      final destRel = rel.replaceAll(r'\', '/');
      final destAbs = p.join(libraryPath, destRel.replaceAll('/', p.separator));

      // Hash for duplicate detection
      final hash = _md5File(absPath);

      // Check if an asset with this hash already exists in the library
      final existing = await assetsDao.getByHash(hash);
      if (existing != null && existing.path != destRel) {
        // Same content, different path → let user decide
        duplicates.add(DuplicateInfo(
          sourcePath: absPath,
          existingAsset: existing,
          destRelPath: destRel,
        ));
        continue;
      }

      // Check if the destination file already exists on disk
      if (File(destAbs).existsSync()) {
        // Same path exists → auto-rename
        toRename.add(ImportItem(
          sourcePath: absPath,
          destRelPath: _uniqueDestRel(destRel),
        ));
      } else {
        toCopy.add(ImportItem(sourcePath: absPath, destRelPath: destRel));
      }
    }

    return ImportPlan(
      toCopy: toCopy,
      toRename: toRename,
      duplicates: duplicates,
      libraryPath: libraryPath,
      stripPrefix: stripPrefix,
    );
  }

  // ── Phase 2: execute ─────────────────────────────────────────────────────

  /// Executes an [ImportPlan] after the user has resolved duplicates.
  /// Optionally creates a collection hierarchy mirroring the folder structure.
  Future<ImportResult> execute(
    ImportPlan plan, {
    bool createCollectionMirror = false,
    String? collectionName,
  }) async {
    var copied = 0;
    var renamed = 0;
    var linked = 0;
    var skipped = 0;
    final errors = <String>[];

    // ── Pre-build collection hierarchy if requested ──
    final Map<String, String> collectionIdByRelDir = {};
    if (createCollectionMirror && collectionName != null) {
      await _buildCollectionHierarchy(
        plan: plan,
        rootName: collectionName,
        collectionIdByRelDir: collectionIdByRelDir,
      );
    }

    // Helper: add asset to collection at its directory position
    Future<void> addToCollection(String assetId, String destRelPath) async {
      if (!createCollectionMirror) return;
      final dir = _dirOf(destRelPath);
      final colId = collectionIdByRelDir[dir];
      if (colId != null) {
        await collectionsDao.addAssetToCollection(colId, assetId);
      }
    }

    // ── Copy new files ──
    for (final item in plan.toCopy) {
      try {
        final assetId = await _copyAndIndex(item.sourcePath, item.destRelPath);
        await addToCollection(assetId, item.destRelPath);
        copied++;
      } catch (e) {
        errors.add('${p.basename(item.sourcePath)}: $e');
      }
    }

    // ── Copy renamed files ──
    for (final item in plan.toRename) {
      try {
        final assetId = await _copyAndIndex(item.sourcePath, item.destRelPath);
        await addToCollection(assetId, item.destRelPath);
        renamed++;
      } catch (e) {
        errors.add('${p.basename(item.sourcePath)}: $e');
      }
    }

    // ── Handle duplicates per user choice ──
    for (final dup in plan.duplicates) {
      switch (dup.choice) {
        case DuplicateChoice.importCopy:
          try {
            final dest = _uniqueDestRel(dup.destRelPath);
            final assetId = await _copyAndIndex(dup.sourcePath, dest);
            await addToCollection(assetId, dest);
            copied++;
          } catch (e) {
            errors.add('${p.basename(dup.sourcePath)}: $e');
          }
        case DuplicateChoice.link:
          // No file copy — just add the existing asset to the collection
          await addToCollection(dup.existingAsset.id, dup.destRelPath);
          linked++;
        case DuplicateChoice.skip:
          skipped++;
      }
    }

    return ImportResult(
      copied: copied,
      renamed: renamed,
      linked: linked,
      skipped: skipped,
      errors: errors,
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Copies [sourcePath] to `libraryPath/destRelPath` and inserts the asset
  /// into the database. Returns the new asset's ID.
  Future<String> _copyAndIndex(String sourcePath, String destRelPath) async {
    final destAbs = p.join(
      libraryPath,
      destRelPath.replaceAll('/', p.separator),
    );
    // Ensure parent directory exists
    await Directory(p.dirname(destAbs)).create(recursive: true);
    await File(sourcePath).copy(destAbs);

    final file = File(destAbs);
    final stat = file.statSync();
    final ext = p.extension(destAbs).replaceFirst('.', '').toLowerCase();
    final mimeType = mimeTypeFromExtension(ext);
    final hash = _md5File(destAbs);
    final filename = p.basename(destAbs);
    final now = DateTime.now().millisecondsSinceEpoch;
    final id = const Uuid().v4();

    await assetsDao.upsertAsset(AssetsCompanion(
      id: Value(id),
      path: Value(destRelPath),
      filename: Value(filename),
      extension: Value(ext.isEmpty ? null : ext),
      size: Value(stat.size),
      mimeType: Value(mimeType),
      contentHash: Value(hash),
      status: const Value('ok'),
      fileModifiedAt: Value(stat.modified.millisecondsSinceEpoch),
      indexedAt: Value(now),
    ));

    return id;
  }

  /// Builds the full collection hierarchy for all paths in the plan.
  /// Fills [collectionIdByRelDir] map (rel-dir → collection ID).
  Future<void> _buildCollectionHierarchy({
    required ImportPlan plan,
    required String rootName,
    required Map<String, String> collectionIdByRelDir,
  }) async {
    // Gather all unique directory paths that will receive files
    final dirs = <String>{};
    for (final item in plan.toCopy) {
      dirs.add(_dirOf(item.destRelPath));
    }
    for (final item in plan.toRename) {
      dirs.add(_dirOf(item.destRelPath));
    }
    for (final dup in plan.duplicates) {
      if (dup.choice != DuplicateChoice.skip) {
        dirs.add(_dirOf(dup.destRelPath));
      }
    }

    // Sort so parents come before children
    final sortedDirs = dirs.toList()..sort();

    for (final dir in sortedDirs) {
      if (collectionIdByRelDir.containsKey(dir)) continue;

      // Build ancestry chain: '' → 'A/' → 'A/B/' → 'A/B/C/'
      final segments = dir.isEmpty
          ? <String>[]
          : dir.split('/').where((s) => s.isNotEmpty).toList();

      String? parentId;
      var cumPath = '';
      for (var i = 0; i < segments.length; i++) {
        cumPath = i == 0 ? '${segments[0]}/' : '$cumPath${segments[i]}/';
        if (collectionIdByRelDir.containsKey(cumPath)) {
          parentId = collectionIdByRelDir[cumPath];
          continue;
        }
        final name = i == 0 ? rootName : segments[i];
        final colId = const Uuid().v4();
        await collectionsDao.createCollection(
          id: colId,
          name: name,
          parentId: parentId,
        );
        collectionIdByRelDir[cumPath] = colId;
        parentId = colId;
      }
    }
  }

  /// Returns a dest-rel path that doesn't collide with an existing file,
  /// by appending `_2`, `_3`, … before the extension.
  String _uniqueDestRel(String destRelPath) {
    final dir = _dirOf(destRelPath);
    final basename = p.basenameWithoutExtension(destRelPath);
    final ext = p.extension(destRelPath); // includes '.'
    var counter = 2;
    while (true) {
      final candidate = '$dir${basename}_$counter$ext';
      final abs = p.join(libraryPath, candidate.replaceAll('/', p.separator));
      if (!File(abs).existsSync()) return candidate;
      counter++;
    }
  }

  /// Directory portion of a relative path, ending with '/'.
  /// e.g. 'Fotos/Urlaub/bild.jpg' → 'Fotos/Urlaub/'
  static String _dirOf(String relPath) {
    final idx = relPath.lastIndexOf('/');
    return idx < 0 ? '' : relPath.substring(0, idx + 1);
  }

  static String _md5File(String path) {
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
}

class _DigestSink implements Sink<Digest> {
  String result = '';
  @override
  void add(Digest data) => result = data.toString();
  @override
  void close() {}
}
