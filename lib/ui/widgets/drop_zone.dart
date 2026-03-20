import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/mime_resolver.dart';
import '../../providers/library_provider.dart';
import '../../providers/scan_provider.dart';

/// Wraps [child] with a drag-and-drop target that accepts files and folders.
/// Dropped media files are copied into the library root and a partial scan
/// is triggered. Only available on desktop (Linux / Windows / macOS).
class DropZoneOverlay extends ConsumerStatefulWidget {
  final Widget child;
  const DropZoneOverlay({super.key, required this.child});

  @override
  ConsumerState<DropZoneOverlay> createState() => _DropZoneOverlayState();
}

class _DropZoneOverlayState extends ConsumerState<DropZoneOverlay> {
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    // desktop_drop is not supported on mobile — skip wrapper
    if (!_isDesktop) return widget.child;

    return DropTarget(
      onDragEntered: (_) => setState(() => _isDragging = true),
      onDragExited: (_) => setState(() => _isDragging = false),
      onDragDone: (detail) {
        setState(() => _isDragging = false);
        _handleDrop(detail.files);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (_isDragging)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 3,
                  ),
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.25),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.drive_folder_upload_outlined,
                        size: 64,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Drop files to add to library',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleDrop(List<XFile> files) async {
    final libraryPath = ref.read(libraryPathProvider);
    if (libraryPath == null) return;

    int copied = 0;
    for (final xfile in files) {
      final src = File(xfile.path);
      if (!src.existsSync()) continue;

      final mime = mimeTypeFromExtension(
        xfile.path.split('.').last.toLowerCase(),
      );
      // Only copy known media/document files
      final cat = categoryFromMime(mime);
      if (cat == MimeCategory.other) continue;

      final dest = File('$libraryPath/${xfile.name}');
      if (dest.existsSync()) continue; // skip duplicates

      try {
        await src.copy(dest.path);
        copied++;
      } catch (e) {
        debugPrint('Drop copy error: $e');
      }
    }

    if (copied > 0 && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $copied file${copied == 1 ? '' : 's'} — scanning…'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Trigger a library scan to index the dropped files
      ref.read(scanProvider.notifier).startScan();
    }
  }

  bool get _isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;
}
