import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'providers/library_provider.dart';
import 'ui/screens/activity_screen.dart';
import 'ui/screens/document_viewer_screen.dart';
import 'ui/screens/image_viewer_screen.dart';
import 'ui/screens/library_screen.dart';
import 'ui/screens/player_screen.dart';
import 'ui/screens/welcome_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final libraryPath = ref.watch(libraryPathProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAtRoot = state.matchedLocation == '/';
      final hasLibrary = libraryPath != null;

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
                DocumentViewerScreen(assetId: state.pathParameters['assetId']!),
          ),
          GoRoute(
            path: 'activity',
            builder: (context, state) => const ActivityScreen(),
          ),
        ],
      ),
    ],
  );
});
