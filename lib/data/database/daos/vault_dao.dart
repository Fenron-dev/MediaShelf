import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/vault_table.dart';

part 'vault_dao.g.dart';

@DriftAccessor(tables: [VaultItems])
class VaultDao extends DatabaseAccessor<AppDatabase> with _$VaultDaoMixin {
  VaultDao(super.db);

  /// Stream of all vault items, newest first.
  Stream<List<VaultItem>> watchAll() => (select(vaultItems)
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
      .watch();

  /// Insert a new vault item.
  Future<void> insertItem(VaultItemsCompanion entry) =>
      into(vaultItems).insert(entry);

  /// Delete a vault item by id.
  Future<void> deleteItem(String id) =>
      (delete(vaultItems)..where((t) => t.id.equals(id))).go();

  /// Returns all vault items (one-shot).
  Future<List<VaultItem>> getAll() => (select(vaultItems)
        ..orderBy([(t) => OrderingTerm.desc(t.addedAt)]))
      .get();
}
