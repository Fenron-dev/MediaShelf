import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import 'library_provider.dart';

/// Live stream of all collections (manual + smart filters).
final collectionsProvider = StreamProvider<List<Collection>>((ref) {
  final dao = ref.watch(collectionsDaoProvider);
  return dao.watchAll();
});
