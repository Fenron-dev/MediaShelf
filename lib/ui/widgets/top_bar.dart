import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../providers/asset_filter_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';

class TopBar extends ConsumerStatefulWidget {
  const TopBar({super.key});

  @override
  ConsumerState<TopBar> createState() => _TopBarState();
}

class _TopBarState extends ConsumerState<TopBar> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanState = ref.watch(scanProvider);
    final showSidebar = ref.watch(showSidebarProvider);
    final libraryPath = ref.watch(libraryPathProvider);
    final libraryName = libraryPath?.split('/').last ?? 'MediaShelf';

    return AppBar(
      leading: IconButton(
        icon: Icon(showSidebar ? Icons.menu_open : Icons.menu),
        tooltip: showSidebar ? 'Hide sidebar' : 'Show sidebar',
        onPressed: () => ref.read(showSidebarProvider.notifier).state = !showSidebar,
      ),
      title: Text(libraryName),
      actions: [
        // Search field
        SizedBox(
          width: 240,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search...',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(assetFilterProvider.notifier).setSearchQuery('');
                      },
                    )
                  : null,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              filled: true,
            ),
            onChanged: (v) {
              setState(() {});
              ref.read(assetFilterProvider.notifier).setSearchQuery(v);
            },
          ),
        ),
        const SizedBox(width: 8),

        // Scan button
        if (scanState.isScanning)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  '${scanState.processed} / ${scanState.total}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Scan library',
            onPressed: () => ref.read(scanProvider.notifier).startScan(),
          ),

        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMenu(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  void _showMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(Offset(renderBox.size.width - 180, renderBox.size.height));

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, offset.dx + 180, offset.dy + 200),
      items: [
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.settings_outlined),
            title: Text('Settings'),
            dense: true,
          ),
          onTap: () {},
        ),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.history),
            title: Text('Activity'),
            dense: true,
          ),
          onTap: () => context.push('/library/activity'),
        ),
      ],
    );
  }
}
