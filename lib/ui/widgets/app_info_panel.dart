import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/app_info_provider.dart';

class AppInfoPanel extends ConsumerWidget {
  const AppInfoPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInfo = ref.watch(appInfoProvider);
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  'assets/branding/app_icon_1024.png',
                  width: 96,
                  height: 96,
                  filterQuality: FilterQuality.high,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'MediaShelf',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              appInfo.when(
                data: (info) => Text(
                  'Version ${info.version} (Build ${info.buildNumber})',
                  key: const ValueKey('app-version'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                loading: () => const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                error: (error, stackTrace) => Text(
                  'Versionsinformation nicht verfügbar',
                  style: TextStyle(color: colors.error),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Lokale Medienbibliothek für Bilder, Videos, Audio, '
                'Dokumente und weitere digitale Assets.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
