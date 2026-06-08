import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/vault_crypto.dart';
import '../core/vault_config_store.dart';
import '../data/database/app_database.dart';
import '../data/services/vault_service.dart';
import 'library_provider.dart';

// ── Vault DAO provider ────────────────────────────────────────────────────────

final vaultDaoProvider = Provider<VaultDao>(
  (ref) => ref.watch(databaseProvider).vaultDao,
);

// ── Vault items stream ────────────────────────────────────────────────────────

final vaultItemsProvider = StreamProvider<List<VaultItem>>((ref) {
  return ref.watch(vaultDaoProvider).watchAll();
});

final vaultConfigStoreProvider = Provider((ref) => const VaultConfigStore());

// ── Vault service ─────────────────────────────────────────────────────────────

final vaultServiceProvider = Provider<VaultService>((ref) {
  final libraryPath = ref.watch(libraryPathProvider);
  if (libraryPath == null) throw StateError('No library open');
  return VaultService(
    libraryPath: libraryPath,
    vaultDao: ref.watch(vaultDaoProvider),
  );
});

// ── Vault state (locked / unlocked / not configured) ─────────────────────────

enum VaultStatus { notConfigured, migrationRequired, locked, unlocked }

class VaultState {
  const VaultState({required this.status, this.key});

  final VaultStatus status;

  /// Non-null only when [status] == [VaultStatus.unlocked].
  final SecretKey? key;

  bool get isUnlocked => status == VaultStatus.unlocked;
  bool get isLocked => status == VaultStatus.locked;
  bool get isNotConfigured => status == VaultStatus.notConfigured;
  bool get needsMigration => status == VaultStatus.migrationRequired;
}

class VaultNotifier extends StateNotifier<VaultState> {
  VaultNotifier(this._ref, this._libraryPath)
    : super(const VaultState(status: VaultStatus.locked)) {
    _init();
  }

  final Ref _ref;
  final String? _libraryPath;

  VaultConfigStore get _store => _ref.read(vaultConfigStoreProvider);

  Future<void> _init() async {
    final libraryPath = _libraryPath;
    if (libraryPath == null) {
      state = const VaultState(status: VaultStatus.locked);
      return;
    }

    final hasLocalConfig = await _store.exists(libraryPath);
    if (hasLocalConfig) {
      state = const VaultState(status: VaultStatus.locked);
      return;
    }

    final hasLegacyConfig = await _store.legacyConfigExists();
    if (hasLegacyConfig && mounted) {
      state = const VaultState(status: VaultStatus.migrationRequired);
      return;
    }

    if (mounted) {
      state = const VaultState(status: VaultStatus.notConfigured);
    }
  }

  /// Creates a new vault with [password]. Returns true on success.
  Future<bool> setup(String password) async {
    final libraryPath = _libraryPath;
    if (libraryPath == null) return false;

    try {
      final config = await VaultCrypto.createConfig(password);
      await _store.write(libraryPath, config);
      final key = await VaultCrypto.unlockWithConfig(password, config);
      if (key == null) return false;
      state = VaultState(status: VaultStatus.unlocked, key: key);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Unlocks the vault with [password]. Returns true on success.
  Future<bool> unlock(String password) async {
    final libraryPath = _libraryPath;
    if (libraryPath == null) return false;

    final config = await _store.read(libraryPath);
    if (config == null) return false;

    final key = await VaultCrypto.unlockWithConfig(password, config);
    if (key == null) return false;
    state = VaultState(status: VaultStatus.unlocked, key: key);
    return true;
  }

  /// Imports the previous device-wide vault configuration into this library.
  Future<bool> importLegacyConfig() async {
    final libraryPath = _libraryPath;
    if (libraryPath == null) return false;

    try {
      await _store.importLegacyConfig(libraryPath);
      state = const VaultState(status: VaultStatus.locked);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Locks the vault and clears the in-memory key.
  void lock() {
    state = const VaultState(status: VaultStatus.locked);
  }

  /// Changes the vault password. Requires the vault to be unlocked.
  Future<bool> changePassword(String newPassword) async {
    final libraryPath = _libraryPath;
    final currentKey = state.key;
    if (currentKey == null || libraryPath == null) return false;

    try {
      final currentConfig = await _store.read(libraryPath);
      if (currentConfig == null) return false;
      await VaultCrypto.decryptRaw(
        currentKey,
        Uint8List.fromList(base64.decode(currentConfig.verifierB64)),
      );
      final nextConfig = await VaultCrypto.createConfig(newPassword);
      await _store.write(libraryPath, nextConfig);
      final newKey = await VaultCrypto.unlockWithConfig(
        newPassword,
        nextConfig,
      );
      if (newKey == null) return false;
      state = VaultState(status: VaultStatus.unlocked, key: newKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes all vault configuration (irreversible — encrypted files remain on disk).
  Future<void> reset() async {
    final libraryPath = _libraryPath;
    if (libraryPath != null) {
      await _store.delete(libraryPath);
    }
    state = const VaultState(status: VaultStatus.notConfigured);
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>(
  (ref) => VaultNotifier(ref, ref.watch(libraryPathProvider)),
);
