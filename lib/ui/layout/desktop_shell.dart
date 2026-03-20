import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/settings_provider.dart';
import '../widgets/asset_grid.dart';
import '../widgets/detail_panel.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';

class DesktopShell extends ConsumerWidget {
  const DesktopShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showSidebar = ref.watch(showSidebarProvider);
    final showDetail = ref.watch(showDetailPanelProvider);
    final width = MediaQuery.sizeOf(context).width;
    final showDetailPanel = showDetail && width >= kDetailPanelBreakpoint;

    return Scaffold(
      body: Column(
        children: [
          const TopBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left sidebar
                if (showSidebar)
                  SizedBox(
                    width: kSidebarWidth,
                    child: const LibrarySidebar(),
                  ),
                if (showSidebar) const VerticalDivider(width: 1),

                // Main content
                Expanded(child: const AssetGrid()),

                // Right detail panel
                if (showDetailPanel) const VerticalDivider(width: 1),
                if (showDetailPanel)
                  SizedBox(
                    width: kDetailPanelWidth,
                    child: const DetailPanel(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
