import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/constants.dart';
import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/asset_list_provider.dart';
import '../../providers/queue_provider.dart';
import '../../providers/settings_provider.dart';
import 'add_to_playlist_dialog.dart';

/// Compact list view of assets — alternative to [AssetGrid].
class AssetListView extends ConsumerStatefulWidget {
  const AssetListView({super.key});

  @override
  ConsumerState<AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends ConsumerState<AssetListView> {
  final _scrollController = ScrollController();
  int _loadedPages = 1;

  static const _dateFormat = 'dd.MM.yyyy';

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

  void _onTap(Asset asset) {
    if (ref.read(isMultiSelectProvider)) {
      ref.read(multiSelectProvider.notifier).toggle(asset.id);
      return;
    }
    ref.read(selectedAssetIdProvider.notifier).state = asset.id;
  }

  void _onDoubleTap(BuildContext context, Asset asset) {
    if (ref.read(isMultiSelectProvider)) return;
    final mime = asset.mimeType ?? '';
    if (isVideo(mime) || isAudio(mime)) {
      context.push('/library/player/${asset.id}');
    } else if (mime.startsWith('image/')) {
      context.push('/library/image/${asset.id}');
    } else {
      final cat = categoryFromMime(mime);
      if (cat == MimeCategory.document || cat == MimeCategory.text) {
        context.push('/library/document/${asset.id}');
      }
    }
  }

  Future<void> _showContextMenu(
      BuildContext context, Asset asset, Offset globalPos) async {
    final mime = asset.mimeType ?? '';
    final isMedia = isVideo(mime) || isAudio(mime);
    final mediaType = isAudio(mime) ? 'audio' : 'video';

    final items = <PopupMenuEntry<String>>[];
    if (isMedia) {
      items.addAll([
        const PopupMenuItem(
          value: 'play_next',
          child: ListTile(
            leading: Icon(Icons.queue_play_next_outlined),
            title: Text('Als nächstes abspielen'),
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'add_to_playlist',
          child: ListTile(
            leading: Icon(Icons.playlist_add_outlined),
            title: Text('Zur Playlist hinzufügen…'),
            dense: true,
          ),
        ),
        const PopupMenuDivider(),
      ]);
    }

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
          globalPos.dx, globalPos.dy, globalPos.dx + 1, globalPos.dy + 1),
      items: items.isEmpty
          ? [
              const PopupMenuItem(
                enabled: false,
                child: Text('Keine Aktionen verfügbar'),
              )
            ]
          : items,
    );
    if (!mounted || result == null) return;

    switch (result) {
      case 'play_next':
        ref.read(queueProvider.notifier).insertNext(asset.id);
      case 'add_to_playlist':
        if (mounted) {
          await showAddToPlaylistDialog(
            context,
            assetId: asset.id,
            mediaType: mediaType,
          );
        }
    }
  }

  Widget _headerCell(ListColumn col, TextStyle? style) {
    switch (col) {
      case ListColumn.name:
        return Expanded(flex: 5, child: Text(col.label, style: style));
      case ListColumn.type:
        return Expanded(flex: 2, child: Text(col.label, style: style));
      case ListColumn.size:
        return SizedBox(width: 72, child: Text(col.label, style: style, textAlign: TextAlign.right));
      case ListColumn.duration:
        return SizedBox(width: 80, child: Text(col.label, style: style, textAlign: TextAlign.right));
      case ListColumn.rating:
        return SizedBox(width: 64, child: Text(col.label, style: style, textAlign: TextAlign.center));
      case ListColumn.modified:
        return SizedBox(width: 88, child: Text(col.label, style: style, textAlign: TextAlign.right));
      default:
        return SizedBox(width: 80, child: Text(col.label, style: style, textAlign: TextAlign.right));
    }
  }

