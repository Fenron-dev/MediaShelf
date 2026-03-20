import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/asset_filter.dart';
import '../../providers/asset_filter_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/tag_provider.dart';

class LibrarySidebar extends ConsumerWidget {
  const LibrarySidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: const [
        _LibrarySection(),
        Divider(height: 1),
        _TagsSection(),
        Divider(height: 1),
        _CollectionsSection(),
      ],
    );
  }
}

// ── Library / quick filters ────────────────────────────────────────────────

class _LibrarySection extends ConsumerWidget {
  const _LibrarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, 'Library'),
        _SidebarTile(
          icon: Icons.grid_view,
          label: 'All Assets',
          selected: !filter.hasActiveFilters,
          onTap: notifier.clearAll,
        ),
        _SidebarTile(
          icon: Icons.star_outline,
          label: 'Rated',
          selected: filter.ratingMin > 0,
          onTap: () => notifier.setRatingMin(filter.ratingMin > 0 ? 0 : 1),
        ),
        _SidebarTile(
          icon: Icons.play_circle_outline,
          label: 'In Progress',
          selected: filter.hasResume == ResumeFilter.hasResume,
          onTap: () => notifier.setHasResume(
            filter.hasResume == ResumeFilter.hasResume
                ? ResumeFilter.all
                : ResumeFilter.hasResume,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Tags ───────────────────────────────────────────────────────────────────

class _TagsSection extends ConsumerWidget {
  const _TagsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, 'Tags'),
        tagsAsync.when(
          data: (tags) => Column(
            children: tags.map((twc) {
              final selected = filter.tagFilter == twc.tag.name;
              return _SidebarTile(
                icon: Icons.label_outline,
                label: twc.tag.name,
                trailing: Text('${twc.count}',
                    style: Theme.of(context).textTheme.bodySmall),
                selected: selected,
                onTap: () => notifier.setTagFilter(selected ? null : twc.tag.name),
              );
            }).toList(),
          ),
          loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: LinearProgressIndicator()),
          error: (e, st) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Collections ────────────────────────────────────────────────────────────

class _CollectionsSection extends ConsumerWidget {
  const _CollectionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionHeader(context, 'Collections'),
        collectionsAsync.when(
          data: (cols) => Column(
            children: cols.map((c) {
              final selected = filter.collectionId == c.id;
              return _SidebarTile(
                icon: c.isSmartFilter
                    ? Icons.auto_awesome_outlined
                    : Icons.folder_outlined,
                label: c.name,
                selected: selected,
                onTap: () => notifier.setCollectionId(selected ? null : c.id),
              );
            }).toList(),
          ),
          loading: () => const SizedBox.shrink(),
          error: (e, st) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────

Widget _sectionHeader(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      title,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
    ),
  );
}

class _SidebarTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  const _SidebarTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(icon,
          size: 18, color: selected ? colorScheme.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? colorScheme.primary : null,
        ),
      ),
      trailing: trailing,
      selected: selected,
      selectedTileColor: colorScheme.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: onTap,
    );
  }
}
