import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/asset_filter_provider.dart';
import '../../providers/asset_list_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/properties_provider.dart';
import '../../providers/tag_provider.dart';
import 'thumbnail_image.dart';

class DetailPanel extends ConsumerWidget {
  const DetailPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedAssetIdProvider);
    if (selectedId == null) {
      return const Center(
        child: Text('Select an asset', style: TextStyle(color: Colors.grey)),
      );
    }

    final dao = ref.watch(assetsDaoProvider);
    return StreamBuilder<Asset?>(
      stream: dao.watchById(selectedId),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final asset = snap.data;
        if (asset == null) return const SizedBox.shrink();
        return _AssetDetail(asset: asset);
      },
    );
  }
}

class _AssetDetail extends ConsumerStatefulWidget {
  final Asset asset;
  const _AssetDetail({required this.asset});

  @override
  ConsumerState<_AssetDetail> createState() => _AssetDetailState();
}

class _AssetDetailState extends ConsumerState<_AssetDetail> {
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.asset.note ?? '');
  }

  @override
  void didUpdateWidget(_AssetDetail old) {
    super.didUpdateWidget(old);
    if (old.asset.id != widget.asset.id) {
      _noteController.text = widget.asset.note ?? '';
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = widget.asset;
    final tagsAsync = ref.watch(assetTagsProvider(asset.id));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Thumbnail preview
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: ThumbnailImage(asset: asset),
          ),
        ),
        const SizedBox(height: 12),

        // Filename
        Text(
          asset.filename,
          style: Theme.of(context).textTheme.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          asset.path,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const Divider(height: 24),

        // Star rating
        _DetailRow(
          label: 'Rating',
          child: _StarRating(
            value: asset.rating,
            onChanged: (v) => _updateRating(v),
          ),
        ),

        // Color label
        _DetailRow(
          label: 'Color',
          child: _ColorLabelPicker(
            value: asset.colorLabel,
            onChanged: (v) => _updateColorLabel(v),
          ),
        ),

        const Divider(height: 24),

        // Tags
        Text('Tags', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        tagsAsync.when(
          data: (tags) => Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ...tags.map((t) => Chip(
                    label: Text(t.tag.name),
                    onDeleted: () => _removeTag(t.tag.name),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                  )),
              ActionChip(
                avatar: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                onPressed: () => _addTagDialog(context),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: EdgeInsets.zero,
                labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, st) => const SizedBox.shrink(),
        ),

        const Divider(height: 24),

        // Note
        Text('Note', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _noteController,
          maxLines: 5,
          minLines: 3,
          decoration: const InputDecoration(
            hintText: 'Add a note...',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (v) => _saveNote(v),
        ),

        const Divider(height: 24),

        // Type-specific metadata template
        _MediaTemplate(asset: asset),

        // Custom properties
        _CustomPropertiesSection(assetId: asset.id),

        // Locations (collections this asset belongs to)
        _LocationsSection(assetId: asset.id, assetPath: asset.path),

        // Playlists (only for audio / video)
        if (categoryFromMime(asset.mimeType ?? '') == MimeCategory.audio ||
            categoryFromMime(asset.mimeType ?? '') == MimeCategory.video)
          _AssetPlaylistsSection(assetId: asset.id),
      ],
    );
  }

  void _bumpMeta() =>
      ref.read(metaVersionProvider.notifier).state++;

  Future<void> _updateRating(int rating) async {
    final dao = ref.read(assetsDaoProvider);
    await dao.updateMeta(id: widget.asset.id, rating: Value(rating));
    _bumpMeta();
  }

  Future<void> _updateColorLabel(String? label) async {
    final dao = ref.read(assetsDaoProvider);
    await dao.updateMeta(id: widget.asset.id, colorLabel: Value(label));
    _bumpMeta();
  }

  Future<void> _saveNote(String note) async {
    final dao = ref.read(assetsDaoProvider);
    await dao.updateMeta(id: widget.asset.id, note: Value(note));
    _bumpMeta();
  }

  Future<void> _removeTag(String tagName) async {
    final dao = ref.read(assetsDaoProvider);
    final currentTags = await dao.getTagsForAsset(widget.asset.id);
    final updatedIds = currentTags
        .where((t) => t.name != tagName)
        .map((t) => t.id)
        .toList();
    await dao.setTagsForAsset(widget.asset.id, updatedIds);
    ref.invalidate(assetTagsProvider(widget.asset.id));
    _bumpMeta();
  }

  Future<void> _addTagDialog(BuildContext context) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tag name'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final tagsDao = ref.read(tagsDaoProvider);
    final newTagId = await tagsDao.upsertTag(result.trim());
    final assetsDao = ref.read(assetsDaoProvider);
    final current = await assetsDao.getTagsForAsset(widget.asset.id);
    final ids = {...current.map((t) => t.id), newTagId}.toList();
    await assetsDao.setTagsForAsset(widget.asset.id, ids);
    ref.invalidate(assetTagsProvider(widget.asset.id));
    _bumpMeta();
  }

}

