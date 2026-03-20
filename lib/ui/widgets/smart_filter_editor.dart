import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';

// ── Rule model ────────────────────────────────────────────────────────────────

class _Rule {
  _Rule({required this.field, required this.op, this.value = ''});
  String field;
  String op;
  String value;

  Map<String, String> toJson() => {'field': field, 'op': op, 'value': value};
}

// ── Field & operator metadata ─────────────────────────────────────────────────

const _fields = [
  ('rating', 'Rating'),
  ('color_label', 'Color Label'),
  ('tag', 'Tag'),
  ('mime_type', 'File Type'),
  ('extension', 'Extension'),
  ('has_resume', 'Resume'),
];

Map<String, List<(String, String)>> get _opsFor => {
      'rating': [('gte', '≥'), ('lte', '≤'), ('eq', '=')],
      'color_label': [('eq', 'is'), ('isset', 'is set'), ('notset', 'not set')],
      'tag': [('eq', 'is')],
      'mime_type': [
        ('startswith', 'starts with'),
        ('eq', 'equals'),
        ('isset', 'is set'),
        ('notset', 'not set'),
      ],
      'extension': [('eq', 'equals')],
      'has_resume': [('isset', 'has resume'), ('notset', 'no resume')],
    };

// ── Pre-filled value suggestions ──────────────────────────────────────────────

const _mimePresets = [
  ('image/', 'Images'),
  ('video/', 'Videos'),
  ('audio/', 'Audio'),
  ('application/pdf', 'PDF'),
];

const _colorPresets = ['red', 'orange', 'yellow', 'green', 'blue', 'purple'];

// ── Public API ────────────────────────────────────────────────────────────────

/// Opens the smart-filter editor dialog.
/// If [existing] is provided the filter is edited in place, otherwise created.
Future<void> showSmartFilterEditor(
  BuildContext context,
  WidgetRef ref, {
  Collection? existing,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => _SmartFilterDialog(ref: ref, existing: existing),
  );
}

// ── Dialog ────────────────────────────────────────────────────────────────────

class _SmartFilterDialog extends StatefulWidget {
  final WidgetRef ref;
  final Collection? existing;

  const _SmartFilterDialog({required this.ref, this.existing});

  @override
  State<_SmartFilterDialog> createState() => _SmartFilterDialogState();
}

