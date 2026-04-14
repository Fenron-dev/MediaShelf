import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../../../data/database/app_database.dart';
import '../../../../data/thumbnailer/thumbnailer.dart';
import '../../../../providers/library_provider.dart';
import '../../domain/drivethrurpg_metadata.dart';
import '../../providers/drivethrurpg_provider.dart';

// ── Public entry point ────────────────────────────────────────────────────────

/// Opens the DriveThruRPG search dialog for [asset].
///
/// If the user confirms a selection the metadata is written back to the DB
/// and the optional [onApplied] callback is fired.
Future<void> showDriveThruRpgDialog(
  BuildContext context, {
  required Asset asset,
  VoidCallback? onApplied,
}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _DriveThruRpgDialog(asset: asset, onApplied: onApplied),
    );

// ── Dialog widget ─────────────────────────────────────────────────────────────

class _DriveThruRpgDialog extends ConsumerStatefulWidget {
  const _DriveThruRpgDialog({required this.asset, this.onApplied});
  final Asset asset;
  final VoidCallback? onApplied;

  @override
  ConsumerState<_DriveThruRpgDialog> createState() =>
      _DriveThruRpgDialogState();
}

class _DriveThruRpgDialogState extends ConsumerState<_DriveThruRpgDialog> {
  late final TextEditingController _searchCtrl;
  DriveThruRpgSearchResult? _selected;

  // Options for "apply" step
  bool _applyTitle = true;
  bool _applyAuthor = true;
  bool _applyPublisher = true;
  bool _applyPageCount = true;
  bool _applyNote = false;
  bool _applyCover = true;
  bool _applySourceUrl = true;

