import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/asset_list_provider.dart';
import '../../providers/library_provider.dart';

/// Animated toolbar that appears at the bottom of the screen during
/// multi-select mode. Provides bulk tag, rating, color, collection, and
/// delete operations on the currently selected assets.
class BulkToolbar extends ConsumerWidget {
  const BulkToolbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIds = ref.watch(multiSelectProvider);
    final isVisible = selectedIds.isNotEmpty;

    return AnimatedSlide(
      offset: isVisible ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1 : 0,
        duration: const Duration(milliseconds: 150),
        child: Material(
          elevation: 8,
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  // Selection count + clear
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Clear selection',
                    onPressed: () =>
                        ref.read(multiSelectProvider.notifier).clear(),
                  ),
                  Text(
                    '${selectedIds.length} selected',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const Spacer(),

                  // Rating
                  IconButton(
                    icon: const Icon(Icons.star_outline),
                    tooltip: 'Set rating',
                    onPressed: () => _showRatingDialog(context, ref, selectedIds),
                  ),

                  // Color label
                  IconButton(
                    icon: const Icon(Icons.circle_outlined),
                    tooltip: 'Set color label',
                    onPressed: () =>
                        _showColorDialog(context, ref, selectedIds),
                  ),

                  // Tag
                  IconButton(
                    icon: const Icon(Icons.label_outline),
                    tooltip: 'Add tag',
                    onPressed: () => _showTagDialog(context, ref, selectedIds),
                  ),

                  // Delete
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Theme.of(context).colorScheme.error),
                    tooltip: 'Remove from library',
                    onPressed: () =>
                        _showDeleteDialog(context, ref, selectedIds),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  Future<void> _showRatingDialog(
    BuildContext ctx,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    int? picked;
    await showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Set Rating'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(6, (i) {
              return GestureDetector(
                onTap: () => setState(() => picked = i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Icon(
                    i == 0
                        ? Icons.star_border
                        : (i <= (picked ?? -1)
                            ? Icons.star
                            : Icons.star_border),
                    color: Colors.amber,
                    size: 28,
                  ),
                ),
              );
            }),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: picked == null ? null : () => Navigator.pop(context),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
    if (picked == null) return;
    final dao = ref.read(assetsDaoProvider);
    for (final id in ids) {
      await dao.updateMeta(id: id, rating: Value(picked!));
    }
    ref.read(scanVersionProvider.notifier).state++;
    ref.read(multiSelectProvider.notifier).clear();
  }

  Future<void> _showColorDialog(
    BuildContext ctx,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    const colors = {
      'red': Colors.red,
      'orange': Colors.orange,
      'yellow': Colors.yellow,
      'green': Colors.green,
      'blue': Colors.blue,
      'purple': Colors.purple,
    };
    await showDialog(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Set Color Label'),
        content: StatefulBuilder(
          builder: (context, setState) => Wrap(
            spacing: 8,
            children: [
              // Clear option
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _applyColor(ref, ids, null);
                },
                child: const CircleAvatar(
                  backgroundColor: Colors.grey,
                  child: Icon(Icons.close, size: 16),
                ),
              ),
              ...colors.entries.map((e) => GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _applyColor(ref, ids, e.key);
                    },
                    child: CircleAvatar(backgroundColor: e.value, radius: 16),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyColor(WidgetRef ref, Set<String> ids, String? color) async {
    final dao = ref.read(assetsDaoProvider);
    for (final id in ids) {
      await dao.updateMeta(id: id, colorLabel: Value(color));
    }
    ref.read(scanVersionProvider.notifier).state++;
    ref.read(multiSelectProvider.notifier).clear();
  }

  Future<void> _showTagDialog(
    BuildContext ctx,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag to selected'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Tag name'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (result == null || result.trim().isEmpty) return;
    final tagsDao = ref.read(tagsDaoProvider);
    final tagId = await tagsDao.upsertTag(result.trim());
    final assetsDao = ref.read(assetsDaoProvider);
    for (final assetId in ids) {
      await assetsDao.addTagToAsset(assetId, tagId);
    }
    ref.read(multiSelectProvider.notifier).clear();
  }

  Future<void> _showDeleteDialog(
    BuildContext ctx,
    WidgetRef ref,
    Set<String> ids,
  ) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Remove from library?'),
        content: Text(
          'Remove ${ids.length} asset${ids.length == 1 ? '' : 's'} from the index.\n'
          'Files on disk will not be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final dao = ref.read(assetsDaoProvider);
    for (final id in ids) {
      await dao.deleteById(id);
    }
    ref.read(scanVersionProvider.notifier).state++;
    ref.read(multiSelectProvider.notifier).clear();
  }
}
