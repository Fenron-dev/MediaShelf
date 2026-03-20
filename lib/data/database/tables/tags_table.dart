import 'package:drift/drift.dart';

import 'assets_table.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();

  /// Optional hex color for tag display (e.g. '#ff5733').
  TextColumn get color => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class AssetTags extends Table {
  TextColumn get assetId =>
      text().references(Assets, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {assetId, tagId};
}
