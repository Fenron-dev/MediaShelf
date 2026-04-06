import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/database/app_database.dart';
import '../../providers/vault_provider.dart';

/// The main Vault screen — shows encrypted items when the vault is unlocked.
class VaultScreen extends ConsumerStatefulWidget {
  const VaultScreen({super.key});

  @override
  ConsumerState<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends ConsumerState<VaultScreen> {
  bool _adding = false;

  @override
  Widget build(BuildContext context) {
    final vaultState = ref.watch(vaultProvider);

    // Safety: redirect back if somehow we got here while locked.
    if (!vaultState.isUnlocked) {
      return const _LockedPlaceholder();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.lock_open_outlined, size: 20),
            SizedBox(width: 8),
            Text('Vault'),
          ],
        ),
        actions: [
          IconButton(
            icon: _adding
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_outlined),
            tooltip: 'Datei hinzufügen',
            onPressed: _adding ? null : _addFiles,
          ),
          IconButton(
            icon: const Icon(Icons.lock_outlined),
            tooltip: 'Vault sperren',
            onPressed: () {
              ref.read(vaultProvider.notifier).lock();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ref.watch(vaultItemsProvider).when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Fehler: $e')),
            data: (items) => items.isEmpty
                ? _EmptyVault(onAdd: _adding ? null : _addFiles)
                : _VaultGrid(items: items),
          ),
    );
  }

  Future<void> _addFiles() async {
    if (_adding) return;
    final key = ref.read(vaultProvider).key;
    if (key == null) return;

    // Pick files before setting _adding=true so the picker opens immediately.
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result == null || result.files.isEmpty) return;
    if (!mounted) return;

    setState(() => _adding = true);

    final service = ref.read(vaultServiceProvider);
    var errors = 0;

    for (final f in result.files) {
      if (f.path == null) continue;
      try {
        await service.addFile(File(f.path!), key);
      } catch (_) {
        errors++;
      }
    }

    if (!mounted) return;
    setState(() => _adding = false);

    if (errors > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$errors Datei(en) konnten nicht verschlüsselt werden.')),
      );
    }
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyVault extends StatelessWidget {
  const _EmptyVault({required this.onAdd});
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock_outlined, size: 64, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            'Vault ist leer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Füge Dateien hinzu, die verschlüsselt gespeichert werden sollen.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_outlined),
            label: const Text('Dateien hinzufügen'),
          ),
        ],
      ),
    );
  }
}

// ── Locked placeholder (shouldn't normally be shown) ─────────────────────────

class _LockedPlaceholder extends StatelessWidget {
  const _LockedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outlined, size: 64),
            SizedBox(height: 16),
            Text('Vault gesperrt'),
          ],
        ),
      ),
    );
  }
}

// ── Grid of vault items ───────────────────────────────────────────────────────

class _VaultGrid extends ConsumerWidget {
  const _VaultGrid({required this.items});
  final List<VaultItem> items;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: items.length,
      itemBuilder: (context, i) => _VaultItemCard(item: items[i]),
    );
  }
}

// ── Single vault item card ────────────────────────────────────────────────────

class _VaultItemCard extends ConsumerWidget {
  const _VaultItemCard({required this.item});
  final VaultItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final added = DateFormat('dd.MM.yyyy').format(
      DateTime.fromMillisecondsSinceEpoch(item.addedAt),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemMenu(context, ref),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Icon area (no thumbnail — security)
            Expanded(
              child: Container(
                color: cs.surfaceContainerHighest,
                child: Center(
                  child: Icon(
                    _iconForMime(item.originalMimeType),
                    size: 40,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            // File info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.originalFilename,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_formatSize(item.fileSizeBytes)} · $added',
                    style: TextStyle(fontSize: 10, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showItemMenu(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.open_in_new_outlined),
              title: const Text('Öffnen / Vorschau'),
              onTap: () => Navigator.pop(context, 'open'),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt_outlined),
              title: const Text('Entschlüsselt speichern'),
              onTap: () => Navigator.pop(context, 'export'),
            ),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Aus Vault löschen',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => Navigator.pop(context, 'delete'),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) return;

    switch (action) {
      case 'open':
        await _openItem(context, ref);
      case 'export':
        await _exportItem(context, ref);
      case 'delete':
        await _deleteItem(context, ref);
    }
  }

  Future<void> _openItem(BuildContext context, WidgetRef ref) async {
    final key = ref.read(vaultProvider).key;
    if (key == null) return;
    final service = ref.read(vaultServiceProvider);

    try {
      final tempFile = await service.decryptToTemp(item, key);
      // Open with system default application
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Temporär entschlüsselt: ${tempFile.path}'),
            action: SnackBarAction(label: 'OK', onPressed: () {}),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Öffnen: $e')),
        );
      }
    }
  }

  Future<void> _exportItem(BuildContext context, WidgetRef ref) async {
    final key = ref.read(vaultProvider).key;
    if (key == null) return;
    final service = ref.read(vaultServiceProvider);

    // Let the user pick a destination folder.
    final destPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Speicherort wählen',
    );
    if (destPath == null || !context.mounted) return;

    try {
      final saved = await service.removeFile(item, key, Directory(destPath));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gespeichert: ${saved.path}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Datei löschen'),
        content: Text(
          '"${item.originalFilename}" wird unwiderruflich aus dem Vault gelöscht. '
          'Kein Backup möglich!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final key = ref.read(vaultProvider).key;
    if (key == null) return;

    // Get library path to construct vault dir
    final service = ref.read(vaultServiceProvider);
    // Use a temp dir just to satisfy the API, but immediately delete the file
    final tmp = await getTemporaryDirectory();
    try {
      final f = await service.removeFile(item, key, tmp);
      await f.delete();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Löschen: $e')),
        );
      }
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  IconData _iconForMime(String mime) {
    if (mime.startsWith('image/')) return Icons.image_outlined;
    if (mime.startsWith('video/')) return Icons.videocam_outlined;
    if (mime.startsWith('audio/')) return Icons.audio_file_outlined;
    if (mime == 'application/pdf') return Icons.picture_as_pdf_outlined;
    if (mime.contains('word') || mime.contains('document')) {
      return Icons.description_outlined;
    }
    if (mime.contains('sheet') || mime.contains('excel')) {
      return Icons.table_chart_outlined;
    }
    return Icons.insert_drive_file_outlined;
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }
}
