import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/library_provider.dart';
import 'import_dialog.dart';

/// Wraps [child] with a drag-and-drop target that accepts files and folders.
/// Dropped items are routed through [showImportDialog] so the full import
/// flow (duplicate detection, collection mirror, etc.) is triggered.
/// Only available on desktop (Linux / Windows / macOS).
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
                        'Dateien zum Import ablegen',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
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
    if (ref.read(libraryPathProvider) == null) return;
    if (files.isEmpty || !mounted) return;

    final sourcePaths = files
        .map((f) => f.path)
        .where((p) => File(p).existsSync() || Directory(p).existsSync())
        .toList();

    if (sourcePaths.isEmpty) return;

    await showImportDialog(context, ref, sourcePaths);
  }

  bool get _isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;
}
