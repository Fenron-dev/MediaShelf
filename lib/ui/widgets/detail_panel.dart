import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers/asset_list_provider.dart';
import '../../providers/library_provider.dart';
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

        // Metadata
        if (asset.mimeType != null)
          _MetaRow('Type', asset.mimeType!),
        if (asset.size != null)
          _MetaRow('Size', _formatSize(asset.size!)),
        if (asset.width != null && asset.height != null)
          _MetaRow('Dimensions', '${asset.width} × ${asset.height}'),
        if (asset.durationMs != null)
          _MetaRow('Duration', _formatDuration(asset.durationMs!)),
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

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  String _formatDuration(int ms) {
    final d = Duration(milliseconds: ms);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
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
