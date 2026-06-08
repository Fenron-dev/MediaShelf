import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants.dart';
import '../../core/safe_paths.dart';
import '../../core/vault_config_store.dart';
import '../database/app_database.dart';

class LibraryBackupBundle {
  const LibraryBackupBundle({
    required this.appSettings,
    required this.vaultItems,
    this.libraryLock,
    this.vaultConfig,
  });

  final Map<String, Object?> appSettings;
  final Map<String, dynamic>? libraryLock;
  final Map<String, dynamic>? vaultConfig;
  final List<Map<String, dynamic>> vaultItems;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'exportedAt': DateTime.now().toIso8601String(),
    'appSettings': appSettings,
    'libraryLock': libraryLock,
    'vaultConfig': vaultConfig,
    'vaultItems': vaultItems,
  };

  static LibraryBackupBundle fromJson(Map<String, dynamic> json) {
    final settings = (json['appSettings'] as Map?)?.cast<String, Object?>();
    final items =
        (json['vaultItems'] as List?)
            ?.map((entry) => (entry as Map).cast<String, dynamic>())
            .toList() ??
        const <Map<String, dynamic>>[];

    return LibraryBackupBundle(
      appSettings: settings ?? const {},
      libraryLock: (json['libraryLock'] as Map?)?.cast<String, dynamic>(),
      vaultConfig: (json['vaultConfig'] as Map?)?.cast<String, dynamic>(),
      vaultItems: items,
    );
  }
}

class LibraryBackupService {
  LibraryBackupService({
    required this.libraryPath,
    required this.vaultDao,
    required this.vaultConfigStore,
  });

  final String libraryPath;
  final VaultDao vaultDao;
  final VaultConfigStore vaultConfigStore;

  Future<String> exportJson() async {
    final bundle = await _buildBundle();
    return const JsonEncoder.withIndent('  ').convert(bundle.toJson());
  }

  Future<void> importJson(String jsonString) async {
    final payload = jsonDecode(jsonString) as Map<String, dynamic>;
    final bundle = LibraryBackupBundle.fromJson(payload);

    await _restoreAppSettings(bundle.appSettings);
    await _restoreLibraryLock(bundle.libraryLock);
    await _restoreVaultConfig(bundle.vaultConfig);
    await _restoreVaultItems(bundle.vaultItems);
  }

  Future<LibraryBackupBundle> _buildBundle() async {
    final prefs = await SharedPreferences.getInstance();
    final settings = <String, Object?>{};
    final keys = prefs.getKeys().toList()..sort();
    for (final key in keys) {
      final value = prefs.get(key);
      if (value is String ||
          value is int ||
          value is double ||
          value is bool ||
          value is List<String>) {
        settings[key] = value;
      }
    }

    final lockFile = File(
      resolveRelativePathWithinRoot(
        rootPath: libraryPath,
        relativePath: '$kMediashelfDir/lock.json',
      ),
    );
    final libraryLock = await lockFile.exists()
        ? (jsonDecode(await lockFile.readAsString()) as Map<String, dynamic>)
        : null;

    final vaultConfig = await vaultConfigStore.read(libraryPath);
    final vaultItems = await vaultDao.getAll();

    return LibraryBackupBundle(
      appSettings: settings,
      libraryLock: libraryLock,
      vaultConfig: vaultConfig?.toJson(),
      vaultItems: vaultItems
          .map(
            (item) => {
              'id': item.id,
              'storageName': item.storageName,
              'originalFilename': item.originalFilename,
              'originalMimeType': item.originalMimeType,
              'originalExtension': item.originalExtension,
              'fileSizeBytes': item.fileSizeBytes,
              'addedAt': item.addedAt,
            },
          )
          .toList(),
    );
  }

  Future<void> _restoreAppSettings(Map<String, Object?> settings) async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in settings.entries) {
      final value = entry.value;
      if (value is String) {
        await prefs.setString(entry.key, value);
      } else if (value is int) {
        await prefs.setInt(entry.key, value);
      } else if (value is double) {
        await prefs.setDouble(entry.key, value);
      } else if (value is bool) {
        await prefs.setBool(entry.key, value);
      } else if (value is List) {
        await prefs.setStringList(
          entry.key,
          value.map((item) => item.toString()).toList(),
        );
      }
    }
  }

  Future<void> _restoreLibraryLock(Map<String, dynamic>? lockJson) async {
    final lockPath = resolveRelativePathWithinRoot(
      rootPath: libraryPath,
      relativePath: '$kMediashelfDir/lock.json',
    );
    final lockFile = File(lockPath);
    if (lockJson == null) {
      if (await lockFile.exists()) await lockFile.delete();
      return;
    }
    await lockFile.parent.create(recursive: true);
    await lockFile.writeAsString(jsonEncode(lockJson), flush: true);
  }

  Future<void> _restoreVaultConfig(Map<String, dynamic>? configJson) async {
    if (configJson == null) {
      await vaultConfigStore.delete(libraryPath);
      return;
    }
    await vaultConfigStore.write(libraryPath, VaultConfig.fromJson(configJson));
  }

  Future<void> _restoreVaultItems(List<Map<String, dynamic>> items) async {
    final companions = items.map((item) {
      final originalFilename = item['originalFilename'];
      final originalMimeType = item['originalMimeType'];
      final fileSizeBytes = item['fileSizeBytes'];
      final addedAt = item['addedAt'];
      if (originalFilename is! String ||
          originalMimeType is! String ||
          fileSizeBytes is! int ||
          addedAt is! int) {
        throw const FormatException('Invalid vault item in backup.');
      }

      final originalExtension = item['originalExtension'];
      return VaultItemsCompanion.insert(
        id: item['id'] as String,
        storageName: item['storageName'] as String,
        originalFilename: sanitizeFilename(originalFilename),
        originalMimeType: originalMimeType,
        originalExtension: Value(
          originalExtension == null ? null : originalExtension as String,
        ),
        fileSizeBytes: fileSizeBytes,
        addedAt: addedAt,
      );
    }).toList();

    await vaultDao.replaceAll(companions);
  }
}