  @override
  void initState() {
    super.initState();
    // Pre-fill with filename (without extension)
    final base = p.basenameWithoutExtension(widget.asset.filename);
    _searchCtrl = TextEditingController(text: base);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(drivethrurpgSearchProvider);
    final fetchAsync = ref.watch(drivethrurpgFetchProvider);

    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                children: [
                  const Icon(Icons.travel_explore, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DriveThruRPG Lookup',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Schließen',
                  ),
                ],
              ),
            ),

            // ── Search bar ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Titel suchen oder Produkt-URL einfügen',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _runSearch(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _runSearch,
                    child: const Text('Suchen'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // ── Body — switches between states ──────────────────────────────
            Expanded(
              child: fetchAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorView(
                  message: e.toString(),
                  onRetry: () => ref
                      .read(drivethrurpgFetchProvider.notifier)
                      .fetchByUrl(_selected!.productUrl),
                ),
                data: (meta) {
                  if (meta != null) {
                    return _ApplyView(
                      meta: meta,
                      asset: widget.asset,
                      applyTitle: _applyTitle,
                      applyAuthor: _applyAuthor,
                      applyPublisher: _applyPublisher,
                      applyPageCount: _applyPageCount,
                      applyNote: _applyNote,
                      applyCover: _applyCover,
                      applySourceUrl: _applySourceUrl,
                      onToggle: (field, value) => setState(() {
                        switch (field) {
                          case 'title': _applyTitle = value;
                          case 'author': _applyAuthor = value;
                          case 'publisher': _applyPublisher = value;
                          case 'pageCount': _applyPageCount = value;
                          case 'note': _applyNote = value;
                          case 'cover': _applyCover = value;
                          case 'sourceUrl': _applySourceUrl = value;
                        }
                      }),
                      onBack: () {
                        ref.read(drivethrurpgFetchProvider.notifier).clear();
                        setState(() => _selected = null);
                      },
                      onApply: () => _applyMetadata(meta),
                    );
                  }
                  return searchAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) =>
                        _ErrorView(message: e.toString(), onRetry: _runSearch),
                    data: (results) {
                      if (results.isEmpty &&
                          searchAsync is! AsyncLoading) {
                        return const Center(
                          child: Text(
                            'Keine Ergebnisse. Bitte Suchbegriff anpassen.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }
                      return _SearchResultList(
                        results: results,
                        onSelect: _fetchProduct,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _runSearch() {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    ref.read(drivethrurpgFetchProvider.notifier).clear();
    setState(() => _selected = null);

    // If input looks like a URL, fetch directly
    if (query.startsWith('http') && query.contains('drivethrurpg')) {
      ref.read(drivethrurpgFetchProvider.notifier).fetchByUrl(query);
    } else {
      ref.read(drivethrurpgSearchProvider.notifier).search(query);
    }
  }

  void _fetchProduct(DriveThruRpgSearchResult result) {
    setState(() => _selected = result);
    ref.read(drivethrurpgFetchProvider.notifier).fetchByUrl(result.productUrl);
  }

  Future<void> _applyMetadata(DriveThruRpgMetadata meta) async {
    final dao = ref.read(assetsDaoProvider);

    await dao.updateMediaMetadata(
      id: widget.asset.id,
      mediaTitle: _applyTitle && meta.title != null
          ? Value(meta.title)
          : const Value.absent(),
      author: _applyAuthor && meta.authors.isNotEmpty
          ? Value(meta.authorsDisplay)
          : const Value.absent(),
      publisher: _applyPublisher && meta.publisher != null
          ? Value(meta.publisher)
          : const Value.absent(),
      pageCount: _applyPageCount && meta.pageCount != null
          ? Value(meta.pageCount)
          : const Value.absent(),
    );

    if (_applySourceUrl) {
      await dao.updateMeta(
        id: widget.asset.id,
        sourceUrl: Value(meta.productUrl),
      );
    }

    if (_applyNote && meta.description != null) {
      await dao.updateMeta(
        id: widget.asset.id,
        note: Value(meta.description),
      );
    }

    if (_applyCover && meta.coverUrl != null) {
      await _downloadCover(meta.coverUrl!);
    }

    if (mounted) {
      Navigator.pop(context);
      widget.onApplied?.call();
    }
  }

  Future<void> _downloadCover(String coverUrl) async {
    try {
      final libraryPath = ref.read(libraryPathProvider);
      if (libraryPath == null) return;
      final asset = widget.asset;
      if (asset.contentHash == null) return;

      final response = await http
          .get(Uri.parse(coverUrl))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return;

      final decoded = img.decodeImage(Uint8List.fromList(response.bodyBytes));
      if (decoded == null) return;
      final resized = img.copyResize(decoded, width: 256);
      final jpegBytes = img.encodeJpg(resized, quality: 85);

      final dest = thumbPath(libraryPath, asset.contentHash!);
      File(dest).writeAsBytesSync(jpegBytes);
    } catch (_) {
      // Cover download is optional — swallow errors silently
    }
  }
}

// ── Search result list ────────────────────────────────────────────────────────

class _SearchResultList extends StatelessWidget {
  const _SearchResultList({
    required this.results,
    required this.onSelect,
  });

  final List<DriveThruRpgSearchResult> results;
  final ValueChanged<DriveThruRpgSearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) return const SizedBox.shrink();

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: results.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final r = results[index];
        return ListTile(
          leading: _CoverImage(url: r.coverUrl, size: 48),
          title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            [r.publisher, if (r.author != null) r.author!]
                .where((s) => s.isNotEmpty)
                .join(' · '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: r.price != null
              ? Text(r.price!,
                  style: Theme.of(context).textTheme.labelSmall)
              : null,
          onTap: () => onSelect(r),
        );
      },
    );
  }
}

// ── Apply / confirm view ──────────────────────────────────────────────────────

class _ApplyView extends StatelessWidget {
  const _ApplyView({
    required this.meta,
    required this.asset,
    required this.applyTitle,
    required this.applyAuthor,
    required this.applyPublisher,
    required this.applyPageCount,
    required this.applyNote,
    required this.applyCover,
    required this.applySourceUrl,
    required this.onToggle,
    required this.onBack,
    required this.onApply,
  });

  final DriveThruRpgMetadata meta;
  final Asset asset;
  final bool applyTitle;
  final bool applyAuthor;
  final bool applyPublisher;
  final bool applyPageCount;
  final bool applyNote;
  final bool applyCover;
  final bool applySourceUrl;
  final void Function(String field, bool value) onToggle;
  final VoidCallback onBack;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cover + title header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoverImage(url: meta.coverUrl, size: 80),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meta.title ?? '(kein Titel)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (meta.publisher != null)
                      Text(meta.publisher!,
                          style: Theme.of(context).textTheme.bodySmall),
                    if (meta.authors.isNotEmpty)
                      Text(
                        meta.authorsDisplay,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1),

        // Field checkboxes
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Text(
                'Felder übernehmen:',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              if (meta.title != null)
                _FieldTile(
                  label: 'Titel',
                  value: meta.title!,
                  checked: applyTitle,
                  onChanged: (v) => onToggle('title', v),
                ),
              if (meta.authors.isNotEmpty)
                _FieldTile(
                  label: 'Autor(en)',
                  value: meta.authorsDisplay,
                  checked: applyAuthor,
                  onChanged: (v) => onToggle('author', v),
                ),
              if (meta.publisher != null)
                _FieldTile(
                  label: 'Verlag',
                  value: meta.publisher!,
                  checked: applyPublisher,
                  onChanged: (v) => onToggle('publisher', v),
                ),
              if (meta.pageCount != null)
                _FieldTile(
                  label: 'Seitenanzahl',
                  value: '${meta.pageCount}',
                  checked: applyPageCount,
                  onChanged: (v) => onToggle('pageCount', v),
                ),
              if (meta.description != null)
                _FieldTile(
                  label: 'Beschreibung als Notiz',
                  value: meta.description!.length > 120
                      ? '${meta.description!.substring(0, 120)}…'
                      : meta.description!,
                  checked: applyNote,
                  onChanged: (v) => onToggle('note', v),
                ),
              if (meta.coverUrl != null)
                _FieldTile(
                  label: 'Cover als Vorschaubild',
                  value: meta.coverUrl!,
                  checked: applyCover,
                  onChanged: (v) => onToggle('cover', v),
                ),
              _FieldTile(
                label: 'Produkt-URL speichern',
                value: meta.productUrl,
                checked: applySourceUrl,
                onChanged: (v) => onToggle('sourceUrl', v),
              ),

              if (meta.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Kategorien:', style: Theme.of(context).textTheme.labelSmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: meta.categories
                      .map((c) => Chip(
                            label: Text(c),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.zero,
                            labelPadding:
                                const EdgeInsets.symmetric(horizontal: 6),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        ),

        // Action buttons
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              TextButton.icon(
                icon: const Icon(Icons.arrow_back, size: 16),
                label: const Text('Zurück'),
                onPressed: onBack,
              ),
              const Spacer(),
              FilledButton.icon(
                icon: const Icon(Icons.check, size: 16),
                label: const Text('Übernehmen'),
                onPressed: onApply,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Small helpers ─────────────────────────────────────────────────────────────

class _FieldTile extends StatelessWidget {
  const _FieldTile({
    required this.label,
    required this.value,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final String value;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: Theme.of(context).textTheme.bodySmall),
      subtitle: Text(
        value,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      value: checked,
      onChanged: (v) => onChanged(v ?? false),
    );
  }
}

class _CoverImage extends StatelessWidget {
  const _CoverImage({this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(Icons.book_outlined, size: 24),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Image.network(
        url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (ctx, err, stack) => Container(
          width: size,
          height: size,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.broken_image_outlined),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 40, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Erneut versuchen')),
        ],
      ),
    );
  }
}
