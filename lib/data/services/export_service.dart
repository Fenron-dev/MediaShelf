import 'dart:io';

import 'package:path/path.dart' as p;

import '../../data/database/app_database.dart';
import '../../domain/models/import_result.dart';

// ── ExportService ─────────────────────────────────────────────────────────────

/// Copies assets from the library to an external destination directory.
class ExportService {
  const ExportService({required this.libraryPath});

  final String libraryPath;

  /// Exports [assets] to [destPath].
  ///
  /// [preserveStructure] = true → `destPath / asset.path` (library-relative)
  /// [preserveStructure] = false → `destPath / asset.filename` (flat, deduped)
  Future<ExportResult> export(
    List<Asset> assets,
    String destPath, {
    required bool preserveStructure,
  }) async {
    var exported = 0;
    final errors = <String>[];
    final usedNames = <String>{};

    for (final asset in assets) {
      final srcAbs = p.join(
        libraryPath,
        asset.path.replaceAll('/', p.separator),
      );

      String destRel;
      if (preserveStructure) {
        destRel = asset.path.replaceAll('/', p.separator);
      } else {
        // Flat export — deduplicate filenames
        destRel = _uniqueName(asset.filename, usedNames);
        usedNames.add(destRel);
      }

      final destAbs = p.join(destPath, destRel);

      try {
        await Directory(p.dirname(destAbs)).create(recursive: true);
        await File(srcAbs).copy(destAbs);
        exported++;
      } catch (e) {
        errors.add('${asset.filename}: $e');
      }
    }

    return ExportResult(exported: exported, errors: errors);
  }

  /// Returns a filename that doesn't collide with [used] names,
  /// appending `_2`, `_3`, … before the extension when needed.
  static String _uniqueName(String filename, Set<String> used) {
    if (!used.contains(filename)) return filename;
    final base = p.basenameWithoutExtension(filename);
    final ext = p.extension(filename);
    var counter = 2;
    while (true) {
      final candidate = '${base}_$counter$ext';
      if (!used.contains(candidate)) return candidate;
      counter++;
    }
  }
}
