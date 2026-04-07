import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/file_picker_helper.dart';
import '../../data/database/app_database.dart';
import '../../data/services/export_service.dart';
import '../../providers/library_provider.dart';

class ExportDialog extends ConsumerStatefulWidget {
  const ExportDialog({super.key, required this.assets});

  final List<Asset> assets;

  @override
  ConsumerState<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends ConsumerState<ExportDialog> {
  String? _destPath;
  bool _preserveStructure = true;
  bool _running = false;
  int? _exported;
  List<String>? _errors;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Export (${widget.assets.length} '
          '${widget.assets.length == 1 ? 'Asset' : 'Assets'})'),
      content: SizedBox(
        width: 440,
        child: _running
            ? const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            : _exported != null
                ? _buildResult()
                : _buildForm(),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildForm() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Destination picker
        Text('Zielordner:', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _destPath ?? 'Kein Ordner ausgewählt',
                  style: TextStyle(
                    fontSize: 13,
                    color: _destPath != null
                        ? cs.onSurface
                        : cs.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: _pickFolder,
              child: const Text('Durchsuchen'),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Structure option
        Text('Struktur:', style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 6),
        RadioGroup<bool>(
          groupValue: _preserveStructure,
          onChanged: (v) { if (v != null) setState(() => _preserveStructure = v); },
          child: Column(
            children: [
              RadioListTile<bool>(
                value: true,
                title: const Text('Ordnerstruktur beibehalten'),
                subtitle: const Text(
                  'Dateien werden gemäß ihrem Bibliothekspfad exportiert.',
                  style: TextStyle(fontSize: 11),
                ),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              RadioListTile<bool>(
                value: false,
                title: const Text('Flach (alle Dateien direkt im Zielordner)'),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    final exported = _exported!;
    final errors = _errors ?? [];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          errors.isEmpty ? Icons.check_circle_outline : Icons.warning_amber,
          size: 56,
          color: errors.isEmpty ? Colors.green : Colors.orange,
        ),
        const SizedBox(height: 16),
        Text('Export abgeschlossen',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('$exported Datei${exported == 1 ? '' : 'en'} exportiert.'),
        if (errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('${errors.length} Fehler',
              style: const TextStyle(color: Colors.red)),
        ],
      ],
    );
  }

  List<Widget> _buildActions() {
    if (_running) return [];
    if (_exported != null) {
      return [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Schließen'),
        ),
      ];
    }
    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Abbrechen'),
      ),
      const SizedBox(width: 8),
      FilledButton(
        onPressed: _destPath != null ? _startExport : null,
        child: const Text('Exportieren'),
      ),
    ];
  }

  Future<void> _pickFolder() async {
    final result = await FilePickerHelper.getDirectoryPath();
    if (result != null && mounted) {
      setState(() => _destPath = result);
    }
  }

  Future<void> _startExport() async {
    final dest = _destPath;
    if (dest == null) return;

    setState(() => _running = true);

    final libraryPath = ref.read(libraryPathProvider)!;
    final service = ExportService(libraryPath: libraryPath);

    final result = await service.export(
      widget.assets,
      dest,
      preserveStructure: _preserveStructure,
    );

    if (mounted) {
      setState(() {
        _running = false;
        _exported = result.exported;
        _errors = result.errors;
      });
    }
  }
}
