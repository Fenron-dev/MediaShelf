import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kEmuvrRootPath = 'pref_emuvr_root_path';

/// Persists the EmuVR root directory path (e.g. C:\EmuVR).
/// Null = not configured.
class EmuvrRootPathNotifier extends StateNotifier<String?> {
  EmuvrRootPathNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_kEmuvrRootPath);
  }

  Future<void> set(String path) async {
    state = path;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kEmuvrRootPath, path);
  }

  Future<void> clear() async {
    state = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kEmuvrRootPath);
  }
}

final emuvrRootPathProvider =
    StateNotifierProvider<EmuvrRootPathNotifier, String?>(
  (ref) => EmuvrRootPathNotifier(),
);
