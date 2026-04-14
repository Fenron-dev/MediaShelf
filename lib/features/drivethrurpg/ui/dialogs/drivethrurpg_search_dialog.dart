import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../../data/database/app_database.dart';
import '../../../../data/thumbnailer/thumbnailer.dart';
import '../../../../providers/library_provider.dart';
import '../../domain/drivethrurpg_metadata.dart';
import '../../providers/drivethrurpg_provider.dart';

// ── Public entry point ────────────────────────────────────────────────────────

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

enum _DialogMode { search, manual, apply }

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
  _DialogMode _mode = _DialogMode.search;

  // Confirmed metadata ready to apply (from scraper OR manual form)
  DriveThruRpgMetadata? _confirmedMeta;
  DriveThruRpgSearchResult? _selectedResult;

  // Apply-field toggles
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
    _searchCtrl = TextEditingController(
      text: p.basenameWithoutExtension(widget.asset.filename),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.hardEdge,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            if (_mode != _DialogMode.apply) _buildSearchBar(context),
            if (_mode != _DialogMode.apply) const SizedBox(height: 4),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          const Icon(Icons.travel_explore, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text('DriveThruRPG Lookup',
                style: Theme.of(context).textTheme.titleMedium),
          ),
          if (_mode == _DialogMode.manual)
            TextButton(
              onPressed: () => setState(() => _mode = _DialogMode.search),
              child: const Text('Suche'),
            ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Schließen',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
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
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_mode == _DialogMode.manual) {
      return _ManualEntryForm(
        asset: widget.asset,
        onSubmit: (meta) {
          setState(() {
            _confirmedMeta = meta;
            _mode = _DialogMode.apply;
          });
        },
      );
    }

    if (_mode == _DialogMode.apply && _confirmedMeta != null) {
      return _ApplyView(
        meta: _confirmedMeta!,
        applyTitle: _applyTitle,
        applyAuthor: _applyAuthor,
        applyPublisher: _applyPublisher,
        applyPageCount: _applyPageCount,
        applyNote: _applyNote,
        applyCover: _applyCover,
        applySourceUrl: _applySourceUrl,
        onToggle: (field, value) => setState(() {
          switch (field) {
            case 'title':
              _applyTitle = value;
            case 'author':
              _applyAuthor = value;
            case 'publisher':
              _applyPublisher = value;
            case 'pageCount':
              _applyPageCount = value;
            case 'note':
              _applyNote = value;
            case 'cover':
              _applyCover = value;
            case 'sourceUrl':
              _applySourceUrl = value;
          }
        }),
        onBack: () => setState(() {
          _mode = _DialogMode.search;
          _confirmedMeta = null;
          _selectedResult = null;
          ref.read(drivethrurpgFetchProvider.notifier).clear();
        }),
        onApply: () => _applyMetadata(_confirmedMeta!),
      );
    }

    // Search mode — show results or loading/error
    final fetchAsync = ref.watch(drivethrurpgFetchProvider);
    final searchAsync = ref.watch(drivethrurpgSearchProvider);

    return fetchAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _ErrorView(
        message: e.toString(),
        onRetry: _selectedResult != null
            ? () => ref
                .read(drivethrurpgFetchProvider.notifier)
                .fetchByUrl(_selectedResult!.productUrl)
            : null,
        onManualEntry: () => setState(() => _mode = _DialogMode.manual),
        searchQuery: _searchCtrl.text.trim(),
      ),
      data: (meta) {
        if (meta != null) {
          // Auto-advance to apply view when fetch succeeds
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _mode == _DialogMode.search) {
              setState(() {
                _confirmedMeta = meta;
                _mode = _DialogMode.apply;
              });
            }
          });
          return const Center(child: CircularProgressIndicator());
        }

        return searchAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorView(
            message: e.toString(),
            onRetry: _runSearch,
            onManualEntry: () => setState(() => _mode = _DialogMode.manual),
            searchQuery: _searchCtrl.text.trim(),
          ),
          data: (results) {
            if (results.isEmpty) {
              return _EmptyResults(
                onManualEntry: () =>
                    setState(() => _mode = _DialogMode.manual),
              );
            }
            return _SearchResultList(
              results: results,
              onSelect: _fetchProduct,
            );
          },
        );
      },
    );
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  void _runSearch() {
    final query = _searchCtrl.text.trim();
    if (query.isEmpty) return;
    ref.read(drivethrurpgFetchProvider.notifier).clear();
    setState(() {
      _mode = _DialogMode.search;
      _confirmedMeta = null;
      _selectedResult = null;
    });

    if (query.startsWith('http') && query.contains('drivethrurpg')) {
      ref.read(drivethrurpgFetchProvider.notifier).fetchByUrl(query);
    } else {
      ref.read(drivethrurpgSearchProvider.notifier).search(query);
    }
  }

  void _fetchProduct(DriveThruRpgSearchResult result) {
    setState(() => _selectedResult = result);
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

    if (_applySourceUrl && meta.productUrl.isNotEmpty) {
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
      // Cover download is optional
    }
  }
}

// ── Manual entry form ─────────────────────────────────────────────────────────

class _ManualEntryForm extends StatefulWidget {
  const _ManualEntryForm({required this.asset, required this.onSubmit});
  final Asset asset;
  final void Function(DriveThruRpgMetadata meta) onSubmit;

