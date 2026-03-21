import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../providers/asset_filter_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/settings_provider.dart';
import 'import_dialog.dart';
import 'manage_properties_dialog.dart';

enum _ImportMode { folder, files }

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

        // View mode toggle
        IconButton(
          icon: Icon(ref.watch(viewModeProvider) == ViewMode.grid
              ? Icons.view_list_outlined
              : Icons.grid_view_outlined),
          tooltip: ref.watch(viewModeProvider) == ViewMode.grid
              ? 'Listenansicht'
              : 'Rasteransicht',
          onPressed: () {
            final mode = ref.read(viewModeProvider);
            ref.read(viewModeProvider.notifier).state =
                mode == ViewMode.grid ? ViewMode.list : ViewMode.grid;
          },
        ),

        // Import button (folder or files)
        PopupMenuButton<_ImportMode>(
          icon: const Icon(Icons.file_download_outlined),
          tooltip: 'Import',
          enabled: libraryPath != null,
          onSelected: (mode) => _pickAndImport(mode),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: _ImportMode.folder,
              child: ListTile(
                leading: Icon(Icons.folder_outlined),
                title: Text('Ordner importieren…'),
                dense: true,
              ),
            ),
            const PopupMenuItem(
              value: _ImportMode.files,
              child: ListTile(
                leading: Icon(Icons.insert_drive_file_outlined),
                title: Text('Dateien importieren…'),
                dense: true,
              ),
            ),
          ],
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
                    value: switch (scanState.phase) {
                      ScanPhase.scanning =>
                        scanState.total > 0 ? scanState.progress : null,
                      ScanPhase.thumbnails =>
                        scanState.thumbsTotal > 0 ? scanState.thumbProgress : null,
                      ScanPhase.metadata =>
                        scanState.total > 0 ? scanState.progress : null,
                      _ => null,
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  switch (scanState.phase) {
                    ScanPhase.scanning =>
                      '${scanState.processed} / ${scanState.total}',
                    ScanPhase.thumbnails => '🖼 ${scanState.thumbsDone}',
                    ScanPhase.metadata =>
                      'Meta ${scanState.processed} / ${scanState.total}',
                    _ => '',
                  },
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

  Future<void> _pickAndImport(_ImportMode mode) async {
    List<String> paths;
    if (mode == _ImportMode.folder) {
      final dir = await FilePicker.platform.getDirectoryPath();
      if (dir == null || !mounted) return;
      paths = [dir];
    } else {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );
      paths = result?.files.map((f) => f.path).whereType<String>().toList() ?? [];
    }
    if (paths.isEmpty || !mounted) return;
    // Bring window to front after file picker closed
    await windowManager.focus();
    if (!mounted) return;
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
        PopupMenuItem(
          child: const ListTile(
            leading: Icon(Icons.tune_outlined),
            title: Text('Custom Properties'),
            dense: true,
          ),
          onTap: () => showManagePropertiesDialog(context, ref),
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
