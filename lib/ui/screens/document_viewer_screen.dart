import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/epub_parser.dart';
import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/epub_settings_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/media_bookmarks_provider.dart';

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
      child: path == null || asset == null
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _buildViewer(asset, path),
    );
  }

  Widget _buildViewer(Asset asset, String path) {
    final mime = asset.mimeType ?? '';

    if (mime == 'application/epub+zip' ||
        path.toLowerCase().endsWith('.epub')) {
      return _EpubViewer(asset: asset, filePath: path);
    }

    if (mime == 'application/pdf') {
      return _PdfViewer(asset: asset, filePath: path);
    }

    if (mime.startsWith('text/') ||
        mime == 'application/json' ||
        mime == 'application/xml' ||
        mime == 'application/sql') {
      return _buildSimpleScaffold(
        asset,
        _TextViewer(path: path, isMarkdown: mime == 'text/markdown'),
      );
    }

    return _buildSimpleScaffold(
      asset,
      _UnsupportedView(asset: asset, onOpen: () => _openExternal(path)),
    );
  }

  Widget _buildSimpleScaffold(Asset asset, Widget body) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(asset.filename),
          actions: [
            if (_filePath != null)
              IconButton(
                icon: const Icon(Icons.open_in_new),
                tooltip: 'Mit System-App öffnen',
                onPressed: () => _openExternal(_filePath!),
              ),
          ],
        ),
        body: body,
      );

  Future<void> _openExternal(String path) async {
    final uri = Uri.file(path);
    if (!await launchUrl(uri)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kein Programm gefunden.')),
        );
      }
    }
  }
}

// ── ePub Viewer ───────────────────────────────────────────────────────────────

class _EpubViewer extends ConsumerStatefulWidget {
  const _EpubViewer({required this.asset, required this.filePath});
  final Asset asset;
  final String filePath;

  @override
  ConsumerState<_EpubViewer> createState() => _EpubViewerState();
}

class _EpubViewerState extends ConsumerState<_EpubViewer> {
  EpubParser? _epub;
  String? _error;
  int _currentChapter = 0;
  final _scrollCtrl = ScrollController();
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _loadEpub();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEpub() async {
    try {
      final epub = await EpubParser.parse(widget.filePath);
      // Restore saved position
      final saved = await ref
          .read(documentPositionsDaoProvider)
          .getPosition(widget.asset.id);
      final savedChapter =
          int.tryParse(saved?.positionKey ?? '') ?? 0;
      if (mounted) {
        setState(() {
          _epub = epub;
          _currentChapter =
              savedChapter.clamp(0, epub.chapters.length - 1);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'ePub konnte nicht geöffnet werden: $e');
    }
  }

  void _goToChapter(int index) {
    if (_epub == null) return;
    setState(() => _currentChapter = index.clamp(0, _epub!.chapters.length - 1));
    _scrollCtrl.jumpTo(0);
    _schedulePositionSave();
  }

  void _schedulePositionSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _savePosition);
  }

  Future<void> _savePosition() async {
    final epub = _epub;
    if (epub == null) return;
    final ch = epub.chapters[_currentChapter];
    final progress = epub.chapters.isEmpty
        ? 0.0
        : _currentChapter / epub.chapters.length;
    await ref.read(documentPositionsDaoProvider).savePosition(
          widget.asset.id,
          _currentChapter.toString(),
          label: ch.title,
          progress: progress,
        );
  }

