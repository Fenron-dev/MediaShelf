import 'package:flutter/material.dart';

import '../../domain/models/import_result.dart';

/// Shows all duplicate files and lets the user choose per-item:
/// skip / import (copy anyway) / link (add to collection, no copy).
class DuplicateDialog extends StatefulWidget {
  const DuplicateDialog({super.key, required this.duplicates});

  final List<DuplicateInfo> duplicates;

  @override
  State<DuplicateDialog> createState() => _DuplicateDialogState();
}

class _DuplicateDialogState extends State<DuplicateDialog> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Text('Duplikate gefunden (${widget.duplicates.length})'),
      contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      content: SizedBox(
        width: 560,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bulk actions bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Für alle:',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => _setAll(DuplicateChoice.skip),
                    child: const Text('Überspringen'),
                  ),
                  TextButton(
                    onPressed: () => _setAll(DuplicateChoice.link),
                    child: const Text('Verknüpfen'),
                  ),
                  TextButton(
                    onPressed: () => _setAll(DuplicateChoice.importCopy),
                    child: const Text('Importieren'),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: widget.duplicates.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) =>
                    _DuplicateTile(dup: widget.duplicates[i], onChanged: () => setState(() {})),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Abbrechen'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Bestätigen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _setAll(DuplicateChoice choice) {
    setState(() {
      for (final d in widget.duplicates) {
        d.choice = choice;
      }
    });
  }
}

class _DuplicateTile extends StatelessWidget {
  const _DuplicateTile({required this.dup, required this.onChanged});

  final DuplicateInfo dup;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // File icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.insert_drive_file_outlined,
                size: 22, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dup.existingAsset.filename,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Bereits in: ${dup.existingAsset.path}',
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Ziel: ${dup.destRelPath}',
                  style: TextStyle(
                      fontSize: 11, color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Choice chips
                Wrap(
                  spacing: 6,
                  children: [
                    _ChoiceChip(
                      label: 'Überspringen',
                      selected: dup.choice == DuplicateChoice.skip,
                      onTap: () {
                        dup.choice = DuplicateChoice.skip;
                        onChanged();
                      },
                    ),
                    _ChoiceChip(
                      label: 'Verknüpfen',
                      selected: dup.choice == DuplicateChoice.link,
                      onTap: () {
                        dup.choice = DuplicateChoice.link;
                        onChanged();
                      },
                    ),
                    _ChoiceChip(
                      label: 'Importieren',
                      selected: dup.choice == DuplicateChoice.importCopy,
                      onTap: () {
                        dup.choice = DuplicateChoice.importCopy;
                        onChanged();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? cs.onPrimary : cs.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
