import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'plugin_interface.dart';

// ── Plugin registration ───────────────────────────────────────────────────────

/// Global list populated by [registerPlugin] calls in main().
final _registeredPlugins = <MediaShelfPlugin>[];

/// Registers a plugin. Must be called before runApp().
void registerPlugin(MediaShelfPlugin plugin) {
  _registeredPlugins.add(plugin);
}

/// All registered plugins, in registration order.
List<MediaShelfPlugin> get registeredPlugins =>
    List.unmodifiable(_registeredPlugins);

// ── Enabled / disabled state ─────────────────────────────────────────────────

String _enabledKey(String pluginId) => 'plugin_enabled_$pluginId';

class PluginEnabledNotifier extends StateNotifier<Map<String, bool>> {
  PluginEnabledNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final plugin in _registeredPlugins) {
      map[plugin.id] = prefs.getBool(_enabledKey(plugin.id)) ?? true;
    }
    state = map;
  }

  /// Toggles a plugin on or off. Change is persisted immediately.
  void setEnabled(String pluginId, bool enabled) {
    state = {...state, pluginId: enabled};
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_enabledKey(pluginId), enabled));
  }

  bool isEnabled(String pluginId) => state[pluginId] ?? true;
}

final pluginEnabledProvider =
    StateNotifierProvider<PluginEnabledNotifier, Map<String, bool>>(
  (ref) => PluginEnabledNotifier(),
);

/// Derived provider — the list of currently enabled plugins.
final enabledPluginsProvider = Provider<List<MediaShelfPlugin>>((ref) {
  final enabledMap = ref.watch(pluginEnabledProvider);
  return _registeredPlugins
      .where((p) => enabledMap[p.id] ?? true)
      .toList();
});
