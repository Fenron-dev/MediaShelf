import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/mime_resolver.dart';
import '../../../../data/database/app_database.dart';
import '../../../../providers/library_provider.dart';
import '../dialogs/drivethrurpg_search_dialog.dart';

/// Injected into the detail panel for PDF and ePub assets.
///
/// Shows the stored DriveThruRPG product URL (if any) and a button to open
/// the lookup / search dialog.
class DriveThruRpgDetailSection extends ConsumerWidget {
  const DriveThruRpgDetailSection({super.key, required this.asset});
  final Asset asset;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show for document-type assets
    final cat = categoryFromMime(asset.mimeType ?? '');
    final isPdf = asset.mimeType == 'application/pdf' ||
        asset.filename.toLowerCase().endsWith('.pdf');
    final isEpub = asset.mimeType == 'application/epub+zip' ||
        asset.filename.toLowerCase().endsWith('.epub');
    if (!isPdf && !isEpub && cat != MimeCategory.document) {
      return const SizedBox.shrink();
    }

    final hasDtUrl = asset.sourceUrl != null &&
        asset.sourceUrl!.contains('drivethrurpg.com');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        Row(
          children: [
            const Icon(Icons.travel_explore, size: 16),
            const SizedBox(width: 6),
            Text(
              'DriveThruRPG',
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (hasDtUrl) ...[
          // Show the linked product URL
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
          label: Text(hasDtUrl ? 'Metadaten aktualisieren' : 'Metadaten suchen'),
          onPressed: () => showDriveThruRpgDialog(
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
