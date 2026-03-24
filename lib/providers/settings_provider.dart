import 'dart:convert';

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

// ── List view columns ────────────────────────────────────────────────────────

/// Columns available in the list view.
enum ListColumn {
  name('Name'),
  type('Typ'),
  size('Größe'),
  duration('Dauer / Seiten'),
  rating('Bewertung'),
  modified('Geändert'),
  artist('Künstler'),
  album('Album'),
  genre('Genre'),
  bitrate('Bitrate'),
  sampleRate('Sample-Rate'),
  resolution('Auflösung'),
  author('Autor'),
  publisher('Verlag'),
  captureDate('Jahr / Datum');

  const ListColumn(this.label);
  final String label;
}

const _kListColumns = 'pref_list_columns';

/// Default columns shown in list view.
const _defaultListColumns = [
  ListColumn.name,
  ListColumn.type,
  ListColumn.size,
  ListColumn.duration,
  ListColumn.rating,
  ListColumn.modified,
];

class ListColumnsNotifier extends StateNotifier<List<ListColumn>> {
  ListColumnsNotifier() : super(_defaultListColumns) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kListColumns);
    if (json == null) return;
    try {
      final keys = (jsonDecode(json) as List).cast<String>();
      final cols = keys
          .map((k) {
            try {
              return ListColumn.values.firstWhere((c) => c.name == k);
            } catch (_) {
              return null;
            }
          })
          .whereType<ListColumn>()
          .toList();
      if (cols.isNotEmpty) state = cols;
    } catch (_) {}
  }

  void setColumns(List<ListColumn> columns) {
    state = columns;
    _persist();
  }

  void addColumn(ListColumn col) {
    if (state.contains(col)) return;
    state = [...state, col];
    _persist();
  }

  void removeColumn(ListColumn col) {
    state = state.where((c) => c != col).toList();
    _persist();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final cols = List.of(state);
    final item = cols.removeAt(oldIndex);
    cols.insert(newIndex, item);
    state = cols;
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kListColumns, jsonEncode(state.map((c) => c.name).toList()));
  }
}

final listColumnsProvider =
    StateNotifierProvider<ListColumnsNotifier, List<ListColumn>>(
  (ref) => ListColumnsNotifier(),
);
