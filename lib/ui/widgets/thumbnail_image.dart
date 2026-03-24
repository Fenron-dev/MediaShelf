import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../core/constants.dart';
import '../../core/mime_resolver.dart';
import '../../data/database/app_database.dart';
import '../../providers/library_provider.dart';

/// Shows the cached thumbnail for [asset], falling back to a placeholder icon.
class ThumbnailImage extends ConsumerWidget {
  final Asset asset;
  final BoxFit fit;

  const ThumbnailImage({
    super.key,
    required this.asset,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryPath = ref.watch(libraryPathProvider);
    if (libraryPath == null) return _Placeholder(asset.mimeType);

    final thumbPath = p.join(
      libraryPath,
      kMediashelfDir,
      kThumbDir,
      '${asset.contentHash ?? asset.id}.jpg',
    );

    final file = File(thumbPath);
    if (!file.existsSync()) {
      return _Placeholder(asset.mimeType);
    }

    return Image.file(
      file,
      fit: fit,
      cacheWidth: kThumbSize * 2,
      errorBuilder: (_, _, _) => _Placeholder(asset.mimeType),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String? mimeType;
  const _Placeholder(this.mimeType);

  @override
  Widget build(BuildContext context) {
    final category = mimeType != null
        ? categoryFromMime(mimeType!)
        : MimeCategory.other;

    return ColoredBox(
      color: _bgColor(category),
      child: Center(
        child: Icon(
          _icon(category),
          size: 32,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ),
    );
  }

  IconData _icon(MimeCategory cat) {
    switch (cat) {
      case MimeCategory.image:
        return Icons.image_outlined;
      case MimeCategory.video:
        return Icons.videocam_outlined;
      case MimeCategory.audio:
        return Icons.audiotrack_outlined;
      case MimeCategory.document:
        return Icons.description_outlined;
      case MimeCategory.text:
        return Icons.article_outlined;
      case MimeCategory.archive:
        return Icons.folder_zip_outlined;
      case MimeCategory.font:
        return Icons.text_fields_outlined;
      case MimeCategory.model:
        return Icons.view_in_ar_outlined;
      case MimeCategory.other:
        return Icons.insert_drive_file_outlined;
    }
  }

  Color _bgColor(MimeCategory cat) {
    switch (cat) {
      case MimeCategory.image:
        return const Color(0xFF4A6572);
      case MimeCategory.video:
        return const Color(0xFF6A4C93);
      case MimeCategory.audio:
        return const Color(0xFF1A535C);
      case MimeCategory.document:
        return const Color(0xFF4E5D6C);
      case MimeCategory.text:
        return const Color(0xFF5C6B73);
      case MimeCategory.archive:
        return const Color(0xFF7A5C3C);
      case MimeCategory.font:
        return const Color(0xFF3C5A7A);
      case MimeCategory.model:
        return const Color(0xFF3C7A5A);
      case MimeCategory.other:
        return const Color(0xFF5C5C5C);
    }
  }
}
