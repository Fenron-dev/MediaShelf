import 'package:drift/drift.dart';

import '../app_database.dart';

part 'collections_dao.g.dart';

@DriftAccessor(tables: [Collections, CollectionAssets, Assets])
class CollectionsDao extends DatabaseAccessor<AppDatabase>
    with _$CollectionsDaoMixin {
  CollectionsDao(super.db);

  Stream<List<Collection>> watchAll() =>
      (select(collections)
            ..orderBy([
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.name),
            ]))
          .watch();

  Future<List<Collection>> getAll() =>
      (select(collections)
            ..orderBy([
              (c) => OrderingTerm.asc(c.sortOrder),
              (c) => OrderingTerm.asc(c.name),
            ]))
          .get();

  Future<Collection?> getById(String id) =>
      (select(collections)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<void> createCollection({
    required String id,
    required String name,
    String? parentId,
    int sortOrder = 0,
  }) =>
      into(collections).insert(CollectionsCompanion.insert(
        id: id,
        name: name,
        parentId: Value(parentId),
        sortOrder: Value(sortOrder),
      ));

  Future<void> createSmartFilter({
    required String id,
    required String name,
    required String queryJson,
    String? parentId,
    int sortOrder = 0,
  }) =>
      into(collections).insert(CollectionsCompanion.insert(
        id: id,
        name: name,
        parentId: Value(parentId),
        isSmartFilter: const Value(true),
        smartFilterQuery: Value(queryJson),
        sortOrder: Value(sortOrder),
      ));

  Future<void> updateCollection({
    required String id,
    String? name,
    Value<String?> smartFilterQuery = const Value.absent(),
  }) =>
      (update(collections)..where((c) => c.id.equals(id))).write(
        CollectionsCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          smartFilterQuery: smartFilterQuery,
        ),
      );

  Future<void> deleteCollection(String id) =>
      (delete(collections)..where((c) => c.id.equals(id))).go();

  Future<void> addAssetToCollection(String collectionId, String assetId) =>
      into(collectionAssets).insert(
        CollectionAssetsCompanion.insert(
          collectionId: collectionId,
          assetId: assetId,
        ),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> removeAssetFromCollection(
    String collectionId,
    String assetId,
  ) =>
      (delete(collectionAssets)
            ..where(
              (ca) =>
                  ca.collectionId.equals(collectionId) &
                  ca.assetId.equals(assetId),
            ))
          .go();

  Future<void> addAssetsToCollection(
    String collectionId,
    List<String> assetIds,
  ) async {
    for (final assetId in assetIds) {
      await into(collectionAssets).insert(
        CollectionAssetsCompanion.insert(
          collectionId: collectionId,
          assetId: assetId,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<List<Collection>> getCollectionsForAsset(String assetId) {
    final query = select(collections).join([
      innerJoin(
        collectionAssets,
        collectionAssets.collectionId.equalsExp(collections.id),
      ),
    ])
      ..where(collectionAssets.assetId.equals(assetId))
      ..where(collections.isSmartFilter.equals(false));
    return query.map((row) => row.readTable(collections)).get();
  }

  /// Returns the count of assets matching a smart filter query.
  Future<int> smartFilterCount(String queryJson) async {
    // Build a minimal SELECT COUNT using raw SQL via AssetsDao logic
    // For now returns 0 — actual counting is done via AssetsDao.queryPage total
    return 0;
  }
}
