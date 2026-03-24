import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/active_player_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/playback_provider.dart';
import '../../providers/queue_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String assetId;
  const PlayerScreen({super.key, required this.assetId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Asset? _asset;
  bool _isVideo = false;
  VideoController? _videoController;

  late final Player _player;
  late final ActivePlayerNotifier _activeNotifier;
  late final PlaybackNotifier _playbackNotifier;

  final _subs = <StreamSubscription>[];
  final _focusNode = FocusNode();
  final _videoViewKey = GlobalKey<_VideoPlayerViewState>();

  @override
  void initState() {
    super.initState();
    _activeNotifier = ref.read(activePlayerProvider.notifier);
    _playbackNotifier = ref.read(playbackProvider.notifier);
    _player = _activeNotifier.player;
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
    final isVid = isVideo(mime);
    final alreadyLoaded =
        ref.read(activePlayerProvider).assetId == widget.assetId;
    final resumeMs = asset.playbackPositionMs ?? 0;

    if (isVid) {
      final ctrl = VideoController(
        _player,
        configuration: const VideoControllerConfiguration(
          enableHardwareAcceleration: false,
        ),
      );
      if (!mounted) return;
      setState(() {
        _videoController = ctrl;
        _isVideo = true;
      });
    }

    setState(() => _asset = asset);

    if (alreadyLoaded) {
      // Media still loaded in background — offer to restart or continue
      final currentPos = _player.state.position;
      // Only offer restart if paused/stopped at a significant position
      if (!_player.state.playing && currentPos.inMilliseconds > 500 && mounted) {
        final restart = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Playback'),
            content: Text('Playing from ${_fmt(currentPos)}. Start from the beginning?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Continue'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('From beginning'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (restart == true) await _player.seek(Duration.zero);
      }
      // Ensure playback is running
      if (mounted && !_player.state.playing) await _player.play();
    } else {
      await _player.open(Media(filePath), play: false);
      await _player.setVolume(100.0); // re-ensure volume after open
      if (!mounted) return;

      _activeNotifier.setMeta(
        assetId: widget.assetId,
        assetName: asset.filename,
        isVideo: isVid,
      );

      if (resumeMs > 500) {
        // Wait until duration is known
        if (_player.state.duration == Duration.zero) {
          await _player.stream.duration
              .firstWhere((d) => d > Duration.zero)
              .timeout(
                const Duration(seconds: 10),
                onTimeout: () => Duration.zero,
              );
        }
        if (!mounted) return;

        final resume = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Resume Playback'),
            content: Text(
                'Continue from ${_fmt(Duration(milliseconds: resumeMs))}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Start from beginning'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Resume'),
              ),
            ],
          ),
        );
        if (!mounted) return;
        if (resume ?? false) {
          await _player.seek(Duration(milliseconds: resumeMs));
        }
      }

      await _player.play();
    }

    if (!mounted) return;

    _playbackNotifier.setAsset(widget.assetId);
    _subs.add(_player.stream.position.listen((pos) {
      if (!mounted) return;
      _playbackNotifier.updatePosition(pos);
      _savePosition(pos.inMilliseconds);
    }));
    _subs.add(_player.stream.duration.listen((dur) {
      if (!mounted) return;
      _playbackNotifier.updateDuration(dur);
    }));
    _subs.add(_player.stream.playing.listen((playing) {
      if (!mounted) return;
      _playbackNotifier.setPlaying(playing);
    }));
  }

  void _savePosition(int ms) {
    final asset = _asset;
    if (asset == null) return;
    ref.read(assetsDaoProvider).savePlaybackPosition(asset.id, ms);
  }

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  void dispose() {
    _focusNode.dispose();
    for (final s in _subs) { s.cancel(); }
    _savePosition(_player.state.position.inMilliseconds);

    if (_isVideo) {
      // No background video — stop player and clear active state
      _activeNotifier.stop();
      _playbackNotifier.clear();
    }
    // For audio: player keeps running; MiniPlayerBar will show in DesktopShell

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _asset;
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.escape) {
          context.pop();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.space) {
          _player.state.playing ? _player.pause() : _player.play();
          return KeyEventResult.handled;
        }
        if (event.logicalKey == LogicalKeyboardKey.keyF && _isVideo) {
          _videoViewKey.currentState?.toggleFullscreen();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
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
          actions: [
            // Queue/Playlist button — only visible when a queue is active
            Consumer(builder: (context, ref, _) {
              final queue = ref.watch(queueProvider);
              if (!queue.hasQueue || queue.total <= 1) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.queue_music, color: Colors.white),
                tooltip: 'Warteschlange (${queue.displayPosition}/${queue.total})',
                onPressed: () => _showQueueDialog(context, ref, queue),
              );
            }),
          ],
        ),
        body: asset == null
            ? const Center(child: CircularProgressIndicator())
            : _buildPlayer(asset),
      ),
    );
  }

  void _showQueueDialog(BuildContext context, WidgetRef ref, QueueState queue) {
    final dao = ref.read(assetsDaoProvider);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Expanded(child: Text('Warteschlange')),
            Text(
              '${queue.displayPosition} / ${queue.total}',
              style: Theme.of(ctx).textTheme.bodySmall,
            ),
          ],
        ),
        content: SizedBox(
          width: 400,
          height: 400,
          child: FutureBuilder<List<Asset?>>(
            future: Future.wait(queue.assetIds.map((id) => dao.getById(id))),
            builder: (ctx, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final assets = snap.data!;
              return ListView.builder(
                itemCount: assets.length,
                itemBuilder: (ctx, i) {
                  final asset = assets[i];
                  final isCurrent = i == queue.currentIndex;
                  return ListTile(
                    dense: true,
                    selected: isCurrent,
                    leading: SizedBox(
                      width: 24,
                      child: Text(
                        '${i + 1}',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight:
                              isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent
                              ? Theme.of(ctx).colorScheme.primary
                              : null,
                        ),
                      ),
                    ),
                    title: Text(
                      asset?.mediaTitle ?? asset?.filename ?? '?',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: asset?.artist != null
                        ? Text(asset!.artist!,
                            maxLines: 1, overflow: TextOverflow.ellipsis)
                        : null,
                    trailing: isCurrent
                        ? Icon(Icons.play_arrow,
                            color: Theme.of(ctx).colorScheme.primary, size: 20)
                        : null,
                    onTap: () {
                      ref.read(queueProvider.notifier).skipTo(i);
                      Navigator.of(ctx).pop();
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
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
      return _VideoPlayerView(key: _videoViewKey, player: _player, controller: ctrl);
    }

    return _AudioPlayerView(player: _player, asset: asset);
  }
}

// ── Video Player ──────────────────────────────────────────────────────────────

class _VideoPlayerView extends StatefulWidget {
  final Player player;
  final VideoController controller;

  const _VideoPlayerView({
    super.key,
    required this.player,
    required this.controller,
  });

  @override
  State<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<_VideoPlayerView> {
  final _videoKey = GlobalKey<VideoState>();

  void toggleFullscreen() {
    final vs = _videoKey.currentState;
    if (vs == null) return;
    if (vs.isFullscreen()) {
      vs.exitFullscreen();
    } else {
      vs.enterFullscreen();
    }
  }

  MaterialDesktopVideoControlsThemeData _buildControls() =>
      MaterialDesktopVideoControlsThemeData(
        topButtonBar: [
          const Spacer(),
          _SpeedButton(player: widget.player),
        ],
        bottomButtonBar: [
          MaterialDesktopCustomButton(
            onPressed: () {
              final pos = widget.player.state.position;
              widget.player.seek(pos - const Duration(seconds: 10));
            },
            icon: const Icon(Icons.replay_10, color: Colors.white),
          ),
          const MaterialDesktopPlayOrPauseButton(),
          MaterialDesktopCustomButton(
            onPressed: () async {
              await widget.player.pause();
              await widget.player.seek(Duration.zero);
            },
            icon: const Icon(Icons.stop, color: Colors.white),
          ),
          MaterialDesktopCustomButton(
            onPressed: () {
              final pos = widget.player.state.position;
              widget.player.seek(pos + const Duration(seconds: 30));
            },
            icon: const Icon(Icons.forward_30, color: Colors.white),
          ),
          const MaterialDesktopVolumeButton(),
          const MaterialDesktopPositionIndicator(),
          const Spacer(),
          const MaterialDesktopFullscreenButton(),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final controls = _buildControls();
    return MaterialDesktopVideoControlsTheme(
      normal: controls,
      fullscreen: controls,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.player.state.playing
            ? widget.player.pause()
            : widget.player.play(),
        child: Video(
          key: _videoKey,
          controller: widget.controller,
          controls: MaterialDesktopVideoControls,
        ),
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
  double _volume = 100.0;

  final _subs = <StreamSubscription>[];

  static const _speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _position = widget.player.state.position;
    _duration = widget.player.state.duration;
    _playing = widget.player.state.playing;
    _rate = widget.player.state.rate;
    _volume = widget.player.state.volume;

    _subs.add(widget.player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    }));
    _subs.add(widget.player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    }));
    _subs.add(widget.player.stream.playing.listen((pl) {
      if (mounted) setState(() => _playing = pl);
    }));
    _subs.add(widget.player.stream.rate.listen((r) {
      if (mounted) setState(() => _rate = r);
    }));
    _subs.add(widget.player.stream.volume.listen((v) {
      if (mounted) setState(() => _volume = v);
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) { s.cancel(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        // Album art + title — centred in available space
        Expanded(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.music_note,
                        size: 80, color: Colors.white38),
                  ),
                  const SizedBox(height: 24),
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
                ],
              ),
            ),
          ),
        ),

        // Controls anchored at the bottom
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  thumbShape:
                      const RoundSliderThumbShape(enabledThumbRadius: 8),
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
              const SizedBox(height: 12),

              // Transport controls + speed dropdown
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10,
                        color: Colors.white, size: 32),
                    onPressed: () => widget.player
                        .seek(_position - const Duration(seconds: 10)),
                  ),
                  const SizedBox(width: 8),
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
                  const SizedBox(width: 4),
                  IconButton(
                    icon:
                        const Icon(Icons.stop, color: Colors.white, size: 32),
                    onPressed: () async {
                      await widget.player.pause();
                      await widget.player.seek(Duration.zero);
                    },
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.forward_30,
                        color: Colors.white, size: 32),
                    onPressed: () => widget.player
                        .seek(_position + const Duration(seconds: 30)),
                  ),
                  const SizedBox(width: 16),
                  // Speed dropdown
                  DropdownButton<double>(
                    value: _speeds.reduce((a, b) =>
                        (a - _rate).abs() < (b - _rate).abs() ? a : b),
                    dropdownColor: Colors.grey[900],
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    underline: const SizedBox.shrink(),
                    icon: const Icon(Icons.speed, color: Colors.white54, size: 18),
                    items: _speeds
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text('${s}x'),
                            ))
                        .toList(),
                    onChanged: (s) {
                      if (s != null) widget.player.setRate(s);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Volume slider
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _volume == 0
                          ? Icons.volume_off
                          : _volume < 50
                              ? Icons.volume_down
                              : Icons.volume_up,
                      color: Colors.white54,
                      size: 20,
                    ),
                    onPressed: () {
                      widget.player.setVolume(_volume == 0 ? 100.0 : 0.0);
                    },
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape:
                            const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: Colors.white70,
                        inactiveTrackColor: Colors.white24,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white24,
                      ),
                      child: Slider(
                        value: _volume.clamp(0.0, 100.0),
                        min: 0,
                        max: 100,
                        onChanged: (v) => widget.player.setVolume(v),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 36,
                    child: Text(
                      '${_volume.round()}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
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
  StreamSubscription<double>? _sub;

  @override
  void initState() {
    super.initState();
    _rate = widget.player.state.rate;
    _sub = widget.player.stream.rate.listen((r) {
      if (mounted) setState(() => _rate = r);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
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

