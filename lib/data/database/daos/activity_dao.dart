import 'package:drift/drift.dart';

import '../app_database.dart';

part 'activity_dao.g.dart';

@DriftAccessor(tables: [ActivityLog])
class ActivityDao extends DatabaseAccessor<AppDatabase>
    with _$ActivityDaoMixin {
  ActivityDao(super.db);

  Future<void> log({
    required String eventType,
    String? assetId,
    required String assetPath,
    required String assetFilename,
  }) =>
      into(activityLog).insert(ActivityLogCompanion.insert(
        eventType: eventType,
        assetId: Value(assetId),
        assetPath: assetPath,
        assetFilename: assetFilename,
        occurredAt: DateTime.now().millisecondsSinceEpoch,
      ));

  Future<List<ActivityLogData>> getRecent({int limit = 200}) =>
      (select(activityLog)
            ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])
            ..limit(limit))
          .get();

  Stream<List<ActivityLogData>> watchRecent({int limit = 200}) =>
      (select(activityLog)
            ..orderBy([(e) => OrderingTerm.desc(e.occurredAt)])
            ..limit(limit))
          .watch();

  Future<void> clearAll() => delete(activityLog).go();
}
