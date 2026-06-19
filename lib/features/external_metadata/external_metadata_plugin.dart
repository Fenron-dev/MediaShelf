import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/plugin_interface.dart';
import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';
import 'ui/external_metadata_lookup_dialog.dart';

class ExternalMetadataPlugin extends MediaShelfPlugin {
  ExternalMetadataPlugin();

  @override
  String get id => 'external_metadata_lookup';

  @override
  String get displayName => 'External Metadata Lookup';

  @override
  String get description =>
      'Lädt Metadaten aus AniList, BoardGameGeek, VideoGameGeek und RPGGeek '
      'in bestehende Asset-Felder.';

  @override
  IconData get icon => Icons.cloud_download_outlined;

  @override
  List<Widget> detailSections(Asset asset, WidgetRef ref) {
    return [_ExternalMetadataDetailSection(asset: asset)];
  }

  @override
  List<PluginBulkAction> bulkActions() => const [];

  @override
  Widget? settingsPage(BuildContext context, WidgetRef ref) => null;

  @override
  List<RouteBase> routes() => const [];
}

class _ExternalMetadataDetailSection extends ConsumerWidget {
  const _ExternalMetadataDetailSection({required this.asset});

  final Asset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasKnownSource = asset.sourceUrl != null &&
        (asset.sourceUrl!.contains('anilist.co') ||
            asset.sourceUrl!.contains('boardgamegeek.com') ||
            asset.sourceUrl!.contains('videogamegeek.com') ||
            asset.sourceUrl!.contains('rpggeek.com'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            const Icon(Icons.cloud_download_outlined, size: 16),
            const SizedBox(width: 6),
            Text(
              'Externe Metadaten',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasKnownSource) ...[
          Text(
            asset.sourceUrl!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton.icon(
          icon: const Icon(Icons.search, size: 16),
          label: Text(hasKnownSource ? 'Aktualisieren' : 'Metadaten suchen'),
          onPressed: () => showExternalMetadataLookupDialog(
            context,
            asset: asset,
            onApplied: () => ref.invalidate(assetsDaoProvider),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
