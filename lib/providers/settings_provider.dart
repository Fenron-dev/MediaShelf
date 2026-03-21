import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants.dart';

// ── Preference keys ───────────────────────────────────────────────────────────
const _kThumbSize = 'pref_thumb_size';
const _kShowSidebar = 'pref_show_sidebar';
const _kShowDetail = 'pref_show_detail';
const _kSidebarWidth = 'pref_sidebar_width';
const _kDetailPanelWidth = 'pref_detail_panel_width';

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

// ── Panel widths (persistent, draggable) ──────────────────────────────────────

class _DoublePrefNotifier extends StateNotifier<double> {
  final String _key;
  final double _min;
  final double _max;

  _DoublePrefNotifier(this._key, double defaultValue, this._min, this._max)
      : super(defaultValue) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_key);
    if (saved != null) state = saved.clamp(_min, _max);
  }

  void set(double value) {
    state = value.clamp(_min, _max);
    SharedPreferences.getInstance().then((p) => p.setDouble(_key, state));
  }
}

final sidebarWidthProvider =
    StateNotifierProvider<_DoublePrefNotifier, double>(
  (ref) => _DoublePrefNotifier(_kSidebarWidth, kSidebarWidth, 150.0, 520.0),
);

final detailPanelWidthProvider =
    StateNotifierProvider<_DoublePrefNotifier, double>(
  (ref) => _DoublePrefNotifier(
      _kDetailPanelWidth, kDetailPanelWidth, 200.0, 600.0),
);
