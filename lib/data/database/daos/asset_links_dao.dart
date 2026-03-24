import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

part 'asset_links_dao.g.dart';

@DriftAccessor(tables: [AssetLinks, Assets, AssetTags, AssetProperties])
class AssetLinksDao extends DatabaseAccessor<AppDatabase>
    with _$AssetLinksDaoMixin {
  AssetLinksDao(super.db);

  /// Creates a link between [originalId] and [linkedId].
  /// Copies tags and properties from the original to the linked asset.
  Future<void> linkAssets(String originalId, String linkedId) async {
    // Prevent self-links and duplicates
    if (originalId == linkedId) return;
    final existing = await (select(assetLinks)
          ..where((l) =>
              (l.originalId.equals(originalId) & l.linkedId.equals(linkedId)) |
              (l.originalId.equals(linkedId) & l.linkedId.equals(originalId))))
        .getSingleOrNull();
    if (existing != null) return;

    await into(assetLinks).insert(AssetLinksCompanion(
      id: Value(const Uuid().v4()),
      originalId: Value(originalId),
      linkedId: Value(linkedId),
      createdAt: Value(DateTime.now().millisecondsSinceEpoch),
    ));

    // Sync metadata from original to linked
    await _syncMetadata(originalId, linkedId);
  }

  /// Removes the link between two assets.
  Future<void> unlinkAssets(String originalId, String linkedId) =>
      (delete(assetLinks)
            ..where((l) =>
                l.originalId.equals(originalId) &
                l.linkedId.equals(linkedId)))
          .go();

  /// Returns all assets linked to [assetId] (both as original or linked).
  Future<List<Asset>> getLinkedAssets(String assetId) async {
    // Assets where this is the original
    final asLinked = await (select(assetLinks)
          ..where((l) => l.originalId.equals(assetId)))
        .get();
    // Assets where this is a linked copy
    final asOriginal = await (select(assetLinks)
          ..where((l) => l.linkedId.equals(assetId)))
        .get();

    final ids = <String>{
      ...asLinked.map((l) => l.linkedId),
      ...asOriginal.map((l) => l.originalId),
    };
    if (ids.isEmpty) return [];

    return (select(assets)..where((a) => a.id.isIn(ids))).get();
  }

  /// Returns all links where [assetId] is involved.
  Stream<List<Asset>> watchLinkedAssets(String assetId) {
    final q1 = select(assetLinks)
      ..where((l) => l.originalId.equals(assetId) | l.linkedId.equals(assetId));
    return q1.watch().asyncMap((links) async {
      final ids = <String>{};
      for (final l in links) {
        if (l.originalId != assetId) ids.add(l.originalId);
        if (l.linkedId != assetId) ids.add(l.linkedId);
      }
      if (ids.isEmpty) return <Asset>[];
      return (select(assets)..where((a) => a.id.isIn(ids.toList()))).get();
    });
  }

  /// Called before deleting an asset. If it's an original in any link,
  /// promotes one linked asset to become the new original.
  /// Returns true if the caller should proceed with deletion.
  Future<bool> handleAssetDeletion(String assetId) async {
    // Find links where this asset is the original
    final linksAsOriginal = await (select(assetLinks)
          ..where((l) => l.originalId.equals(assetId)))
        .get();

    if (linksAsOriginal.isNotEmpty) {
      // Pick the first linked asset as the new original
      final newOriginalId = linksAsOriginal.first.linkedId;

      // Remove the link that will become the new original
      await (delete(assetLinks)
            ..where((l) =>
                l.originalId.equals(assetId) &
                l.linkedId.equals(newOriginalId)))
          .go();

      // Transfer remaining links from old original to new original
      for (final link in linksAsOriginal.skip(1)) {
        await (update(assetLinks)..where((l) => l.id.equals(link.id)))
            .write(AssetLinksCompanion(originalId: Value(newOriginalId)));
      }

      // Also transfer links where old original was a linkedId
      final linksAsLinked = await (select(assetLinks)
            ..where((l) => l.linkedId.equals(assetId)))
          .get();
      for (final link in linksAsLinked) {
        await (update(assetLinks)..where((l) => l.id.equals(link.id)))
            .write(AssetLinksCompanion(linkedId: Value(newOriginalId)));
      }

      // Copy metadata from deleted original to new original
      await _syncMetadata(assetId, newOriginalId);
    } else {
      // Not an original — just remove any links where it's linked
      await (delete(assetLinks)
            ..where((l) => l.linkedId.equals(assetId)))
          .go();
    }

    return true;
  }

  /// Syncs tags and custom properties from [sourceId] to [targetId].
  Future<void> _syncMetadata(String sourceId, String targetId) async {
    // Sync tags
    final sourceTags = await (select(assetTags)
          ..where((at) => at.assetId.equals(sourceId)))
        .get();
    for (final tag in sourceTags) {
      await into(assetTags).insertOnConflictUpdate(
        AssetTagsCompanion(
          assetId: Value(targetId),
          tagId: Value(tag.tagId),
        ),
      );
    }

    // Sync custom properties
    final sourceProps = await (select(assetProperties)
          ..where((ap) => ap.assetId.equals(sourceId)))
        .get();
    for (final prop in sourceProps) {
      await into(assetProperties).insertOnConflictUpdate(
        AssetPropertiesCompanion(
          assetId: Value(targetId),
          propertyId: Value(prop.propertyId),
          valueText: Value(prop.valueText),
        ),
      );
    }

    // Sync core metadata fields (rating, colorLabel, note)
    final source = await (select(assets)
          ..where((a) => a.id.equals(sourceId)))
        .getSingleOrNull();
    if (source != null) {
      await (update(assets)..where((a) => a.id.equals(targetId))).write(
        AssetsCompanion(
          rating: Value(source.rating),
          colorLabel: Value(source.colorLabel),
          note: Value(source.note),
        ),
      );
    }
  }

  /// Syncs metadata changes from [sourceId] to all linked assets.
  Future<void> syncToAllLinked(String sourceId) async {
    final linked = await getLinkedAssets(sourceId);
    for (final asset in linked) {
      await _syncMetadata(sourceId, asset.id);
    }
  }
}
