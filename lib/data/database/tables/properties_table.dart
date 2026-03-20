import 'package:drift/drift.dart';

import 'assets_table.dart';

/// Defines a custom property schema (EAV pattern).
///
/// field_type: 'text' | 'number' | 'date' | 'boolean' | 'url' | 'select' | 'multiselect'
class PropertyDefinitions extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fieldType => text()();

  /// JSON array of option strings for 'select' / 'multiselect' fields.
  TextColumn get optionsJson => text().nullable()();

  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Stores the value of a custom property for a specific asset.
class AssetProperties extends Table {
  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();
  TextColumn get propertyId =>
      text().references(PropertyDefinitions, #id, onDelete: KeyAction.cascade)();

  /// All values stored as text; interpretation depends on [PropertyDefinitions.fieldType].
  TextColumn get valueText => text().nullable()();

  @override
  Set<Column> get primaryKey => {assetId, propertyId};
}
