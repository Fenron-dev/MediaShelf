import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../data/database/app_database.dart';
import '../../../domain/models/asset_filter.dart';

/// Maps an EmuVR tag name to the target subdirectory under Custom/.
const Map<String, String> kEmuvrTagToSubdir = {
  'EmuVR/Console': 'Consoles',
  'EmuVR/Cart': 'Cartridges',
};

/// Progress event emitted during export.
class EmuvrExportProgress {
  final int done;
  final int total;
  final String? currentFile;
  final String? error;

  const EmuvrExportProgress({
    required this.done,
    required this.total,
    this.currentFile,
    this.error,
  });

  bool get isComplete => done >= total;
}

/// Exports all EmuVR-tagged .obj groups to [emuvrRootPath].
///
/// Yields [EmuvrExportProgress] events as files are copied.
/// The last event always has [isComplete] == true.
Stream<EmuvrExportProgress> exportTaggedGroups({
  required String emuvrRootPath,
  required String libraryPath,
  required AssetsDao assetsDao,
  required AssetLinksDao linksDao,
}) async* {
  // Collect all .obj assets for each EmuVR tag
  final groups = <({Asset obj, String subdir})>[];

  for (final entry in kEmuvrTagToSubdir.entries) {
    final tagName = entry.key;
    const pageSize = 500;
    int page = 0;

    while (true) {
      final result = await assetsDao.queryPage(
        filter: const AssetFilter().copyWith(
          tagFilter: tagName,
          extension: 'obj',
          statusFilter: 'ok',
        ),
        page: page,
        pageSize: pageSize,
      );

      for (final asset in result.assets) {
        groups.add((obj: asset, subdir: entry.value));
      }

      if (result.assets.length < pageSize) break;
      page++;
    }
  }

  if (groups.isEmpty) {
    yield const EmuvrExportProgress(done: 0, total: 0);
    return;
  }

  // Pre-fetch companions for total count
  final resolved = <({Asset obj, String subdir, List<Asset> companions})>[];
  for (final g in groups) {
    final companions = await linksDao.getLinkedAssets(g.obj.id);
    resolved.add((obj: g.obj, subdir: g.subdir, companions: companions));
  }

  final totalFiles =
      resolved.fold<int>(0, (sum, g) => sum + 1 + g.companions.length);
  int done = 0;

  for (final group in resolved) {
    final targetDir = Directory(
      p.join(emuvrRootPath, 'Custom', group.subdir),
    );
    await targetDir.create(recursive: true);

    for (final asset in [group.obj, ...group.companions]) {
      final srcPath = p.join(
        libraryPath,
        asset.path.replaceAll('/', Platform.pathSeparator),
      );
      final srcFile = File(srcPath);
      final destFile = File(p.join(targetDir.path, asset.filename));

      yield EmuvrExportProgress(
        done: done,
        total: totalFiles,
        currentFile: asset.filename,
      );

      try {
        if (await srcFile.exists()) {
          await srcFile.copy(destFile.path);
        }
      } catch (e) {
        yield EmuvrExportProgress(
          done: done,
          total: totalFiles,
          error: '${asset.filename}: $e',
        );
      }

      done++;
    }
  }

  yield EmuvrExportProgress(done: totalFiles, total: totalFiles);
}
