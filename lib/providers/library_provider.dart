import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';
import '../data/database/app_database.dart';
import '../data/repositories/library_repository.dart';
import '../data/watcher/library_watcher.dart';

// ── Library Path ─────────────────────────────────────────────────────────────

/// The absolute path of the currently open library, or null if none.
final libraryPathProvider = StateProvider<String?>((ref) => null);

// ── Database ─────────────────────────────────────────────────────────────────

/// Opens the Drift database for the current library path.
/// Automatically closes when the path changes.
final databaseProvider = Provider<AppDatabase>((ref) {
  final path = ref.watch(libraryPathProvider);
  if (path == null) throw StateError('No library open');

  final dbPath = p.join(path, kMediashelfDir, kDbFilename);
  final db = AppDatabase(dbPath);
  ref.onDispose(db.close);
  return db;
});

// ── DAO Accessors ─────────────────────────────────────────────────────────────

final assetsDaoProvider = Provider((ref) => ref.watch(databaseProvider).assetsDao);
final tagsDaoProvider = Provider((ref) => ref.watch(databaseProvider).tagsDao);
final collectionsDaoProvider = Provider((ref) => ref.watch(databaseProvider).collectionsDao);
final activityDaoProvider = Provider((ref) => ref.watch(databaseProvider).activityDao);
final propertiesDaoProvider = Provider((ref) => ref.watch(databaseProvider).propertiesDao);
final playlistsDaoProvider = Provider((ref) => ref.watch(databaseProvider).playlistsDao);
final assetLinksDaoProvider = Provider((ref) => ref.watch(databaseProvider).assetLinksDao);

/// Live stream of all playlists, ordered by creation time.
final playlistsProvider = StreamProvider<List<Playlist>>((ref) {
  return ref.watch(playlistsDaoProvider).watchAll();
});

// ── Library Repository ───────────────────────────────────────────────────────

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

// ── Library Watcher ──────────────────────────────────────────────────────────

/// Active filesystem watcher for the current library.
/// Null when no library is open.
final libraryWatcherProvider = Provider<LibraryWatcher?>((ref) {
  final path = ref.watch(libraryPathProvider);
  if (path == null) return null;

  final watcher = LibraryWatcher(path);
  watcher.start();
  ref.onDispose(watcher.dispose);
  return watcher;
});

// ── Recent Libraries ─────────────────────────────────────────────────────────

class RecentLibrariesNotifier extends AsyncNotifier<List<String>> {
  static const _prefKey = 'recent_libraries';
  static const _maxRecent = 10;

  @override
  Future<List<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefKey) ?? [];
  }

  Future<void> add(String path) async {
    final current = state.valueOrNull ?? [];
    final updated = [path, ...current.where((p) => p != path)].take(_maxRecent).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, updated);
    state = AsyncData(updated);
  }

  Future<void> remove(String path) async {
    final current = state.valueOrNull ?? [];
    final updated = current.where((p) => p != path).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefKey, updated);
    state = AsyncData(updated);
  }
}

final recentLibrariesProvider =
    AsyncNotifierProvider<RecentLibrariesNotifier, List<String>>(
  RecentLibrariesNotifier.new,
);
