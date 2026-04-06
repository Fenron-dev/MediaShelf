import 'package:flutter/material.dart';

import '../../core/library_lock.dart';

/// Dialog shown when the user tries to open a password-protected library.
/// Returns `true` if the password was correct, `false`/null otherwise.
class LibraryLockDialog extends StatefulWidget {
  const LibraryLockDialog({super.key, required this.libraryPath});

  final String libraryPath;

  @override
  State<LibraryLockDialog> createState() => _LibraryLockDialogState();
}

class _LibraryLockDialogState extends State<LibraryLockDialog> {
  final _ctrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  bool _wrong = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _wrong = false;
    });

    final ok = await LibraryLock.verify(widget.libraryPath, _ctrl.text);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      setState(() => _wrong = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final libraryName = widget.libraryPath.split('/').last;

    return AlertDialog(
      icon: Icon(Icons.lock_outlined, color: cs.primary, size: 32),
      title: const Text('Bibliothek gesperrt'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '"$libraryName" ist passwortgeschützt.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ctrl,
                autofocus: true,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  prefixIcon: const Icon(Icons.key_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  errorText: _wrong ? 'Falsches Passwort' : null,
                ),
                onFieldSubmitted: (_) => _submit(),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Passwort eingeben' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: _loading ? null : _submit,
          child: _loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Entsperren'),
        ),
      ],
    );
  }
}
