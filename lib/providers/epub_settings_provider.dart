import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kFontSize = 'epub_font_size';
const _kTheme = 'epub_theme';
const _kLineHeight = 'epub_line_height';

enum EpubTheme {
  light('Hell', Colors.white, Colors.black87),
  sepia('Sepia', Color(0xFFF5ECD7), Color(0xFF3C2F1E)),
  dark('Dunkel', Color(0xFF1A1A1A), Color(0xFFE0E0E0));

  const EpubTheme(this.label, this.background, this.foreground);
  final String label;
  final Color background;
  final Color foreground;
}

class EpubSettings {
  const EpubSettings({
    this.fontSize = 17.0,
    this.theme = EpubTheme.light,
    this.lineHeight = 1.6,
  });

  final double fontSize;
  final EpubTheme theme;
  final double lineHeight;

  EpubSettings copyWith({double? fontSize, EpubTheme? theme, double? lineHeight}) =>
      EpubSettings(
        fontSize: fontSize ?? this.fontSize,
        theme: theme ?? this.theme,
        lineHeight: lineHeight ?? this.lineHeight,
      );
}

class EpubSettingsNotifier extends Notifier<EpubSettings> {
  @override
  EpubSettings build() {
    _load();
    return const EpubSettings();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble(_kFontSize) ?? 17.0;
    final themeName = prefs.getString(_kTheme) ?? 'light';
    final lineHeight = prefs.getDouble(_kLineHeight) ?? 1.6;
    final theme = EpubTheme.values.firstWhere(
      (t) => t.name == themeName,
      orElse: () => EpubTheme.light,
    );
    state = EpubSettings(fontSize: fontSize, theme: theme, lineHeight: lineHeight);
  }

  Future<void> setFontSize(double size) async {
    state = state.copyWith(fontSize: size);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kFontSize, size);
  }

  Future<void> setTheme(EpubTheme theme) async {
    state = state.copyWith(theme: theme);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kTheme, theme.name);
  }

  Future<void> setLineHeight(double height) async {
    state = state.copyWith(lineHeight: height);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kLineHeight, height);
  }
}

final epubSettingsProvider =
    NotifierProvider<EpubSettingsNotifier, EpubSettings>(EpubSettingsNotifier.new);
