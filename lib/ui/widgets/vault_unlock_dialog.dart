import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/vault_provider.dart';

/// Dialog shown when the user clicks the locked Vault entry in the sidebar.
/// Handles both first-time setup (choose password) and regular unlock.
class VaultUnlockDialog extends ConsumerStatefulWidget {
  const VaultUnlockDialog({super.key});

  @override
  ConsumerState<VaultUnlockDialog> createState() => _VaultUnlockDialogState();
}

class _VaultUnlockDialogState extends ConsumerState<VaultUnlockDialog> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _isSetup =>
      ref.read(vaultProvider).status == VaultStatus.notConfigured;

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    final notifier = ref.read(vaultProvider.notifier);
    bool success;

    if (_isSetup) {
      success = await notifier.setup(_passwordCtrl.text);
    } else {
      success = await notifier.unlock(_passwordCtrl.text);
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.of(context).pop();
      context.push('/library/vault');
    } else {
      setState(() => _error = 'Falsches Passwort. Bitte erneut versuchen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSetup = _isSetup;

    return AlertDialog(
      icon: Icon(
        isSetup ? Icons.lock_outlined : Icons.lock_open_outlined,
        color: cs.primary,
        size: 32,
      ),
      title: Text(isSetup ? 'Vault einrichten' : 'Vault entsperren'),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSetup) ...[
                Text(
                  'Wähle ein sicheres Passwort für deinen Vault. '
                  'Es gibt keine Passwort-Wiederherstellung — '
                  'vergissst du es, sind die Dateien nicht mehr zugänglich.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _passwordCtrl,
                autofocus: true,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  prefixIcon: const Icon(Icons.key_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onFieldSubmitted: (_) => isSetup ? null : _submit(),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Passwort eingeben';
                  if (isSetup && v.length < 8) {
                    return 'Mindestens 8 Zeichen';
                  }
                  return null;
                },
              ),
              if (isSetup) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscure,
                  decoration: const InputDecoration(
                    labelText: 'Passwort bestätigen',
                    prefixIcon: Icon(Icons.key_outlined),
                  ),
                  onFieldSubmitted: (_) => _submit(),
                  validator: (v) {
                    if (v != _passwordCtrl.text) {
                      return 'Passwörter stimmen nicht überein';
                    }
                    return null;
                  },
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.error_outline, size: 16, color: cs.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: cs.error, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(),
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
              : Text(isSetup ? 'Vault erstellen' : 'Entsperren'),
        ),
      ],
    );
  }
}
