import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/models/asset_filter.dart';
import '../../providers/asset_filter_provider.dart';
import '../../providers/collection_provider.dart';
import '../../providers/folder_tree_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/tag_provider.dart';
import 'smart_filter_editor.dart';

// Prefs keys for section collapse state
const _kExpandFolders = 'sidebar_expand_folders';
const _kExpandSmart = 'sidebar_expand_smart';
const _kExpandCollections = 'sidebar_expand_collections';
const _kExpandTags = 'sidebar_expand_tags';

class LibrarySidebar extends ConsumerStatefulWidget {
  const LibrarySidebar({super.key});

  @override
  ConsumerState<LibrarySidebar> createState() => _LibrarySidebarState();
}

class _LibrarySidebarState extends ConsumerState<LibrarySidebar> {
  bool _expandFolders = true;
  bool _expandSmart = true;
  bool _expandCollections = true;
  bool _expandTags = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _expandFolders = prefs.getBool(_kExpandFolders) ?? true;
      _expandSmart = prefs.getBool(_kExpandSmart) ?? true;
      _expandCollections = prefs.getBool(_kExpandCollections) ?? true;
      _expandTags = prefs.getBool(_kExpandTags) ?? true;
    });
  }

  void _toggle(String key, bool current, void Function(bool) setter) async {
    final next = !current;
    setter(next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, next);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        const _LibrarySection(),
        const Divider(height: 1),

        // ── Ordner ──────────────────────────────────────────────────────────
        _CollapsibleSection(
          title: 'Ordner',
          expanded: _expandFolders,
          onToggle: () => setState(() =>
              _toggle(_kExpandFolders, _expandFolders, (v) => _expandFolders = v)),
          child: const _FolderTreeSection(),
        ),
        const Divider(height: 1),

        // ── Smarte Ordner ────────────────────────────────────────────────────
        _CollapsibleSection(
          title: 'Smarte Ordner',
          expanded: _expandSmart,
          onToggle: () => setState(() =>
              _toggle(_kExpandSmart, _expandSmart, (v) => _expandSmart = v)),
          trailing: IconButton(
            icon: const Icon(Icons.auto_awesome_outlined, size: 16),
            tooltip: 'Neuer smarter Ordner',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => showSmartFilterEditor(context, ref),
          ),
          child: const _SmartFiltersSection(),
        ),
        const Divider(height: 1),

        // ── Sammlungen ───────────────────────────────────────────────────────
        _CollapsibleSection(
          title: 'Sammlungen',
          expanded: _expandCollections,
          onToggle: () => setState(() => _toggle(
              _kExpandCollections, _expandCollections, (v) => _expandCollections = v)),
          trailing: IconButton(
            icon: const Icon(Icons.create_new_folder_outlined, size: 16),
            tooltip: 'Neue Sammlung',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            onPressed: () => _createCollection(context, ref),
          ),
          child: const _ManualCollectionsSection(),
        ),
        const Divider(height: 1),

        // ── Tags ─────────────────────────────────────────────────────────────
        _CollapsibleSection(
          title: 'Tags',
          expanded: _expandTags,
          onToggle: () => setState(() =>
              _toggle(_kExpandTags, _expandTags, (v) => _expandTags = v)),
          child: const _TagsSection(),
        ),
      ],
    );
  }

  Future<void> _createCollection(BuildContext ctx, WidgetRef ref) async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: ctx,
      builder: (context) => AlertDialog(
        title: const Text('Neue Sammlung'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name der Sammlung'),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Abbrechen')),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text),
            child: const Text('Erstellen'),
          ),
        ],
      ),
    );
    if (name == null || name.trim().isEmpty) return;
    final dao = ref.read(collectionsDaoProvider);
    await dao.createCollection(id: const Uuid().v4(), name: name.trim());
  }
}

// ── Top-level Library quick-filters (always visible) ─────────────────────────

class _LibrarySection extends ConsumerWidget {
  const _LibrarySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionLabel(context, 'Bibliothek'),
        _SidebarTile(
          icon: Icons.grid_view,
          label: 'Alle Assets',
          selected: !filter.hasActiveFilters,
          onTap: notifier.clearAll,
        ),
        _SidebarTile(
          icon: Icons.star_outline,
          label: 'Bewertet',
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
        const SizedBox(height: 4),
      ],
    );
  }
}

// ── Folder tree ───────────────────────────────────────────────────────────────

class _FolderTreeSection extends ConsumerWidget {
  const _FolderTreeSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeAsync = ref.watch(folderTreeProvider);
    final filter = ref.watch(assetFilterProvider);

    return treeAsync.when(
      data: (roots) => roots.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Keine Ordner',
                  style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            )
          : Column(
              children: roots
                  .map((node) => _FolderTile(
                        node: node,
                        depth: 0,
                        activeDir: filter.dirFilter,
                      ))
                  .toList(),
            ),
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

class _FolderTile extends ConsumerStatefulWidget {
  const _FolderTile({
    required this.node,
    required this.depth,
    required this.activeDir,
  });

