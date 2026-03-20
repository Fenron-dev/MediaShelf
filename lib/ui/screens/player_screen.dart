import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:just_audio/just_audio.dart';
import 'package:video_player/video_player.dart';

import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String assetId;
  const PlayerScreen({super.key, required this.assetId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Asset? _asset;
  // Video
  VideoPlayerController? _videoCtrl;
  ChewieController? _chewieCtrl;
  // Audio
  AudioPlayer? _audioPlayer;
  Duration _audioDuration = Duration.zero;
  Duration _audioPosition = Duration.zero;
  bool _audioPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    final dao = ref.read(assetsDaoProvider);
    final asset = await dao.getById(widget.assetId);
    if (!mounted || asset == null) return;
    setState(() => _asset = asset);
    _initPlayer(asset);
  }

  Future<void> _initPlayer(Asset asset) async {
    final libraryPath = ref.read(libraryPathProvider);
    if (libraryPath == null) return;
    final filePath = '$libraryPath/${asset.path}';
    final mime = asset.mimeType ?? '';

    if (isVideo(mime)) {
      await _initVideo(filePath, asset.playbackPositionMs);
    } else if (isAudio(mime)) {
      await _initAudio(filePath, asset.playbackPositionMs);
    }
    ref.read(playbackProvider.notifier).setAsset(asset.id);
  }

  Future<void> _initVideo(String path, int? resumeMs) async {
    final ctrl = VideoPlayerController.file(File(path));
    await ctrl.initialize();
    if (resumeMs != null && resumeMs > 0) {
      await ctrl.seekTo(Duration(milliseconds: resumeMs));
    }
    if (!mounted) return;
    final primary = Theme.of(context).colorScheme.primary;
    final chewie = ChewieController(
      videoPlayerController: ctrl,
      autoPlay: true,
      allowFullScreen: true,
      allowMuting: true,
      showOptions: false,
      materialProgressColors: ChewieProgressColors(
        playedColor: primary,
        handleColor: primary,
      ),
    );
    ctrl.addListener(_onVideoProgress);
    if (mounted) {
      setState(() {
        _videoCtrl = ctrl;
        _chewieCtrl = chewie;
      });
    }
  }

  void _onVideoProgress() {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    final pos = ctrl.value.position;
    ref.read(playbackProvider.notifier).updatePosition(pos);
    _savePosition(pos.inMilliseconds);
  }

  Future<void> _initAudio(String path, int? resumeMs) async {
    final player = AudioPlayer();
    await player.setFilePath(path);
    if (resumeMs != null && resumeMs > 0) {
      await player.seek(Duration(milliseconds: resumeMs));
    }
    player.durationStream.listen((d) {
      if (d != null && mounted) {
        setState(() => _audioDuration = d);
        ref.read(playbackProvider.notifier).updateDuration(d);
      }
    });
    player.positionStream.listen((p) {
      if (mounted) {
        setState(() => _audioPosition = p);
        ref.read(playbackProvider.notifier).updatePosition(p);
        _savePosition(p.inMilliseconds);
      }
    });
    player.playingStream.listen((playing) {
      if (mounted) {
        setState(() => _audioPlaying = playing);
        ref.read(playbackProvider.notifier).setPlaying(playing);
      }
    });
    await player.play();
    if (mounted) setState(() => _audioPlayer = player);
  }

  void _savePosition(int ms) {
    final asset = _asset;
    if (asset == null) return;
    final dao = ref.read(assetsDaoProvider);
    dao.savePlaybackPosition(asset.id, ms);
  }

  @override
  void dispose() {
    _chewieCtrl?.dispose();
    _videoCtrl?.removeListener(_onVideoProgress);
    _videoCtrl?.dispose();
    _audioPlayer?.dispose();
    ref.read(playbackProvider.notifier).clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _asset;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(
          asset?.filename ?? '',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: asset == null
          ? const Center(child: CircularProgressIndicator())
          : _buildPlayer(asset),
    );
  }

  Widget _buildPlayer(Asset asset) {
    final mime = asset.mimeType ?? '';

    if (isVideo(mime)) {
      final chewie = _chewieCtrl;
      if (chewie == null) {
        return const Center(child: CircularProgressIndicator(color: Colors.white));
      }
      return Center(child: Chewie(controller: chewie));
    }

    if (isAudio(mime)) {
      return _AudioPlayerView(
        asset: asset,
        player: _audioPlayer,
        position: _audioPosition,
        duration: _audioDuration,
        isPlaying: _audioPlaying,
      );
    }

    // Unsupported format
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.file_present_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'Cannot play ${asset.extension ?? 'this file'}',
            style: const TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }
}

// ── Audio player UI ───────────────────────────────────────────────────────────

class _AudioPlayerView extends StatelessWidget {
  final Asset asset;
  final AudioPlayer? player;
  final Duration position;
  final Duration duration;
  final bool isPlaying;

  const _AudioPlayerView({
    required this.asset,
    required this.player,
    required this.position,
    required this.duration,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Album art placeholder
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.music_note, size: 80, color: Colors.white38),
          ),
          const SizedBox(height: 32),

          Text(
            asset.filename,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 24),

          // Progress bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final ms = (v * duration.inMilliseconds).round();
                player?.seek(Duration(milliseconds: ms));
              },
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(position), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                Text(_fmt(duration), style: const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                onPressed: () => player?.seek(position - const Duration(seconds: 10)),
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 56,
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: () => isPlaying ? player?.pause() : player?.play(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_30, color: Colors.white, size: 32),
                onPressed: () => player?.seek(position + const Duration(seconds: 30)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }
}
