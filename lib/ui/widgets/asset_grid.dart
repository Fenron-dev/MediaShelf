import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../providers/asset_list_provider.dart';
import '../../providers/settings_provider.dart';
import 'asset_card.dart';

/// Infinite-scrolling grid of [AssetCard]s backed by [assetPageProvider].
class AssetGrid extends ConsumerStatefulWidget {
  const AssetGrid({super.key});

  @override
  ConsumerState<AssetGrid> createState() => _AssetGridState();
}

class _AssetGridState extends ConsumerState<AssetGrid> {
  final _scrollController = ScrollController();
  int _loadedPages = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      _loadMore();
    }
  }

  void _loadMore() {
    final total = ref.read(assetTotalProvider).valueOrNull ?? 0;
    final loaded = _loadedPages * kPageSize;
    if (loaded < total) {
      setState(() => _loadedPages++);
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbSize = ref.watch(thumbnailSizeProvider);
    final selectedId = ref.watch(selectedAssetIdProvider);
    final selectedIds = ref.watch(multiSelectProvider);

    // Collect all assets across loaded pages
    final allAssets = <dynamic>[];
    bool isLoading = false;

    for (var page = 0; page < _loadedPages; page++) {
      final pageAsync = ref.watch(assetPageProvider(page));
      pageAsync.when(
        data: (p) => allAssets.addAll(p.assets),
        loading: () => isLoading = true,
        error: (_, __) {},
      );
    }

    if (allAssets.isEmpty && isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (allAssets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No assets found', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: thumbSize.toDouble(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: allAssets.length + (isLoading ? 1 : 0),
      itemBuilder: (context, i) {
        if (i >= allAssets.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final asset = allAssets[i];
        return AssetCard(
          asset: asset,
          isSelected: selectedIds.contains(asset.id) || selectedId == asset.id,
          onTap: () {
            if (ref.read(isMultiSelectProvider)) {
              ref.read(multiSelectProvider.notifier).toggle(asset.id);
            } else {
              ref.read(selectedAssetIdProvider.notifier).state = asset.id;
            }
          },
          onLongPress: () {
            ref.read(multiSelectProvider.notifier).toggle(asset.id);
          },
        );
      },
    );
  }
}
