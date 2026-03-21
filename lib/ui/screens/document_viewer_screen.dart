import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';


class DocumentViewerScreen extends ConsumerStatefulWidget {
  final String assetId;
  const DocumentViewerScreen({super.key, required this.assetId});

  @override
  ConsumerState<DocumentViewerScreen> createState() =>
      _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends ConsumerState<DocumentViewerScreen> {
  Asset? _asset;
  String? _filePath;

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
    final asset = _asset;
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(asset?.filename ?? ''),
          actions: [
            if (path != null)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Open with system app',
                onPressed: () => _openExternal(path),
              ),
          ],
        ),
        body: path == null
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(asset!, path),
      ),
    );
  }

  Widget _buildBody(Asset asset, String path) {
    final mime = asset.mimeType ?? '';

    if (mime == 'application/pdf') {
      return PdfViewer.file(path);
    }

    if (mime.startsWith('text/') ||
        mime == 'application/json' ||
        mime == 'application/xml' ||
        mime == 'application/sql') {
      return _TextViewer(path: path, isMarkdown: mime == 'text/markdown');
    }

    // Unsupported format — offer to open externally.
    return _UnsupportedView(
      asset: asset,
      onOpen: () => _openExternal(path),
    );
  }

  Future<void> _openExternal(String path) async {
    final uri = Uri.file(path);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No app found to open this file.')),
        );
      }
    }
  }
}

// ── Text / Markdown viewer ────────────────────────────────────────────────────

class _TextViewer extends StatefulWidget {
  final String path;
  final bool isMarkdown;
  const _TextViewer({required this.path, required this.isMarkdown});

  @override
  State<_TextViewer> createState() => _TextViewerState();
}

class _TextViewerState extends State<_TextViewer> {
  String? _content;
  String? _error;
  static const _maxBytes = 4 * 1024 * 1024; // 4 MB soft limit

  @override
  void initState() {
    super.initState();
    _readFile();
  }

  Future<void> _readFile() async {
    try {
      final file = File(widget.path);
      final size = await file.length();
      if (size > _maxBytes) {
        if (mounted) setState(() => _error = 'File too large to preview (${(size / 1024 / 1024).toStringAsFixed(1)} MB).\nUse "Open with system app" instead.');
        return;
      }
      final text = await file.readAsString();
      if (mounted) setState(() => _content = text);
    } catch (e) {
      if (mounted) setState(() => _error = 'Cannot read file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_error!, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red)),
        ),
      );
    }
    if (_content == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.isMarkdown) {
      return Markdown(
        data: _content!,
        selectable: true,
        padding: const EdgeInsets.all(16),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        _content!,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
      ),
    );
  }
}

// ── Unsupported format fallback ───────────────────────────────────────────────

class _UnsupportedView extends StatelessWidget {
  final Asset asset;
  final VoidCallback onOpen;
  const _UnsupportedView({required this.asset, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final cat = categoryFromMime(asset.mimeType ?? '');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_iconForCategory(cat), size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            asset.filename,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            asset.mimeType ?? 'Unknown format',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open with system app'),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(MimeCategory cat) => switch (cat) {
        MimeCategory.document => Icons.description_outlined,
        MimeCategory.archive => Icons.folder_zip_outlined,
        MimeCategory.font => Icons.font_download_outlined,
        MimeCategory.model => Icons.view_in_ar_outlined,
        _ => Icons.insert_drive_file_outlined,
      };
}
