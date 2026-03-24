import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/mime_resolver.dart';
import 'active_player_provider.dart';
import 'library_provider.dart';

const _kPrefsKey = 'mediashelf_queue';

/// Repeat mode for queue playback.
enum QueueRepeatMode { none, one, all }

// ── State ─────────────────────────────────────────────────────────────────────

class QueueState {
  const QueueState({
    this.assetIds = const [],
    this.currentIndex = -1,
    this.repeatMode = QueueRepeatMode.none,
    this.shuffle = false,
    this.shuffleOrder = const [],
    this.shuffleIndex = -1,
  });

  final List<String> assetIds;
  final int currentIndex;
  final QueueRepeatMode repeatMode;
  final bool shuffle;
  /// Shuffled index order (indices into [assetIds]).
  final List<int> shuffleOrder;
  /// Current position within [shuffleOrder].
  final int shuffleIndex;

  bool get hasQueue => assetIds.isNotEmpty;
  bool get hasPrevious {
    if (shuffle) return shuffleIndex > 0 || repeatMode == QueueRepeatMode.all;
    return currentIndex > 0 || repeatMode == QueueRepeatMode.all;
  }
  bool get hasNext {
    if (shuffle) {
      return shuffleIndex < shuffleOrder.length - 1 ||
          repeatMode == QueueRepeatMode.all;
    }
    return (currentIndex >= 0 && currentIndex < assetIds.length - 1) ||
        repeatMode == QueueRepeatMode.all;
  }

  String? get currentId =>
      (currentIndex >= 0 && currentIndex < assetIds.length)
          ? assetIds[currentIndex]
          : null;

  int get total => assetIds.length;

  /// 1-based position for display (e.g. "2 / 5").
  int get displayPosition => currentIndex >= 0 ? currentIndex + 1 : 0;

