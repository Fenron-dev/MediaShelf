import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../../providers/asset_list_provider.dart';
import '../../../../providers/library_provider.dart';
import '../../data/emuvr_import_service.dart';

/// Three-step import wizard:
///   Step 0 — Mode selection (external folder / library rescan)
///   Step 1 — Review detected groups + suggested tags
///   Step 2 — Result summary
class EmuvrImportScreen extends ConsumerStatefulWidget {
  const EmuvrImportScreen({super.key});

  @override
  ConsumerState<EmuvrImportScreen> createState() => _EmuvrImportScreenState();
}

class _EmuvrImportScreenState extends ConsumerState<EmuvrImportScreen> {
  int _step = 0;
  bool _isExternal = true;
  String? _selectedFolderPath;
  List<EmuvrImportPreview> _previews = [];
  bool _importing = false;
  EmuvrImportResult? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EmuVR Assets importieren'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: IndexedStack(
        index: _step,
        children: [
          _StepMode(
            isExternal: _isExternal,
            onModeChanged: (v) => setState(() => _isExternal = v),
            onPickFolder: _pickFolder,
            selectedFolder: _selectedFolderPath,
          ),
          _StepReview(
            previews: _previews,
            isExternal: _isExternal,
            importing: _importing,
            onConfirm: _runImport,
            onBack: () => setState(() => _step = 0),
          ),
          _StepResult(
            result: _result,
            onDone: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: _isExternal
          ? 'EmuVR-Ordner auswählen'
          : 'Bibliotheks-Unterordner auswählen',
    );
    if (path == null) return;

    final dir = Directory(path);
    List<EmuvrImportPreview> previews;

    if (_isExternal) {
      previews = scanFolder(dir);
    } else {
      // Library mode: validate the folder is inside the library
      final libraryPath = ref.read(libraryPathProvider);
      if (libraryPath == null || !path.startsWith(libraryPath)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bitte einen Ordner innerhalb der Bibliothek wählen.'),
            ),
          );
        }
        return;
      }
      previews = scanFolder(dir);
    }

    setState(() {
      _selectedFolderPath = path;
      _previews = previews;
      if (previews.isNotEmpty) _step = 1;
    });

    if (previews.isEmpty && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keine OBJ-Gruppen in diesem Ordner gefunden.'),
        ),
      );
    }
  }

  Future<void> _runImport() async {
    final libraryPath = ref.read(libraryPathProvider);
    if (libraryPath == null) return;

    setState(() => _importing = true);

    final result = await executeImport(
      previews: _previews,
      libraryPath: libraryPath,
      isExternal: _isExternal,
      assetsDao: ref.read(assetsDaoProvider),
      tagsDao: ref.read(tagsDaoProvider),
      linksDao: ref.read(assetLinksDaoProvider),
      propertiesDao: ref.read(propertiesDaoProvider),
    );

    // Trigger a library scan refresh so new assets appear in the grid
    ref.read(scanVersionProvider.notifier).state++;

    setState(() {
      _importing = false;
      _result = result;
      _step = 2;
    });
  }
}

// ── Step 0: Mode selection ────────────────────────────────────────────────────

class _StepMode extends StatelessWidget {
  const _StepMode({
    required this.isExternal,
    required this.onModeChanged,
    required this.onPickFolder,
    required this.selectedFolder,
  });

  final bool isExternal;
  final ValueChanged<bool> onModeChanged;
  final VoidCallback onPickFolder;
  final String? selectedFolder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Import-Modus',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),

          RadioGroup<bool>(
            groupValue: isExternal,
            onChanged: (v) { if (v != null) onModeChanged(v); },
            child: Column(
              children: const [
                RadioListTile<bool>(
                  value: true,
                  title: Text('Externer Ordner'),
                  subtitle: Text(
                    'Dateien aus einem beliebigen Ordner in die Bibliothek kopieren.',
                  ),
                ),
                RadioListTile<bool>(
                  value: false,
                  title: Text('Bibliotheks-Unterordner'),
                  subtitle: Text(
                    'Bereits indizierte Dateien verknüpfen — kein Kopieren.',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (selectedFolder != null) ...[
            Text(
              'Ausgewählt: $selectedFolder',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
          ],

          FilledButton.icon(
            icon: const Icon(Icons.folder_open_outlined),
            label: const Text('Ordner auswählen'),
            onPressed: onPickFolder,
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Review detected groups ───────────────────────────────────────────

class _StepReview extends StatefulWidget {
  const _StepReview({
    required this.previews,
    required this.isExternal,
    required this.importing,
    required this.onConfirm,
    required this.onBack,
  });

  final List<EmuvrImportPreview> previews;
  final bool isExternal;
  final bool importing;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  @override
  State<_StepReview> createState() => _StepReviewState();
}

class _StepReviewState extends State<_StepReview> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            children: [
              Text(
                '${widget.previews.length} Gruppen erkannt',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              TextButton(
                onPressed: widget.onBack,
                child: const Text('Zurück'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: widget.importing ? null : widget.onConfirm,
                child: widget.importing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Importieren'),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: widget.previews.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) => _PreviewTile(
              preview: widget.previews[i],
              onTagsChanged: () => setState(() {}),
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.preview, required this.onTagsChanged});
  final EmuvrImportPreview preview;
  final VoidCallback onTagsChanged;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.view_in_ar_outlined),
      title: Text(preview.basename),
      subtitle: Text('${preview.files.length} Dateien'),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // File list
              ...preview.files.map((f) => Text(
                    '  ${p.basename(f.path)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  )),
              const SizedBox(height: 8),

              // Tag chips
              Text('Tags:',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                children: [
                  ...preview.selectedTags.map((tag) => Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 11)),
                        onDeleted: () {
                          preview.selectedTags.remove(tag);
                          onTagsChanged();
                        },
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        padding: EdgeInsets.zero,
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 6),
                      )),
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 14),
                    label: const Text('Tag', style: TextStyle(fontSize: 11)),
                    onPressed: () => _addTagDialog(context),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding:
                        const EdgeInsets.symmetric(horizontal: 4),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _addTagDialog(BuildContext context) async {
    final controller = TextEditingController();
    final tag = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tag hinzufügen'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'z.B. EmuVR/Console'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Hinzufügen'),
          ),
        ],
      ),
    );
    if (tag != null && tag.trim().isNotEmpty) {
      preview.selectedTags.add(tag.trim());
      onTagsChanged();
    }
  }
}

// ── Step 2: Result ────────────────────────────────────────────────────────────

class _StepResult extends StatelessWidget {
  const _StepResult({required this.result, required this.onDone});
  final EmuvrImportResult? result;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    if (result == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            result!.errors.isEmpty ? Icons.check_circle_outline : Icons.warning_outlined,
            size: 48,
            color: result!.errors.isEmpty
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Import abgeschlossen',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text('${result!.groupsImported} Gruppen importiert'),
          Text('${result!.filesImported} Dateien verarbeitet'),
          if (result!.errors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Fehler:',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
            ...result!.errors.map((e) => Text(
                  e,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                )),
          ],
          const Spacer(),
          FilledButton(
            onPressed: onDone,
            child: const Text('Fertig'),
          ),
        ],
      ),
    );
  }
}
