import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ActivePlayerState {
  const ActivePlayerState({
    this.assetId,
    this.assetName,
    this.isVideo = false,
  });

  final String? assetId;
  final String? assetName;
  final bool isVideo;

  bool get hasMedia => assetId != null;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ActivePlayerNotifier extends StateNotifier<ActivePlayerState> {
  ActivePlayerNotifier() : super(const ActivePlayerState()) {
    _player = Player();
    _player.setVolume(100.0);
    _initPlayer();
  }

  late final Player _player;

  Future<void> _initPlayer() async {
    // On Linux, try to explicitly configure audio output via libmpv
    if (Platform.isLinux) {
      try {
        final native = _player.platform as NativePlayer;
        await native.setProperty('ao', 'pulse');
      } catch (_) {
        // Fallback: let mpv choose automatically
      }
    }
  }
  Player get player => _player;

  void setMeta({
    required String assetId,
    required String assetName,
    required bool isVideo,
  }) {
    state = ActivePlayerState(
      assetId: assetId,
      assetName: assetName,
      isVideo: isVideo,
    );
  }

  Future<void> stop() async {
    await _player.stop();
    state = const ActivePlayerState();
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final activePlayerProvider =
    StateNotifierProvider<ActivePlayerNotifier, ActivePlayerState>(
  (ref) => ActivePlayerNotifier(),
);
