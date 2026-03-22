import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';
import '../../providers/queue_provider.dart';

class PlaylistScreen extends ConsumerStatefulWidget {
  final String playlistId;

  const PlaylistScreen({super.key, required this.playlistId});

  @override
  ConsumerState<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends ConsumerState<PlaylistScreen> {
  Playlist? _playlist;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    final dao = ref.read(playlistsDaoProvider);
    final p = await dao.getById(widget.playlistId);
    if (mounted) setState(() => _playlist = p);
  }

  Future<void> _rename() async {
    if (_playlist == null) return;
    final ctrl = TextEditingController(text: _playlist!.name);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Playlist umbenennen'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    await ref
        .read(playlistsDaoProvider)
        .renamePlaylist(widget.playlistId, name.trim());
    await _loadPlaylist();
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Playlist löschen'),
        content:
            Text('Playlist "${_playlist?.name ?? ''}" wirklich löschen?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Abbrechen')),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await ref.read(playlistsDaoProvider).deletePlaylist(widget.playlistId);
    if (mounted) context.pop();
  }

  void _playAll(List<PlaylistItemWithAsset> items, int startIndex) {
    if (items.isEmpty) return;
    final ids = items.map((i) => i.asset.id).toList();
    ref.read(queueProvider.notifier).setQueue(ids, startIndex);
    context.push('/library/player/${ids[startIndex]}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
        title: Text(_playlist?.name ?? ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Umbenennen',
            onPressed: _rename,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Playlist löschen',
            onPressed: _delete,
          ),
        ],
      ),
      body: StreamBuilder<List<PlaylistItemWithAsset>>(
        stream:
            ref.read(playlistsDaoProvider).watchItems(widget.playlistId),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final items = snap.data!;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _playlist?.mediaType == 'audio'
                        ? Icons.queue_music
                        : Icons.video_library_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text('Playlist ist leer',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),
                  const Text(
                    'Rechtsklick auf eine Mediendatei → Zur Playlist hinzufügen',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // ── Play-All-Bar ──────────────────────────────────────────────
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    FilledButton.icon(
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: Text('Alle abspielen (${items.length})'),
                      onPressed: () => _playAll(items, 0),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ── Reorderable item list ─────────────────────────────────────
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: items.length,
                  onReorder: (oldIndex, newIndex) async {
                    if (newIndex > oldIndex) newIndex--;
                    await ref.read(playlistsDaoProvider).reorder(
                          widget.playlistId,
                          oldIndex,
                          newIndex,
                        );
                  },
                  itemBuilder: (context, i) {
                    final entry = items[i];
                    return _PlaylistItemTile(
                      key: ValueKey(entry.item.id),
                      index: i,
                      entry: entry,
                      onPlay: () => _playAll(items, i),
                      onPlayNext: () {
                        ref
                            .read(queueProvider.notifier)
                            .insertNext(entry.asset.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '"${entry.asset.filename}" wird als nächstes abgespielt'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      onRemove: () async {
                        await ref
                            .read(playlistsDaoProvider)
                            .removeItem(entry.item.id);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Playlist item tile ────────────────────────────────────────────────────────

class _PlaylistItemTile extends StatelessWidget {
  const _PlaylistItemTile({
    super.key,
    required this.index,
    required this.entry,
    required this.onPlay,
    required this.onPlayNext,
    required this.onRemove,
  });

  final int index;
  final PlaylistItemWithAsset entry;
  final VoidCallback onPlay;
  final VoidCallback onPlayNext;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final asset = entry.asset;
    final mime = asset.mimeType ?? '';
    final isAudio = mime.startsWith('audio/');

    return ListTile(
      dense: true,
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '${index + 1}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            isAudio ? Icons.music_note_outlined : Icons.movie_outlined,
            size: 18,
            color: isAudio ? Colors.purple : Colors.blue,
          ),
        ],
      ),
      title: Text(
        asset.mediaTitle ?? asset.filename,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: asset.artist != null
          ? Text(
              asset.artist!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (asset.durationMs != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                _fmtDuration(asset.durationMs!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            tooltip: 'Aus Playlist entfernen',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            onPressed: onRemove,
          ),
        ],
      ),
      onTap: onPlay,
      onLongPress: onPlayNext,
    );
  }

  static String _fmtDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