  QueueState copyWith({
    List<String>? assetIds,
    int? currentIndex,
    QueueRepeatMode? repeatMode,
    bool? shuffle,
    List<int>? shuffleOrder,
    int? shuffleIndex,
  }) =>
      QueueState(
        assetIds: assetIds ?? this.assetIds,
        currentIndex: currentIndex ?? this.currentIndex,
        repeatMode: repeatMode ?? this.repeatMode,
        shuffle: shuffle ?? this.shuffle,
        shuffleOrder: shuffleOrder ?? this.shuffleOrder,
        shuffleIndex: shuffleIndex ?? this.shuffleIndex,
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class QueueNotifier extends StateNotifier<QueueState> {
  QueueNotifier(this._ref) : super(const QueueState()) {
    _init();
  }

  final Ref _ref;
  StreamSubscription<bool>? _completedSub;

  void _init() {
    // Subscribe to player track-completion for auto-advance.
    final player = _ref.read(activePlayerProvider.notifier).player;
    _completedSub = player.stream.completed.listen((completed) {
      if (completed && mounted) _onTrackCompleted();
    });

    // Restore persisted queue once a library is open.
    _ref.listen<String?>(libraryPathProvider, (_, path) {
      if (path != null) _restoreQueue(path);
    });
    final currentPath = _ref.read(libraryPathProvider);
    if (currentPath != null) _restoreQueue(currentPath);
  }

  @override
  void dispose() {
    _completedSub?.cancel();
    super.dispose();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Replaces the queue without auto-playing.
  /// Call this before navigating to [PlayerScreen] so the screen handles play.
  void setQueue(List<String> ids, int startIndex) {
    final shuffleOrder = state.shuffle ? _generateShuffleOrder(ids.length, startIndex) : <int>[];
    final shuffleIdx = state.shuffle ? 0 : -1;
    state = QueueState(
      assetIds: ids,
      currentIndex: startIndex,
      repeatMode: state.repeatMode,
      shuffle: state.shuffle,
      shuffleOrder: shuffleOrder,
      shuffleIndex: shuffleIdx,
    );
    _persist();
  }

  /// Cycles repeat mode: none → all → one → none.
  void cycleQueueRepeatMode() {
    final next = switch (state.repeatMode) {
      QueueRepeatMode.none => QueueRepeatMode.all,
      QueueRepeatMode.all => QueueRepeatMode.one,
      QueueRepeatMode.one => QueueRepeatMode.none,
    };
    state = state.copyWith(repeatMode: next);
    _persist();
  }

  /// Toggles shuffle on/off.
  void toggleShuffle() {
    if (state.shuffle) {
      // Disable shuffle
      state = state.copyWith(
        shuffle: false,
        shuffleOrder: const [],
        shuffleIndex: -1,
      );
    } else {
      // Enable shuffle — generate order starting from current
      final order = _generateShuffleOrder(state.assetIds.length, state.currentIndex);
      state = state.copyWith(
        shuffle: true,
        shuffleOrder: order,
        shuffleIndex: 0,
      );
    }
    _persist();
  }

  /// Jumps to the next track and plays it immediately (mini-player button).
  Future<void> skipToNext() async {
    if (!state.hasNext) return;
    if (state.shuffle) {
      var nextShuffleIdx = state.shuffleIndex + 1;
      if (nextShuffleIdx >= state.shuffleOrder.length) {
        if (state.repeatMode == QueueRepeatMode.all) {
          // Re-shuffle and start over
          final order = _generateShuffleOrder(state.assetIds.length, -1);
          state = state.copyWith(
            shuffleOrder: order,
            shuffleIndex: 0,
            currentIndex: order[0],
          );
        } else {
          return;
        }
      } else {
        state = state.copyWith(
          shuffleIndex: nextShuffleIdx,
          currentIndex: state.shuffleOrder[nextShuffleIdx],
        );
      }
    } else {
      var nextIdx = state.currentIndex + 1;
      if (nextIdx >= state.assetIds.length) {
        if (state.repeatMode == QueueRepeatMode.all) {
          nextIdx = 0;
        } else {
          return;
        }
      }
      state = state.copyWith(currentIndex: nextIdx);
    }
    await _playCurrentAsset();
    _persist();
  }

  /// Jumps to the previous track and plays it immediately (mini-player button).
  Future<void> skipToPrevious() async {
    if (!state.hasPrevious) return;
    if (state.shuffle) {
      var prevShuffleIdx = state.shuffleIndex - 1;
      if (prevShuffleIdx < 0) {
        if (state.repeatMode == QueueRepeatMode.all) {
          prevShuffleIdx = state.shuffleOrder.length - 1;
        } else {
          return;
        }
      }
      state = state.copyWith(
        shuffleIndex: prevShuffleIdx,
        currentIndex: state.shuffleOrder[prevShuffleIdx],
      );
    } else {
      var prevIdx = state.currentIndex - 1;
      if (prevIdx < 0) {
        if (state.repeatMode == QueueRepeatMode.all) {
          prevIdx = state.assetIds.length - 1;
        } else {
          return;
        }
      }
      state = state.copyWith(currentIndex: prevIdx);
    }
    await _playCurrentAsset();
    _persist();
  }

  /// Jumps to [index] and plays immediately (tap in queue list).
  Future<void> skipTo(int index) async {
    if (index < 0 || index >= state.assetIds.length) return;
    state = state.copyWith(currentIndex: index);
    // Update shuffle index if in shuffle mode
    if (state.shuffle) {
      final sIdx = state.shuffleOrder.indexOf(index);
      if (sIdx >= 0) {
        state = state.copyWith(shuffleIndex: sIdx);
      }
    }
    await _playCurrentAsset();
    _persist();
  }

  /// Appends [id] to the end of the queue if not already present.
  void addToEnd(String id) {
    if (state.assetIds.contains(id)) return;
    state = state.copyWith(assetIds: [...state.assetIds, id]);
    _persist();
  }

  /// Inserts [id] immediately after the current track.
  void insertNext(String id) {
    final ids = List<String>.from(state.assetIds);
    final insertAt = (state.currentIndex + 1).clamp(0, ids.length);
    ids.insert(insertAt, id);
    state = state.copyWith(assetIds: ids);
    _persist();
  }

  /// Removes the track at [index] from the queue.
  void removeAt(int index) {
    if (index < 0 || index >= state.assetIds.length) return;
    final ids = List<String>.from(state.assetIds)..removeAt(index);
    int newIndex = state.currentIndex;
    if (index < state.currentIndex) newIndex--;
    if (newIndex >= ids.length) newIndex = ids.length - 1;
    state = QueueState(assetIds: ids, currentIndex: newIndex);
    _persist();
  }

  void clear() {
    state = const QueueState();
    _clearPrefs();
  }

  /// Called by [PlayerScreen] to keep the queue index in sync when the user
  /// navigates directly to an asset that's already in the queue.
  void notifyPlaying(String assetId) {
    final idx = state.assetIds.indexOf(assetId);
    if (idx >= 0 && idx != state.currentIndex) {
      state = state.copyWith(currentIndex: idx);
      _persist();
    }
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  void _onTrackCompleted() {
    if (state.repeatMode == QueueRepeatMode.one) {
      // Repeat current track
      _replayCurrent();
      return;
    }
    if (state.hasNext) {
      skipToNext();
    } else if (state.repeatMode == QueueRepeatMode.all && state.assetIds.isNotEmpty) {
      // Wrap around
      skipToNext();
    }
  }

  Future<void> _replayCurrent() async {
    final player = _ref.read(activePlayerProvider.notifier).player;
    await player.seek(Duration.zero);
    await player.play();
  }

  /// Generates a shuffled order of indices [0..length), placing [startIndex]
  /// first (if >= 0).
  List<int> _generateShuffleOrder(int length, int startIndex) {
    final rng = Random();
    final indices = List<int>.generate(length, (i) => i);
    if (startIndex >= 0 && startIndex < length) {
      indices.remove(startIndex);
      indices.shuffle(rng);
      return [startIndex, ...indices];
    }
    indices.shuffle(rng);
    return indices;
  }

  Future<void> _playCurrentAsset() async {
    final id = state.currentId;
    if (id == null) return;
    final libraryPath = _ref.read(libraryPathProvider);
    if (libraryPath == null) return;

    final dao = _ref.read(assetsDaoProvider);
    final asset = await dao.getById(id);
    if (asset == null) return;

    final filePath = '$libraryPath/${asset.path}';
    final mime = asset.mimeType ?? '';
    final isVid = isVideo(mime);

    await _ref.read(activePlayerProvider.notifier).playAsset(
          filePath: filePath,
          assetId: asset.id,
          assetName: asset.filename,
          isVideo: isVid,
        );
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _persist() async {
    final libraryPath = _ref.read(libraryPathProvider);
    if (libraryPath == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kPrefsKey,
      jsonEncode({
        'assetIds': state.assetIds,
        'currentIndex': state.currentIndex,
        'libraryPath': libraryPath,
        'repeatMode': state.repeatMode.index,
        'shuffle': state.shuffle,
      }),
    );
  }

  Future<void> _restoreQueue(String libraryPath) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kPrefsKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      if (map['libraryPath'] != libraryPath) return;
      final ids = (map['assetIds'] as List).cast<String>();
      final idx = (map['currentIndex'] as int?) ?? -1;
      if (ids.isEmpty) return;
      final repeatIdx = (map['repeatMode'] as int?) ?? 0;
      final repeat = QueueRepeatMode.values[repeatIdx.clamp(0, 2)];
      final shuffleOn = (map['shuffle'] as bool?) ?? false;
      final shuffleOrder = shuffleOn ? _generateShuffleOrder(ids.length, idx) : <int>[];
      state = QueueState(
        assetIds: ids,
        currentIndex: idx,
        repeatMode: repeat,
        shuffle: shuffleOn,
        shuffleOrder: shuffleOrder,
        shuffleIndex: shuffleOn ? 0 : -1,
      );
      // Don't auto-play on restore — user resumes manually.
    } catch (_) {}
  }

  Future<void> _clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kPrefsKey);
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final queueProvider =
    StateNotifierProvider<QueueNotifier, QueueState>((ref) {
  return QueueNotifier(ref);
});
