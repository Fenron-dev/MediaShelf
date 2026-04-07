import 'package:drift/drift.dart';

import '../app_database.dart';

part 'document_positions_dao.g.dart';

@DriftAccessor(tables: [DocumentPositions])
class DocumentPositionsDao extends DatabaseAccessor<AppDatabase>
    with _$DocumentPositionsDaoMixin {
  DocumentPositionsDao(super.db);

  /// Upsert the reading position for [assetId].
  Future<void> savePosition(
    String assetId,
    String positionKey, {
    String? label,
    double progress = 0.0,
  }) =>
      into(documentPositions).insertOnConflictUpdate(
        DocumentPositionsCompanion.insert(
          assetId: assetId,
          positionKey: positionKey,
          positionLabel: Value(label),
          progress: Value(progress),
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  /// Returns the saved position for [assetId], or null if none exists.
  Future<DocumentPosition?> getPosition(String assetId) =>
      (select(documentPositions)
            ..where((t) => t.assetId.equals(assetId)))
          .getSingleOrNull();
}
