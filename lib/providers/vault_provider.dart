import 'package:cryptography/cryptography.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/vault_crypto.dart';
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

enum VaultStatus { notConfigured, locked, unlocked }

class VaultState {
  const VaultState({required this.status, this.key});

  final VaultStatus status;

  /// Non-null only when [status] == [VaultStatus.unlocked].
  final SecretKey? key;

  bool get isUnlocked => status == VaultStatus.unlocked;
  bool get isLocked => status == VaultStatus.locked;
  bool get isNotConfigured => status == VaultStatus.notConfigured;
}

class VaultNotifier extends StateNotifier<VaultState> {
  VaultNotifier() : super(const VaultState(status: VaultStatus.locked)) {
    _init();
  }

  Future<void> _init() async {
    final configured = await VaultCrypto.isConfigured();
    if (!configured && mounted) {
      state = const VaultState(status: VaultStatus.notConfigured);
    }
  }

  /// Creates a new vault with [password]. Returns true on success.
  Future<bool> setup(String password) async {
    try {
      final key = await VaultCrypto.setup(password);
      state = VaultState(status: VaultStatus.unlocked, key: key);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Unlocks the vault with [password]. Returns true on success.
  Future<bool> unlock(String password) async {
    final key = await VaultCrypto.unlock(password);
    if (key == null) return false;
    state = VaultState(status: VaultStatus.unlocked, key: key);
    return true;
  }

  /// Locks the vault and clears the in-memory key.
  void lock() {
    state = const VaultState(status: VaultStatus.locked);
  }

  /// Changes the vault password. Requires the vault to be unlocked.
  Future<bool> changePassword(String newPassword) async {
    final currentKey = state.key;
    if (currentKey == null) return false;
    try {
      final newKey = await VaultCrypto.changePassword(currentKey, newPassword);
      state = VaultState(status: VaultStatus.unlocked, key: newKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Deletes all vault configuration (irreversible — encrypted files remain on disk).
  Future<void> reset() async {
    await VaultCrypto.reset();
    state = const VaultState(status: VaultStatus.notConfigured);
  }
}

final vaultProvider = StateNotifierProvider<VaultNotifier, VaultState>(
  (ref) => VaultNotifier(),
);
