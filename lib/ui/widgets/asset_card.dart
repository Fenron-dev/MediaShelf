import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/database/app_database.dart';
import '../../providers/asset_list_provider.dart';
import 'thumbnail_image.dart';

class AssetCard extends ConsumerWidget {
  final Asset asset;
  final bool isSelected;
  final VoidCallback? onTapDown;
  final VoidCallback? onDoubleTap;
  final VoidCallback? onLongPress;

  const AssetCard({
    super.key,
    required this.asset,
    this.isSelected = false,
    this.onTapDown,
    this.onDoubleTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMultiSelect = ref.watch(isMultiSelectProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final card = _buildCard(colorScheme, isMultiSelect);

    return Draggable<Asset>(
      data: asset,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.75,
          child: SizedBox(
            width: 80,
            height: 80,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: ThumbnailImage(asset: asset),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.4, child: card),
      child: card,
    );
  }

  Widget _buildCard(ColorScheme colorScheme, bool isMultiSelect) {
    return GestureDetector(
      onTapDown: onTapDown != null ? (_) => onTapDown!() : null,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 2,
          ),
          color: isSelected
              ? colorScheme.primaryContainer.withValues(alpha: 0.3)
              : colorScheme.surface,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ThumbnailImage(asset: asset),

              if (asset.colorLabel != null && (asset.colorLabel ?? '').isNotEmpty)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 4,
                  child: ColoredBox(color: _colorFromLabel(asset.colorLabel!)),
                ),

              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _BottomBar(asset: asset),
              ),

              if (isMultiSelect)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? colorScheme.primary
                          : Colors.white.withValues(alpha: 0.8),
                      border: Border.all(
                        color: isSelected ? colorScheme.primary : Colors.grey,
                        width: 2,
                      ),
                    ),
                    width: 20,
                    height: 20,
                    child: isSelected
                        ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
                        : null,
                  ),
                ),

              if ((asset.playbackPositionMs ?? 0) > 0)
                const Positioned(
                  top: 8,
                  left: 8,
                  child: _ResumeBadge(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorFromLabel(String label) {
    switch (label) {
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

class _BottomBar extends StatelessWidget {
  final Asset asset;
  const _BottomBar({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (asset.rating > 0)
            Row(
              children: List.generate(
                asset.rating,
                (_) => const Icon(Icons.star, size: 10, color: Colors.amber),
              ),
            ),
          Text(
            asset.filename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              shadows: [Shadow(color: Colors.black, blurRadius: 2)],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumeBadge extends StatelessWidget {
  const _ResumeBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Icon(Icons.play_arrow, size: 12, color: Colors.white),
    );
  }
}
