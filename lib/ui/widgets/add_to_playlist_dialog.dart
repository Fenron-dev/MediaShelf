import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library_provider.dart';

/// Shows a dialog that lets the user pick an existing playlist or create a new
/// one, then adds [assetId] to that playlist.
///
/// [mediaType] must be `'audio'` or `'video'` — only matching playlists are shown.
Future<void> showAddToPlaylistDialog(
  BuildContext context, {
  required String assetId,
  required String mediaType,
}) {
  return showDialog(
    context: context,
    builder: (_) => _AddToPlaylistDialog(
      assetId: assetId,
      mediaType: mediaType,
    ),
  );
}

class _AddToPlaylistDialog extends ConsumerStatefulWidget {
  const _AddToPlaylistDialog({
    required this.assetId,
    required this.mediaType,
  });
  final String assetId;
  final String mediaType;

  @override
  ConsumerState<_AddToPlaylistDialog> createState() =>
      _AddToPlaylistDialogState();
}

class _AddToPlaylistDialogState extends ConsumerState<_AddToPlaylistDialog> {
  bool _creating = false;
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _addTo(String playlistId) async {
    await ref.read(playlistsDaoProvider).addItem(playlistId, widget.assetId);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _createAndAdd() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final dao = ref.read(playlistsDaoProvider);
    final id = await dao.createPlaylist(name: name, mediaType: widget.mediaType);
    await dao.addItem(id, widget.assetId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(playlistsProvider);
    final playlists = (allAsync.valueOrNull ?? [])
        .where((p) => p.mediaType == widget.mediaType)
        .toList();

    return AlertDialog(
      title: Text(widget.mediaType == 'audio'
          ? 'Zur Audio-Playlist hinzufügen'
          : 'Zur Video-Playlist hinzufügen'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (playlists.isEmpty && !_creating)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Noch keine Playliste vorhanden.',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              )
            else if (!_creating)
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: playlists.length,
                  itemBuilder: (_, i) {
                    final p = playlists[i];
                    return ListTile(
                      dense: true,
                      leading: Icon(
                        widget.mediaType == 'audio'
                            ? Icons.queue_music
                            : Icons.video_library_outlined,
                        size: 20,
                      ),
                      title: Text(p.name),
                      onTap: () => _addTo(p.id),
                    );
                  },
                ),
              ),
            if (_creating) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name der Playlist',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _createAndAdd(),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _creating = false),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _createAndAdd,
                    child: const Text('Erstellen & Hinzufügen'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_creating)
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Neue Playlist'),
            onPressed: () => setState(() => _creating = true),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Abbrechen'),
        ),
      ],
    );
  }
}
