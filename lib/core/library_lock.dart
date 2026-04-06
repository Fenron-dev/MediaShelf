import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'constants.dart';
import 'vault_crypto.dart';

/// Manages the optional App-Lock for a library.
///
/// When enabled, a `lock.json` file is written to `.mediashelf/`.
/// It contains a salt and an AES-256-GCM verifier blob (same scheme as
/// VaultCrypto) — the password is never stored.
///
/// On disk the file looks like:
/// ```json
/// { "salt": "<base64>", "verifier": "<base64>", "obfuscate_filenames": false }
/// ```
class LibraryLock {
  const LibraryLock._();

  static String _lockPath(String libraryPath) =>
      p.join(libraryPath, kMediashelfDir, 'lock.json');

  // ── Query ───────────────────────────────────────────────────────────────────

  /// Returns true when the given library has an App-Lock configured.
  static bool isLocked(String libraryPath) =>
      File(_lockPath(libraryPath)).existsSync();

  /// Reads the `obfuscate_filenames` setting from the lock file.
  /// Returns false if no lock file exists.
  static bool filenamesObfuscated(String libraryPath) {
    final f = File(_lockPath(libraryPath));
    if (!f.existsSync()) return false;
    try {
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      return data['obfuscate_filenames'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  // ── Setup / change password ─────────────────────────────────────────────────

  /// Enables the App-Lock for [libraryPath] with [password].
  /// Overwrites any existing lock file.
  static Future<void> enable(
    String libraryPath,
    String password, {
    bool obfuscateFilenames = false,
  }) async {
    // Derive key + verifier using the same crypto as VaultCrypto, but with a
    // library-scoped prefs key so it doesn't collide with the Vault key.
    final salt = VaultCrypto.generateSalt();
    final key = await VaultCrypto.deriveKeyFromSalt(password, salt);
    final verifier = await VaultCrypto.encryptRaw(
      key,
      utf8.encode('mediashelf-lock-v1-ok'),
    );

    final lockFile = File(_lockPath(libraryPath));
    await lockFile.writeAsString(
      jsonEncode({
        'salt': base64.encode(salt),
        'verifier': base64.encode(verifier),
        'obfuscate_filenames': obfuscateFilenames,
      }),
      flush: true,
    );
  }

  /// Disables the App-Lock by deleting the lock file.
  static Future<void> disable(String libraryPath) async {
    final f = File(_lockPath(libraryPath));
    if (f.existsSync()) await f.delete();
  }

  /// Updates only the `obfuscate_filenames` flag without changing the password.
  static Future<void> setObfuscateFilenames(
    String libraryPath,
    bool value,
  ) async {
    final f = File(_lockPath(libraryPath));
    if (!f.existsSync()) return;
    final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    data['obfuscate_filenames'] = value;
    await f.writeAsString(jsonEncode(data), flush: true);
  }

  // ── Verification ────────────────────────────────────────────────────────────

  /// Returns true if [password] is correct for this library.
  static Future<bool> verify(String libraryPath, String password) async {
    final f = File(_lockPath(libraryPath));
    if (!f.existsSync()) return true; // no lock → always ok

    try {
      final data = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final salt = base64.decode(data['salt'] as String);
      final verifier = base64.decode(data['verifier'] as String);

      final key = await VaultCrypto.deriveKeyFromSalt(password, salt);
      await VaultCrypto.decryptRaw(key, verifier); // throws if wrong
      return true;
    } catch (_) {
      return false;
    }
  }
}
