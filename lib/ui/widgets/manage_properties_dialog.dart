import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';
import '../../providers/properties_provider.dart';

Future<void> showManagePropertiesDialog(
  BuildContext context,
  WidgetRef ref,
) {
  return showDialog(
    context: context,
    builder: (ctx) => _ManagePropertiesDialog(ref: ref),
  );
}

class _ManagePropertiesDialog extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _ManagePropertiesDialog({required this.ref});

  @override
  ConsumerState<_ManagePropertiesDialog> createState() =>
      _ManagePropertiesDialogState();
}

class _ManagePropertiesDialogState
    extends ConsumerState<_ManagePropertiesDialog> {
  bool _showForm = false;
  PropertyDefinition? _editing;

  // Form state
  final _nameCtrl = TextEditingController();
  String _fieldType = 'text';
  final _optionsCtrl = TextEditingController();

  static const _typeLabels = {
    'text': 'Text',
    'number': 'Number',
    'boolean': 'Yes/No',
    'date': 'Date',
    'select': 'Select (single)',
    'multiselect': 'Select (multi)',
    'tags': 'Tags',
    'list': 'List',
    'url': 'URL',
  };

  @override
  void dispose() {
    _nameCtrl.dispose();
    _optionsCtrl.dispose();
    super.dispose();
  }

  void _startCreate() {
    _editing = null;
    _nameCtrl.clear();
    _fieldType = 'text';
    _optionsCtrl.clear();
    setState(() => _showForm = true);
  }

  void _startEdit(PropertyDefinition def) {
    _editing = def;
    _nameCtrl.text = def.name;
    _fieldType = def.fieldType;
    if (def.optionsJson != null) {
      try {
        final opts = (jsonDecode(def.optionsJson!) as List).cast<String>();
        _optionsCtrl.text = opts.join(', ');
      } catch (_) {
        _optionsCtrl.clear();
      }
    } else {
      _optionsCtrl.clear();
    }
    setState(() => _showForm = true);
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    final dao = ref.read(propertiesDaoProvider);
    List<String>? options;
    if (_fieldType == 'select' || _fieldType == 'multiselect') {
      options = _optionsCtrl.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    if (_editing != null) {
      await dao.updateDefinition(
        id: _editing!.id,
        name: name,
        fieldType: _fieldType,
        options: options,
      );
    } else {
      await dao.createDefinition(
        name: name,
        fieldType: _fieldType,
        options: options,
      );
    }
    setState(() => _showForm = false);
  }

  Future<void> _delete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Property'),
        content: const Text(
          'This will remove the property and all its values from every asset.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(propertiesDaoProvider).deleteDefinition(id);
  }

  @override
  Widget build(BuildContext context) {
    final defsAsync = ref.watch(propertyDefsProvider);

    return AlertDialog(
      title: const Text('Custom Properties'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Definitions list
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: defsAsync.when(
                data: (defs) => defs.isEmpty && !_showForm
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text(
                          'No custom properties yet. Add one below.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: defs.length,
                        itemBuilder: (_, i) {
                          final def = defs[i];
                          return ListTile(
                            dense: true,
                            title: Text(def.name),
                            subtitle:
                                Text(_typeLabels[def.fieldType] ?? def.fieldType),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Edit',
                                  onPressed: () => _startEdit(def),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  tooltip: 'Delete',
                                  onPressed: () => _delete(def.id),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              ),
            ),

            // Inline form
            if (_showForm) ...[
              const Divider(),
              Text(
                _editing != null ? 'Edit property' : 'New property',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                key: ValueKey(_fieldType),
                initialValue: _fieldType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _typeLabels.entries
                    .map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _fieldType = v);
                },
              ),
              if (_fieldType == 'select' || _fieldType == 'multiselect') ...[
                const SizedBox(height: 8),
                TextField(
                  controller: _optionsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Options (comma separated)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => setState(() => _showForm = false),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (!_showForm)
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add property'),
            onPressed: _startCreate,
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
