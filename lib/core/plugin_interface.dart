import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/database/app_database.dart';

/// Describes a single action the plugin adds to the bulk toolbar.
class PluginBulkAction {
  final IconData icon;
  final String tooltip;
  final Future<void> Function(
    BuildContext context,
    WidgetRef ref,
    Set<String> selectedIds,
  ) onPressed;

  const PluginBulkAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
}

/// Abstract base class for MediaShelf feature plugins.
///
/// To register a plugin, call [registerPlugin] in main() before runApp().
/// Plugins can be enabled/disabled by the user in Settings → Plugins.
abstract class MediaShelfPlugin {
  /// Unique identifier — also used as SharedPreferences key.
  String get id;

  /// Display name shown in Settings → Plugins.
  String get displayName;

  /// Short description shown beneath the display name.
  String get description;

  /// Icon shown next to the plugin name.
  IconData get icon;

  /// Widgets injected into the detail panel after the Linked Assets section.
  /// Return an empty list if this plugin has nothing to show for [asset].
  List<Widget> detailSections(Asset asset, WidgetRef ref);

  /// Actions added to the bulk toolbar between Export and Delete.
  List<PluginBulkAction> bulkActions();

  /// Optional settings page for the plugin.
  /// Shown when the user taps the settings button next to the plugin toggle.
  Widget? settingsPage(BuildContext context, WidgetRef ref);

  /// GoRouter sub-routes added under /library/.
  List<RouteBase> routes();
}
