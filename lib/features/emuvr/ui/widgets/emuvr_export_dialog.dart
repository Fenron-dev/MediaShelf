import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/file_picker_helper.dart';
import '../../../../providers/library_provider.dart';
import '../../data/emuvr_export_service.dart';
import '../../providers/emuvr_settings_provider.dart';

/// Dialog for exporting EmuVR-tagged assets to the EmuVR directory.
class EmuvrExportDialog extends ConsumerStatefulWidget {
  const EmuvrExportDialog({super.key});

  @override
  ConsumerState<EmuvrExportDialog> createState() => _EmuvrExportDialogState();
}

class _EmuvrExportDialogState extends ConsumerState<EmuvrExportDialog> {
  bool _running = false;
  int _done = 0;
  int _total = 0;
  String? _currentFile;
  final List<String> _errors = [];
  bool _finished = false;

  @override
  Widget build(BuildContext context) {
    final emuvrPath = ref.watch(emuvrRootPathProvider);

    return AlertDialog(
      title: const Text('Nach EmuVR exportieren'),
      content: SizedBox(
        width: 400,
        child: _finished
            ? _ResultView(
                done: _done,
                total: _total,
                errors: _errors,
              )
            : _running
                ? _ProgressView(
                    done: _done,
                    total: _total,
                    currentFile: _currentFile,
                  )
                : _ConfirmView(
                    emuvrPath: emuvrPath,
                    onChangePath: _changePath,
                  ),
      ),
      actions: [
        if (!_running)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        if (!_running && !_finished) ...[
          if (emuvrPath == null)
            TextButton.icon(
              icon: const Icon(Icons.settings_outlined, size: 16),
              label: const Text('Einstellungen öffnen'),
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/library/settings');
              },
            )
          else
            FilledButton(
              onPressed: _runExport,
              child: const Text('Exportieren'),
            ),
        ],
      ],
    );
  }

  Future<void> _changePath() async {
    final path = await FilePickerHelper.getDirectoryPath(
      dialogTitle: 'EmuVR-Ordner auswählen',
    );
    if (path != null) {
      await ref.read(emuvrRootPathProvider.notifier).set(path);
    }
  }

  Future<void> _runExport() async {
    final emuvrPath = ref.read(emuvrRootPathProvider);
    final libraryPath = ref.read(libraryPathProvider);
    if (emuvrPath == null || libraryPath == null) return;

    setState(() {
      _running = true;
      _errors.clear();
    });

    final stream = exportTaggedGroups(
      emuvrRootPath: emuvrPath,
      libraryPath: libraryPath,
      assetsDao: ref.read(assetsDaoProvider),
      linksDao: ref.read(assetLinksDaoProvider),
    );

    await for (final progress in stream) {
      if (!mounted) return;
      setState(() {
        _done = progress.done;
        _total = progress.total;
        _currentFile = progress.currentFile;
        if (progress.error != null) _errors.add(progress.error!);
        if (progress.isComplete) {
          _running = false;
          _finished = true;
        }
      });
    }
  }
}

// ── Sub-views ─────────────────────────────────────────────────────────────────

class _ConfirmView extends StatelessWidget {
  const _ConfirmView({required this.emuvrPath, required this.onChangePath});
  final String? emuvrPath;
  final VoidCallback onChangePath;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (emuvrPath == null)
          const Text(
            'Kein EmuVR-Pfad konfiguriert.\n'
            'Bitte in den Einstellungen unter "Plugins" → "EmuVR" festlegen.',
          )
        else ...[
          Text('Zielordner:', style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  emuvrPath!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16),
                tooltip: 'Pfad ändern',
                onPressed: onChangePath,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Alle Assets mit Tags "EmuVR/Console" und "EmuVR/Cart" '
            'werden mit ihren Dateien in den EmuVR-Ordner kopiert.',
          ),
        ],
      ],
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView({
    required this.done,
    required this.total,
    required this.currentFile,
  });
  final int done;
  final int total;
  final String? currentFile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LinearProgressIndicator(
          value: total > 0 ? done / total : null,
        ),
        const SizedBox(height: 8),
        Text(
          total > 0 ? '$done / $total Dateien' : 'Lädt…',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (currentFile != null) ...[
          const SizedBox(height: 4),
          Text(
            currentFile!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.done,
    required this.total,
    required this.errors,
  });
  final int done;
  final int total;
  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              errors.isEmpty
                  ? Icons.check_circle_outline
                  : Icons.warning_amber_outlined,
              color: errors.isEmpty
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              errors.isEmpty
                  ? '$done Dateien exportiert.'
                  : '$done Dateien, ${errors.length} Fehler.',
            ),
          ],
        ),
        if (errors.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...errors.map((e) => Text(
                e,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              )),
        ],
      ],
    );
  }
}
