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
    _playbackNotifier = ref.read(playbackProvider.notifier);
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

    if (isVideo(mime)) {
      // Disable hardware decoding: system libmpv may return YUV frames in a
      // colour space that the texture compositor can't convert → blue image.
      final ctrl = VideoController(
        _player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: false,
        ),
      );
      if (mounted) setState(() => _videoController = ctrl);
    }

    setState(() => _asset = asset);

    await _player.open(Media(filePath), play: false);

    // Resume: open() may have already completed and the duration is known;
    // in that case skip the stream wait to avoid a missed-emission deadlock.
    final resumeMs = asset.playbackPositionMs ?? 0;
    if (resumeMs > 500) {
      if (_player.state.duration == Duration.zero) {
        await _player.stream.duration
            .firstWhere((d) => d > Duration.zero)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => Duration.zero,
            );
      }
      await _player.seek(Duration(milliseconds: resumeMs));
    }
    await _player.play();

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
    _player.stop(); // ensure audio/video output stops before the handle is freed
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
      return _VideoPlayerView(player: _player, controller: ctrl);
    }

    return _AudioPlayerView(player: _player, asset: asset);
  }
}

// ── Video Player ──────────────────────────────────────────────────────────────

class _VideoPlayerView extends StatelessWidget {
  final Player player;
  final VideoController controller;

  const _VideoPlayerView({required this.player, required this.controller});

  @override
  Widget build(BuildContext context) {
    return MaterialDesktopVideoControlsTheme(
      normal: MaterialDesktopVideoControlsThemeData(
        topButtonBar: [
          const Spacer(),
          _SpeedButton(player: player),
          _TracksButton(player: player),
        ],
      ),
      fullscreen: MaterialDesktopVideoControlsThemeData(
        topButtonBar: [
          const Spacer(),
          _SpeedButton(player: player),
          _TracksButton(player: player),
        ],
      ),
      child: Video(
        controller: controller,
        controls: MaterialDesktopVideoControls,
      ),
    );
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
  double _rate = 1.0;

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _position = widget.player.state.position;
    _duration = widget.player.state.duration;
    _playing = widget.player.state.playing;
    _rate = widget.player.state.rate;

    widget.player.stream.position
        .listen((p) { if (mounted) setState(() => _position = p); });
    widget.player.stream.duration
        .listen((d) { if (mounted) setState(() => _duration = d); });
    widget.player.stream.playing
        .listen((pl) { if (mounted) setState(() => _playing = pl); });
    widget.player.stream.rate
        .listen((r) { if (mounted) setState(() => _rate = r); });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;
    final primary = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),

