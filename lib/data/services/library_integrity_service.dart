import 'dart:io';

import '../../core/constants.dart';
import '../../core/safe_paths.dart';
import '../../core/vault_config_store.dart';
import '../../data/database/app_database.dart';
import '../../data/repositories/library_repository.dart';
import '../../data/thumbnailer/thumbnailer.dart';

class IntegrityIssue {
  const IntegrityIssue({
    required this.code,
    required this.description,
    required this.count,
    this.examples = const [],
  });

  final String code;
  final String description;
  final int count;
  final List<String> examples;
}

class LibraryIntegrityReport {
  const LibraryIntegrityReport(this.issues);

  final List<IntegrityIssue> issues;

  bool get isHealthy => issues.every((issue) => issue.count == 0);
}

class LibraryRepairResult {
  const LibraryRepairResult({
    required this.before,
    required this.after,
    required this.removedOrphanThumbnails,
  });

  final LibraryIntegrityReport before;
  final LibraryIntegrityReport after;
  final int removedOrphanThumbnails;
}

class LibraryIntegrityService {
  LibraryIntegrityService({
    required this.libraryPath,
    required this.assetsDao,
    required this.vaultDao,
    required this.libraryRepository,
    required this.vaultConfigStore,
  });

  final String libraryPath;
  final AssetsDao assetsDao;
  final VaultDao vaultDao;
  final LibraryRepository libraryRepository;
  final VaultConfigStore vaultConfigStore;

  Future<LibraryIntegrityReport> inspect() async {
    final issues = <IntegrityIssue>[];
    final assets = await assetsDao.getAllAssets();
    final vaultItems = await vaultDao.getAll();

    final invalidPaths = <String>[];
    final missingAssets = <String>[];
    final missingThumbs = <String>[];
    final expectedThumbs = <String>{};

    for (final asset in assets) {
      try {
        final assetPath = resolveLibraryRelativePath(
          libraryPath,
          asset.path,
          requireExisting: asset.status == 'ok',
        );
        if (asset.status == 'ok' && !File(assetPath).existsSync()) {
          missingAssets.add(asset.path);
        }
      } on UnsafePathException {
        invalidPaths.add(asset.path);
      }

      final hash = asset.contentHash;
      if (asset.status == 'ok' && hash != null && hash.isNotEmpty) {
        final path = thumbPath(libraryPath, hash);
        expectedThumbs.add(path);
        if (!File(path).existsSync()) {
          missingThumbs.add(asset.path);
        }
      }
    }

    final thumbDir = Directory(
      resolveRelativePathWithinRoot(
        rootPath: libraryPath,
        relativePath: '$kMediashelfDir/$kThumbDir',
      ),
    );
    final orphanThumbs = <String>[];
    if (thumbDir.existsSync()) {
      for (final entity in thumbDir.listSync(followLinks: false)) {
        if (entity is File && !expectedThumbs.contains(entity.path)) {
          orphanThumbs.add(entity.path);
        }
      }
    }

    final missingVaultFiles = <String>[];
    final expectedVaultFiles = <String>{};
    for (final item in vaultItems) {
      final encPath = resolveVaultStoragePath(libraryPath, item.storageName);
      expectedVaultFiles.add(encPath);
      if (!File(encPath).existsSync()) {
        missingVaultFiles.add(item.originalFilename);
      }
    }

    final vaultDir = Directory(
      resolveRelativePathWithinRoot(
        rootPath: libraryPath,
        relativePath: '$kMediashelfDir/$kVaultDir',
      ),
    );
    final orphanVaultFiles = <String>[];
    if (vaultDir.existsSync()) {
      for (final entity in vaultDir.listSync(followLinks: false)) {
        if (entity is File && !expectedVaultFiles.contains(entity.path)) {
          orphanVaultFiles.add(entity.path);
        }
      }
    }

    final hasVaultConfig = await vaultConfigStore.exists(libraryPath);
    final vaultConfigMissing = !hasVaultConfig && vaultItems.isNotEmpty;

    issues.add(
      IntegrityIssue(
        code: 'invalid_asset_paths',
        description:
            'Ungültige oder aus dem Bibliotheks-Root ausbrechende Asset-Pfade',
        count: invalidPaths.length,
        examples: invalidPaths.take(5).toList(),
      ),
    );
    issues.add(
      IntegrityIssue(
        code: 'missing_assets',
        description: 'Als vorhanden markierte Assets fehlen auf der Festplatte',
        count: missingAssets.length,
        examples: missingAssets.take(5).toList(),
      ),
    );
    issues.add(
      IntegrityIssue(
        code: 'missing_thumbnails',
        description: 'Thumbnails fehlen für vorhandene Assets',
        count: missingThumbs.length,
        examples: missingThumbs.take(5).toList(),
      ),
    );
    issues.add(
      IntegrityIssue(
        code: 'orphan_thumbnails',
        description: 'Verwaiste Thumbnail-Dateien ohne Asset-Referenz',
        count: orphanThumbs.length,
        examples: orphanThumbs.take(5).toList(),
      ),
    );
    issues.add(
      IntegrityIssue(
        code: 'missing_vault_files',
        description:
            'Vault-Metadaten verweisen auf fehlende verschlüsselte Dateien',
        count: missingVaultFiles.length,
        examples: missingVaultFiles.take(5).toList(),
      ),
    );
    issues.add(
      IntegrityIssue(
        code: 'orphan_vault_files',
        description: 'Verwaiste verschlüsselte Vault-Dateien ohne DB-Eintrag',
        count: orphanVaultFiles.length,
        examples: orphanVaultFiles.take(5).toList(),
      ),
    );
    issues.add(
      IntegrityIssue(
        code: 'missing_vault_config',
        description:
            'Vault-Dateien vorhanden, aber keine bibliotheksbezogene Vault-Konfiguration gefunden',
        count: vaultConfigMissing ? 1 : 0,
      ),
    );

    return LibraryIntegrityReport(
      issues.where((issue) => issue.count > 0).toList(),
    );
  }

  Future<LibraryRepairResult> repair() async {
    final before = await inspect();

    final mediashelfDir = Directory(
      resolveRelativePathWithinRoot(
        rootPath: libraryPath,
        relativePath: kMediashelfDir,
      ),
    );
    final thumbDir = Directory(
      resolveRelativePathWithinRoot(
        rootPath: libraryPath,
        relativePath: '$kMediashelfDir/$kThumbDir',
      ),
    );
    final vaultDir = Directory(
      resolveRelativePathWithinRoot(
        rootPath: libraryPath,
        relativePath: '$kMediashelfDir/$kVaultDir',
      ),
    );

    await mediashelfDir.create(recursive: true);
    await thumbDir.create(recursive: true);
    await vaultDir.create(recursive: true);

    var removedOrphanThumbnails = 0;
    final assets = await assetsDao.getAllAssets();
    final expectedThumbs = <String>{
      for (final asset in assets)
        if (asset.status == 'ok' &&
            asset.contentHash != null &&
            asset.contentHash!.isNotEmpty)
          thumbPath(libraryPath, asset.contentHash!),
    };
    if (thumbDir.existsSync()) {
      for (final entity in thumbDir.listSync(followLinks: false)) {
        if (entity is File && !expectedThumbs.contains(entity.path)) {
          await entity.delete();
          removedOrphanThumbnails++;
        }
      }
    }

    await libraryRepository.scanLibrary();
    final after = await inspect();

    return LibraryRepairResult(
      before: before,
      after: after,
      removedOrphanThumbnails: removedOrphanThumbnails,
    );
  }
}
