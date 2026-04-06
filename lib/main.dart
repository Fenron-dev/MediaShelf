import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/plugin_registry.dart';
import 'features/emuvr/emuvr_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // ── Register plugins ───────────────────────────────────────────────────────
  registerPlugin(EmuvrPlugin());

  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    await windowManager.maximize();
  }

  runApp(const ProviderScope(child: MediaShelfApp()));
}