          // Album art placeholder
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.music_note, size: 80, color: Colors.white38),
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

          // Transport controls
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
          const SizedBox(height: 20),

          // Playback speed
          Text('Speed', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            alignment: WrapAlignment.center,
            children: _speeds.map((s) {
              final selected = (_rate - s).abs() < 0.01;
              return ChoiceChip(
                label: Text('${s}x'),
                selected: selected,
                selectedColor: primary,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
                backgroundColor: Colors.white12,
                onSelected: (_) => widget.player.setRate(s),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // Audio track selection (shown when file has multiple tracks)
          _AudioTracksRow(player: widget.player),
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

// ── Shared speed & tracks widgets ─────────────────────────────────────────────

class _SpeedButton extends StatefulWidget {
  final Player player;
  const _SpeedButton({required this.player});

  @override
  State<_SpeedButton> createState() => _SpeedButtonState();
}

class _SpeedButtonState extends State<_SpeedButton> {
  static const _speeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
  double _rate = 1.0;

  @override
  void initState() {
    super.initState();
    _rate = widget.player.state.rate;
    widget.player.stream.rate
        .listen((r) { if (mounted) setState(() => _rate = r); });
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<double>(
      tooltip: 'Playback speed',
      icon: const Icon(Icons.speed, color: Colors.white),
      initialValue: _rate,
      onSelected: widget.player.setRate,
      itemBuilder: (_) => _speeds
          .map((s) => PopupMenuItem(
                value: s,
                child: Text(
                  '${s}x',
                  style: TextStyle(
                    fontWeight:
                        (s - _rate).abs() < 0.01 ? FontWeight.bold : null,
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _TracksButton extends StatelessWidget {
  final Player player;
  const _TracksButton({required this.player});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Audio & subtitle tracks',
      icon: const Icon(Icons.tune, color: Colors.white),
      onPressed: () => _showDialog(context),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => _TracksDialog(player: player),
    );
  }
}

class _TracksDialog extends StatefulWidget {
  final Player player;
  const _TracksDialog({required this.player});

  @override
  State<_TracksDialog> createState() => _TracksDialogState();
}

class _TracksDialogState extends State<_TracksDialog> {
  late AudioTrack _audio;
  late SubtitleTrack _subtitle;

  @override
  void initState() {
    super.initState();
    _audio = widget.player.state.track.audio;
    _subtitle = widget.player.state.track.subtitle;
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.player.state.tracks;
    final audioTracks = tracks.audio;
    final subTracks = tracks.subtitle;

    return AlertDialog(
      title: const Text('Tracks'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Audio ───────────────────────────────────────────────────────
            if (audioTracks.isNotEmpty) ...[
              const Text('Audio',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              RadioGroup<String>(
                groupValue: _audio.id,
                onChanged: (id) {
                  if (id == null) return;
                  final t = audioTracks.firstWhere((t) => t.id == id);
                  setState(() => _audio = t);
                  widget.player.setAudioTrack(t);
                },
                child: Column(
                  children: audioTracks
                      .map((t) => RadioListTile<String>(
                            dense: true,
                            title:
                                Text(t.title ?? t.language ?? 'Track ${t.id}'),
                            value: t.id,
                          ))
                      .toList(),
                ),
              ),
              const Divider(),
            ],

            // ── Subtitles ────────────────────────────────────────────────────
            const Text('Subtitles',
                style: TextStyle(fontWeight: FontWeight.bold)),
            RadioGroup<String>(
              groupValue: _subtitle.id,
              onChanged: (id) {
                if (id == null) return;
                if (id == 'no') {
                  setState(() => _subtitle = SubtitleTrack.no());
                  widget.player.setSubtitleTrack(SubtitleTrack.no());
                } else {
                  final t = subTracks.firstWhere((t) => t.id == id);
                  setState(() => _subtitle = t);
                  widget.player.setSubtitleTrack(t);
                }
              },
              child: Column(
                children: [
                  const RadioListTile<String>(
                    dense: true,
                    title: Text('None'),
                    value: 'no',
                  ),
                  ...subTracks.map((t) => RadioListTile<String>(
                        dense: true,
                        title: Text(t.title ?? t.language ?? 'Track ${t.id}'),
                        value: t.id,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

class _AudioTracksRow extends StatefulWidget {
  final Player player;
  const _AudioTracksRow({required this.player});

  @override
  State<_AudioTracksRow> createState() => _AudioTracksRowState();
}

class _AudioTracksRowState extends State<_AudioTracksRow> {
  late AudioTrack _current;

  @override
  void initState() {
    super.initState();
    _current = widget.player.state.track.audio;
    widget.player.stream.track.listen((t) {
      if (mounted) setState(() => _current = t.audio);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tracks = widget.player.state.tracks.audio;
    if (tracks.length <= 1) return const SizedBox.shrink();

    return Column(
      children: [
        Text('Audio Track',
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: tracks.map((t) {
            final label = t.title ?? t.language ?? 'Track ${t.id}';
            final selected = t.id == _current.id;
            final primary = Theme.of(context).colorScheme.primary;
            return ChoiceChip(
              label: Text(label),
              selected: selected,
              selectedColor: primary,
              labelStyle: TextStyle(
                  color: selected ? Colors.white : Colors.white70,
                  fontSize: 12),
              backgroundColor: Colors.white12,
              onSelected: (_) {
                widget.player.setAudioTrack(t);
                setState(() => _current = t);
              },
            );
          }).toList(),
        ),
      ],
    );
  }
}
