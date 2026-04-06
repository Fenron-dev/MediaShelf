import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:shared_preferences/shared_preferences.dart';

// SharedPreferences keys
const _kSaltKey = 'vault_salt_v1';
const _kVerifierKey = 'vault_verifier_v1';

// A fixed known plaintext — encrypting this and storing it lets us verify the
// password on subsequent unlocks without storing the password itself.
const _kVerificationText = 'mediashelf-vault-v1-ok';

/// Low-level cryptographic primitives for the MediaShelf Vault.
///
/// Encryption: AES-256-GCM (authenticated — detects tampering).
/// Key derivation: PBKDF2-HMAC-SHA256, 310 000 iterations.
/// On-disk file format: [nonce:12][mac:16][ciphertext:N] — 28 bytes overhead.
class VaultCrypto {
  VaultCrypto._();

  static final _aes = AesGcm.with256bits();
  static final _kdf = Pbkdf2(
    macAlgorithm: Hmac.sha256(),
    iterations: 310000,
    bits: 256,
  );

  // ── Key derivation ──────────────────────────────────────────────────────────

  /// Derives a 256-bit [SecretKey] from [password] + [salt].
  static Future<SecretKey> _deriveKey(String password, List<int> salt) {
    return _kdf.deriveKey(
      secretKey: SecretKey(utf8.encode(password)),
      nonce: salt,
    );
  }

  /// Public alias for external callers (e.g. LibraryLock).
  static Future<SecretKey> deriveKeyFromSalt(
          String password, List<int> salt) =>
      _deriveKey(password, salt);

  /// Generates 16 cryptographically random bytes.
  static List<int> _randomSalt() {
    final rng = Random.secure();
    return List.generate(16, (_) => rng.nextInt(256));
  }

  /// Public alias for external callers.
  static List<int> generateSalt() => _randomSalt();

  /// Public alias for [encrypt] — same format, usable without the Vault context.
  static Future<Uint8List> encryptRaw(SecretKey key, List<int> plaintext) =>
      encrypt(key, plaintext);

  /// Public alias for [decrypt].
  static Future<Uint8List> decryptRaw(SecretKey key, Uint8List data) =>
      decrypt(key, data);

  // ── Encryption / Decryption ─────────────────────────────────────────────────

  /// Encrypts [plaintext] with [key].
  /// Returns `[nonce:12][mac:16][ciphertext]`.
  static Future<Uint8List> encrypt(SecretKey key, List<int> plaintext) async {
    final box = await _aes.encrypt(plaintext, secretKey: key);
    final out = Uint8List(box.nonce.length + box.mac.bytes.length + box.cipherText.length);
    var offset = 0;
    out.setRange(offset, offset += box.nonce.length, box.nonce);
    out.setRange(offset, offset += box.mac.bytes.length, box.mac.bytes);
    out.setRange(offset, offset + box.cipherText.length, box.cipherText);
    return out;
  }

  /// Decrypts data produced by [encrypt].
  /// Throws [SecretBoxAuthenticationError] if the key is wrong or data is corrupted.
  static Future<Uint8List> decrypt(SecretKey key, Uint8List data) async {
    const nonceLen = 12;
    const macLen = 16;
    final box = SecretBox(
      data.sublist(nonceLen + macLen),
      nonce: data.sublist(0, nonceLen),
      mac: Mac(data.sublist(nonceLen, nonceLen + macLen)),
    );
    final plain = await _aes.decrypt(box, secretKey: key);
    return Uint8List.fromList(plain);
  }

  // ── Vault lifecycle ─────────────────────────────────────────────────────────

  /// Returns true when a vault has been configured on this device.
  static Future<bool> isConfigured() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_kSaltKey) && prefs.containsKey(_kVerifierKey);
  }

  /// Sets up a new vault with [password].
  /// Generates a salt, derives a key, stores a verifier blob.
  /// Returns the derived [SecretKey] (vault is unlocked after setup).
  static Future<SecretKey> setup(String password) async {
    final salt = _randomSalt();
    final key = await _deriveKey(password, salt);
    final verifier = await encrypt(key, utf8.encode(_kVerificationText));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSaltKey, base64.encode(salt));
    await prefs.setString(_kVerifierKey, base64.encode(verifier));
    return key;
  }

  /// Attempts to unlock the vault with [password].
  /// Returns the derived [SecretKey] on success, or `null` if the password is wrong.
  static Future<SecretKey?> unlock(String password) async {
    final prefs = await SharedPreferences.getInstance();
    final saltB64 = prefs.getString(_kSaltKey);
    final verifierB64 = prefs.getString(_kVerifierKey);
    if (saltB64 == null || verifierB64 == null) return null;

    final salt = base64.decode(saltB64);
    final key = await _deriveKey(password, salt);

    try {
      final decrypted = await decrypt(key, base64.decode(verifierB64));
      if (utf8.decode(decrypted) == _kVerificationText) return key;
    } on SecretBoxAuthenticationError {
      // Wrong password — fall through to return null.
    } catch (_) {
      // Any other decryption failure.
    }
    return null;
  }

  /// Changes the vault password. Requires the current [SecretKey].
  /// Re-encrypts the verifier with the new password and saves the new salt.
  static Future<SecretKey> changePassword(
    SecretKey currentKey,
    String newPassword,
  ) async {
    // Verify current key is valid first.
    final prefs = await SharedPreferences.getInstance();
    final verifierB64 = prefs.getString(_kVerifierKey);
    if (verifierB64 != null) {
      await decrypt(currentKey, base64.decode(verifierB64)); // throws if invalid
    }
    return setup(newPassword);
  }

  /// Wipes all vault configuration from SharedPreferences (irreversible!).
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSaltKey);
    await prefs.remove(_kVerifierKey);
  }
}
