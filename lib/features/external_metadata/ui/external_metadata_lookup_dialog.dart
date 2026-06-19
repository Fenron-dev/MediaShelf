import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

import '../../../data/database/app_database.dart';
import '../../../providers/asset_list_provider.dart';
import '../../../providers/library_provider.dart';
import '../data/external_metadata_service.dart';
import '../domain/external_metadata_models.dart';

Future<void> showExternalMetadataLookupDialog(
  BuildContext context, {
  required Asset asset,
  VoidCallback? onApplied,
}) =>
    showDialog<void>(
      context: context,
      builder: (_) => _ExternalMetadataLookupDialog(
        asset: asset,
        onApplied: onApplied,
      ),
    );

class _ExternalMetadataLookupDialog extends ConsumerStatefulWidget {
  const _ExternalMetadataLookupDialog({
    required this.asset,
    this.onApplied,
  });

  final Asset asset;
  final VoidCallback? onApplied;

  @override
  ConsumerState<_ExternalMetadataLookupDialog> createState() =>
      _ExternalMetadataLookupDialogState();
}

class _ExternalMetadataLookupDialogState
    extends ConsumerState<_ExternalMetadataLookupDialog> {
  late final TextEditingController _queryCtrl;
  ExternalMetadataSource _source = ExternalMetadataSource.anilistAnime;
  bool _adult = false;
  bool _searching = false;
  bool _loadingDetails = false;
  bool _autoSearchTriggered = false;
  String? _error;
  List<ExternalMetadataCandidate> _results = const [];
  ExternalMetadataCandidate? _selectedCandidate;
  ExternalMetadataRecord? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _queryCtrl = TextEditingController(text: _defaultQuery());
    _adult = _suggestAdult(_queryCtrl.text);
  }

  @override
  void dispose() {
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_autoSearchTriggered) return;
    _autoSearchTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _search();
    });
  }

  String _defaultQuery() {
    final filename = p.basenameWithoutExtension(widget.asset.filename);
    final pathName = p.basenameWithoutExtension(widget.asset.path);
    final candidate = filename.trim().isNotEmpty ? filename : pathName;
    return candidate.replaceAll(RegExp(r'[_\.]+'), ' ').trim();
  }

  bool _suggestAdult(String query) {
    return RegExp(r'\b(hentai|ecchi|adult|nsfw|18\+)\b', caseSensitive: false)
        .hasMatch(query);
  }

  Future<void> _search() async {
    final query = _queryCtrl.text.trim();
    if (query.isEmpty) {
      setState(() {
        _error = 'Bitte zuerst einen Suchbegriff eingeben.';
        _results = const [];
        _selectedCandidate = null;
        _selectedRecord = null;
      });
      return;
    }

    setState(() {
      _searching = true;
      _error = null;
      _results = const [];
      _selectedCandidate = null;
      _selectedRecord = null;
    });

    try {
      final results = await ExternalMetadataService.instance.search(
        source: _source,
        query: query,
        adult: _adult,
      );
      if (!mounted) return;

      setState(() {
        _results = results;
        _searching = false;
        if (results.isNotEmpty) {
          _selectedCandidate = results.first;
        }
      });

      if (results.isNotEmpty) {
        await _loadDetails(results.first);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _loadDetails(ExternalMetadataCandidate candidate) async {
    setState(() {
      _selectedCandidate = candidate;
      _loadingDetails = true;
      _selectedRecord = candidate.record;
      _error = null;
    });

    try {
      final record = candidate.record ??
          await ExternalMetadataService.instance.fetchCandidate(candidate);
      if (!mounted) return;
      setState(() {
        _selectedRecord = record;
        _loadingDetails = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingDetails = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _applySelected() async {
    final record = _selectedRecord;
    if (record == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final dao = ref.read(assetsDaoProvider);
    final note = record.shortDescription.trim();
    final genres = record.combinedTags.trim();

    await dao.updateExternalMetadata(
      id: widget.asset.id,
      mediaTitle: Value(record.title),
      author: Value(record.creator),
      publisher: Value(record.publisher),
      genre: Value(genres.isEmpty ? null : genres),
      note: Value(note.isEmpty ? null : note),
      sourceUrl: Value(record.sourceUrl),
    );

    ref.read(metaVersionProvider.notifier).state++;
    if (!mounted) return;

    widget.onApplied?.call();
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Metadaten aus ${record.source.label} übernommen.'),
      ),
    );
  }

  Future<void> _openSourceUrl() async {
    final url = _selectedRecord?.sourceUrl;
    if (url == null || url.isEmpty) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.cloud_download_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Externe Metadaten',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Schließen',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSearchControls(context),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(flex: 5, child: _buildResultsPane(context)),
                    const SizedBox(width: 16),
                    Expanded(flex: 6, child: _buildDetailsPane(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchControls(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _queryCtrl,
                decoration: const InputDecoration(
                  labelText: 'Titel oder URL',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onSubmitted: (_) => _search(),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 260,
              child: DropdownButtonFormField<ExternalMetadataSource>(
                initialValue: _source,
                decoration: const InputDecoration(
                  labelText: 'Quelle',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: ExternalMetadataSource.values
                    .map(
                      (source) => DropdownMenuItem(
                        value: source,
                        child: Row(
                          children: [
                            Icon(source.icon, size: 16),
                            const SizedBox(width: 8),
                            Text(source.label),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (source) {
                  if (source == null) return;
                  setState(() => _source = source);
                },
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: _searching ? null : _search,
                icon: _searching
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_searching ? 'Suche...' : 'Suchen'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (_source.isAniList)
              Switch(
                value: _adult,
                onChanged: (value) => setState(() => _adult = value),
              ),
            if (_source.isAniList) ...[
              const SizedBox(width: 6),
              Text(
                'AniList adult filter (isAdult = true)',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const Spacer(),
            Text(
              'Vorgeschlagener Suchbegriff: ${_defaultQuery()}',
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultsPane(BuildContext context) {
    if (_searching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_results.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Treffer', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Text(
                'Noch keine Ergebnisse. Suche starten oder Titel / URL anpassen.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Text('Treffer', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(width: 8),
                Text('(${_results.length})',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final candidate = _results[index];
                final selected = candidate.id == _selectedCandidate?.id &&
                    candidate.source == _selectedCandidate?.source;
                return ListTile(
                  selected: selected,
                  onTap: () => _loadDetails(candidate),
                  leading: _buildThumbnail(candidate.thumbnailUrl),
                  title: Text(candidate.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                  subtitle: Text(
                    candidate.subtitle ?? candidate.source.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsPane(BuildContext context) {
    final candidate = _selectedCandidate;
    final record = _selectedRecord;

    return Card(
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: _loadingDetails
            ? const Center(child: CircularProgressIndicator())
            : record == null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vorschau',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        candidate == null
                            ? 'Wähle einen Treffer aus, um die Metadaten zu prüfen.'
                            : 'Für diesen Treffer sind noch keine Daten geladen.',
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (record.imageUrl != null) ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  record.imageUrl!,
                                  width: 140,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _buildThumbnail(record.imageUrl),
                                ),
                              ),
                              const SizedBox(width: 16),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.title,
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _InfoChip(
                                        icon: record.source.icon,
                                        label: record.source.label,
                                      ),
                                      if (record.kindLabel != null &&
                                          record.kindLabel!.isNotEmpty)
                                        _InfoChip(
                                          icon: Icons.info_outline,
                                          label: record.kindLabel!,
                                        ),
                                      if (record.year != null)
                                        _InfoChip(
                                          icon: Icons.event_outlined,
                                          label: record.year.toString(),
                                        ),
                                      if (record.isAdult == true)
                                        const _InfoChip(
                                          icon: Icons.visibility_off_outlined,
                                          label: 'Adult',
                                        ),
                                    ],
                                  ),
                                  if (record.sourceUrl != null) ...[
                                    const SizedBox(height: 8),
                                    TextButton.icon(
                                      onPressed: _openSourceUrl,
                                      icon: const Icon(Icons.open_in_new, size: 16),
                                      label: const Text('Quelle im Browser öffnen'),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (record.facts.isNotEmpty) ...[
                          Text(
                            'Fakten',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: record.facts.entries
                                .map(
                                  (entry) => Chip(
                                    label: Text('${entry.key}: ${entry.value}'),
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        if ((record.shortDescription).isNotEmpty) ...[
                          Text(
                            'Beschreibung',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          SelectableText(record.shortDescription),
                          const SizedBox(height: 16),
                        ],
                        if (record.tags.isNotEmpty) ...[
                          Text(
                            'Tags / Genres',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: record.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                          ),
                          const SizedBox(height: 16),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _applySelected,
                            icon: const Icon(Icons.check),
                            label: const Text('Auf Asset übernehmen'),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildThumbnail(String? url) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 48,
        height: 48,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image_not_supported_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 48,
          height: 48,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Icon(Icons.image_not_supported_outlined),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}
