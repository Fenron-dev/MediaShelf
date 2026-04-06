import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/library_lock.dart';
import '../../providers/library_provider.dart';
import '../widgets/library_lock_dialog.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentLibrariesProvider);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Title
                Icon(
                  Icons.photo_library_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const Gap(16),
                Text(
                  'MediaShelf',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Gap(8),
                Text(
                  'Your local Digital Asset Manager',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const Gap(40),

                // Primary actions
                FilledButton.icon(
                  onPressed: () => _openLibrary(context, ref),
                  icon: const Icon(Icons.folder_open),
                  label: const Text('Open Library'),
                ),
                const Gap(12),
                OutlinedButton.icon(
                  onPressed: () => _createLibrary(context, ref),
                  icon: const Icon(Icons.create_new_folder_outlined),
                  label: const Text('Create New Library'),
                ),

                // Recent libraries
                recents.when(
                  data: (paths) {
                    if (paths.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Gap(32),
                        Text(
                          'Recent',
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const Gap(8),
                        ...paths.map(
                          (path) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.history, size: 18),
                            title: Text(
                              path.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              path,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            onTap: () => _openPath(context, ref, path),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () => ref
                                  .read(recentLibrariesProvider.notifier)
                                  .remove(path),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openLibrary(BuildContext context, WidgetRef ref) async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Open MediaShelf Library',
    );
    if (dir == null || !context.mounted) return;
    await _openPath(context, ref, dir);
  }

  Future<void> _createLibrary(BuildContext context, WidgetRef ref) async {
    final dir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Choose Folder for New Library',
    );
    if (dir == null || !context.mounted) return;

    try {
      final repo = ref.read(libraryRepositoryProvider);
      await repo.initLibrary(dir);
      ref.read(libraryPathProvider.notifier).state = dir;
      await ref.read(recentLibrariesProvider.notifier).add(dir);
      if (context.mounted) context.go('/library');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openPath(
    BuildContext context,
    WidgetRef ref,
    String path,
  ) async {
    // If the library has an App-Lock, require the password first.
    if (LibraryLock.isLocked(path)) {
      final unlocked = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => LibraryLockDialog(libraryPath: path),
      );
      if (unlocked != true || !context.mounted) return;
    }

    try {
      final repo = ref.read(libraryRepositoryProvider);
      await repo.openLibrary(path);
      ref.read(libraryPathProvider.notifier).state = path;
      await ref.read(recentLibrariesProvider.notifier).add(path);
      if (context.mounted) context.go('/library');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open library: $e')),
        );
      }
    }
  }
}
