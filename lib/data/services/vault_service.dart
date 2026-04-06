import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:drift/drift.dart' show Value;
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../core/constants.dart';
import '../../core/vault_crypto.dart';
import '../../data/database/app_database.dart';

/// High-level service for adding and removing files from the Vault.
///
/// All encrypted files live in `<library>/.mediashelf/vault/` with random
/// UUID filenames (`<uuid>.enc`) so the filesystem reveals nothing meaningful.
class VaultService {
  VaultService({required this.libraryPath, required this.vaultDao});

  final String libraryPath;
  final VaultDao vaultDao;

  String get _vaultDir => p.join(libraryPath, kMediashelfDir, kVaultDir);

  /// Ensures the vault folder exists on disk.
  Future<void> ensureVaultDir() async {
    final dir = Directory(_vaultDir);
    if (!dir.existsSync()) await dir.create(recursive: true);
  }

  /// Encrypts [sourceFile] and stores it in the vault.
  ///
  /// The source file is NOT deleted — the caller decides whether to remove it.
  /// The vault screen refreshes automatically via the [VaultDao.watchAll] stream.
  Future<void> addFile(File sourceFile, SecretKey key) async {
    await ensureVaultDir();

    final id = const Uuid().v4();
    final storageName = '$id$kVaultExt';
    final destPath = p.join(_vaultDir, storageName);

    final plaintext = await sourceFile.readAsBytes();
    final encrypted = await VaultCrypto.encrypt(key, plaintext);
    await File(destPath).writeAsBytes(encrypted, flush: true);

    final ext = p.extension(sourceFile.path).replaceFirst('.', '').toLowerCase();
    final entry = VaultItemsCompanion.insert(
      id: id,
      storageName: storageName,
      originalFilename: p.basename(sourceFile.path),
      originalMimeType: _mimeForExtension(ext),
      originalExtension: Value(ext.isEmpty ? null : ext),
      fileSizeBytes: plaintext.length,
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await vaultDao.insertItem(entry);
  }

  /// Decrypts [item] and writes the plaintext file to [destDir].
  /// Removes the encrypted file from vault storage and the DB entry.
  Future<File> removeFile(VaultItem item, SecretKey key, Directory destDir) async {
    final encPath = p.join(_vaultDir, item.storageName);
    final encFile = File(encPath);

    final encrypted = await encFile.readAsBytes();
    final plaintext = await VaultCrypto.decrypt(key, encrypted);

    final destFile = File(p.join(destDir.path, item.originalFilename));
    await destFile.writeAsBytes(plaintext, flush: true);

    // Overwrite the encrypted file with zeros before deleting (best-effort wipe).
    await encFile.writeAsBytes(
      List.filled(encrypted.length, 0),
      flush: true,
    );
    await encFile.delete();
    await vaultDao.deleteItem(item.id);

    return destFile;
  }

  /// Decrypts [item] to a system temp directory for in-app preview.
  /// The caller is responsible for deleting the returned file when done.
  Future<File> decryptToTemp(VaultItem item, SecretKey key) async {
    final encPath = p.join(_vaultDir, item.storageName);
    final encrypted = await File(encPath).readAsBytes();
    final plaintext = await VaultCrypto.decrypt(key, encrypted);

    final tempDir = await Directory.systemTemp.createTemp('mediashelf_vault_');
    final tempFile = File(p.join(tempDir.path, item.originalFilename));
    await tempFile.writeAsBytes(plaintext, flush: true);
    return tempFile;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static String _mimeForExtension(String ext) => switch (ext) {
        'jpg' || 'jpeg' => 'image/jpeg',
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'heic' || 'heif' => 'image/heic',
        'mp4' => 'video/mp4',
        'mov' => 'video/quicktime',
        'mkv' => 'video/x-matroska',
        'avi' => 'video/x-msvideo',
        'mp3' => 'audio/mpeg',
        'flac' => 'audio/flac',
        'aac' => 'audio/aac',
        'wav' => 'audio/wav',
        'pdf' => 'application/pdf',
        'zip' => 'application/zip',
        'doc' || 'docx' => 'application/msword',
        'xls' || 'xlsx' => 'application/vnd.ms-excel',
        _ => 'application/octet-stream',
      };
}
