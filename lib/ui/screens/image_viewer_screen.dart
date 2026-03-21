import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';

import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';

class ImageViewerScreen extends ConsumerStatefulWidget {
  final String assetId;
  const ImageViewerScreen({super.key, required this.assetId});

  @override
  ConsumerState<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends ConsumerState<ImageViewerScreen> {
  Asset? _asset;
  String? _filePath;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final asset = await ref.read(assetsDaoProvider).getById(widget.assetId);
    if (!mounted || asset == null) return;
    final libraryPath = ref.read(libraryPathProvider);
    if (libraryPath == null) return;
    setState(() {
      _asset = asset;
      _filePath = '$libraryPath/${asset.path}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final path = _filePath;
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          context.pop();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black54,
              foregroundColor: Colors.white,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
              title: Text(
                _asset?.filename ?? '',
                style: const TextStyle(color: Colors.white),
              ),
            )
          : null,
      body: path == null
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onTap: () => setState(() => _showControls = !_showControls),
              child: PhotoView(
                imageProvider: FileImage(File(path)),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
                backgroundDecoration:
                    const BoxDecoration(color: Colors.black),
                loadingBuilder: (_, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null || event.expectedTotalBytes == null
                        ? null
                        : event.cumulativeBytesLoaded /
                            event.expectedTotalBytes!,
                    color: Colors.white,
                  ),
                ),
                errorBuilder: (_, error, stack) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.broken_image,
                          size: 64, color: Colors.white38),
                      const SizedBox(height: 12),
                      Text('Cannot display image',
                          style: TextStyle(color: Colors.white54)),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
