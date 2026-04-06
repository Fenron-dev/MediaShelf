import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/emuvr_settings_provider.dart';

/// Settings page for the EmuVR add-on, shown at /library/settings/plugin/emuvr.
class EmuvrSettingsPage extends ConsumerWidget {
  const EmuvrSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emuvrPath = ref.watch(emuvrRootPathProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── EmuVR Root Path ────────────────────────────────────────────
        Text('EmuVR-Verzeichnis',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Der Ordner, in dem EmuVR installiert ist (enthält Custom/).',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                emuvrPath ?? 'Nicht konfiguriert',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: emuvrPath == null
                          ? Theme.of(context).colorScheme.error
                          : null,
                    ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.folder_open_outlined, size: 16),
              label: const Text('Auswählen'),
              onPressed: () async {
                final path = await FilePicker.platform.getDirectoryPath(
                  dialogTitle: 'EmuVR-Installationsordner auswählen',
                );
                if (path != null) {
                  await ref
                      .read(emuvrRootPathProvider.notifier)
                      .set(path);
                }
              },
            ),
            if (emuvrPath != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.clear, size: 16),
                tooltip: 'Pfad entfernen',
                onPressed: () =>
                    ref.read(emuvrRootPathProvider.notifier).clear(),
              ),
            ],
          ],
        ),

        const Divider(height: 32),

        // ── Import ─────────────────────────────────────────────────────
        Text('Import', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          icon: const Icon(Icons.file_download_outlined, size: 16),
          label: const Text('EmuVR Assets importieren'),
          onPressed: () => context.push('/library/emuvr/import'),
        ),
        const SizedBox(height: 8),
        Text(
          'Importiert OBJ/MTL/PNG-Gruppen aus einem Ordner in die Bibliothek '
          'und verknüpft die Dateien automatisch.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),

        const Divider(height: 32),

        // ── Export tag mapping info ────────────────────────────────────
        Text('Export-Tags', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Text(
          'Setze folgende Tags auf deine OBJ-Assets, '
          'um sie beim Export dem richtigen EmuVR-Ordner zuzuordnen:',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        _TagMappingRow(tag: 'EmuVR/Console', folder: 'Custom/Consoles/'),
        _TagMappingRow(tag: 'EmuVR/Cart', folder: 'Custom/Cartridges/'),
      ],
    );
  }
}

class _TagMappingRow extends StatelessWidget {
  const _TagMappingRow({required this.tag, required this.folder});
  final String tag;
  final String folder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Chip(
            label: Text(tag, style: const TextStyle(fontSize: 11)),
            padding: EdgeInsets.zero,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward, size: 14),
          const SizedBox(width: 8),
          Text(folder, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
