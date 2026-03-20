import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:watcher/watcher.dart';

import '../../core/constants.dart';

/// Monitors a library directory for external file changes.
///
/// Debounces events by [kWatcherDebounce] and exposes a [Stream<void>]
/// that fires whenever files outside `.mediashelf/` are added, modified,
/// or removed. The caller (typically a Riverpod provider) should react
/// by prompting a rescan.
class LibraryWatcher {
  LibraryWatcher(this.libraryPath);

  final String libraryPath;

  DirectoryWatcher? _watcher;
  StreamSubscription<WatchEvent>? _sub;
  Timer? _debounceTimer;
  final _controller = StreamController<void>.broadcast();

  /// Stream that emits a void event after the debounce period whenever
  /// external changes are detected in the library directory.
  Stream<void> get changes => _controller.stream;

  bool get isActive => _sub != null;

  void start() {
    if (_sub != null) return;

    _watcher = DirectoryWatcher(libraryPath);
    _sub = _watcher!.events.listen(_onEvent);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _watcher = null;
  }

  void dispose() {
    stop();
    _controller.close();
  }

  void _onEvent(WatchEvent event) {
    // Ignore anything inside .mediashelf/
    final rel = p.relative(event.path, from: libraryPath);
    if (rel.startsWith(kMediashelfDir)) return;

    // Reset the debounce timer on each event
    _debounceTimer?.cancel();
    _debounceTimer = Timer(kWatcherDebounce, () {
      if (!_controller.isClosed) _controller.add(null);
    });
  }
}
