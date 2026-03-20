import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants.dart';

enum ViewMode { grid, list }

/// Thumbnail grid cell size in logical pixels.
final thumbnailSizeProvider = StateProvider<double>((ref) => kDefaultThumbnailSize);

/// Current view mode (grid or list).
final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

/// Whether the left sidebar is visible.
final showSidebarProvider = StateProvider<bool>((ref) => true);

/// Whether the right detail panel is visible.
final showDetailPanelProvider = StateProvider<bool>((ref) => true);
