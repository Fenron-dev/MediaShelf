import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../domain/models/import_result.dart';
import '../../providers/asset_list_provider.dart';
import '../../providers/import_provider.dart';
import 'duplicate_dialog.dart';

/// Opens the import dialog for [sourcePaths] (files or directories).
/// Handles the full flow: path-strip selection → analysis → duplicate
/// resolution → execution → result snackbar.
Future<void> showImportDialog(
  BuildContext context,
  WidgetRef ref,
  List<String> sourcePaths,
) async {
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => ImportDialog(sourcePaths: sourcePaths),
  );
  // Invalidate grid after import
  ref.read(scanVersionProvider.notifier).state++;
}

class ImportDialog extends ConsumerStatefulWidget {
  const ImportDialog({super.key, required this.sourcePaths});

  final List<String> sourcePaths;

  @override
  ConsumerState<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends ConsumerState<ImportDialog> {
  // Strip prefix: derived from the longest common ancestor of source paths.
  late String _stripPrefix;
  late List<String> _prefixSegments; // all segments of the common ancestor
  int _stripDepth = 0;              // how many segments to KEEP (from the end)

  bool _createCollection = false;
  late TextEditingController _collectionNameCtrl;

  @override
  void initState() {
    super.initState();
    final commonAncestor = _commonAncestor(widget.sourcePaths);
    _stripPrefix = commonAncestor;
    _prefixSegments = p.split(commonAncestor)
        .where((s) => s.isNotEmpty && s != '/' && s != p.separator)
        .toList();
    _stripDepth = 0; // default: strip everything (use only filename)

    final rootName = widget.sourcePaths.length == 1
        ? p.basename(widget.sourcePaths.first)
        : p.basename(commonAncestor);
    _collectionNameCtrl = TextEditingController(text: rootName);
  }

  @override
  void dispose() {
    _collectionNameCtrl.dispose();
    super.dispose();
  }

  String get _currentStripPrefix {
    if (_prefixSegments.isEmpty) return '';
    // Keep the last _stripDepth segments as part of the dest path
    final keepCount = _prefixSegments.length - _stripDepth;
    if (keepCount <= 0) return _stripPrefix; // strip all → flat-ish
    return p.joinAll(_prefixSegments.sublist(0, keepCount)) + p.separator;
  }

  String get _previewPath {
    final rel = _currentStripPrefix.isEmpty
        ? p.basename(widget.sourcePaths.first)
        : widget.sourcePaths.first
            .substring(_currentStripPrefix.length)
            .replaceAll(p.separator, '/');
    return rel.isEmpty ? p.basename(widget.sourcePaths.first) : rel;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(importProvider);
    final cs = Theme.of(context).colorScheme;
    final isWorking = state.isWorking;

    return AlertDialog(
      title: Text('Import (${widget.sourcePaths.length} '
          '${widget.sourcePaths.length == 1 ? 'Quelle' : 'Quellen'})'),
      content: SizedBox(
        width: 500,
        child: isWorking
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            : state.phase == ImportPhase.done
                ? _buildResult(state.result!)
                : _buildForm(cs),
      ),
      actions: _buildActions(state, cs),
    );
  }

  Widget _buildForm(ColorScheme cs) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Source list (up to 4 shown)
          Text('Quellen:', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 4),
          ...widget.sourcePaths.take(4).map(
                (sp) => Text(
                  sp,
                  style: const TextStyle(fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          if (widget.sourcePaths.length > 4)
            Text('… und ${widget.sourcePaths.length - 4} weitere',
                style: const TextStyle(fontSize: 11)),

          const SizedBox(height: 20),

          // Path strip selector
          if (_prefixSegments.isNotEmpty) ...[
            Text('Pfad in Bibliothek:',
                style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            _PathStripSelector(
              segments: _prefixSegments,
              keepCount: _prefixSegments.length - _stripDepth,
              onKeepCountChanged: (v) => setState(() {
                _stripDepth = _prefixSegments.length - v;
              }),
            ),
            const SizedBox(height: 4),
            Text(
              '→ Bibliothek: $_previewPath',
              style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
          ],

          // Collection mirror
          CheckboxListTile(
            value: _createCollection,
            onChanged: (v) => setState(() => _createCollection = v ?? false),
            title: const Text('Ordnerstruktur als Sammlung speichern'),
            subtitle: const Text(
              'Erstellt eine Sammlung mit der Ordnerhierarchie '
              'für späteren Export.',
              style: TextStyle(fontSize: 11),
            ),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
          ),
          if (_createCollection) ...[
            const SizedBox(height: 4),
            TextField(
              controller: _collectionNameCtrl,
              decoration: const InputDecoration(
                labelText: 'Sammlungsname',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(ImportResult result) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_outline, size: 56, color: Colors.green),
        const SizedBox(height: 16),
        Text('Import abgeschlossen',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        _ResultRow(label: 'Kopiert', value: result.copied),
        if (result.renamed > 0)
          _ResultRow(label: 'Umbenannt', value: result.renamed),
        if (result.linked > 0)
          _ResultRow(label: 'Verknüpft', value: result.linked),
        if (result.skipped > 0)
          _ResultRow(label: 'Übersprungen', value: result.skipped),
        if (result.errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${result.errors.length} Fehler',
              style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }

  List<Widget> _buildActions(ImportState state, ColorScheme cs) {
    if (state.phase == ImportPhase.done) {
      return [
        FilledButton(
          onPressed: () {
            ref.read(importProvider.notifier).reset();
            Navigator.of(context).pop();
          },
          child: const Text('Schließen'),
        ),
      ];
    }
    if (state.isWorking) return [];

    return [
      TextButton(
        onPressed: () {
          ref.read(importProvider.notifier).reset();
          Navigator.of(context).pop();
        },
        child: const Text('Abbrechen'),
      ),
      const SizedBox(width: 8),
      FilledButton(
        onPressed: _startImport,
        child: const Text('Analysieren & Importieren'),
      ),
    ];
  }

  Future<void> _startImport() async {
    final notifier = ref.read(importProvider.notifier);
    final plan = await notifier.analyze(
      widget.sourcePaths,
      _currentStripPrefix,
    );
    if (plan == null || !mounted) return;

    if (plan.hasDuplicates) {
      // Show duplicate resolution dialog
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => DuplicateDialog(duplicates: plan.duplicates),
      );
      if (confirmed != true || !mounted) return;
    }

    await notifier.execute(
      createCollectionMirror: _createCollection,
      collectionName:
          _createCollection ? _collectionNameCtrl.text.trim() : null,
    );
  }

  static String _commonAncestor(List<String> paths) {
    if (paths.isEmpty) return '';
    if (paths.length == 1) return p.dirname(paths.first);
    final parts = paths.map((path) => p.split(p.dirname(path))).toList();
    final minLen = parts.map((p) => p.length).reduce((a, b) => a < b ? a : b);
    final common = <String>[];
    for (var i = 0; i < minLen; i++) {
      final seg = parts.first[i];
      if (parts.every((p) => p[i] == seg)) {
        common.add(seg);
      } else {
        break;
      }
    }
    return common.isEmpty ? '' : p.joinAll(common);
  }
}

class _PathStripSelector extends StatelessWidget {
  const _PathStripSelector({
    required this.segments,
    required this.keepCount,
    required this.onKeepCountChanged,
  });

  final List<String> segments;
  final int keepCount;
  final ValueChanged<int> onKeepCountChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 2,
      children: [
        for (var i = 0; i < segments.length; i++) ...[
          GestureDetector(
            onTap: () => onKeepCountChanged(i + 1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: i < keepCount
                    ? cs.primaryContainer
                    : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                segments[i],
                style: TextStyle(
                  fontSize: 12,
                  color: i < keepCount
                      ? cs.onPrimaryContainer
                      : cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          Text('/', style: TextStyle(color: cs.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