  @override
  State<_ManualEntryForm> createState() => _ManualEntryFormState();
}

class _ManualEntryFormState extends State<_ManualEntryForm> {
  final _titleCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _publisherCtrl = TextEditingController();
  final _pageCtrl = TextEditingController();
  final _urlCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill from existing asset data
    _titleCtrl.text = widget.asset.mediaTitle ?? '';
    _authorCtrl.text = widget.asset.author ?? '';
    _publisherCtrl.text = widget.asset.publisher ?? '';
    _pageCtrl.text =
        widget.asset.pageCount != null ? '${widget.asset.pageCount}' : '';
    _urlCtrl.text = widget.asset.sourceUrl ?? '';
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _authorCtrl.dispose();
    _publisherCtrl.dispose();
    _pageCtrl.dispose();
    _urlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Metadaten manuell eingeben',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Öffne die Produktseite im Browser und übertrage die '
                'gewünschten Informationen hier.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              _field(_urlCtrl, 'Produkt-URL (optional)',
                  icon: Icons.link, action: _openUrl),
              const SizedBox(height: 10),
              _field(_titleCtrl, 'Titel', icon: Icons.title),
              const SizedBox(height: 10),
              _field(_authorCtrl, 'Autor(en)', icon: Icons.person_outline),
              const SizedBox(height: 10),
              _field(_publisherCtrl, 'Verlag', icon: Icons.business_outlined),
              const SizedBox(height: 10),
              _field(_pageCtrl, 'Seitenanzahl',
                  icon: Icons.menu_book_outlined,
                  inputType: TextInputType.number),
            ],
          ),
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            icon: const Icon(Icons.check, size: 16),
            label: const Text('Weiter'),
            onPressed: _submit,
          ),
        ),
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    IconData? icon,
    TextInputType? inputType,
    VoidCallback? action,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 18) : null,
        suffixIcon: action != null
            ? IconButton(
                icon: const Icon(Icons.open_in_browser, size: 18),
                tooltip: 'Im Browser öffnen',
                onPressed: action,
              )
            : null,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  void _openUrl() {
    final url = _urlCtrl.text.trim();
    if (url.isNotEmpty) {
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  void _submit() {
    final authors = _authorCtrl.text.trim().isEmpty
        ? <String>[]
        : _authorCtrl.text
            .split(RegExp(r'[,;]'))
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();

    final meta = DriveThruRpgMetadata(
      title: _titleCtrl.text.trim().isEmpty ? null : _titleCtrl.text.trim(),
      authors: authors,
      publisher:
          _publisherCtrl.text.trim().isEmpty ? null : _publisherCtrl.text.trim(),
      pageCount: int.tryParse(_pageCtrl.text.trim()),
      productUrl: _urlCtrl.text.trim(),
    );
    widget.onSubmit(meta);
  }
}

// ── Search result list ────────────────────────────────────────────────────────

class _SearchResultList extends StatelessWidget {
  const _SearchResultList({required this.results, required this.onSelect});
  final List<DriveThruRpgSearchResult> results;
  final ValueChanged<DriveThruRpgSearchResult> onSelect;

  @override
  Widget build(BuildContext context) {
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
              ? Text(r.price!, style: Theme.of(context).textTheme.labelSmall)
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
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              Text('Felder übernehmen:',
                  style: Theme.of(context).textTheme.labelMedium),
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
              if (meta.productUrl.isNotEmpty)
                _FieldTile(
                  label: 'Produkt-URL speichern',
                  value: meta.productUrl,
                  checked: applySourceUrl,
                  onChanged: (v) => onToggle('sourceUrl', v),
                ),
              if (meta.categories.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Kategorien:',
                    style: Theme.of(context).textTheme.labelSmall),
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

// ── Empty / error states ──────────────────────────────────────────────────────

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({required this.onManualEntry});
  final VoidCallback onManualEntry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off,
              size: 40,
              color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          const Text('Keine Ergebnisse gefunden.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, size: 16),
            label: const Text('Manuell eingeben'),
            onPressed: onManualEntry,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onManualEntry,
    required this.searchQuery,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;
  final VoidCallback onManualEntry;
  final String searchQuery;

  @override
  Widget build(BuildContext context) {
    final isBlocked = message.contains('403') || message.contains('401');

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isBlocked ? Icons.block : Icons.error_outline,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              isBlocked
                  ? 'DriveThruRPG hat die Anfrage blockiert (Bot-Schutz).'
                  : message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (isBlocked) ...[
              const SizedBox(height: 6),
              Text(
                'Die Seite kann direkt im Browser geöffnet werden. '
                'Alternativ Metadaten manuell eintragen.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                if (isBlocked && searchQuery.isNotEmpty)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.open_in_browser, size: 16),
                    label: const Text('Im Browser suchen'),
                    onPressed: () => launchUrl(
                      Uri.parse(
                        'https://www.drivethrurpg.com/de/search'
                        '?keywords=${Uri.encodeComponent(searchQuery)}'
                        '&search_type=products',
                      ),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                if (onRetry != null && !isBlocked)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Erneut versuchen'),
                    onPressed: onRetry,
                  ),
                FilledButton.icon(
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Manuell eingeben'),
                  onPressed: onManualEntry,
                ),
              ],
            ),
          ],
        ),
      ),
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
