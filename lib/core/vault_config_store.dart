import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'safe_paths.dart';

const _kLegacySaltKey = 'vault_salt_v1';
const _kLegacyVerifierKey = 'vault_verifier_v1';

class VaultConfig {
  const VaultConfig({required this.saltB64, required this.verifierB64});

  final String saltB64;
  final String verifierB64;

  Map<String, dynamic> toJson() => {
    'version': 1,
    'salt': saltB64,
    'verifier': verifierB64,
  };

  static VaultConfig fromJson(Map<String, dynamic> json) {
    final salt = json['salt'];
    final verifier = json['verifier'];
    if (salt is! String || verifier is! String) {
      throw const FormatException('Invalid vault config payload.');
    }
    return VaultConfig(saltB64: salt, verifierB64: verifier);
  }
}

class VaultConfigStore {
  const VaultConfigStore();

  String configPath(String libraryPath) => resolveRelativePathWithinRoot(
    rootPath: libraryPath,
    relativePath: '$kMediashelfDir/vault.json',
  );

  Future<bool> exists(String libraryPath) async {
    return File(configPath(libraryPath)).exists();
  }

  Future<VaultConfig?> read(String libraryPath) async {
    final file = File(configPath(libraryPath));
    if (!await file.exists()) return null;

    final json = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
    return VaultConfig.fromJson(json);
  }

  Future<void> write(String libraryPath, VaultConfig config) async {
    final file = File(configPath(libraryPath));
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(config.toJson()), flush: true);
  }

  Future<void> delete(String libraryPath) async {
    final file = File(configPath(libraryPath));
    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<bool> legacyConfigExists() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kLegacySaltKey) &&
        prefs.containsKey(_kLegacyVerifierKey);
  }

  Future<VaultConfig?> readLegacyConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final salt = prefs.getString(_kLegacySaltKey);
    final verifier = prefs.getString(_kLegacyVerifierKey);
    if (salt == null || verifier == null) return null;
    return VaultConfig(saltB64: salt, verifierB64: verifier);
  }

  Future<void> importLegacyConfig(String libraryPath) async {
    final legacy = await readLegacyConfig();
    if (legacy == null) {
      throw FileSystemException('No legacy vault configuration found.');
    }
    await write(libraryPath, legacy);
    await clearLegacyConfig();
  }

  Future<void> clearLegacyConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLegacySaltKey);
    await prefs.remove(_kLegacyVerifierKey);
  }
}
