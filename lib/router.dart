import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/library_provider.dart';
import 'ui/screens/activity_screen.dart';
import 'ui/screens/document_viewer_screen.dart';
import 'ui/screens/image_viewer_screen.dart';
import 'ui/screens/library_screen.dart';
import 'ui/screens/player_screen.dart';
import 'ui/screens/playlist_screen.dart';
import 'ui/screens/welcome_screen.dart';

// MaterialApp.router ignores changes to routerConfig after initial build.
// Solution: keep the GoRouter instance stable and use refreshListenable so
// the router re-evaluates its redirect when the library path changes —
// without recreating the router object itself.
class _LibraryNotifier extends ChangeNotifier {
  _LibraryNotifier(Ref ref) {
    ref.listen<String?>(libraryPathProvider, (prev, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _LibraryNotifier(ref);
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final hasLibrary = ref.read(libraryPathProvider) != null;
      final isAtRoot = state.matchedLocation == '/';
      if (!hasLibrary && !isAtRoot) return '/';
      if (hasLibrary && isAtRoot) return '/library';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
        routes: [
          GoRoute(
            path: 'player/:assetId',
            builder: (context, state) =>
                PlayerScreen(assetId: state.pathParameters['assetId']!),
          ),
          GoRoute(
            path: 'image/:assetId',
            builder: (context, state) =>
                ImageViewerScreen(assetId: state.pathParameters['assetId']!),
          ),
          GoRoute(
            path: 'document/:assetId',
            builder: (context, state) =>
                DocumentViewerScreen(
                    assetId: state.pathParameters['assetId']!),
          ),
          GoRoute(
            path: 'activity',
            builder: (context, state) => const ActivityScreen(),
          ),
          GoRoute(
            path: 'playlist/:playlistId',
            builder: (context, state) => PlaylistScreen(
                playlistId: state.pathParameters['playlistId']!),
          ),
        ],
      ),
    ],
  );
});
