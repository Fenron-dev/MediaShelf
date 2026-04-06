import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/plugin_interface.dart';
import '../../data/database/app_database.dart';
import '../../providers/asset_list_provider.dart';
import 'ui/screens/emuvr_import_screen.dart';
import 'ui/screens/emuvr_settings_page.dart';
import 'ui/widgets/emuvr_detail_section.dart';
import 'ui/widgets/emuvr_export_dialog.dart';

/// The EmuVR UGC Manager plugin for MediaShelf.
///
/// Adds:
/// - 3D preview + companion file list in the detail panel
/// - "Export to EmuVR" bulk toolbar action
/// - Import wizard (externer Ordner / Bibliotheks-Rescan)
/// - Settings page with EmuVR root path configuration
class EmuvrPlugin extends MediaShelfPlugin {
  EmuvrPlugin();

  @override
  String get id => 'emuvr_addon';

  @override
  String get displayName => 'EmuVR UGC Manager';

  @override
  String get description =>
      'Verwaltet EmuVR 3D-Modelle (OBJ/MTL/PNG), '
      'Vorschau und Export in EmuVR-Ordnerstruktur.';

  @override
  IconData get icon => Icons.videogame_asset_outlined;

  // ── Detail panel ───────────────────────────────────────────────────────────

  @override
  List<Widget> detailSections(Asset asset, WidgetRef ref) {
    // Show the section for all assets — EmuvrDetailSection handles
    // internally whether the asset belongs to a group.
    return [EmuvrDetailSection(asset: asset)];
  }

  // ── Bulk toolbar ──────────────────────────────────────────────────────────

  @override
  List<PluginBulkAction> bulkActions() {
    return [
      PluginBulkAction(
        icon: Icons.videogame_asset_outlined,
        tooltip: 'Nach EmuVR exportieren',
        onPressed: (context, ref, selectedIds) async {
          await showDialog<void>(
            context: context,
            builder: (_) => const EmuvrExportDialog(),
          );
          // Clear selection after dialog closes
          ref.read(multiSelectProvider.notifier).clear();
        },
      ),
    ];
  }

  // ── Settings ──────────────────────────────────────────────────────────────

  @override
  Widget? settingsPage(BuildContext context, WidgetRef ref) {
    return const EmuvrSettingsPage();
  }

  // ── Routes ────────────────────────────────────────────────────────────────

  @override
  List<RouteBase> routes() {
    return [
      GoRoute(
        path: 'emuvr/import',
        builder: (context, state) => const EmuvrImportScreen(),
      ),
    ];
  }
}
