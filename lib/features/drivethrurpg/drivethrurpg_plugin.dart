import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/plugin_interface.dart';
import '../../data/database/app_database.dart';
import 'ui/widgets/drivethrurpg_detail_section.dart';

/// Plugin that adds DriveThruRPG metadata lookup to the detail panel.
///
/// Shows a "DriveThruRPG" section for PDF and ePub assets with a search
/// button that opens a scrape / apply dialog.
class DriveThruRpgPlugin extends MediaShelfPlugin {
  DriveThruRpgPlugin();

  @override
  String get id => 'drivethrurpg_lookup';

  @override
  String get displayName => 'DriveThruRPG Lookup';

  @override
  String get description =>
      'Liest Metadaten (Titel, Autor, Verlag, Cover …) '
      'direkt von DriveThruRPG.com ein.';

  @override
  IconData get icon => Icons.travel_explore;

  @override
  List<Widget> detailSections(Asset asset, WidgetRef ref) =>
      [DriveThruRpgDetailSection(asset: asset)];

  @override
  List<PluginBulkAction> bulkActions() => [];

  @override
  Widget? settingsPage(BuildContext context, WidgetRef ref) => null;

  @override
  List<RouteBase> routes() => [];
}
