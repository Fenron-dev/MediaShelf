import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'library_provider.dart';

// ── Model ─────────────────────────────────────────────────────────────────────

/// All possible metadata fields that can be shown in the detail panel.
enum MetadataField {
  mimeType('Typ', 'mimeType'),
  size('Größe', 'size'),
  mediaTitle('Titel', 'mediaTitle'),
  artist('Künstler / Regisseur', 'artist'),
  album('Album', 'album'),
  genre('Genre', 'genre'),
  trackNumber('Track-Nr.', 'trackNumber'),
  captureDate('Jahr / Datum', 'captureDate'),
  durationMs('Dauer', 'durationMs'),
  bitrate('Bitrate', 'bitrate'),
  sampleRate('Sample-Rate', 'sampleRate'),
  width('Breite', 'width'),
  height('Höhe', 'height'),
  resolution('Auflösung', 'resolution'),
  cameraModel('Kamera', 'cameraModel'),
  author('Autor', 'author'),
  publisher('Verlag', 'publisher'),
  pageCount('Seiten', 'pageCount'),
  sourceUrl('Quell-URL', 'sourceUrl'),
  note('Notiz', 'note');

  const MetadataField(this.label, this.key);
  final String label;
  final String key;
}

/// A media type category for template configuration.
enum MediaCategory {
  audio('Audio'),
  video('Video'),
  image('Bild'),
  documentPdf('PDF'),
  documentEbook('E-Book'),
  documentOther('Dokument'),
  text('Text'),
  archive('Archiv'),
  other('Sonstige');

  const MediaCategory(this.label);
  final String label;
}

/// Configuration for a single media type template.
class MediaTemplateConfig {
  const MediaTemplateConfig({required this.fields});

  final List<MetadataField> fields;

  Map<String, dynamic> toJson() => {
        'fields': fields.map((f) => f.key).toList(),
      };

  factory MediaTemplateConfig.fromJson(Map<String, dynamic> json) {
    final fieldKeys = (json['fields'] as List?)?.cast<String>() ?? [];
    final fields = fieldKeys
        .map((k) {
          try {
            return MetadataField.values.firstWhere((f) => f.key == k);
          } catch (_) {
            return null;
          }
        })
        .whereType<MetadataField>()
        .toList();
    return MediaTemplateConfig(fields: fields);
  }
}

/// All templates keyed by media category.
class MediaTemplatesState {
  const MediaTemplatesState({required this.templates});

  final Map<MediaCategory, MediaTemplateConfig> templates;

  MediaTemplateConfig getTemplate(MediaCategory category) =>
      templates[category] ?? _defaults[category]!;

  Map<String, dynamic> toJson() => {
        'templates': templates.map(
            (k, v) => MapEntry(k.name, v.toJson())),
      };

  factory MediaTemplatesState.fromJson(Map<String, dynamic> json) {
    final templatesJson =
        (json['templates'] as Map<String, dynamic>?) ?? {};
    final templates = <MediaCategory, MediaTemplateConfig>{};
    for (final entry in templatesJson.entries) {
      try {
        final cat =
            MediaCategory.values.firstWhere((c) => c.name == entry.key);
        templates[cat] = MediaTemplateConfig.fromJson(
            entry.value as Map<String, dynamic>);
      } catch (_) {}
    }
    return MediaTemplatesState(templates: templates);
  }

  MediaTemplatesState copyWithTemplate(
      MediaCategory category, MediaTemplateConfig config) {
    return MediaTemplatesState(
        templates: {...templates, category: config});
  }

  static const _defaults = <MediaCategory, MediaTemplateConfig>{
    MediaCategory.audio: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
      MetadataField.mediaTitle,
      MetadataField.artist,
      MetadataField.album,
      MetadataField.genre,
      MetadataField.trackNumber,
      MetadataField.captureDate,
      MetadataField.durationMs,
      MetadataField.bitrate,
      MetadataField.sampleRate,
    ]),
    MediaCategory.video: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
      MetadataField.mediaTitle,
      MetadataField.artist,
      MetadataField.durationMs,
      MetadataField.resolution,
      MetadataField.bitrate,
      MetadataField.captureDate,
    ]),
    MediaCategory.image: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
      MetadataField.resolution,
      MetadataField.cameraModel,
      MetadataField.captureDate,
    ]),
    MediaCategory.documentPdf: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
      MetadataField.mediaTitle,
      MetadataField.author,
      MetadataField.publisher,
      MetadataField.pageCount,
      MetadataField.captureDate,
    ]),
    MediaCategory.documentEbook: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
      MetadataField.mediaTitle,
      MetadataField.author,
      MetadataField.publisher,
      MetadataField.pageCount,
      MetadataField.captureDate,
    ]),
    MediaCategory.documentOther: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
      MetadataField.author,
    ]),
    MediaCategory.text: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
    ]),
    MediaCategory.archive: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
    ]),
    MediaCategory.other: MediaTemplateConfig(fields: [
      MetadataField.mimeType,
      MetadataField.size,
    ]),
  };

  static MediaTemplatesState get defaults =>
      MediaTemplatesState(templates: Map.of(_defaults));
}

// ── Notifier ──────────────────────────────────────────────────────────────────

const _kGlobalKey = 'mediashelf_templates_global';
String _libraryKey(String path) => 'mediashelf_templates_$path';

class MediaTemplatesNotifier extends StateNotifier<MediaTemplatesState> {
  MediaTemplatesNotifier(this._ref)
      : super(MediaTemplatesState.defaults) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final libraryPath = _ref.read(libraryPathProvider);

    // Try library-specific first, then global, then defaults
    if (libraryPath != null) {
      final libJson = prefs.getString(_libraryKey(libraryPath));
      if (libJson != null) {
        try {
          state = MediaTemplatesState.fromJson(
              jsonDecode(libJson) as Map<String, dynamic>);
          return;
        } catch (_) {}
      }
    }

    final globalJson = prefs.getString(_kGlobalKey);
    if (globalJson != null) {
      try {
        state = MediaTemplatesState.fromJson(
            jsonDecode(globalJson) as Map<String, dynamic>);
        return;
      } catch (_) {}
    }
  }

  void updateTemplate(MediaCategory category, MediaTemplateConfig config) {
    state = state.copyWithTemplate(category, config);
    _persist();
  }

  void resetToDefaults() {
    state = MediaTemplatesState.defaults;
    _persist();
  }

  Future<void> saveAsGlobal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGlobalKey, jsonEncode(state.toJson()));
  }

  Future<void> saveForLibrary() async {
    final libraryPath = _ref.read(libraryPathProvider);
    if (libraryPath == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _libraryKey(libraryPath), jsonEncode(state.toJson()));
  }

  Future<void> clearLibraryOverride() async {
    final libraryPath = _ref.read(libraryPathProvider);
    if (libraryPath == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_libraryKey(libraryPath));
    await _load(); // Reload from global
  }

  /// Exports current config as JSON string.
  String exportToJson() => const JsonEncoder.withIndent('  ')
      .convert(state.toJson());

  /// Imports config from JSON string.
  bool importFromJson(String json) {
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      state = MediaTemplatesState.fromJson(data);
      _persist();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(state.toJson());
    // Save both globally and per-library
    await prefs.setString(_kGlobalKey, json);
    final libraryPath = _ref.read(libraryPathProvider);
    if (libraryPath != null) {
      await prefs.setString(_libraryKey(libraryPath), json);
    }
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final mediaTemplatesProvider =
    StateNotifierProvider<MediaTemplatesNotifier, MediaTemplatesState>(
  (ref) => MediaTemplatesNotifier(ref),
);
