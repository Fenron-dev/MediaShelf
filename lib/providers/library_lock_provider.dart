import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/library_lock.dart';
import 'library_provider.dart';

/// Whether the current library has an App-Lock configured.
final libraryLockedProvider = Provider<bool>((ref) {
  final path = ref.watch(libraryPathProvider);
  if (path == null) return false;
  return LibraryLock.isLocked(path);
});

/// Whether the current library has filename obfuscation enabled.
final filenamesObfuscatedProvider = Provider<bool>((ref) {
  final path = ref.watch(libraryPathProvider);
  if (path == null) return false;
  return LibraryLock.filenamesObfuscated(path);
});
