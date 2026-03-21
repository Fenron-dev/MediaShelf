import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/asset_filter_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';
import 'import_dialog.dart';

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
    final showDetail = ref.watch(showDetailPanelProvider);
    final thumbSize = ref.watch(thumbnailSizeProvider);
    final libraryPath = ref.watch(libraryPathProvider);
    final libraryName = libraryPath?.split('/').last ?? 'MediaShelf';

    return AppBar(
      leading: IconButton(
        icon: Icon(showSidebar ? Icons.menu_open : Icons.menu),
        tooltip: showSidebar ? 'Hide sidebar' : 'Show sidebar',
        onPressed: () =>
            ref.read(showSidebarProvider.notifier).state = !showSidebar,
      ),
      title: Text(libraryName),
      actions: [
        // Search field
        SizedBox(
          width: 220,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search…',
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref
                            .read(assetFilterProvider.notifier)
                            .setSearchQuery('');
                        setState(() {});
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
        const SizedBox(width: 4),

        // Thumbnail size slider
        SizedBox(
          width: 100,
          child: Slider(
            value: thumbSize,
            min: 80,
            max: 400,
            divisions: 16,
            label: '${thumbSize.round()}px',
            onChanged: (v) =>
                ref.read(thumbnailSizeProvider.notifier).set(v),
          ),
        ),

        // Import button
        IconButton(
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Import files',
          onPressed: libraryPath == null ? null : _pickAndImport,
        ),

        // Detail panel toggle
        IconButton(
          icon: Icon(showDetail ? Icons.view_sidebar : Icons.view_sidebar_outlined),
          tooltip: showDetail ? 'Hide detail panel' : 'Show detail panel',
          onPressed: () =>
              ref.read(showDetailPanelProvider.notifier).state = !showDetail,
        ),

        // Scan / progress
        if (scanState.isScanning)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: scanState.phase == ScanPhase.scanning
                        ? (scanState.total > 0 ? scanState.progress : null)
                        : (scanState.thumbsTotal > 0
                            ? scanState.thumbProgress
                            : null),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  scanState.phase == ScanPhase.scanning
                      ? '${scanState.processed} / ${scanState.total}'
                      : '🖼 ${scanState.thumbsDone}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Scan library',
            onPressed: () =>
                ref.read(scanProvider.notifier).startScan(),
          ),

        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () => _showMenu(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Future<void> _pickAndImport() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.any,
    );
    final paths = result?.files.map((f) => f.path).whereType<String>().toList();
    if (paths == null || paths.isEmpty || !mounted) return;
    await showImportDialog(context, ref, paths);
  }

  void _showMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final offset = renderBox.localToGlobal(
      Offset(renderBox.size.width - 180, renderBox.size.height),
    );
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
          offset.dx, offset.dy, offset.dx + 180, offset.dy + 200),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.history),
            title: Text('Activity'),
            dense: true,
          ),
          onTap: () => context.push('/library/activity'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.logout),
            title: Text('Close Library'),
            dense: true,
          ),
          onTap: () => ref.read(libraryPathProvider.notifier).state = null,
        ),
      ],
    );
  }
}
