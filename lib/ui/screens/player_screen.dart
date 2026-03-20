import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  late final Player _player;
  late final PlaybackNotifier _playbackNotifier;
  VideoController? _videoController;

  @override
  void initState() {
    super.initState();
    _player = Player();
    _playbackNotifier = _playbackNotifier;
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    final dao = ref.read(assetsDaoProvider);
    final asset = await dao.getById(widget.assetId);
    if (!mounted || asset == null) return;

    final libraryPath = ref.read(libraryPathProvider);
    if (libraryPath == null) return;

    final mime = asset.mimeType ?? '';
    final filePath = '$libraryPath/${asset.path}';

    // For video: create a VideoController so the Video widget can render frames.
    // For audio: the Player alone is sufficient.
    if (isVideo(mime)) {
      final ctrl = VideoController(_player);
      if (mounted) setState(() => _videoController = ctrl);
    }

    setState(() => _asset = asset);

    await _player.open(Media(filePath), play: false);

    // Resume: wait until the player has buffered enough to know the duration,
    // only then seek — otherwise the seek is silently dropped.
    final resumeMs = asset.playbackPositionMs ?? 0;
    if (resumeMs > 500) {
      await _player.stream.duration
          .firstWhere((d) => d > Duration.zero)
          .timeout(const Duration(seconds: 10), onTimeout: () => Duration.zero);
      await _player.seek(Duration(milliseconds: resumeMs));
    }
    await _player.play();

    // Track position changes for resume & playback provider
    _player.stream.position.listen((pos) {
      if (!mounted) return;
      _playbackNotifier.updatePosition(pos);
      _savePosition(pos.inMilliseconds);
    });
    _player.stream.duration.listen((dur) {
      if (!mounted) return;
      _playbackNotifier.updateDuration(dur);
    });
    _player.stream.playing.listen((playing) {
      if (!mounted) return;
      _playbackNotifier.setPlaying(playing);
    });

    _playbackNotifier.setAsset(widget.assetId);
  }

  void _savePosition(int ms) {
    final asset = _asset;
    if (asset == null) return;
    ref.read(assetsDaoProvider).savePlaybackPosition(asset.id, ms);
  }

  @override
  void dispose() {
    _savePosition(_player.state.position.inMilliseconds);
    _playbackNotifier.clear();
    _player.dispose();
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
      final ctrl = _videoController;
      if (ctrl == null) {
        return const Center(
            child: CircularProgressIndicator(color: Colors.white));
      }
      return Video(
        controller: ctrl,
        controls: AdaptiveVideoControls,
      );
    }

    // Audio (and M4B audiobooks)
    return _AudioPlayerView(player: _player, asset: asset);
  }
}

// ── Audio Player UI ───────────────────────────────────────────────────────────

class _AudioPlayerView extends StatefulWidget {
  final Player player;
  final Asset asset;

  const _AudioPlayerView({required this.player, required this.asset});

  @override
  State<_AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<_AudioPlayerView> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    // Snapshot current state in case streams already fired
    _position = widget.player.state.position;
    _duration = widget.player.state.duration;
    _playing = widget.player.state.playing;

    widget.player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    widget.player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    widget.player.stream.playing.listen((pl) {
      if (mounted) setState(() => _playing = pl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Art placeholder
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
            widget.asset.filename,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600),
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
              activeTrackColor: primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: primary,
              overlayColor: primary.withValues(alpha: 0.2),
            ),
            child: Slider(
              value: progress.clamp(0.0, 1.0),
              onChanged: (v) {
                final ms = (v * _duration.inMilliseconds).round();
                widget.player.seek(Duration(milliseconds: ms));
              },
            ),
          ),

          // Time labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(_position),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
                Text(_fmt(_duration),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10,
                    color: Colors.white, size: 32),
                onPressed: () => widget.player
                    .seek(_position - const Duration(seconds: 10)),
              ),
              const SizedBox(width: 16),
              IconButton(
                iconSize: 56,
                icon: Icon(
                  _playing
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: Colors.white,
                ),
                onPressed: () =>
                    _playing ? widget.player.pause() : widget.player.play(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.forward_30,
                    color: Colors.white, size: 32),
                onPressed: () => widget.player
                    .seek(_position + const Duration(seconds: 30)),
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
