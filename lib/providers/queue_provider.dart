import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/mime_resolver.dart';
import 'active_player_provider.dart';
import 'library_provider.dart';

const _kPrefsKey = 'mediashelf_queue';

// ── State ─────────────────────────────────────────────────────────────────────

class QueueState {
  const QueueState({
    this.assetIds = const [],
    this.currentIndex = -1,
  });

  final List<String> assetIds;
  final int currentIndex;

  bool get hasQueue => assetIds.isNotEmpty;
  bool get hasPrevious => currentIndex > 0;
  bool get hasNext =>
      currentIndex >= 0 && currentIndex < assetIds.length - 1;

  String? get currentId =>
      (currentIndex >= 0 && currentIndex < assetIds.length)
          ? assetIds[currentIndex]
          : null;

  int get total => assetIds.length;

  /// 1-based position for display (e.g. "2 / 5").
  int get displayPosition => currentIndex >= 0 ? currentIndex + 1 : 0;

  QueueState copyWith({List<String>? assetIds, int? currentIndex}) =>
      QueueState(
        assetIds: assetIds ?? this.assetIds,
        currentIndex: currentIndex ?? this.currentIndex,
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
    state = QueueState(assetIds: ids, currentIndex: startIndex);
    _persist();
  }

  /// Jumps to the next track and plays it immediately (mini-player button).
  Future<void> skipToNext() async {
    if (!state.hasNext) return;
    state = state.copyWith(currentIndex: state.currentIndex + 1);
    await _playCurrentAsset();
    _persist();
  }

  /// Jumps to the previous track and plays it immediately (mini-player button).
  Future<void> skipToPrevious() async {
    if (!state.hasPrevious) return;
    state = state.copyWith(currentIndex: state.currentIndex - 1);
    await _playCurrentAsset();
    _persist();
  }

  /// Jumps to [index] and plays immediately (tap in queue list).
  Future<void> skipTo(int index) async {
    if (index < 0 || index >= state.assetIds.length) return;
    state = state.copyWith(currentIndex: index);
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
    if (state.hasNext) {
      skipToNext();
    }
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
      state = QueueState(assetIds: ids, currentIndex: idx);
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
