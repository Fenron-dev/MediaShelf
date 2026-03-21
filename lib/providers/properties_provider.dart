import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import 'library_provider.dart';

/// All property definitions, ordered by sortOrder.
final propertyDefsProvider = StreamProvider<List<PropertyDefinition>>((ref) {
  return ref.watch(propertiesDaoProvider).watchAllDefinitions();
});

/// Custom property values for a specific asset.
final assetPropertiesProvider =
    StreamProvider.family<List<AssetProperty>, String>((ref, assetId) {
  return ref.watch(propertiesDaoProvider).watchPropertiesForAsset(assetId);
});
