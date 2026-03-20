import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

// ── Preference keys ───────────────────────────────────────────────────────────
const _kThumbSize = 'pref_thumb_size';
const _kShowSidebar = 'pref_show_sidebar';
const _kShowDetail = 'pref_show_detail';

enum ViewMode { grid, list }

// ── Thumbnail size ────────────────────────────────────────────────────────────

class ThumbnailSizeNotifier extends StateNotifier<double> {
  ThumbnailSizeNotifier() : super(kDefaultThumbnailSize) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_kThumbSize);
    if (saved != null) state = saved;
  }

  void set(double size) async {
    state = size.clamp(80.0, 400.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kThumbSize, state);
  }
}

final thumbnailSizeProvider =
    StateNotifierProvider<ThumbnailSizeNotifier, double>(
  (ref) => ThumbnailSizeNotifier(),
);

// ── View mode ─────────────────────────────────────────────────────────────────

final viewModeProvider = StateProvider<ViewMode>((ref) => ViewMode.grid);

// ── Sidebar / detail panel visibility ────────────────────────────────────────

class _BoolPrefNotifier extends StateNotifier<bool> {
  final String _key;
  _BoolPrefNotifier(this._key, bool defaultValue) : super(defaultValue) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getBool(_key);
    if (saved != null) state = saved;
  }

  @override
  set state(bool value) {
    super.state = value;
    SharedPreferences.getInstance()
        .then((p) => p.setBool(_key, value));
  }
}

final showSidebarProvider =
    StateNotifierProvider<_BoolPrefNotifier, bool>(
  (ref) => _BoolPrefNotifier(_kShowSidebar, true),
);

final showDetailPanelProvider =
    StateNotifierProvider<_BoolPrefNotifier, bool>(
  (ref) => _BoolPrefNotifier(_kShowDetail, true),
);
