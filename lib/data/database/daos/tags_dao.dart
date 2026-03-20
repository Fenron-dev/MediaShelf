import 'package:drift/drift.dart';

import '../app_database.dart';

part 'tags_dao.g.dart';

/// A tag with its usage count across the library.
class TagWithCount {
  const TagWithCount({required this.tag, required this.count});
  final Tag tag;
  final int count;
}

@DriftAccessor(tables: [Tags, AssetTags])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Future<Tag?> getById(String id) =>
      (select(tags)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<Tag?> getByName(String name) =>
      (select(tags)..where((t) => t.name.equals(name))).getSingleOrNull();

  Future<String> upsertTag(String name) async {
    final existing = await getByName(name);
    if (existing != null) return existing.id;
    final id = _generateId();
    await into(tags).insert(TagsCompanion.insert(id: id, name: name));
    return id;
  }

  Future<void> deleteTag(String id) =>
      (delete(tags)..where((t) => t.id.equals(id))).go();

  Future<void> renameTag(String id, String newName) =>
      (update(tags)..where((t) => t.id.equals(id)))
          .write(TagsCompanion(name: Value(newName)));

  Future<void> updateTagColor(String id, String? color) =>
      (update(tags)..where((t) => t.id.equals(id)))
          .write(TagsCompanion(color: Value(color)));

  /// All tags with their asset usage counts, sorted by name.
  Stream<List<TagWithCount>> watchAllTagsWithCount() {
    final query = customSelect(
      'SELECT t.id, t.name, t.color, COUNT(at.asset_id) as cnt'
      ' FROM tags t'
      ' LEFT JOIN asset_tags at ON at.tag_id = t.id'
      ' GROUP BY t.id'
      ' ORDER BY LOWER(t.name)',
      readsFrom: {tags, assetTags},
    );
    return query.watch().map(
          (rows) => rows
              .map(
                (row) => TagWithCount(
                  tag: Tag(
                    id: row.read<String>('id'),
                    name: row.read<String>('name'),
                    color: row.readNullable<String>('color'),
                  ),
                  count: row.read<int>('cnt'),
                ),
              )
              .toList(),
        );
  }

  Future<List<TagWithCount>> getAllTagsWithCount() async {
    final rows = await customSelect(
      'SELECT t.id, t.name, t.color, COUNT(at.asset_id) as cnt'
      ' FROM tags t'
      ' LEFT JOIN asset_tags at ON at.tag_id = t.id'
      ' GROUP BY t.id'
      ' ORDER BY LOWER(t.name)',
      readsFrom: {tags, assetTags},
    ).get();
    return rows
        .map(
          (row) => TagWithCount(
            tag: Tag(
              id: row.read<String>('id'),
              name: row.read<String>('name'),
              color: row.readNullable<String>('color'),
            ),
            count: row.read<int>('cnt'),
          ),
        )
        .toList();
  }

  String _generateId() {
    // Simple UUID-like ID using DateTime + random — uuid pkg used in scanner
    return DateTime.now().microsecondsSinceEpoch.toRadixString(16);
  }
}
