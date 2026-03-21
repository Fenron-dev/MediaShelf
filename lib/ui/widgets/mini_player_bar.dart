import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/active_player_provider.dart';
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

  StreamSubscription<Duration>? _posSub;
  StreamSubscription<Duration>? _durSub;
  StreamSubscription<bool>? _playSub;

  @override
  void initState() {
    super.initState();
    final player = ref.read(activePlayerProvider.notifier).player;
    _position = player.state.position;
    _duration = player.state.duration;
    _playing = player.state.playing;

    _posSub = player.stream.position.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _durSub = player.stream.duration.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _playSub = player.stream.playing.listen((pl) {
      if (mounted) setState(() => _playing = pl);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _playSub?.cancel();
    super.dispose();
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

                      // Queue position (e.g. "2 / 5")
                      if (queue.hasQueue && queue.total > 1)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Text(
                            '${queue.displayPosition} / ${queue.total}',
                            style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ),

                      // Time
                      Text(
                        '${_fmt(_position)} / ${_fmt(_duration)}',
                        style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
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
