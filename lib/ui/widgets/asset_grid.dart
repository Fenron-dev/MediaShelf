import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants.dart';
import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/asset_list_provider.dart';
import '../../providers/folder_tree_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/queue_provider.dart';
import '../../providers/settings_provider.dart';
import 'asset_card.dart';

/// Infinite-scrolling grid of [AssetCard]s backed by [assetPageProvider].
class AssetGrid extends ConsumerStatefulWidget {
  const AssetGrid({super.key});

  @override
  ConsumerState<AssetGrid> createState() => _AssetGridState();
}

class _AssetGridState extends ConsumerState<AssetGrid> {
  final _scrollController = ScrollController();
  int _loadedPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  void _loadMore() {
    final total = ref.read(assetTotalProvider).valueOrNull ?? 0;
    if (_loadedPages * kPageSize < total) {
      setState(() => _loadedPages++);
    }
  }

  // Fires on pointer-down — no 300 ms double-tap disambiguation delay.
  void _setQueue(Asset tapped, List<Asset> all) {
    final playableIds = all
        .where((a) {
          final m = a.mimeType ?? '';
          return isVideo(m) || isAudio(m);
        })
        .map((a) => a.id)
        .toList();
    final startIdx = playableIds.indexOf(tapped.id);
    if (playableIds.isNotEmpty && startIdx >= 0) {
      ref.read(queueProvider.notifier).setQueue(playableIds, startIdx);
    }
  }

  void _onTapDown(BuildContext context, Asset asset) {
    if (ref.read(isMultiSelectProvider)) {
      ref.read(multiSelectProvider.notifier).toggle(asset.id);
      return;
    }
    ref.read(selectedAssetIdProvider.notifier).state = asset.id;
  }

  void _onDoubleTap(BuildContext context, Asset asset, List<Asset> allAssets) {
    if (ref.read(isMultiSelectProvider)) return;
    final mime = asset.mimeType ?? '';
    if (isVideo(mime) || isAudio(mime)) {
      _setQueue(asset, allAssets);
      context.push('/library/player/${asset.id}');
    } else if (mime.startsWith('image/')) {
      context.push('/library/image/${asset.id}');
    } else {
      final cat = categoryFromMime(mime);
      if (cat == MimeCategory.document ||
          cat == MimeCategory.text ||
          mime == 'application/json' ||
          mime == 'application/xml' ||
          mime == 'application/sql') {
        context.push('/library/document/${asset.id}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = ref.watch(thumbnailSizeProvider);
    final selectedId = ref.watch(selectedAssetIdProvider);
    final selectedIds = ref.watch(multiSelectProvider);

    final allAssets = <Asset>[];
    bool isLoading = false;

    for (var page = 0; page < _loadedPages; page++) {
      final pageAsync = ref.watch(assetPageProvider(page));
      pageAsync.when(
        data: (p) => allAssets.addAll(p.assets),
        loading: () => isLoading = true,
        error: (e, st) {},
      );
    }

    if (allAssets.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allAssets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No assets found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: thumbSize,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: allAssets.length + (isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= allAssets.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final asset = allAssets[i];
        return GestureDetector(
          onSecondaryTapUp: (details) =>
              _showAssetContextMenu(context, asset, details.globalPosition),
          child: AssetCard(
            asset: asset,
            isSelected: selectedIds.contains(asset.id) || selectedId == asset.id,
            onTapDown: () => _onTapDown(context, asset),
            onDoubleTap: () => _onDoubleTap(context, asset, allAssets),
            onLongPress: () =>
                ref.read(multiSelectProvider.notifier).toggle(asset.id),
          ),
        );
      },
    );
  }

  Future<void> _showAssetContextMenu(
      BuildContext context, Asset asset, Offset globalPos) async {
    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          globalPos.dx, globalPos.dy, globalPos.dx + 1, globalPos.dy + 1),
      items: [
        const PopupMenuItem(
          value: 'move',
          child: ListTile(
            leading: Icon(Icons.drive_file_move_outlined),
            title: Text('Verschieben nach…'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'copy',
          child: ListTile(
            leading: Icon(Icons.copy_outlined),
            title: Text('Kopieren nach…'),
            dense: true,
          ),
        ),
      ],
    );
    if (!mounted || result == null) return;
    await _pickDestAndTransfer(context, asset, move: result == 'move');
  }

  Future<void> _pickDestAndTransfer(
      BuildContext context, Asset asset, {required bool move}) async {
    final libraryPath = ref.read(libraryPathProvider);
    if (libraryPath == null) return;

    final destDir = await showDialog<String>(
      context: context,
      builder: (ctx) => _FolderPickerDialog(libraryPath: libraryPath),
    );
    if (!mounted || destDir == null) return;

    final src = File('$libraryPath/${asset.path}');
    final destRel = destDir.isEmpty ? asset.filename : '$destDir/${asset.filename}';
    final dest = File('$libraryPath/$destRel');

    if (dest.existsSync()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datei existiert bereits: $destRel')),
        );
      }
      return;
    }

    if (move) {
      await src.rename(dest.path);
      await ref.read(assetsDaoProvider).updateAsset(AssetsCompanion(
        id: Value(asset.id),
        path: Value(destRel),
        filename: Value(asset.filename),
      ));
    } else {
      await src.copy(dest.path);
    }
    ref.read(scanVersionProvider.notifier).state++;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(move
              ? 'Verschoben nach ${destDir.isEmpty ? "Bibliothek" : destDir}'
              : 'Kopiert nach ${destDir.isEmpty ? "Bibliothek" : destDir}'),
        ),
      );
    }
  }
}