class _SmartFilterDialogState extends State<_SmartFilterDialog> {
  late final TextEditingController _nameCtrl;
  String _logic = 'AND';
  final List<_Rule> _rules = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameCtrl = TextEditingController(text: existing?.name ?? '');
    if (existing?.smartFilterQuery != null) {
      _loadFrom(existing!.smartFilterQuery!);
    } else {
      _rules.add(_Rule(field: 'rating', op: 'gte', value: '1'));
    }
  }

  void _loadFrom(String json) {
    try {
      final q = jsonDecode(json) as Map<String, dynamic>;
      _logic = (q['logic'] as String?) ?? 'AND';
      final rules = (q['rules'] as List?) ?? [];
      for (final r in rules) {
        final m = r as Map<String, dynamic>;
        _rules.add(_Rule(
          field: (m['field'] as String?) ?? 'rating',
          op: (m['op'] as String?) ?? 'gte',
          value: (m['value'] as String?) ?? '',
        ));
      }
    } catch (_) {}
  }

  String _buildJson() {
    return jsonEncode({
      'logic': _logic,
      'rules': _rules.map((r) => r.toJson()).toList(),
    });
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final dao = widget.ref.read(collectionsDaoProvider);
      final json = _buildJson();
      if (widget.existing != null) {
        await dao.updateCollection(
          id: widget.existing!.id,
          name: name,
          smartFilterQuery: Value(json),
        );
      } else {
        await dao.createSmartFilter(
          id: const Uuid().v4(),
          name: name,
          queryJson: json,
        );
      }
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing != null ? 'Edit Smart Filter' : 'New Smart Filter'),
      contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      content: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Name
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Filter name',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),

            // Logic toggle
            Row(
              children: [
                const Text('Match  '),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'AND', label: Text('ALL rules')),
                    ButtonSegment(value: 'OR', label: Text('ANY rule')),
                  ],
                  selected: {_logic},
                  onSelectionChanged: (s) => setState(() => _logic = s.first),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Rules
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._rules.asMap().entries.map((entry) => _RuleRow(
                          index: entry.key,
                          rule: entry.value,
                          onChanged: () => setState(() {}),
                          onRemove: () => setState(() => _rules.removeAt(entry.key)),
                        )),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add rule'),
                      onPressed: () => setState(
                        () => _rules.add(_Rule(field: 'rating', op: 'gte', value: '1')),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ── Rule row ──────────────────────────────────────────────────────────────────

class _RuleRow extends StatefulWidget {
  final int index;
  final _Rule rule;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _RuleRow({
    required this.index,
    required this.rule,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  State<_RuleRow> createState() => _RuleRowState();
}

class _RuleRowState extends State<_RuleRow> {
  late final TextEditingController _valueCtrl;

  @override
  void initState() {
    super.initState();
    _valueCtrl = TextEditingController(text: widget.rule.value);
  }

  @override
  void dispose() {
    _valueCtrl.dispose();
    super.dispose();
  }

  bool get _needsValue {
    final op = widget.rule.op;
    return op != 'isset' && op != 'notset';
  }

  @override
  Widget build(BuildContext context) {
    final rule = widget.rule;
    final ops = _opsFor[rule.field] ?? [('eq', 'equals')];

    // Ensure op is valid for current field
    if (!ops.any((o) => o.$1 == rule.op)) {
      rule.op = ops.first.$1;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          // Field selector
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              initialValue: rule.field,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              items: _fields
                  .map((f) => DropdownMenuItem(value: f.$1, child: Text(f.$2)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  rule.field = v;
                  rule.op = (_opsFor[v] ?? [('eq', 'eq')]).first.$1;
                  rule.value = '';
                  _valueCtrl.text = '';
                });
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),

          // Operator selector
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<String>(
              initialValue: rule.op,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                isDense: true,
              ),
              items: ops
                  .map((o) => DropdownMenuItem(value: o.$1, child: Text(o.$2)))
                  .toList(),
              onChanged: (v) {
                if (v == null) return;
                setState(() => rule.op = v);
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 8),

          // Value input
          Expanded(
            flex: 3,
            child: _needsValue
                ? _buildValueInput(rule)
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: 4),

          // Remove
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: widget.onRemove,
            tooltip: 'Remove rule',
          ),
        ],
      ),
    );
  }

  Widget _buildValueInput(_Rule rule) {
    // Rating → numeric stepper via dropdown
    if (rule.field == 'rating') {
      return DropdownButtonFormField<String>(
        initialValue: rule.value.isEmpty ? '1' : rule.value,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
        items: ['0', '1', '2', '3', '4', '5']
            .map((v) => DropdownMenuItem(
                  value: v,
                  child: Row(
                    children: [
                      ...List.generate(
                        int.parse(v),
                        (_) => const Icon(Icons.star, size: 14, color: Colors.amber),
                      ),
                      if (v == '0') const Text('Unrated'),
                    ],
                  ),
                ))
            .toList(),
        onChanged: (v) {
          setState(() => rule.value = v ?? '1');
          widget.onChanged();
        },
      );
    }

    // Color label → preset buttons
    if (rule.field == 'color_label' && rule.op == 'eq') {
      return Wrap(
        spacing: 4,
        children: _colorPresets.map((c) {
          final selected = rule.value == c;
          return GestureDetector(
            onTap: () {
              setState(() => rule.value = c);
              widget.onChanged();
            },
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _colorValue(c),
                border: selected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.onSurface,
                        width: 2,
                      )
                    : null,
              ),
            ),
          );
        }).toList(),
      );
    }

    // MIME type → preset dropdown
    if (rule.field == 'mime_type' && rule.op == 'startswith') {
      final currentValue =
          _mimePresets.any((p) => p.$1 == rule.value) ? rule.value : _mimePresets.first.$1;
      return DropdownButtonFormField<String>(
        initialValue: currentValue,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          isDense: true,
        ),
        items: _mimePresets
            .map((p) => DropdownMenuItem(value: p.$1, child: Text(p.$2)))
            .toList(),
        onChanged: (v) {
          setState(() => rule.value = v ?? '');
          widget.onChanged();
        },
      );
    }

    // Default: text field
    return TextField(
      controller: _valueCtrl,
      decoration: InputDecoration(
        isDense: true,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        hintText: _hintFor(rule.field),
      ),
      onChanged: (v) {
        rule.value = v;
        widget.onChanged();
      },
    );
  }

  String _hintFor(String field) {
    switch (field) {
      case 'tag':
        return 'Tag name';
      case 'extension':
        return 'jpg, mp4 …';
      case 'mime_type':
        return 'image/jpeg …';
      default:
        return 'Value';
    }
  }

  Color _colorValue(String name) {
    switch (name) {
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'yellow':
        return Colors.yellow;
      case 'green':
        return Colors.green;
      case 'blue':
        return Colors.blue;
      case 'purple':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