  final FolderNode node;
  final int depth;
  final String? activeDir;

  @override
  ConsumerState<_FolderTile> createState() => _FolderTileState();
}

class _FolderTileState extends ConsumerState<_FolderTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasChildren = widget.node.children.isNotEmpty;
    final nodeDir = widget.node.fullPath.endsWith('/')
        ? widget.node.fullPath.substring(0, widget.node.fullPath.length - 1)
        : widget.node.fullPath;
    final selected = widget.activeDir == nodeDir;
    final indent = 12.0 + widget.depth * 14.0;

    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.only(left: indent, right: 4),
          leading: Icon(
            hasChildren
                ? (_expanded
                    ? Icons.folder_open_outlined
                    : Icons.folder_outlined)
                : Icons.folder_outlined,
            size: 18,
            color: selected ? cs.primary : null,
          ),
          title: Text(
            widget.node.name,
            style: TextStyle(
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? cs.primary : null,
            ),
          ),
          trailing: hasChildren
              ? IconButton(
                  icon: Icon(
                    _expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: () => setState(() => _expanded = !_expanded),
                )
              : null,
          selected: selected,
          selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
          onTap: () {
            final notifier = ref.read(assetFilterProvider.notifier);
            if (selected) {
              notifier.clearDirFilter();
            } else {
              // fullPath ends with '/', strip it for the filter
              final dir = widget.node.fullPath.endsWith('/')
                  ? widget.node.fullPath.substring(
                      0, widget.node.fullPath.length - 1)
                  : widget.node.fullPath;
              notifier.setDirFilter(dir, includeSubdirs: true);
            }
          },
        ),
        if (_expanded && hasChildren)
          ...widget.node.children.map((child) => _FolderTile(
                node: child,
                depth: widget.depth + 1,
                activeDir: widget.activeDir,
              )),
      ],
    );
  }
}

// ── Smart filters ─────────────────────────────────────────────────────────────

class _SmartFiltersSection extends ConsumerWidget {
  const _SmartFiltersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return collectionsAsync.when(
      data: (cols) {
        final smart = cols.where((c) => c.isSmartFilter).toList();
        if (smart.isEmpty) return const SizedBox.shrink();
        return Column(
          children: smart.map((c) {
            final selected = filter.collectionId == c.id;
            return _SidebarTile(
              icon: Icons.auto_awesome_outlined,
              label: c.name,
              selected: selected,
              onTap: () => notifier.setCollectionId(selected ? null : c.id),
              onLongPress: () =>
                  showSmartFilterEditor(context, ref, existing: c),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

// ── Manual collections ────────────────────────────────────────────────────────

class _ManualCollectionsSection extends ConsumerWidget {
  const _ManualCollectionsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return collectionsAsync.when(
      data: (cols) {
        final manual = cols.where((c) => !c.isSmartFilter).toList();
        if (manual.isEmpty) return const SizedBox.shrink();
        return Column(
          children: manual.map((c) {
            final selected = filter.collectionId == c.id;
            return _SidebarTile(
              icon: Icons.folder_outlined,
              label: c.name,
              selected: selected,
              onTap: () => notifier.setCollectionId(selected ? null : c.id),
            );
          }).toList(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

// ── Tags ──────────────────────────────────────────────────────────────────────

class _TagsSection extends ConsumerWidget {
  const _TagsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsAsync = ref.watch(allTagsProvider);
    final filter = ref.watch(assetFilterProvider);
    final notifier = ref.read(assetFilterProvider.notifier);

    return tagsAsync.when(
      data: (tags) => Column(
        children: tags.map((twc) {
          final selected = filter.tagFilter == twc.tag.name;
          return _SidebarTile(
            icon: Icons.label_outline,
            label: twc.tag.name,
            trailing: Text('${twc.count}',
                style: Theme.of(context).textTheme.bodySmall),
            selected: selected,
            onTap: () =>
                notifier.setTagFilter(selected ? null : twc.tag.name),
          );
        }).toList(),
      ),
      loading: () => const Padding(
          padding: EdgeInsets.all(16),
          child: LinearProgressIndicator()),
      error: (e, _) => const SizedBox.shrink(),
    );
  }
}

// ── Collapsible section wrapper ───────────────────────────────────────────────

class _CollapsibleSection extends StatelessWidget {
  const _CollapsibleSection({
    required this.title,
    required this.expanded,
    required this.onToggle,
    required this.child,
    this.trailing,
  });

  final String title;
  final bool expanded;
  final VoidCallback onToggle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: cs.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: onToggle,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 4, 6),
            child: Row(
              children: [
                Icon(
                  expanded ? Icons.expand_more : Icons.chevron_right,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Expanded(child: Text(title.toUpperCase(), style: labelStyle)),
                ?trailing,
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: child,
          secondChild: const SizedBox.shrink(),
          crossFadeState: expanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

Widget _sectionLabel(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
    child: Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
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
  final VoidCallback? onLongPress;

  const _SidebarTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: selected ? cs.primary : null),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? cs.primary : null,
        ),
      ),
      trailing: trailing,
      selected: selected,
      selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}