// ── Sub-widgets ────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget child;
  const _DetailRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 64,
            child: Text(label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  final String label;
  final String value;
  const _MetaRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// ── Media-type template ───────────────────────────────────────────────────────

class _MediaTemplate extends StatelessWidget {
  final Asset asset;
  const _MediaTemplate({required this.asset});

  @override
  Widget build(BuildContext context) {
    final mime = asset.mimeType ?? '';
    final cat = categoryFromMime(mime);

    final rows = <Widget>[];

    // Always show type + size
    rows.add(_MetaRow('Typ', mime));
    if (asset.size != null) rows.add(_MetaRow('Größe', _fmtSize(asset.size!)));

    switch (cat) {
      case MimeCategory.audio:
        if (asset.mediaTitle != null) rows.add(_MetaRow('Titel', asset.mediaTitle!));
        if (asset.artist != null) rows.add(_MetaRow('Künstler', asset.artist!));
        if (asset.album != null) rows.add(_MetaRow('Album', asset.album!));
        if (asset.genre != null) rows.add(_MetaRow('Genre', asset.genre!));
        if (asset.trackNumber != null) rows.add(_MetaRow('Track', '${asset.trackNumber}'));
        if (asset.captureDate != null) rows.add(_MetaRow('Jahr', asset.captureDate!));
        if (asset.durationMs != null) rows.add(_MetaRow('Dauer', _fmtDuration(asset.durationMs!)));
        if (asset.bitrate != null) rows.add(_MetaRow('Bitrate', '${asset.bitrate} kbps'));
        if (asset.sampleRate != null) rows.add(_MetaRow('Sample-Rate', '${asset.sampleRate} Hz'));

      case MimeCategory.video:
        if (asset.mediaTitle != null) rows.add(_MetaRow('Titel', asset.mediaTitle!));
        if (asset.artist != null) rows.add(_MetaRow('Regisseur', asset.artist!));
        if (asset.durationMs != null) rows.add(_MetaRow('Dauer', _fmtDuration(asset.durationMs!)));
        if (asset.width != null && asset.height != null) {
          rows.add(_MetaRow('Auflösung', '${asset.width} × ${asset.height}'));
        }
        if (asset.bitrate != null) rows.add(_MetaRow('Bitrate', '${asset.bitrate} kbps'));
        if (asset.captureDate != null) rows.add(_MetaRow('Jahr', asset.captureDate!));

      case MimeCategory.image:
        if (asset.width != null && asset.height != null) {
          rows.add(_MetaRow('Abmessungen', '${asset.width} × ${asset.height}'));
        }
        if (asset.cameraModel != null) rows.add(_MetaRow('Kamera', asset.cameraModel!));
        if (asset.captureDate != null) rows.add(_MetaRow('Aufnahmedatum', asset.captureDate!));

      case MimeCategory.document:
        if (mime == 'application/pdf' || mime.contains('epub')) {
          if (asset.mediaTitle != null) rows.add(_MetaRow('Titel', asset.mediaTitle!));
          if (asset.author != null) rows.add(_MetaRow('Autor', asset.author!));
          if (asset.publisher != null) rows.add(_MetaRow('Verlag', asset.publisher!));
          if (asset.pageCount != null) rows.add(_MetaRow('Seiten', '${asset.pageCount}'));
          if (asset.captureDate != null) rows.add(_MetaRow('Jahr', asset.captureDate!));
        } else {
          if (asset.author != null) rows.add(_MetaRow('Autor', asset.author!));
        }

      case MimeCategory.text:
      case MimeCategory.archive:
      case MimeCategory.font:
      case MimeCategory.model:
      case MimeCategory.other:
        break;
    }

    if (rows.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }

  static String _fmtSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  static String _fmtDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}

class _StarRating extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _StarRating({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return GestureDetector(
          onTap: () => onChanged(value == i + 1 ? 0 : i + 1),
          child: Icon(
            i < value ? Icons.star : Icons.star_border,
            size: 20,
            color: Colors.amber,
          ),
        );
      }),
    );
  }
}

// ── Locations (collections this asset belongs to) ─────────────────────────────

class _LocationsSection extends ConsumerWidget {
  const _LocationsSection({required this.assetId, required this.assetPath});
  final String assetId;
  final String assetPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final dao = ref.watch(collectionsDaoProvider);

    final parts = assetPath.split('/');
    final dirPath = parts.length > 1
        ? parts.sublist(0, parts.length - 1).join('/')
        : '';

