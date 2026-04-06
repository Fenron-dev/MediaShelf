import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../../core/mime_resolver.dart';
import '../../../data/database/app_database.dart';
import '../domain/emuvr_tag_suggester.dart';
import 'emuvr_group_service.dart';

const _uuid = Uuid();

/// Describes one detected EmuVR group before import is confirmed.
class EmuvrImportPreview {
  final String basename;
  final List<File> files;
  final List<String> suggestedTags;
  List<String> selectedTags; // user can edit before confirming

  EmuvrImportPreview({
    required this.basename,
    required this.files,
    required this.suggestedTags,
  }) : selectedTags = List.of(suggestedTags);
}

// ── Scanning ──────────────────────────────────────────────────────────────────

/// Scans [folder] for EmuVR-compatible file groups.
///
/// Returns a list of [EmuvrImportPreview] objects. The caller can review
/// them (edit tags) and then call [executeImport].
List<EmuvrImportPreview> scanFolder(Directory folder) {
  final entities = folder.listSync().whereType<File>().toList();
  final byBasename = <String, List<File>>{};
  for (final file in entities) {
    final ext = p.extension(file.path).replaceFirst('.', '').toLowerCase();
    if (!const {'obj', 'mtl', 'png', 'jpg', 'jpeg', 'ini'}.contains(ext)) {
      continue;
    }
    final base = p.basenameWithoutExtension(file.path).toLowerCase();
    (byBasename[base] ??= []).add(file);
  }

  return byBasename.entries
      .where((e) => e.value.any(
            (f) => p.extension(f.path).toLowerCase() == '.obj',
          ))
      .map((e) => EmuvrImportPreview(
            basename: e.key,
            files: e.value,
            suggestedTags: suggestEmuvrTags(e.key),
          ))
      .toList()
    ..sort((a, b) => a.basename.compareTo(b.basename));
}

// ── Import execution ──────────────────────────────────────────────────────────

/// Result of a completed import.
class EmuvrImportResult {
  final int groupsImported;
  final int filesImported;
  final List<String> errors;

  const EmuvrImportResult({
    required this.groupsImported,
    required this.filesImported,
    this.errors = const [],
  });
}

/// Imports the confirmed [previews] into the MediaShelf library.
///
/// [libraryPath] is the absolute path to the library root.
/// [isExternal] — if true, files are copied into the library first.
/// If false, files are already inside the library and only need indexing.
Future<EmuvrImportResult> executeImport({
  required List<EmuvrImportPreview> previews,
  required String libraryPath,
  required bool isExternal,
  required AssetsDao assetsDao,
  required TagsDao tagsDao,
  required AssetLinksDao linksDao,
  required PropertiesDao propertiesDao,
}) async {
  int groupsImported = 0;
  int filesImported = 0;
  final errors = <String>[];

  for (final preview in previews) {
    try {
      // 1. Determine target directory in library
      final targetDir = isExternal
          ? Directory(p.join(libraryPath, 'EmuVR', 'Models'))
          : null;
      if (isExternal && targetDir != null) {
        await targetDir.create(recursive: true);
      }

      // 2. Upsert all files as assets
      final assetIds = <File, String>{};
      for (final file in preview.files) {
        File targetFile;
        String relativePath;
        if (isExternal && targetDir != null) {
          targetFile = File(p.join(targetDir.path, p.basename(file.path)));
          if (!await targetFile.exists() ||
              await targetFile.length() != await file.length()) {
            await file.copy(targetFile.path);
          }
        } else {
          targetFile = file;
        }

        relativePath = p.relative(targetFile.path, from: libraryPath)
            .replaceAll(Platform.pathSeparator, '/');

        final ext = p.extension(targetFile.path).replaceFirst('.', '').toLowerCase();
        final mime = mimeTypeFromExtension(ext);
        final stat = await targetFile.stat();

        final existing = await assetsDao.getByPath(relativePath);
        final assetId = existing?.id ?? _uuid.v4();

        await assetsDao.upsertAsset(AssetsCompanion(
          id: Value(assetId),
          path: Value(relativePath),
          filename: Value(p.basename(targetFile.path)),
          extension: Value(ext),
          mimeType: Value(mime),
          size: Value(stat.size),
          fileModifiedAt: Value(stat.modified.millisecondsSinceEpoch),
          indexedAt: Value(DateTime.now().millisecondsSinceEpoch),
          status: const Value('ok'),
        ));

        assetIds[file] = assetId;
        filesImported++;
      }

      // 3. Find the .obj asset and mark it as primary
      final objFile = preview.files.firstWhere(
        (f) => p.extension(f.path).toLowerCase() == '.obj',
      );
      final objAssetId = assetIds[objFile]!;
      await markAsPrimary(objAssetId, propertiesDao);

      // 4. Link companions to the .obj asset
      for (final file in preview.files) {
        if (file == objFile) continue;
        final companionId = assetIds[file];
        if (companionId != null) {
          await linksDao.linkAssets(objAssetId, companionId);
        }
      }

      // 5. Apply selected tags to the .obj asset
      for (final tag in preview.selectedTags) {
        if (tag.isEmpty) continue;
        final tagId = await tagsDao.upsertTag(tag);
        await assetsDao.addTagToAsset(objAssetId, tagId);
      }

      groupsImported++;
    } catch (e) {
      errors.add('${preview.basename}: $e');
    }
  }

  return EmuvrImportResult(
    groupsImported: groupsImported,
    filesImported: filesImported,
    errors: errors,
  );
}

// ── Library rescan: find unlinked OBJ groups ──────────────────────────────────

/// Scans already-indexed assets in [subfolder] (relative to library root) and
/// links any unlinked OBJ groups it finds.
///
/// Intended as the "Bibliotheks-Rescan" mode: no file copying, just linking.
Future<int> linkExistingGroups({
  required String libraryPath,
  required String subfolderRelative,
  required AssetsDao assetsDao,
  required AssetLinksDao linksDao,
  required PropertiesDao propertiesDao,
}) async {
  final prefix = subfolderRelative.replaceAll(Platform.pathSeparator, '/');

  // Load all assets under the chosen subfolder
  final allAssets = await assetsDao.searchByFilename('');
  final inFolder = allAssets
      .where((a) => a.path.startsWith('$prefix/') || a.path.startsWith(prefix))
      .toList();

  final groups = detectGroups(inFolder);
  int linked = 0;

  for (final group in groups) {
    // Skip if already marked as primary (already imported)
    final alreadyPrimary = await propertiesDao.watchPropertiesForAsset(
      group.objAsset.id,
    ).first;
    final primaryPropId = await _getOrNullPropId(propertiesDao);
    if (primaryPropId != null &&
        alreadyPrimary.any(
          (p) => p.propertyId == primaryPropId && p.valueText == 'true',
        )) {
      continue;
    }

    await markAsPrimary(group.objAsset.id, propertiesDao);
    for (final companion in group.companions) {
      await linksDao.linkAssets(group.objAsset.id, companion.id);
    }
    linked++;
  }

  return linked;
}

Future<String?> _getOrNullPropId(PropertiesDao dao) async {
  final defs = await dao.getAllDefinitions();
  return defs
      .where((d) => d.name == kEmuvrPrimaryAssetProp)
      .firstOrNull
      ?.id;
}