// ── Folder picker dialog ──────────────────────────────────────────────────────

class _FolderPickerDialog extends ConsumerWidget {
  final String libraryPath;
  const _FolderPickerDialog({required this.libraryPath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _FolderPickerDialogBody(libraryPath: libraryPath);
  }
}

class _FolderPickerDialogBody extends ConsumerStatefulWidget {
  final String libraryPath;
  const _FolderPickerDialogBody({required this.libraryPath});

  @override
  ConsumerState<_FolderPickerDialogBody> createState() =>
      _FolderPickerDialogBodyState();
}

class _FolderPickerDialogBodyState
    extends ConsumerState<_FolderPickerDialogBody> {
  String? _selectedPath;

  @override
  Widget build(BuildContext context) {
    final treeAsync = ref.watch(folderTreeProvider);
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Zielordner wählen'),
      content: SizedBox(
        width: 320,
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              dense: true,
              leading: const Icon(Icons.home_outlined, size: 18),
              title: const Text('Bibliothek (Wurzel)'),
              selected: _selectedPath == '',
              selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
              onTap: () => setState(() => _selectedPath = ''),
            ),
            const Divider(height: 1),
            Expanded(
              child: treeAsync.when(
                data: (roots) => ListView(
                  children: roots
                      .map((n) => _PickerFolderTile(
                            node: n,
                            depth: 0,
                            selectedPath: _selectedPath,
                            onSelect: (p) =>
                                setState(() => _selectedPath = p),
                          ))
                      .toList(),
                ),
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen')),
        FilledButton(
          onPressed: _selectedPath == null
              ? null
              : () => Navigator.pop(context, _selectedPath),
          child: const Text('Hierhin'),
        ),
      ],
    );
  }
}

class _PickerFolderTile extends StatefulWidget {
  const _PickerFolderTile({
    required this.node,
    required this.depth,
    required this.selectedPath,
    required this.onSelect,
  });
  final FolderNode node;
  final int depth;
  final String? selectedPath;
  final void Function(String) onSelect;

  @override
  State<_PickerFolderTile> createState() => _PickerFolderTileState();
}

class _PickerFolderTileState extends State<_PickerFolderTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final dir = widget.node.fullPath.endsWith('/')
        ? widget.node.fullPath.substring(0, widget.node.fullPath.length - 1)
        : widget.node.fullPath;
    final selected = widget.selectedPath == dir;
    final indent = 4.0 + widget.depth * 14.0;
    final hasChildren = widget.node.children.isNotEmpty;
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: indent, right: 4),
          leading: Icon(
            hasChildren && _expanded
                ? Icons.folder_open_outlined
                : Icons.folder_outlined,
            size: 16,
          ),
          title: Text(widget.node.name),
          trailing: hasChildren
              ? IconButton(
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => setState(() => _expanded = !_expanded),
                )
              : null,
          selected: selected,
          selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
          onTap: () => widget.onSelect(dir),
        ),
        if (_expanded && hasChildren)
          ...widget.node.children.map((child) => _PickerFolderTile(
                node: child,
                depth: widget.depth + 1,
                selectedPath: widget.selectedPath,
                onSelect: widget.onSelect,
              )),
      ],
    );
  }
}