  void _showColumnMenu(BuildContext context, Offset pos) {
    final columns = ref.read(listColumnsProvider);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(pos.dx, pos.dy, pos.dx + 1, pos.dy + 1),
      items: ListColumn.values.map((col) {
        final active = columns.contains(col);
        return PopupMenuItem(
          child: Row(
            children: [
              Icon(active ? Icons.check_box : Icons.check_box_outline_blank, size: 18),
              const SizedBox(width: 8),
              Text(col.label),
            ],
          ),
          onTap: () {
            if (active) {
              ref.read(listColumnsProvider.notifier).removeColumn(col);
            } else {
              ref.read(listColumnsProvider.notifier).addColumn(col);
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
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

    final cs = Theme.of(context).colorScheme;
    final headerStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
        );
    final columns = ref.watch(listColumnsProvider);

    return Column(
      children: [
        // ── Header row ─────────────────────────────────────────────────────
        GestureDetector(
          onSecondaryTapUp: (d) => _showColumnMenu(context, d.globalPosition),
          child: Container(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                const SizedBox(width: 28), // icon column
                ...columns.map((col) => _headerCell(col, headerStyle)),
              ],
            ),
          ),
        ),
        const Divider(height: 1),

        // ── Rows ──────────────────────────────────────────────────────────
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: allAssets.length + (isLoading ? 1 : 0),
            itemBuilder: (context, i) {
              if (i >= allAssets.length) {
                return const Center(
                    child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ));
              }
              final asset = allAssets[i];
              final isSelected =
                  selectedIds.contains(asset.id) || selectedId == asset.id;
              return _AssetRow(
                asset: asset,
                isSelected: isSelected,
                columns: columns,
                onTap: () => _onTap(asset),
                onDoubleTap: () => _onDoubleTap(context, asset),
                onContextMenu: (pos) => _showContextMenu(context, asset, pos),
                dateFormat: _dateFormat,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AssetRow extends ConsumerWidget {
  final Asset asset;
  final bool isSelected;
  final List<ListColumn> columns;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final void Function(Offset) onContextMenu;
  final String dateFormat;

  const _AssetRow({
    required this.asset,
    required this.isSelected,
    required this.columns,
    required this.onTap,
    required this.onDoubleTap,
    required this.onContextMenu,
    required this.dateFormat,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final mime = asset.mimeType ?? '';
    final cat = categoryFromMime(mime);
    final sub = Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onSecondaryTapUp: (details) => onContextMenu(details.globalPosition),
      onLongPress: () => ref.read(multiSelectProvider.notifier).toggle(asset.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: isSelected
            ? cs.primaryContainer.withValues(alpha: 0.35)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        child: Row(
          children: [
            // Type icon (always shown)
            SizedBox(
              width: 28,
              child: Icon(_categoryIcon(cat, mime), size: 18,
                  color: _categoryColor(cat, mime)),
            ),
            ...columns.map((col) => _buildCell(context, col, cat, mime, sub)),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, ListColumn col, MimeCategory cat, String mime, TextStyle? sub) {
    switch (col) {
      case ListColumn.name:
        return Expanded(
          flex: 5,
          child: Row(
            children: [
              if ((asset.colorLabel ?? '').isNotEmpty)
                Container(
                  width: 8, height: 8,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _colorFromLabel(asset.colorLabel!),
                  ),
                ),
              Expanded(
                child: Text(asset.filename, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
              if (_subtitle(asset) != null) ...[
                const SizedBox(width: 8),
                Flexible(child: Text(_subtitle(asset)!, maxLines: 1,
                    overflow: TextOverflow.ellipsis, style: sub)),
              ],
            ],
          ),
        );
      case ListColumn.type:
        return Expanded(flex: 2, child: Text(_typeLabel(cat, mime), maxLines: 1,
            overflow: TextOverflow.ellipsis, style: sub));
      case ListColumn.size:
        return SizedBox(width: 72, child: Text(
            asset.size != null ? _fmtSize(asset.size!) : '—',
            textAlign: TextAlign.right, style: sub));
      case ListColumn.duration:
        return SizedBox(width: 80, child: Text(_durationOrPages(asset),
            textAlign: TextAlign.right, style: sub));
      case ListColumn.rating:
        return SizedBox(width: 64, child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(asset.rating,
              (_) => const Icon(Icons.star, size: 10, color: Colors.amber)),
        ));
      case ListColumn.modified:
        return SizedBox(width: 88, child: Text(
            asset.fileModifiedAt != null
                ? DateFormat(dateFormat).format(
                    DateTime.fromMillisecondsSinceEpoch(asset.fileModifiedAt!))
                : '—',
            textAlign: TextAlign.right, style: sub));
      case ListColumn.artist:
        return SizedBox(width: 80, child: Text(asset.artist ?? '—',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right, style: sub));
      case ListColumn.album:
        return SizedBox(width: 80, child: Text(asset.album ?? '—',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right, style: sub));
      case ListColumn.genre:
        return SizedBox(width: 80, child: Text(asset.genre ?? '—',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right, style: sub));
      case ListColumn.bitrate:
        return SizedBox(width: 80, child: Text(
            asset.bitrate != null ? '${asset.bitrate} kbps' : '—',
            textAlign: TextAlign.right, style: sub));
      case ListColumn.sampleRate:
        return SizedBox(width: 80, child: Text(
            asset.sampleRate != null ? '${asset.sampleRate} Hz' : '—',
            textAlign: TextAlign.right, style: sub));
      case ListColumn.resolution:
        return SizedBox(width: 80, child: Text(
            asset.width != null && asset.height != null
                ? '${asset.width}×${asset.height}' : '—',
            textAlign: TextAlign.right, style: sub));
      case ListColumn.author:
        return SizedBox(width: 80, child: Text(asset.author ?? '—',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right, style: sub));
      case ListColumn.publisher:
        return SizedBox(width: 80, child: Text(asset.publisher ?? '—',
            maxLines: 1, overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right, style: sub));
      case ListColumn.captureDate:
        return SizedBox(width: 80, child: Text(asset.captureDate ?? '—',
            textAlign: TextAlign.right, style: sub));
    }
  }

  String? _subtitle(Asset a) {
    if (a.artist != null && a.mediaTitle != null) {
      return '${a.artist} — ${a.mediaTitle}';
    }
    if (a.artist != null) return a.artist;
    if (a.author != null) return a.author;
    return null;
  }

  String _durationOrPages(Asset a) {
    if (a.durationMs != null && a.durationMs! > 0) {
      return _fmtDuration(a.durationMs!);
    }
    if (a.pageCount != null) return '${a.pageCount} S.';
    return '—';
  }

  String _fmtDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _typeLabel(MimeCategory cat, String mime) {
    switch (cat) {
      case MimeCategory.video:
        return 'Video';
      case MimeCategory.audio:
        return 'Audio';
      case MimeCategory.image:
        return 'Bild';
      case MimeCategory.document:
        if (mime == 'application/pdf') return 'PDF';
        if (mime.contains('epub')) return 'E-Book';
        return 'Dokument';
      case MimeCategory.text:
        return 'Text';
      case MimeCategory.archive:
        return 'Archiv';
      case MimeCategory.font:
        return 'Schrift';
      case MimeCategory.model:
        return '3D-Modell';
      case MimeCategory.other:
        final ext = mime.split('/').last.split('+').first.toUpperCase();
        return ext.length <= 6 ? ext : 'Datei';
    }
  }

  IconData _categoryIcon(MimeCategory cat, String mime) {
    switch (cat) {
      case MimeCategory.video:
        return Icons.movie_outlined;
      case MimeCategory.audio:
        return Icons.music_note_outlined;
      case MimeCategory.image:
        return Icons.image_outlined;
      case MimeCategory.document:
        if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
        if (mime.contains('epub')) return Icons.auto_stories_outlined;
        return Icons.description_outlined;
      case MimeCategory.text:
        return Icons.text_snippet_outlined;
      case MimeCategory.archive:
        return Icons.folder_zip_outlined;
      case MimeCategory.font:
        return Icons.text_fields_outlined;
      case MimeCategory.model:
        return Icons.view_in_ar_outlined;
      case MimeCategory.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _categoryColor(MimeCategory cat, String mime) {
    switch (cat) {
      case MimeCategory.video:
        return Colors.blue;
      case MimeCategory.audio:
        return Colors.purple;
      case MimeCategory.image:
        return Colors.green;
      case MimeCategory.document:
        if (mime == 'application/pdf') return Colors.red;
        if (mime.contains('epub')) return Colors.orange;
        return Colors.blueGrey;
      case MimeCategory.text:
        return Colors.teal;
      case MimeCategory.archive:
        return Colors.brown;
      case MimeCategory.font:
        return Colors.indigo;
      case MimeCategory.model:
        return Colors.cyan;
      case MimeCategory.other:
        return Colors.grey;
    }
  }

  Color _colorFromLabel(String label) {
    switch (label) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
