import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediashelf/core/vault_config_store.dart';
import 'package:mediashelf/core/vault_crypto.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('vault config store', () {
    test('keeps vault configs separated per library', () async {
      SharedPreferences.setMockInitialValues({});
      final store = const VaultConfigStore();
      final libraryA = await Directory.systemTemp.createTemp(
        'mediashelf_vault_a_',
      );
      final libraryB = await Directory.systemTemp.createTemp(
        'mediashelf_vault_b_',
      );
      addTearDown(() => libraryA.delete(recursive: true));
      addTearDown(() => libraryB.delete(recursive: true));

      final configA = await VaultCrypto.createConfig('alpha-password');
      final configB = await VaultCrypto.createConfig('beta-password');
      await store.write(libraryA.path, configA);
      await store.write(libraryB.path, configB);

      final unlockA = await VaultCrypto.unlockWithConfig(
        'alpha-password',
        (await store.read(libraryA.path))!,
      );
      final unlockB = await VaultCrypto.unlockWithConfig(
        'beta-password',
        (await store.read(libraryB.path))!,
      );
      final wrongForA = await VaultCrypto.unlockWithConfig(
        'beta-password',
        (await store.read(libraryA.path))!,
      );

      expect(unlockA, isNotNull);
      expect(unlockB, isNotNull);
      expect(wrongForA, isNull);
    });

    test('imports legacy config exactly once', () async {
      SharedPreferences.setMockInitialValues({
        'vault_salt_v1': 'c2FsdA==',
        'vault_verifier_v1': 'dmVyaWZpZXI=',
      });

      final store = const VaultConfigStore();
      final libraryA = await Directory.systemTemp.createTemp(
        'mediashelf_vault_a_',
      );
      final libraryB = await Directory.systemTemp.createTemp(
        'mediashelf_vault_b_',
      );
      addTearDown(() => libraryA.delete(recursive: true));
      addTearDown(() => libraryB.delete(recursive: true));

      await store.importLegacyConfig(libraryA.path);

      expect(await store.exists(libraryA.path), isTrue);
      expect(await store.legacyConfigExists(), isFalse);
      expect(await store.read(libraryB.path), isNull);
    });
  });
}
