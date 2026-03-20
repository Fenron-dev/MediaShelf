import 'package:drift/drift.dart';

/// Records filesystem events for the Activity Journal.
///
/// event_type: 'added' | 'missing' | 'restored' | 'deleted'
class ActivityLog extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get eventType => text()();

  /// May be null for 'deleted' events where the record no longer exists.
  TextColumn get assetId => text().nullable()();

  TextColumn get assetPath => text()();
  TextColumn get assetFilename => text()();

  /// Unix timestamp in milliseconds.
  IntColumn get occurredAt => integer()();
}