    return FutureBuilder<List<Collection>>(
      future: dao.getCollectionsForAsset(assetId),
      builder: (context, snap) {
        final cols = snap.data ?? [];
        if (cols.isEmpty && dirPath.isEmpty) return const SizedBox.shrink();

        return collectionsAsync.when(
          data: (allCols) {
            final colMap = {for (final c in allCols) c.id: c};

            String buildPath(Collection col) {
              final segments = <String>[];
              Collection? current = col;
              while (current != null) {
                segments.insert(0, current.name);
                current = current.parentId != null
                    ? colMap[current.parentId]
                    : null;
              }
              return segments.join(' › ');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 24),
                Text('Orte', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (dirPath.isNotEmpty)
                      ActionChip(
                        avatar: const Icon(Icons.folder_outlined, size: 14),
                        label: Text(
                          dirPath.split('/').last,
                          style: const TextStyle(fontSize: 11),
                        ),
                        tooltip: dirPath,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                        onPressed: () {
                          ref.read(assetFilterProvider.notifier)
                              .setDirFilter(dirPath, includeSubdirs: true);
                          context.pop();
                        },
                      ),
                    ...cols.map((c) => ActionChip(
                      avatar: const Icon(Icons.collections_bookmark_outlined, size: 14),
                      label: Text(
                        buildPath(c),
                        style: const TextStyle(fontSize: 11),
                      ),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.zero,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      onPressed: () {
                        ref.read(assetFilterProvider.notifier)
                            .setCollectionId(c.id);
                        context.pop();
                      },
                    )),
                  ],
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
      },
    );
  }
}

// ── Playlists this asset belongs to ──────────────────────────────────────────

class _AssetPlaylistsSection extends ConsumerWidget {
  const _AssetPlaylistsSection({required this.assetId});
  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Playlist>>(
      future: ref.watch(playlistsDaoProvider).getPlaylistsForAsset(assetId),
      builder: (context, snap) {
        final playlists = snap.data ?? [];
        if (playlists.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text('Playlists', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: playlists.map((p) {
                final isAudio = p.mediaType == 'audio';
                return ActionChip(
                  avatar: Icon(
                    isAudio
                        ? Icons.queue_music
                        : Icons.video_library_outlined,
                    size: 14,
                  ),
                  label: Text(p.name, style: const TextStyle(fontSize: 11)),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () =>
                      context.push('/library/playlist/${p.id}'),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}

// ── Custom Properties ─────────────────────────────────────────────────────────

class _CustomPropertiesSection extends ConsumerWidget {
  const _CustomPropertiesSection({required this.assetId});
  final String assetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defsAsync = ref.watch(propertyDefsProvider);
    final valuesAsync = ref.watch(assetPropertiesProvider(assetId));

    return defsAsync.when(
      data: (defs) {
        if (defs.isEmpty) return const SizedBox.shrink();
        return valuesAsync.when(
          data: (values) {
            final valueMap = {
              for (final v in values) v.propertyId: v.valueText ?? '',
            };
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 24),
                Text('Eigenschaften',
                    style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 8),
                ...defs.map((def) => _PropertyValueRow(
                      def: def,
                      assetId: assetId,
                      currentValue: valueMap[def.id] ?? '',
                    )),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, s) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}

class _PropertyValueRow extends ConsumerStatefulWidget {
  const _PropertyValueRow({
    required this.def,
    required this.assetId,
    required this.currentValue,
  });
  final PropertyDefinition def;
  final String assetId;
  final String currentValue;

  @override
  ConsumerState<_PropertyValueRow> createState() => _PropertyValueRowState();
}

class _PropertyValueRowState extends ConsumerState<_PropertyValueRow> {
  late TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.currentValue);
  }

  @override
  void didUpdateWidget(_PropertyValueRow old) {
    super.didUpdateWidget(old);
    if (old.currentValue != widget.currentValue &&
        !_ctrl.value.composing.isValid) {
      _ctrl.text = widget.currentValue;
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save(String value) async {
    await ref
        .read(propertiesDaoProvider)
        .setPropertyValue(widget.assetId, widget.def.id, value);
  }

  @override
  Widget build(BuildContext context) {
    final def = widget.def;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              def.name,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: _buildEditor(def)),
        ],
      ),
    );
  }

  Widget _buildEditor(PropertyDefinition def) {
    switch (def.fieldType) {
      case 'boolean':
        return Checkbox(
          value: widget.currentValue == 'true',
          onChanged: (v) => _save(v == true ? 'true' : ''),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );

      case 'select':
        final options = _parseOptions(def.optionsJson);
        return DropdownButtonFormField<String>(
          initialValue: widget.currentValue.isEmpty ? null : widget.currentValue,
          isDense: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem(value: '', child: Text('—')),
            ...options.map((o) => DropdownMenuItem(value: o, child: Text(o))),
          ],
          onChanged: (v) => _save(v ?? ''),
        );

      case 'multiselect':
        final options = _parseOptions(def.optionsJson);
        final selected =
            widget.currentValue.isEmpty ? <String>[] : widget.currentValue.split(',');
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: options.map((o) {
            final on = selected.contains(o);
            return FilterChip(
              label: Text(o, style: const TextStyle(fontSize: 11)),
              selected: on,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 6),
              onSelected: (v) {
                final next = {...selected};
                if (v) { next.add(o); } else { next.remove(o); }
                _save(next.join(','));
              },
            );
          }).toList(),
        );

      case 'tags':
        final selectedTags = _parseJsonList(widget.currentValue);
        final allTagsAsync = ref.watch(allTagsProvider);
        final allTagNames = allTagsAsync.valueOrNull
                ?.map((t) => t.tag.name)
                .toList() ??
            [];
        return Wrap(
          spacing: 4,
          runSpacing: 4,
          children: [
            ...selectedTags.map((tag) => Chip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  onDeleted: () {
                    final next = [...selectedTags]..remove(tag);
                    _save(jsonEncode(next));
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 6),
                )),
            ActionChip(
              avatar: const Icon(Icons.add, size: 14),
              label: const Text('Tag', style: TextStyle(fontSize: 11)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () => _addTagDialog(selectedTags, allTagNames),
            ),
          ],
        );

      case 'list':
        final items = _parseJsonList(widget.currentValue);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...items.asMap().entries.map((entry) {
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.value,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 14),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      final next = [...items]..removeAt(entry.key);
                      _save(jsonEncode(next));
                    },
                  ),
                ],
              );
            }),
            ActionChip(
              avatar: const Icon(Icons.add, size: 14),
              label: const Text('Hinzufügen', style: TextStyle(fontSize: 11)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () => _addListItemDialog(items),
            ),
          ],
        );

      default:
        // text, number, date, url
        return TextField(
          controller: _ctrl,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            suffixIcon: def.fieldType == 'url' && _ctrl.text.isNotEmpty
                ? const Icon(Icons.open_in_new, size: 16)
                : null,
          ),
          keyboardType: def.fieldType == 'number'
              ? TextInputType.number
              : TextInputType.text,
          style: Theme.of(context).textTheme.bodySmall,
          onSubmitted: _save,
          onEditingComplete: () => _save(_ctrl.text),
        );
    }
  }

  List<String> _parseOptions(String? json) {
    if (json == null) return [];
    try {
      return (jsonDecode(json) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  List<String> _parseJsonList(String value) {
    if (value.isEmpty) return [];
    try {
      return (jsonDecode(value) as List).cast<String>();
    } catch (_) {
      return [];
    }
  }

  Future<void> _addTagDialog(
      List<String> current, List<String> allTags) async {
    final ctrl = TextEditingController();
    final available = allTags.where((t) => !current.contains(t)).toList();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) {
          final query = ctrl.text.toLowerCase();
          final filtered = query.isEmpty
              ? available
              : available.where((t) => t.toLowerCase().contains(query)).toList();
          return AlertDialog(
            title: const Text('Tag hinzufügen'),
            content: SizedBox(
              width: 280,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: ctrl,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: 'Tag-Name',
                      isDense: true,
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setSt(() {}),
                    onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
                  ),
                  if (filtered.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView(
                        shrinkWrap: true,
                        children: filtered
                            .map((t) => ListTile(
                                  dense: true,
                                  title: Text(t),
                                  onTap: () => Navigator.pop(ctx, t),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Abbrechen'),
              ),
            ],
          );
        },
      ),
    );
    if (result == null || result.isEmpty) return;
    if (current.contains(result)) return;
    _save(jsonEncode([...current, result]));
  }

  Future<void> _addListItemDialog(List<String> current) async {
    final ctrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eintrag hinzufügen'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Eintrag',
            isDense: true,
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    _save(jsonEncode([...current, result]));
  }
}

class _ColorLabelPicker extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  static const _colors = {
    'red': Colors.red,
    'orange': Colors.orange,
    'yellow': Colors.yellow,
    'green': Colors.green,
    'blue': Colors.blue,
    'purple': Colors.purple,
  };

  const _ColorLabelPicker({this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Clear button
        GestureDetector(
          onTap: () => onChanged(null),
          child: Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey),
              color: value == null
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
                  : null,
            ),
            child: const Icon(Icons.close, size: 12),
          ),
        ),
        ..._colors.entries.map((e) => GestureDetector(
              onTap: () => onChanged(e.key),
              child: Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: e.value,
                  border: value == e.key
                      ? Border.all(
                          color: Theme.of(context).colorScheme.onSurface,
                          width: 2,
                        )
                      : null,
                ),
              ),
            )),
      ],
    );
  }
}
