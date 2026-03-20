import 'dart:convert';

import 'package:drift/drift.dart';

import '../app_database.dart';
import '../../../domain/models/asset_filter.dart';

part 'assets_dao.g.dart';

/// Result of a paginated asset query.
class AssetsPage {
  const AssetsPage({
    required this.assets,
    required this.total,
    required this.page,
    required this.pageSize,
  });
  final List<Asset> assets;
  final int total;
  final int page;
  final int pageSize;
}

@DriftAccessor(tables: [Assets, Tags, AssetTags, Collections])
class AssetsDao extends DatabaseAccessor<AppDatabase> with _$AssetsDaoMixin {
  AssetsDao(super.db);

  // ── Basic CRUD ─────────────────────────────────────────────────────────────

  Future<Asset?> getById(String id) =>
      (select(assets)..where((a) => a.id.equals(id))).getSingleOrNull();

  Future<Asset?> getByPath(String path) =>
      (select(assets)..where((a) => a.path.equals(path))).getSingleOrNull();

  Future<Asset?> getByHash(String hash) =>
      (select(assets)..where((a) => a.contentHash.equals(hash)))
          .getSingleOrNull();

  Future<void> upsertAsset(AssetsCompanion companion) =>
      into(assets).insertOnConflictUpdate(companion);

  Future<void> updateAsset(AssetsCompanion companion) =>
      (update(assets)..where((a) => a.id.equals(companion.id.value)))
          .write(companion);

  Future<void> deleteById(String id) =>
      (delete(assets)..where((a) => a.id.equals(id))).go();

  /// Marks all 'ok' assets as 'missing' — first step of a full rescan.
  Future<void> markAllMissing() =>
      (update(assets)..where((a) => a.status.equals('ok')))
          .write(const AssetsCompanion(status: Value('missing')));

  Future<void> markAsOk(String id) =>
      (update(assets)..where((a) => a.id.equals(id)))
          .write(const AssetsCompanion(status: Value('ok')));

  Future<List<Asset>> getMissingAssets() =>
      (select(assets)..where((a) => a.status.equals('missing'))).get();

  // ── Metadata updates ───────────────────────────────────────────────────────

  Future<void> updateMeta({
    required String id,
    Value<int> rating = const Value.absent(),
    Value<String?> colorLabel = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
  }) =>
      (update(assets)..where((a) => a.id.equals(id))).write(AssetsCompanion(
        rating: rating,
        colorLabel: colorLabel,
        note: note,
        sourceUrl: sourceUrl,
      ));

  Future<void> savePlaybackPosition(String id, int positionMs) =>
      (update(assets)..where((a) => a.id.equals(id))).write(
        AssetsCompanion(playbackPositionMs: Value(positionMs)),
      );

  Future<void> clearPlaybackPosition(String id) =>
      (update(assets)..where((a) => a.id.equals(id))).write(
        const AssetsCompanion(playbackPositionMs: Value(null)),
      );

  // ── Tags ──────────────────────────────────────────────────────────────────

  Future<List<Tag>> getTagsForAsset(String assetId) {
    final query = select(tags).join([
      innerJoin(assetTags, assetTags.tagId.equalsExp(tags.id)),
    ])
      ..where(assetTags.assetId.equals(assetId));
    return query.map((row) => row.readTable(tags)).get();
  }

