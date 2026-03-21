import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/active_player_provider.dart';
import '../../providers/settings_provider.dart';
import '../widgets/asset_grid.dart';
import '../widgets/bulk_toolbar.dart';
import '../widgets/detail_panel.dart';
import '../widgets/drop_zone.dart';
import '../widgets/mini_player_bar.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';

class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSidebar = ref.watch(showSidebarProvider);
    final showDetail = ref.watch(showDetailPanelProvider);
    final sidebarWidth = ref.watch(sidebarWidthProvider);
    final detailWidth = ref.watch(detailPanelWidthProvider);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final showDetailPanel = showDetail && screenWidth >= kDetailPanelBreakpoint;
    final hasActivePlayer = ref.watch(activePlayerProvider).hasMedia;

    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: DropZoneOverlay(
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (showSidebar) ...[
                        SizedBox(
                            width: sidebarWidth,
                            child: const LibrarySidebar()),
                        _ResizeDivider(
                          onDrag: (dx) => ref
                              .read(sidebarWidthProvider.notifier)
                              .set(sidebarWidth + dx),
                        ),
                      ],
                      const Expanded(child: AssetGrid()),
                      if (showDetailPanel) ...[
                        _ResizeDivider(
                          onDrag: (dx) => ref
                              .read(detailPanelWidthProvider.notifier)
                              .set(detailWidth - dx),
                        ),
                        SizedBox(
                            width: detailWidth,
                            child: const DetailPanel()),
                      ],
                    ],
                  ),
                  const Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: BulkToolbar(),
                  ),
                ],
              ),
            ),
          ),
          if (hasActivePlayer) const MiniPlayerBar(),
        ],
      ),
    );
  }
}

// ── Draggable resize handle ───────────────────────────────────────────────────

class _ResizeDivider extends StatelessWidget {
  final void Function(double dx) onDrag;
  const _ResizeDivider({required this.onDrag});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeColumn,
      child: Listener(
        onPointerMove: (event) => onDrag(event.delta.dx),
        child: SizedBox(
          width: 8,
          child: Center(
            child: Container(
              width: 1,
              color: Theme.of(context).dividerColor,
            ),
          ),
        ),
      ),
    );
  }
}
