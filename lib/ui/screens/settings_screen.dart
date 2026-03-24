import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/media_template_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  MediaCategory _selectedCategory = MediaCategory.audio;

  @override
  Widget build(BuildContext context) {
    final templates = ref.watch(mediaTemplatesProvider);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Einstellungen'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) => _onMenuAction(v),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.upload_outlined),
                  title: Text('Exportieren'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.download_outlined),
                  title: Text('Importieren'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'copy_json',
                child: ListTile(
                  leading: Icon(Icons.copy),
                  title: Text('JSON kopieren'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'save_global',
                child: ListTile(
                  leading: Icon(Icons.public),
                  title: Text('Global speichern'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'save_library',
                child: ListTile(
                  leading: Icon(Icons.library_books_outlined),
                  title: Text('Für Bibliothek speichern'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_library',
                child: ListTile(
                  leading: Icon(Icons.layers_clear_outlined),
                  title: Text('Bibliothek-Override löschen'),
                  dense: true,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'reset',
                child: ListTile(
                  leading: Icon(Icons.restore),
                  title: Text('Auf Standard zurücksetzen'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          // ── Category list ──────────────────────────────────────────────
          SizedBox(
            width: 200,
            child: ListView(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('Medien-Templates',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ...MediaCategory.values.map((cat) => ListTile(
                      dense: true,
                      selected: _selectedCategory == cat,
                      selectedTileColor:
                          cs.primaryContainer.withValues(alpha: 0.3),
                      leading: Icon(_categoryIcon(cat), size: 20),
                      title: Text(cat.label),
                      trailing: Text(
                        '${templates.getTemplate(cat).fields.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () =>
                          setState(() => _selectedCategory = cat),
                    )),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // ── Template editor ────────────────────────────────────────────
          Expanded(
            child: _TemplateEditor(
              category: _selectedCategory,
              config: templates.getTemplate(_selectedCategory),
              onChanged: (config) => ref
                  .read(mediaTemplatesProvider.notifier)
                  .updateTemplate(_selectedCategory, config),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onMenuAction(String action) async {
    final notifier = ref.read(mediaTemplatesProvider.notifier);
    switch (action) {
      case 'export':
        final json = notifier.exportToJson();
        final result = await FilePicker.platform.saveFile(
          dialogTitle: 'Template-Einstellungen exportieren',
          fileName: 'mediashelf_templates.json',
          allowedExtensions: ['json'],
          type: FileType.custom,
        );
        if (result != null) {
          await File(result).writeAsString(json);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Exportiert')),
            );
          }
        }
      case 'import':
        final result = await FilePicker.platform.pickFiles(
          dialogTitle: 'Template-Einstellungen importieren',
          allowedExtensions: ['json'],
          type: FileType.custom,
        );
        if (result != null && result.files.single.path != null) {
          final json = await File(result.files.single.path!).readAsString();
          final success = notifier.importFromJson(json);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      success ? 'Importiert' : 'Import fehlgeschlagen')),
            );
          }
        }
      case 'copy_json':
        final json = notifier.exportToJson();
        await Clipboard.setData(ClipboardData(text: json));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('JSON in Zwischenablage kopiert')),
          );
        }
      case 'save_global':
        await notifier.saveAsGlobal();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Global gespeichert')),
          );
        }
      case 'save_library':
        await notifier.saveForLibrary();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Für Bibliothek gespeichert')),
          );
        }
      case 'clear_library':
        await notifier.clearLibraryOverride();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Bibliothek-Override gelöscht')),
          );
        }
      case 'reset':
        notifier.resetToDefaults();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Auf Standard zurückgesetzt')),
          );
        }
    }
  }

  IconData _categoryIcon(MediaCategory cat) => switch (cat) {
        MediaCategory.audio => Icons.music_note_outlined,
        MediaCategory.video => Icons.movie_outlined,
        MediaCategory.image => Icons.image_outlined,
        MediaCategory.documentPdf => Icons.picture_as_pdf_outlined,
        MediaCategory.documentEbook => Icons.auto_stories_outlined,
        MediaCategory.documentOther => Icons.description_outlined,
        MediaCategory.text => Icons.text_snippet_outlined,
        MediaCategory.archive => Icons.folder_zip_outlined,
        MediaCategory.other => Icons.insert_drive_file_outlined,
      };
}

// ── Template Editor ───────────────────────────────────────────────────────────

class _TemplateEditor extends StatelessWidget {
  const _TemplateEditor({
    required this.category,
    required this.config,
    required this.onChanged,
  });

  final MediaCategory category;
  final MediaTemplateConfig config;
  final ValueChanged<MediaTemplateConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final active = config.fields;
    final available = MetadataField.values
        .where((f) => !active.contains(f))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${category.label} — Angezeigte Felder',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Ziehe Felder zum Sortieren oder entferne sie. '
            'Felder unten können hinzugefügt werden.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),

          // Active fields (reorderable)
          Text('Aktive Felder',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: Material(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              child: active.isEmpty
                  ? const Center(
                      child: Text('Keine Felder ausgewählt',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ReorderableListView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: active.length,
                      onReorder: (oldIdx, newIdx) {
                        if (newIdx > oldIdx) newIdx--;
                        final fields = List.of(active);
                        final item = fields.removeAt(oldIdx);
                        fields.insert(newIdx, item);
                        onChanged(
                            MediaTemplateConfig(fields: fields));
                      },
                      itemBuilder: (context, i) {
                        final field = active[i];
                        return ListTile(
                          key: ValueKey(field),
                          dense: true,
                          leading: const Icon(Icons.drag_handle,
                              size: 18),
                          title: Text(field.label),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                size: 18),
                            tooltip: 'Entfernen',
                            onPressed: () {
                              final fields = List.of(active)
                                ..removeAt(i);
                              onChanged(MediaTemplateConfig(
                                  fields: fields));
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Available fields
          Text('Verfügbare Felder',
              style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Expanded(
            flex: 2,
            child: Material(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              child: available.isEmpty
                  ? const Center(
                      child: Text('Alle Felder werden angezeigt',
                          style: TextStyle(color: Colors.grey)),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(4),
                      children: available.map((field) {
                        return ListTile(
                          dense: true,
                          leading: const Icon(
                              Icons.add_circle_outline,
                              size: 18),
                          title: Text(field.label),
                          onTap: () {
                            final fields = [...active, field];
                            onChanged(
                                MediaTemplateConfig(fields: fields));
                          },
                        );
                      }).toList(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