  Future<void> setTagsForAsset(String assetId, List<String> tagIds) async {
    await (delete(assetTags)..where((at) => at.assetId.equals(assetId))).go();
    for (final tagId in tagIds) {
      await into(assetTags).insert(
        AssetTagsCompanion.insert(assetId: assetId, tagId: tagId),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  Future<void> addTagToAsset(String assetId, String tagId) =>
      into(assetTags).insert(
        AssetTagsCompanion.insert(assetId: assetId, tagId: tagId),
        mode: InsertMode.insertOrIgnore,
      );

  Future<void> removeTagFromAsset(String assetId, String tagId) =>
      (delete(assetTags)
            ..where(
              (at) => at.assetId.equals(assetId) & at.tagId.equals(tagId),
            ))
          .go();

  Future<void> addTagToAssets(List<String> assetIds, String tagId) async {
    for (final assetId in assetIds) {
      await into(assetTags).insert(
        AssetTagsCompanion.insert(assetId: assetId, tagId: tagId),
        mode: InsertMode.insertOrIgnore,
      );
    }
  }

  // ── Paginated Query ────────────────────────────────────────────────────────

  /// Returns a page of assets matching [filter], along with the total count.
  Future<AssetsPage> queryPage({
    required AssetFilter filter,
    required int page,
    required int pageSize,
  }) async {
    final offset = page * pageSize;
    final conditions = <String>[];
    final params = <Variable<Object>>[];

    // Status filter
    conditions.add('a.status = ?');
    params.add(Variable.withString(filter.statusFilter));

    // Full-text search
    if (filter.searchQuery.isNotEmpty) {
      final terms = filter.searchQuery.trim().split(RegExp(r'\s+'));
      final orConds = <String>[];

      // FTS5 prefix search
      final ftsQuery = terms
          .map((w) {
            final clean = w.replaceAll(RegExp(r'[^\w\-_.]'), '');
            return clean.isEmpty ? null : '"$clean"*';
          })
          .whereType<String>()
          .join(' ');
      if (ftsQuery.isNotEmpty) {
        orConds.add(
          'a.rowid IN (SELECT rowid FROM assets_fts WHERE assets_fts MATCH ?)',
        );
        params.add(Variable.withString(ftsQuery));
      }

      // Filename LIKE fallback
      for (final term in terms) {
        orConds.add('a.filename LIKE ?');
        params.add(Variable.withString('%$term%'));
      }

      // Tag name search
      for (final term in terms) {
        orConds.add(
          'EXISTS (SELECT 1 FROM asset_tags at2'
          ' JOIN tags t ON t.id = at2.tag_id'
          ' WHERE at2.asset_id = a.id AND t.name LIKE ?)',
        );
        params.add(Variable.withString('%$term%'));
      }

      if (orConds.isNotEmpty) {
        conditions.add('(${orConds.join(' OR ')})');
      }
    }

    // Directory filter
    if (filter.dirFilter.isNotEmpty) {
      if (filter.includeSubdirs) {
        conditions.add('(a.path LIKE ? OR a.path = ?)');
        params
          ..add(Variable.withString('${filter.dirFilter}/%'))
          ..add(Variable.withString(filter.dirFilter));
      } else {
        conditions.add(
          'a.path LIKE ? AND instr(substr(a.path, length(?) + 2), \'/\') = 0',
        );
        params
          ..add(Variable.withString('${filter.dirFilter}/%'))
          ..add(Variable.withString(filter.dirFilter));
      }
    }

    // Collection filter
    if (filter.collectionId != null) {
      final colId = filter.collectionId!;
      final col = await (select(collections)
            ..where((c) => c.id.equals(colId)))
          .getSingleOrNull();
      if (col != null && col.isSmartFilter && col.smartFilterQuery != null) {
        final smartWhere =
            _buildSmartFilterSql(col.smartFilterQuery!, params);
        if (smartWhere != null) conditions.add(smartWhere);
      } else {
        conditions.add(
          'a.id IN (SELECT asset_id FROM collection_assets WHERE collection_id = ?)',
        );
        params.add(Variable.withString(colId));
      }
    }

    // Tag filter
    if (filter.tagFilter != null && filter.tagFilter!.isNotEmpty) {
      conditions.add(
        'EXISTS (SELECT 1 FROM asset_tags at2'
        ' JOIN tags t ON t.id = at2.tag_id'
        ' WHERE at2.asset_id = a.id AND LOWER(t.name) = LOWER(?))',
      );
      params.add(Variable.withString(filter.tagFilter!));
    }

    // Rating minimum
    if (filter.ratingMin > 0) {
      conditions.add('a.rating >= ?');
      params.add(Variable.withInt(filter.ratingMin));
    }

    // Color label
    if (filter.colorLabel.isNotEmpty) {
      conditions.add('a.color_label = ?');
      params.add(Variable.withString(filter.colorLabel));
    }

    // MIME type prefix
    if (filter.mimeType.isNotEmpty) {
      conditions.add('a.mime_type LIKE ?');
      params.add(Variable.withString('${filter.mimeType}%'));
    }

    // Extension
    if (filter.extension.isNotEmpty) {
      conditions.add('a.extension = ?');
      params.add(Variable.withString(filter.extension.toLowerCase()));
    }

    // Resume filter
    switch (filter.hasResume) {
      case ResumeFilter.hasResume:
        conditions.add(
          '(a.playback_position_ms IS NOT NULL AND a.playback_position_ms > 0)',
        );
      case ResumeFilter.noResume:
        conditions.add(
          '(a.playback_position_ms IS NULL OR a.playback_position_ms = 0)',
        );
      case ResumeFilter.all:
        break;
    }

    // Date range (indexed_at)
    if (filter.dateFrom.isNotEmpty) {
      conditions.add('a.indexed_at >= ?');
      params.add(Variable.withInt(
        DateTime.parse(filter.dateFrom).millisecondsSinceEpoch,
      ));
    }
    if (filter.dateTo.isNotEmpty) {
      conditions.add('a.indexed_at <= ?');
      params.add(Variable.withInt(
        DateTime.parse(filter.dateTo)
            .add(const Duration(days: 1))
            .millisecondsSinceEpoch,
      ));
    }

    final whereClause =
        conditions.isEmpty ? '1=1' : conditions.join(' AND ');

    final orderClause = filter.randomMode
        ? 'ORDER BY RANDOM()'
        : _buildOrderClause(filter.sortBy, filter.sortDir);

    // Total count
    final countResult = await customSelect(
      'SELECT COUNT(*) as cnt FROM assets a WHERE $whereClause',
      variables: params,
    ).getSingle();
    final total = countResult.read<int>('cnt');

    // Paginated rows
    final pageParams = <Variable<Object>>[
      ...params,
      Variable.withInt(pageSize),
      Variable.withInt(offset),
    ];
    final rows = await customSelect(
      'SELECT a.* FROM assets a WHERE $whereClause $orderClause LIMIT ? OFFSET ?',
      variables: pageParams,
      readsFrom: {assets},
    ).get();

    final result = rows.map((row) {
      return Asset(
        id: row.read<String>('id'),
        path: row.read<String>('path'),
        filename: row.read<String>('filename'),
        extension: row.readNullable<String>('extension'),
        size: row.readNullable<int>('size'),
        mimeType: row.readNullable<String>('mime_type'),
        width: row.readNullable<int>('width'),
        height: row.readNullable<int>('height'),
        durationMs: row.readNullable<int>('duration_ms'),
        playbackPositionMs: row.readNullable<int>('playback_position_ms'),
        contentHash: row.readNullable<String>('content_hash'),
        phash: row.readNullable<String>('phash'),
        status: row.read<String>('status'),
        rating: row.read<int>('rating'),
        colorLabel: row.readNullable<String>('color_label'),
        note: row.readNullable<String>('note'),
        sourceUrl: row.readNullable<String>('source_url'),
        fileCreatedAt: row.readNullable<int>('file_created_at'),
        fileModifiedAt: row.readNullable<int>('file_modified_at'),
        indexedAt: row.read<int>('indexed_at'),
      );
    }).toList();

    return AssetsPage(
      assets: result,
      total: total,
      page: page,
      pageSize: pageSize,
    );
  }

  // ── Smart Filter SQL builder ───────────────────────────────────────────────

  /// Converts a smart-filter JSON string into a SQL WHERE fragment.
  ///
  /// The JSON format (`{logic, rules}`) is identical to Nexus Explorer's.
  String? _buildSmartFilterSql(
    String queryJson,
    List<Variable<Object>> params,
  ) {
    try {
      final q = jsonDecode(queryJson) as Map<String, dynamic>;
      final logic = (q['logic'] as String?) ?? 'AND';
      final rules = (q['rules'] as List?) ?? [];

      final conditions = <String>[];
      for (final r in rules) {
        final rule = r as Map<String, dynamic>;
        final field = (rule['field'] as String?) ?? '';
        final op = (rule['op'] as String?) ?? '';
        final value = (rule['value'] as String?) ?? '';

        String? cond;
        switch ('$field:$op') {
          case 'rating:gte':
            cond = 'a.rating >= ?';
            params.add(Variable.withInt(int.tryParse(value) ?? 0));
          case 'rating:lte':
            cond = 'a.rating <= ?';
            params.add(Variable.withInt(int.tryParse(value) ?? 5));
          case 'rating:eq':
            cond = 'a.rating = ?';
            params.add(Variable.withInt(int.tryParse(value) ?? 0));
          case 'color_label:eq':
            cond = 'a.color_label = ?';
            params.add(Variable.withString(value));
          case 'color_label:isset':
            cond = 'a.color_label IS NOT NULL';
          case 'color_label:notset':
            cond = 'a.color_label IS NULL';
          case 'tag:eq':
            cond = 'EXISTS (SELECT 1 FROM asset_tags at2 JOIN tags t ON t.id = at2.tag_id'
                ' WHERE at2.asset_id = a.id AND LOWER(t.name) = LOWER(?))';
            params.add(Variable.withString(value));
          case 'mime_type:startswith':
            cond = 'a.mime_type LIKE ?';
            params.add(Variable.withString('$value%'));
          case 'mime_type:eq':
            cond = 'LOWER(a.mime_type) = LOWER(?)';
            params.add(Variable.withString(value));
          case 'mime_type:isset':
            cond = "a.mime_type IS NOT NULL AND a.mime_type != ''";
          case 'mime_type:notset':
            cond = "(a.mime_type IS NULL OR a.mime_type = '')";
          case 'extension:eq':
            cond = 'a.extension = ?';
            params.add(Variable.withString(value.toLowerCase()));
          case 'has_resume:isset':
            cond = '(a.playback_position_ms IS NOT NULL AND a.playback_position_ms > 0)';
          case 'has_resume:notset':
            cond = '(a.playback_position_ms IS NULL OR a.playback_position_ms = 0)';
          default:
            if (field.startsWith('prop:')) {
              final propId = field.substring('prop:'.length);
              switch (op) {
                case 'eq':
                  cond = 'EXISTS (SELECT 1 FROM asset_properties ap WHERE ap.asset_id = a.id'
                      ' AND ap.property_id = ? AND LOWER(ap.value_text) = LOWER(?))';
                  params
                    ..add(Variable.withString(propId))
                    ..add(Variable.withString(value));
                case 'contains':
                  final esc = value
                      .replaceAll('%', r'\%')
                      .replaceAll('_', r'\_');
                  cond = "EXISTS (SELECT 1 FROM asset_properties ap WHERE ap.asset_id = a.id"
                      " AND ap.property_id = ? AND ap.value_text LIKE ? ESCAPE '\\')";
                  params
                    ..add(Variable.withString(propId))
                    ..add(Variable.withString('%$esc%'));
                case 'isset':
                  cond = "EXISTS (SELECT 1 FROM asset_properties ap WHERE ap.asset_id = a.id"
                      " AND ap.property_id = ? AND ap.value_text IS NOT NULL AND ap.value_text != '')";
                  params.add(Variable.withString(propId));
                case 'notset':
                  cond = "NOT EXISTS (SELECT 1 FROM asset_properties ap WHERE ap.asset_id = a.id"
                      " AND ap.property_id = ? AND ap.value_text IS NOT NULL AND ap.value_text != '')";
                  params.add(Variable.withString(propId));
              }
            }
        }
        if (cond != null) conditions.add(cond);
      }

      if (conditions.isEmpty) return null;
      final join = logic == 'OR' ? ' OR ' : ' AND ';
      return '(${conditions.join(join)})';
    } catch (_) {
      return null;
    }
  }

  String _buildOrderClause(SortBy sortBy, SortDir sortDir) {
    final dir = sortDir == SortDir.desc ? 'DESC' : 'ASC';
    switch (sortBy) {
      case SortBy.name:
        return 'ORDER BY LOWER(a.filename) $dir';
      case SortBy.date:
        return 'ORDER BY a.file_modified_at $dir NULLS LAST';
      case SortBy.size:
        return 'ORDER BY a.size $dir NULLS LAST';
      case SortBy.rating:
        return 'ORDER BY a.rating $dir';
      case SortBy.extension:
        return 'ORDER BY a.extension $dir NULLS LAST, LOWER(a.filename) ASC';
      case SortBy.indexedAt:
        return 'ORDER BY a.indexed_at $dir';
      case SortBy.random:
        return 'ORDER BY RANDOM()';
    }
  }

  // ── Bulk operations ────────────────────────────────────────────────────────

  Future<void> updateRatingForAssets(List<String> ids, int rating) async {
    for (final id in ids) {
      await (update(assets)..where((a) => a.id.equals(id)))
          .write(AssetsCompanion(rating: Value(rating)));
    }
  }

  Future<void> updateColorLabelForAssets(
    List<String> ids,
    String? colorLabel,
  ) async {
    for (final id in ids) {
      await (update(assets)..where((a) => a.id.equals(id)))
          .write(AssetsCompanion(colorLabel: Value(colorLabel)));
    }
  }

  Future<void> deleteAssets(List<String> ids) async {
    for (final id in ids) {
      await (delete(assets)..where((a) => a.id.equals(id))).go();
    }
  }
}
