import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/library_lock.dart';
import '../../core/plugin_registry.dart';
import '../../providers/library_lock_provider.dart';
import '../../providers/library_provider.dart';
import '../../providers/media_template_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  MediaCategory _selectedCategory = MediaCategory.audio;
  bool _showPlugins = false;
  bool _showSecurity = false;

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
                      selected: !_showPlugins && _selectedCategory == cat,
                      selectedTileColor:
                          cs.primaryContainer.withValues(alpha: 0.3),
                      leading: Icon(_categoryIcon(cat), size: 20),
                      title: Text(cat.label),
                      trailing: Text(
                        '${templates.getTemplate(cat).fields.length}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => setState(() {
                        _selectedCategory = cat;
                        _showPlugins = false;
                      }),
                    )),
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Plugins',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ListTile(
                  dense: true,
                  selected: _showPlugins,
                  selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
                  leading: const Icon(Icons.extension_outlined, size: 20),
                  title: const Text('Plugins verwalten'),
                  trailing: Text(
                    '${registeredPlugins.length}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () => setState(() {
                    _showPlugins = true;
                    _showSecurity = false;
                  }),
                ),
                const Divider(height: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Text('Sicherheit',
                      style: Theme.of(context).textTheme.titleSmall),
                ),
                ListTile(
                  dense: true,
                  selected: _showSecurity,
                  selectedTileColor: cs.primaryContainer.withValues(alpha: 0.3),
                  leading: const Icon(Icons.shield_outlined, size: 20),
                  title: const Text('Bibliotheks-Schutz'),
                  onTap: () => setState(() {
                    _showSecurity = true;
                    _showPlugins = false;
                  }),
                ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),

          // ── Template editor / Plugin manager / Security ───────────────
          Expanded(
            child: _showSecurity
                ? const _SecurityPanel()
                : _showPlugins
                    ? const _PluginManager()
                    : _TemplateEditor(
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

// ── Plugin Manager ────────────────────────────────────────────────────────────

class _PluginManager extends ConsumerWidget {
  const _PluginManager();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plugins = registeredPlugins;
    final enabledMap = ref.watch(pluginEnabledProvider);
    final notifier = ref.read(pluginEnabledProvider.notifier);

    if (plugins.isEmpty) {
      return Center(
        child: Text(
          'Keine Plugins installiert.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: plugins.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final plugin = plugins[i];
        final enabled = enabledMap[plugin.id] ?? true;
        final hasSettings = plugin.settingsPage(context, ref) != null;
        return ListTile(
          leading: Icon(plugin.icon),
          title: Text(plugin.displayName),
          subtitle: Text(
            plugin.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSettings)
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 18),
                  tooltip: '${plugin.displayName} Einstellungen',
                  onPressed: () => context.push(
                    '/library/settings/plugin/${plugin.id}',
                  ),
                ),
              Switch(
                value: enabled,
                onChanged: (v) => notifier.setEnabled(plugin.id, v),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Security Panel ────────────────────────────────────────────────────────────

class _SecurityPanel extends ConsumerStatefulWidget {
  const _SecurityPanel();

  @override
  ConsumerState<_SecurityPanel> createState() => _SecurityPanelState();
}

class _SecurityPanelState extends ConsumerState<_SecurityPanel> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final libraryPath = ref.watch(libraryPathProvider);
    if (libraryPath == null) {
      return const Center(child: Text('Keine Bibliothek geöffnet.'));
    }

    final isLocked = ref.watch(libraryLockedProvider);
    final obfuscated = ref.watch(filenamesObfuscatedProvider);
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── App-Lock ─────────────────────────────────────────────────────
        Text('App-Lock', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Beim Öffnen dieser Bibliothek wird ein Passwort verlangt. '
          'Die Dateien auf der Festplatte bleiben unverändert.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: isLocked,
          title: const Text('Bibliothek mit Passwort schützen'),
          subtitle: Text(isLocked ? 'Aktiv' : 'Deaktiviert'),
          onChanged: _loading ? null : (v) => v ? _enable(libraryPath) : _disable(libraryPath),
        ),
        if (isLocked) ...[
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('Passwort ändern'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _loading ? null : () => _changePassword(libraryPath),
          ),
        ],

        const Divider(height: 32),

        // ── Dateinamen-Verschleierung ─────────────────────────────────────
        Text('Dateinamen-Verschleierung',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          'Dateien werden beim Import unter zufälligen UUIDs gespeichert '
          '(z.B. "3f9a1b2c.jpg"). Der Ordner auf der Festplatte verrät '
          'so keine Dateinamen. Nur für neue Importe wirksam.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: obfuscated,
          title: const Text('Dateinamen verschleiern'),
          subtitle: Text(obfuscated ? 'Aktiv — neue Dateien erhalten UUID-Namen' : 'Deaktiviert'),
          onChanged: isLocked && !_loading
              ? (v) async {
                  await LibraryLock.setObfuscateFilenames(libraryPath, v);
                  setState(() {});
                  // Force provider re-read
                  ref.invalidate(filenamesObfuscatedProvider);
                }
              : null,
        ),
        if (!isLocked)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              'Dateinamen-Verschleierung erfordert einen aktiven App-Lock.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
      ],
    );
  }

  Future<void> _enable(String libraryPath) async {
    final password = await _askPassword(context, isSetup: true);
    if (password == null || !mounted) return;
    setState(() => _loading = true);
    await LibraryLock.enable(libraryPath, password);
    ref.invalidate(libraryLockedProvider);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _disable(String libraryPath) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Schutz deaktivieren'),
        content: const Text('Der Passwortschutz wird entfernt. Fortfahren?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Deaktivieren')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    await LibraryLock.disable(libraryPath);
    await LibraryLock.setObfuscateFilenames(libraryPath, false);
    ref.invalidate(libraryLockedProvider);
    ref.invalidate(filenamesObfuscatedProvider);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _changePassword(String libraryPath) async {
    final password = await _askPassword(context, isSetup: true, title: 'Neues Passwort');
    if (password == null || !mounted) return;
    setState(() => _loading = true);
    final obfuscated = LibraryLock.filenamesObfuscated(libraryPath);
    await LibraryLock.enable(libraryPath, password, obfuscateFilenames: obfuscated);
    if (mounted) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort geändert')),
      );
    }
  }

  /// Shows a dialog to enter (and optionally confirm) a password.
  /// Returns the password or null if cancelled.
  static Future<String?> _askPassword(
    BuildContext context, {
    required bool isSetup,
    String title = 'Passwort festlegen',
  }) {
    final ctrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var obscure = true;

    return showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 320,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: ctrl,
                    autofocus: true,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Passwort',
                      suffixIcon: IconButton(
                        icon: Icon(obscure
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () => setSt(() => obscure = !obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Pflichtfeld';
                      if (v.length < 8) return 'Mindestens 8 Zeichen';
                      return null;
                    },
                  ),
                  if (isSetup) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmCtrl,
                      obscureText: obscure,
                      decoration: const InputDecoration(
                          labelText: 'Passwort bestätigen'),
                      validator: (v) => v != ctrl.text
                          ? 'Passwörter stimmen nicht überein'
                          : null,
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Abbrechen')),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.pop(ctx, ctrl.text);
                }
              },
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
  }
}