  Future<void> _addBookmark() async {
    final epub = _epub;
    if (epub == null) return;
    final ch = epub.chapters[_currentChapter];

    final label = await _showBookmarkDialog(context);
    if (label == null || !mounted) return;

    await ref.read(mediaBookmarksDaoProvider).addBookmark(
          assetId: widget.asset.id,
          mediaType: 'epub',
          positionKey: _currentChapter.toString(),
          positionLabel: ch.title,
          label: label.isEmpty ? null : label,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesezeichen gesetzt')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(epubSettingsProvider);
    final epub = _epub;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(epub?.title ?? widget.asset.filename, maxLines: 1),
        actions: [
          if (epub != null) ...[
            IconButton(
              icon: const Icon(Icons.bookmark_add_outlined),
              tooltip: 'Lesezeichen hinzufügen',
              onPressed: _addBookmark,
            ),
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.bookmarks_outlined),
                tooltip: 'Lesezeichen',
                onPressed: () => Scaffold.of(ctx).openEndDrawer(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.text_fields_outlined),
              tooltip: 'Leseeinstellungen',
              onPressed: () => _showSettingsSheet(context),
            ),
          ],
        ],
      ),
      endDrawer: epub != null
          ? _BookmarkDrawer(
              assetId: widget.asset.id,
              mediaType: 'epub',
              onJumpTo: (positionKey) {
                Navigator.pop(context);
                final ch = int.tryParse(positionKey) ?? 0;
                _goToChapter(ch);
              },
            )
          : null,
      body: _buildBody(epub, settings),
      bottomNavigationBar: epub != null ? _buildNav(epub) : null,
    );
  }

  Widget _buildBody(EpubParser? epub, EpubSettings settings) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text('Mit System-App öffnen'),
                onPressed: () async {
                  final uri = Uri.file(widget.filePath);
                  await launchUrl(uri);
                },
              ),
            ],
          ),
        ),
      );
    }
    if (epub == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (epub.chapters.isEmpty) {
      return const Center(child: Text('Keine Kapitel gefunden.'));
    }

    final chapter = epub.chapters[_currentChapter];
    final bg = settings.theme.background;
    final fg = settings.theme.foreground;
    final fontSize = settings.fontSize;
    final lineHeight = settings.lineHeight;

    return Container(
      color: bg,
      child: SingleChildScrollView(
        controller: _scrollCtrl,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Html(
          data: chapter.htmlContent,
          style: {
            'body': Style(
              fontSize: FontSize(fontSize),
              color: fg,
              lineHeight: LineHeight(lineHeight),
              backgroundColor: bg,
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'p': Style(
              margin: Margins.only(bottom: fontSize * 0.75),
            ),
            'a': Style(color: Theme.of(context).colorScheme.primary),
          },
        ),
      ),
    );
  }

  Widget _buildNav(EpubParser epub) {
    return BottomAppBar(
      height: 56,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                _currentChapter > 0 ? () => _goToChapter(_currentChapter - 1) : null,
          ),
          Expanded(
            child: Text(
              '${_currentChapter + 1} / ${epub.chapters.length}  •  '
              '${epub.chapters[_currentChapter].title}',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _currentChapter < epub.chapters.length - 1
                ? () => _goToChapter(_currentChapter + 1)
                : null,
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsSheet(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      builder: (ctx) => const _EpubSettingsSheet(),
    );
  }
}

// ── ePub Settings Bottom Sheet ────────────────────────────────────────────────

class _EpubSettingsSheet extends ConsumerWidget {
  const _EpubSettingsSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(epubSettingsProvider);
    final notifier = ref.read(epubSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Leseeinstellungen',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          // Theme selector
          Text('Design', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Row(
            children: EpubTheme.values.map((t) {
              final selected = settings.theme == t;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => notifier.setTheme(t),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: t.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outlineVariant,
                        width: selected ? 2 : 1,
                      ),
                    ),
                    child: Text(
                      t.label,
                      style: TextStyle(color: t.foreground, fontSize: 13),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Font size
          Row(
            children: [
              Text('Schriftgröße',
                  style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text('${settings.fontSize.round()}px',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Slider(
            value: settings.fontSize,
            min: 12,
            max: 28,
            divisions: 16,
            onChanged: notifier.setFontSize,
          ),

          // Line height
          Row(
            children: [
              Text('Zeilenabstand',
                  style: Theme.of(context).textTheme.labelMedium),
              const Spacer(),
              Text(settings.lineHeight.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          Slider(
            value: settings.lineHeight,
            min: 1.0,
            max: 2.5,
            divisions: 15,
            onChanged: notifier.setLineHeight,
          ),
        ],
      ),
    );
  }
}

// ── PDF Viewer ────────────────────────────────────────────────────────────────

class _PdfViewer extends ConsumerStatefulWidget {
  const _PdfViewer({required this.asset, required this.filePath});
  final Asset asset;
  final String filePath;

  @override
  ConsumerState<_PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends ConsumerState<_PdfViewer> {
  late final PdfViewerController _controller;
  Timer? _saveTimer;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _controller = PdfViewerController();
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }

  Future<void> _restorePosition() async {
    final saved = await ref
        .read(documentPositionsDaoProvider)
        .getPosition(widget.asset.id);
    final page = int.tryParse(saved?.positionKey ?? '') ?? 1;
    if (page > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_controller.isReady) {
          _controller.goToPage(pageNumber: page);
        }
      });
    }
  }

  void _onPageChanged(int? page) {
    if (page == null) return;
    setState(() => _currentPage = page);
    _schedulePositionSave();
  }

  void _schedulePositionSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 800), _savePosition);
  }

  Future<void> _savePosition() async {
    final total = _totalPages;
    final progress = total > 0 ? _currentPage / total : 0.0;
    await ref.read(documentPositionsDaoProvider).savePosition(
          widget.asset.id,
          _currentPage.toString(),
          label: 'Seite $_currentPage',
          progress: progress,
        );
  }

  Future<void> _addBookmark() async {
    final label = await _showBookmarkDialog(context);
    if (label == null || !mounted) return;
    await ref.read(mediaBookmarksDaoProvider).addBookmark(
          assetId: widget.asset.id,
          mediaType: 'pdf',
          positionKey: _currentPage.toString(),
          positionLabel: 'Seite $_currentPage',
          label: label.isEmpty ? null : label,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesezeichen gesetzt')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.asset.filename, maxLines: 1),
        actions: [
          if (_totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'Lesezeichen',
            onPressed: _addBookmark,
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.bookmarks_outlined),
              tooltip: 'Lesezeichen anzeigen',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _BookmarkDrawer(
        assetId: widget.asset.id,
        mediaType: 'pdf',
        onJumpTo: (positionKey) {
          Navigator.pop(context);
          final page = int.tryParse(positionKey) ?? 1;
          _controller.goToPage(pageNumber: page);
        },
      ),
      body: PdfViewer.file(
        widget.filePath,
        controller: _controller,
        params: PdfViewerParams(
          onViewerReady: (document, controller) {
            setState(() => _totalPages = document.pages.length);
            _restorePosition();
          },
          onPageChanged: _onPageChanged,
        ),
      ),
    );
  }
}

// ── Bookmark Drawer ───────────────────────────────────────────────────────────

class _BookmarkDrawer extends ConsumerWidget {
  const _BookmarkDrawer({
    required this.assetId,
    required this.mediaType,
    required this.onJumpTo,
  });

  final String assetId;
  final String mediaType;
  final void Function(String positionKey) onJumpTo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarksAsync = ref.watch(bookmarksProvider(assetId));
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: cs.primaryContainer),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.bookmarks_outlined,
                    size: 28, color: cs.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'Lesezeichen',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: bookmarksAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Fehler: $e')),
              data: (bookmarks) {
                final filtered = bookmarks
                    .where((b) => b.mediaType == mediaType)
                    .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'Noch keine Lesezeichen.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, i) =>
                      const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final bm = filtered[i];
                    return ListTile(
                      leading: Icon(Icons.bookmark_outlined,
                          color: cs.primary, size: 20),
                      title: Text(
                        bm.label ?? bm.positionLabel ?? bm.positionKey,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        bm.positionLabel ?? '',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('dd.MM.yy').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                  bm.createdAt),
                            ),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          IconButton(
                            icon: Icon(Icons.delete_outline,
                                size: 16, color: cs.error),
                            onPressed: () => ref
                                .read(mediaBookmarksDaoProvider)
                                .deleteBookmark(bm.id),
                          ),
                        ],
                      ),
                      onTap: () => onJumpTo(bm.positionKey),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared bookmark dialog ────────────────────────────────────────────────────

Future<String?> _showBookmarkDialog(BuildContext context) {
  final ctrl = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Lesezeichen'),
      content: TextField(
        controller: ctrl,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: 'Bezeichnung (optional)',
        ),
        onSubmitted: (v) => Navigator.pop(ctx, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, ctrl.text),
          child: const Text('Speichern'),
        ),
      ],
    ),
  );
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
  static const _maxBytes = 4 * 1024 * 1024;

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
        if (mounted) {
          setState(() => _error =
              'Datei zu groß für Vorschau (${(size / 1024 / 1024).toStringAsFixed(1)} MB).\n'
              'Bitte mit System-App öffnen.');
        }
        return;
      }
      final text = await file.readAsString();
      if (mounted) setState(() => _content = text);
    } catch (e) {
      if (mounted) setState(() => _error = 'Datei kann nicht gelesen werden: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(_error!,
              textAlign: TextAlign.center,
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
            label: const Text('Mit System-App öffnen'),
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

