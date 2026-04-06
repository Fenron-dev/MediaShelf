import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';

/// In-app help screen that renders the bundled Markdown manual.
///
/// Features:
/// - Full Markdown rendering (headings, tables, code blocks)
/// - Live search that highlights and jumps to matching sections
/// - Table of contents drawer (chapters from H2 headings)
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String? _content;
  String _query = '';
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _showSearch = false;

  // Chapter anchors extracted from the document (## headings)
  final List<_Chapter> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadManual();
  }

  Future<void> _loadManual() async {
    final raw =
        await rootBundle.loadString('assets/help/manual_de.md');
    final chapters = <_Chapter>[];
    final lines = raw.split('\n');
    for (final line in lines) {
      if (line.startsWith('## ')) {
        chapters.add(_Chapter(title: line.substring(3).trim()));
      }
    }
    setState(() {
      _content = raw;
      _chapters.addAll(chapters);
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  /// Returns the content filtered/highlighted for the current query.
  /// For simplicity we show full content always; the search just drives
  /// the chapter filter in the TOC drawer.
  String get _displayContent {
    if (_content == null) return '';
    if (_query.isEmpty) return _content!;
    // Surround matching lines with a bold marker so they stand out.
    final q = _query.toLowerCase();
    return _content!.split('\n').map((line) {
      if (line.toLowerCase().contains(q) && !line.startsWith('#')) {
        return '**→ $line**';
      }
      return line;
    }).join('\n');
  }

  List<_Chapter> get _filteredChapters {
    if (_query.isEmpty) return _chapters;
    final q = _query.toLowerCase();
    return _chapters
        .where((c) => c.title.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Im Handbuch suchen…',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Hilfe & Handbuch'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            tooltip: _showSearch ? 'Suche schließen' : 'Suchen',
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _query = '';
                  _searchCtrl.clear();
                }
              });
            },
          ),
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu_book_outlined),
              tooltip: 'Inhaltsverzeichnis',
              onPressed: () => Scaffold.of(ctx).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: _TocDrawer(
        chapters: _filteredChapters,
        query: _query,
        onSelect: (chapter) {
          Navigator.pop(context); // close drawer
          // Scroll to chapter — we search for the heading in the doc.
          _scrollToChapter(chapter);
        },
      ),
      body: _content == null
          ? const Center(child: CircularProgressIndicator())
          : Markdown(
              controller: _scrollCtrl,
              data: _displayContent,
              selectable: true,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context))
                  .copyWith(
                h1: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
                h2: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                h3: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                tableHead: const TextStyle(fontWeight: FontWeight.bold),
                tableBorder: TableBorder.all(
                  color: cs.outlineVariant,
                  width: 1,
                ),
                tableCellsPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: cs.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border(
                    left: BorderSide(color: cs.secondary, width: 4),
                  ),
                ),
                code: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
                codeblockDecoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
    );
  }

  void _scrollToChapter(_Chapter chapter) {
    if (_content == null) return;
    // Find the approximate character offset of this heading.
    final lines = _content!.split('\n');
    var charOffset = 0;
    var found = false;
    for (final line in lines) {
      if (line.startsWith('## ') &&
          line.substring(3).trim() == chapter.title) {
        found = true;
        break;
      }
      charOffset += line.length + 1; // +1 for '\n'
    }
    if (!found) return;

    // Approximate scroll position: ~20px per character line width.
    // This is a rough heuristic — Markdown layout height isn't known
    // without a rendered measurement. We use a ratio of the full doc.
    final ratio = charOffset / _content!.length;
    final maxScroll = _scrollCtrl.position.maxScrollExtent;
    _scrollCtrl.animateTo(
      maxScroll * ratio,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }
}

// ── Chapter model ─────────────────────────────────────────────────────────────

class _Chapter {
  const _Chapter({required this.title});
  final String title;
}

// ── Table of Contents drawer ──────────────────────────────────────────────────

class _TocDrawer extends StatelessWidget {
  const _TocDrawer({
    required this.chapters,
    required this.query,
    required this.onSelect,
  });

  final List<_Chapter> chapters;
  final String query;
  final void Function(_Chapter) onSelect;

  @override
  Widget build(BuildContext context) {
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
                Icon(Icons.menu_book_outlined,
                    size: 32, color: cs.onPrimaryContainer),
                const SizedBox(height: 8),
                Text(
                  'Inhaltsverzeichnis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (query.isNotEmpty)
                  Text(
                    '${chapters.length} Treffer für "$query"',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onPrimaryContainer.withValues(alpha: 0.8),
                        ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: chapters.isEmpty
                ? Center(
                    child: Text(
                      'Keine Kapitel gefunden.',
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: chapters.length,
                    itemBuilder: (context, i) {
                      final ch = chapters[i];
                      return ListTile(
                        dense: true,
                        leading: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        title: Text(ch.title),
                        onTap: () => onSelect(ch),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
