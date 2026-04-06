import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/database/app_database.dart';
import '../../../../providers/asset_list_provider.dart';
import '../../../../providers/library_provider.dart';
import '../../providers/emuvr_group_provider.dart';
import 'obj_3d_preview.dart';

/// Injected into the detail panel for any asset that is part of an EmuVR group.
///
/// For .obj primary assets: shows a tabbed "3D Preview" + "Dateien" view.
/// For companion assets (.mtl, .png, .ini): shows a chip linking back to
/// the group's primary .obj asset.
class EmuvrDetailSection extends ConsumerWidget {
  const EmuvrDetailSection({super.key, required this.asset});
  final Asset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupAsync = ref.watch(emuvrGroupProvider(asset.id));

    return groupAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (group) {
        if (group == null) return const SizedBox.shrink();

        final libraryPath = ref.watch(libraryPathProvider) ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.videogame_asset_outlined, size: 16),
                const SizedBox(width: 6),
                Text(
                  'EmuVR Asset',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // If this is a companion, show a back-link to the primary
            if (asset.id != group.objAsset.id)
              _CompanionBackLink(
                primaryAsset: group.objAsset,
                onTap: () => ref
                    .read(selectedAssetIdProvider.notifier)
                    .state = group.objAsset.id,
              )
            else
              _PrimaryView(
                group: group,
                libraryPath: libraryPath,
              ),
          ],
        );
      },
    );
  }
}

// ── Primary asset view (tabs) ─────────────────────────────────────────────────

class _PrimaryView extends StatefulWidget {
  const _PrimaryView({required this.group, required this.libraryPath});
  final dynamic group; // EmuvrAssetGroup
  final String libraryPath;

  @override
  State<_PrimaryView> createState() => _PrimaryViewState();
}

class _PrimaryViewState extends State<_PrimaryView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final objPath =
        '${widget.libraryPath}${Platform.pathSeparator}${group.objAsset.path}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: '3D Vorschau'),
            Tab(text: 'Dateien'),
          ],
          labelStyle: Theme.of(context).textTheme.labelSmall,
          isScrollable: false,
          dividerColor: Colors.transparent,
        ),
        SizedBox(
          height: 220,
          child: TabBarView(
            controller: _tabs,
            children: [
              // Tab 1: 3D preview
              Obj3dPreview(objPath: objPath),

              // Tab 2: File list
              _FileList(group: group),
            ],
          ),
        ),
      ],
    );
  }
}

// ── File list tab ─────────────────────────────────────────────────────────────

class _FileList extends StatelessWidget {
  const _FileList({required this.group});
  final dynamic group; // EmuvrAssetGroup

  @override
  Widget build(BuildContext context) {
    final all = group.all as List;
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: all.length,
      itemBuilder: (context, i) {
        final a = all[i] as Asset;
        final isPrimary = a.id == group.objAsset.id;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(
            _iconForExtension(a.extension ?? ''),
            size: 16,
            color: isPrimary
                ? Theme.of(context).colorScheme.primary
                : null,
          ),
          title: Text(
            a.filename,
            style: TextStyle(
              fontSize: 12,
              fontWeight:
                  isPrimary ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            a.extension?.toUpperCase() ?? '?',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        );
      },
    );
  }

  IconData _iconForExtension(String ext) => switch (ext) {
        'obj' => Icons.view_in_ar_outlined,
        'mtl' => Icons.palette_outlined,
        'png' || 'jpg' || 'jpeg' => Icons.image_outlined,
        'ini' => Icons.settings_outlined,
        _ => Icons.insert_drive_file_outlined,
      };
}

// ── Companion back-link ───────────────────────────────────────────────────────

class _CompanionBackLink extends StatelessWidget {
  const _CompanionBackLink({
    required this.primaryAsset,
    required this.onTap,
  });
  final Asset primaryAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.view_in_ar_outlined, size: 14),
      label: Text(
        'Teil von: ${primaryAsset.filename}',
        style: const TextStyle(fontSize: 11),
      ),
      onPressed: onTap,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: EdgeInsets.zero,
    );
  }
}
