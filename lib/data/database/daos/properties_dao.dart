import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../app_database.dart';

part 'properties_dao.g.dart';

@DriftAccessor(tables: [PropertyDefinitions, AssetProperties])
class PropertiesDao extends DatabaseAccessor<AppDatabase>
    with _$PropertiesDaoMixin {
  PropertiesDao(super.db);

  // ── Definitions ────────────────────────────────────────────────────────────

  Future<List<PropertyDefinition>> getAllDefinitions() =>
      (select(propertyDefinitions)
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .get();

  Stream<List<PropertyDefinition>> watchAllDefinitions() =>
      (select(propertyDefinitions)
            ..orderBy([(p) => OrderingTerm.asc(p.sortOrder)]))
          .watch();

  Future<void> createDefinition({
    required String name,
    required String fieldType,
    List<String>? options,
    int sortOrder = 0,
  }) =>
      into(propertyDefinitions).insert(
        PropertyDefinitionsCompanion(
          id: Value(const Uuid().v4()),
          name: Value(name),
          fieldType: Value(fieldType),
          optionsJson:
              options != null ? Value(jsonEncode(options)) : const Value.absent(),
          sortOrder: Value(sortOrder),
        ),
      );

  Future<void> updateDefinition({
    required String id,
    String? name,
    String? fieldType,
    List<String>? options,
    int? sortOrder,
  }) =>
      (update(propertyDefinitions)..where((p) => p.id.equals(id))).write(
        PropertyDefinitionsCompanion(
          name: name != null ? Value(name) : const Value.absent(),
          fieldType:
              fieldType != null ? Value(fieldType) : const Value.absent(),
          optionsJson: options != null
              ? Value(jsonEncode(options))
              : const Value.absent(),
          sortOrder:
              sortOrder != null ? Value(sortOrder) : const Value.absent(),
        ),
      );

  Future<void> deleteDefinition(String id) =>
      (delete(propertyDefinitions)..where((p) => p.id.equals(id))).go();

  // ── Asset property values ──────────────────────────────────────────────────

  Stream<List<AssetProperty>> watchPropertiesForAsset(String assetId) =>
      (select(assetProperties)
            ..where((ap) => ap.assetId.equals(assetId)))
          .watch();

  /// Returns all unique tag values used across assets for a given property.
  /// Works with properties of type 'tags' where values are JSON arrays.
  Future<List<String>> getUsedTagsForProperty(String propertyId) async {
    final rows = await (select(assetProperties)
          ..where((ap) => ap.propertyId.equals(propertyId)))
        .get();
    final tags = <String>{};
    for (final row in rows) {
      final val = row.valueText;
      if (val == null || val.isEmpty) continue;
      try {
        final list = (jsonDecode(val) as List).cast<String>();
        tags.addAll(list);
      } catch (_) {}
    }
    final sorted = tags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  Future<void> setPropertyValue(
    String assetId,
    String propertyId,
    String? value,
  ) async {
    if (value == null || value.isEmpty) {
      await (delete(assetProperties)
            ..where(
              (ap) =>
                  ap.assetId.equals(assetId) &
                  ap.propertyId.equals(propertyId),
            ))
          .go();
    } else {
      await into(assetProperties).insertOnConflictUpdate(
        AssetPropertiesCompanion(
          assetId: Value(assetId),
          propertyId: Value(propertyId),
          valueText: Value(value),
        ),
      );
    }
  }
}
