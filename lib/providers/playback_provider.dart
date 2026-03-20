import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlaybackState {
  const PlaybackState({
    this.assetId,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
  });

  final String? assetId;
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isBuffering;

  double get progress =>
      duration.inMilliseconds == 0
          ? 0
          : position.inMilliseconds / duration.inMilliseconds;

  PlaybackState copyWith({
    String? assetId,
    Duration? position,
    Duration? duration,
    bool? isPlaying,
    bool? isBuffering,
  }) =>
      PlaybackState(
        assetId: assetId ?? this.assetId,
        position: position ?? this.position,
        duration: duration ?? this.duration,
        isPlaying: isPlaying ?? this.isPlaying,
        isBuffering: isBuffering ?? this.isBuffering,
      );
}

class PlaybackNotifier extends StateNotifier<PlaybackState> {
  PlaybackNotifier() : super(const PlaybackState());

  void setAsset(String assetId) =>
      state = PlaybackState(assetId: assetId);

  void updatePosition(Duration position) =>
      state = state.copyWith(position: position);

  void updateDuration(Duration duration) =>
      state = state.copyWith(duration: duration);

  void setPlaying(bool playing) =>
      state = state.copyWith(isPlaying: playing);

  void setBuffering(bool buffering) =>
      state = state.copyWith(isBuffering: buffering);

  void clear() => state = const PlaybackState();
}

final playbackProvider =
    StateNotifierProvider<PlaybackNotifier, PlaybackState>(
  (ref) => PlaybackNotifier(),
);
