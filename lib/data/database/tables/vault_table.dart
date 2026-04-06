import 'package:drift/drift.dart';

/// Stores metadata for files that have been encrypted and moved into the Vault.
///
/// The actual encrypted content lives in:
///   `<library>/.mediashelf/vault/<storage_name>.enc`
///
/// Filenames on disk are random UUIDs — the original filename is only stored
/// here in the DB (which is itself in the hidden .mediashelf folder).
class VaultItems extends Table {
  /// UUID — primary key.
  TextColumn get id => text()();

  /// Filename on disk (UUID + ".enc") inside the vault folder.
  TextColumn get storageName => text()();

  /// Original filename shown in the UI (e.g. "passport_scan.pdf").
  TextColumn get originalFilename => text()();

  /// MIME type for choosing the right icon (e.g. "image/jpeg").
  TextColumn get originalMimeType => text()();

  /// File extension without dot (e.g. "pdf"), nullable.
  TextColumn get originalExtension => text().nullable()();

  /// Size of the original (unencrypted) file in bytes.
  IntColumn get fileSizeBytes => integer()();

  /// Unix timestamp (ms) when the item was added to the vault.
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
