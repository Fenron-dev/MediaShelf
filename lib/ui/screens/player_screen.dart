import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final String assetId;
  const PlayerScreen({super.key, required this.assetId});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  Asset? _asset;

  @override
  void initState() {
    super.initState();
    _loadAsset();
  }

  Future<void> _loadAsset() async {
    final dao = ref.read(assetsDaoProvider);
    final asset = await dao.getById(widget.assetId);
    if (mounted) setState(() => _asset = asset);
  }

  @override
  Widget build(BuildContext context) {
    final asset = _asset;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(asset?.filename ?? ''),
      ),
      body: asset == null
          ? const Center(child: CircularProgressIndicator())
          : _PlayerBody(asset: asset),
    );
  }
}

class _PlayerBody extends ConsumerWidget {
  final Asset asset;
  const _PlayerBody({required this.asset});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Placeholder — full chewie/just_audio integration in Phase 1-D
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isAudio(asset.mimeType) ? Icons.music_note : Icons.play_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            asset.filename,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          if (asset.mimeType != null) ...[
            const SizedBox(height: 8),
            Text(
              asset.mimeType!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 32),
          Text(
            'Full player coming in Phase 1-D',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  bool _isAudio(String? mime) => mime?.startsWith('audio/') == true;
}
