import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/database/app_database.dart';
import '../../providers/active_player_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/queue_provider.dart';

class MiniPlayerBar extends ConsumerStatefulWidget {
  const MiniPlayerBar({super.key});

  @override
  ConsumerState<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends ConsumerState<MiniPlayerBar> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _playing = false;
  double _volume = 100.0;

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playSub;
  StreamSubscription<double>? _volSub;

  @override
  void initState() {
    super.initState();
    final player = ref.read(activePlayerProvider.notifier).player;
    _position = player.state.position;
    _duration = player.state.duration;
    _playing = player.state.playing;
    _volume = player.state.volume;

    _posSub = player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _playSub = player.stream.playing.listen((pl) {
      if (mounted) setState(() => _playing = pl);
    });
    _volSub = player.stream.volume.listen((v) {
      if (mounted) setState(() => _volume = v);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    _volSub?.cancel();
    super.dispose();
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

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(activePlayerProvider);
    final queue = ref.watch(queueProvider);
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds)
            .clamp(0.0, 1.0);
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerHighest,
      child: InkWell(
        onTap: () {
          if (state.assetId != null) {
            context.push('/library/player/${state.assetId}');
          }
        },
        child: SizedBox(
          height: 56,
          child: Column(
            children: [
              LinearProgressIndicator(
                value: progress,
                minHeight: 2,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(cs.primary),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Previous
                      IconButton(
                        icon: Icon(Icons.skip_previous, color: queue.hasPrevious ? cs.onSurface : cs.onSurface.withValues(alpha: 0.3)),
                        tooltip: 'Previous',
                        onPressed: queue.hasPrevious
                            ? () => ref.read(queueProvider.notifier).skipToPrevious()
                            : null,
                      ),

                      // Play / Pause
                      IconButton(
                        icon: Icon(
                          _playing ? Icons.pause : Icons.play_arrow,
                          color: cs.onSurface,
                        ),
                        onPressed: () {
                          final p = ref.read(activePlayerProvider.notifier).player;
                          _playing ? p.pause() : p.play();
                        },
                      ),

                      // Next
                      IconButton(
                        icon: Icon(Icons.skip_next, color: queue.hasNext ? cs.onSurface : cs.onSurface.withValues(alpha: 0.3)),
                        tooltip: 'Next',
                        onPressed: queue.hasNext
                            ? () => ref.read(queueProvider.notifier).skipToNext()
                            : null,
                      ),

                      const SizedBox(width: 4),

                      // Track title
                      Expanded(
                        child: Text(
                          state.assetName ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: cs.onSurface),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Queue list button + position
                      if (queue.hasQueue && queue.total > 1)
                        IconButton(
                          icon: Icon(Icons.queue_music, size: 20, color: cs.onSurface),
                          tooltip: 'Warteschlange (${queue.displayPosition}/${queue.total})',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => _showQueueDialog(context, ref, queue),
                        ),

                      // Volume
                      _VolumePopup(
                        volume: _volume,
                        onChanged: (v) => ref.read(activePlayerProvider.notifier).player.setVolume(v),
                        onMuteToggle: () {
                          final p = ref.read(activePlayerProvider.notifier).player;
                          p.setVolume(_volume == 0 ? 100.0 : 0.0);
                        },
                      ),

                      // Time
                      Text(
                        '${_fmt(_position)} / ${_fmt(_duration)}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                      ),

                      // Shuffle
                      if (queue.hasQueue && queue.total > 1)
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            size: 18,
                            color: queue.shuffle
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.5),
                          ),
                          tooltip: queue.shuffle ? 'Shuffle aus' : 'Shuffle an',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => ref.read(queueProvider.notifier).toggleShuffle(),
                        ),

                      // Repeat
                      if (queue.hasQueue && queue.total > 1)
                        IconButton(
                          icon: Icon(
                            queue.repeatMode == QueueRepeatMode.one
                                ? Icons.repeat_one
                                : Icons.repeat,
                            size: 18,
                            color: queue.repeatMode != QueueRepeatMode.none
                                ? cs.primary
                                : cs.onSurface.withValues(alpha: 0.5),
                          ),
                          tooltip: switch (queue.repeatMode) {
                            QueueRepeatMode.none => 'Wiederholen: Aus',
                            QueueRepeatMode.all => 'Wiederholen: Alle',
                            QueueRepeatMode.one => 'Wiederholen: Eins',
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          onPressed: () => ref.read(queueProvider.notifier).cycleQueueRepeatMode(),
                        ),

                      // Stop
                      IconButton(
                        icon: Icon(Icons.stop, color: cs.onSurface),
                        tooltip: 'Stop',
                        onPressed: () {
                          ref.read(activePlayerProvider.notifier).stop();
                          ref.read(queueProvider.notifier).clear();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Volume popup for miniplayer ──────────────────────────────────────────────

class _VolumePopup extends StatelessWidget {
  const _VolumePopup({
    required this.volume,
    required this.onChanged,
    required this.onMuteToggle,
  });

  final double volume;
  final ValueChanged<double> onChanged;
  final VoidCallback onMuteToggle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<void>(
      tooltip: 'Lautstärke',
      position: PopupMenuPosition.over,
      offset: const Offset(0, -160),
      icon: Icon(
        volume == 0
            ? Icons.volume_off
            : volume < 50
                ? Icons.volume_down
                : Icons.volume_up,
        size: 20,
        color: cs.onSurface,
      ),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: StatefulBuilder(
            builder: (context, setSt) => SizedBox(
              height: 140,
              width: 36,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${volume.round()}',
                    style: TextStyle(fontSize: 11, color: cs.onSurface),
                  ),
                  Expanded(
                    child: RotatedBox(
                      quarterTurns: -1,
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6),
                        ),
                        child: Slider(
                          value: volume.clamp(0.0, 100.0),
                          min: 0,
                          max: 100,
                          onChanged: onChanged,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onMuteToggle,
                    child: Icon(
                      volume == 0 ? Icons.volume_off : Icons.volume_up,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
