import 'dart:io';
import 'dart:isolate';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

import '../../core/constants.dart';
import '../../core/mime_resolver.dart';

/// Input for a single thumbnail generation job.
class ThumbJob {
  const ThumbJob({
    required this.libraryPath,
    required this.assetId,
    required this.absFilePath,
    required this.mimeType,
    required this.contentHash,
  });
  final String libraryPath;
  final String assetId;
  final String absFilePath;
  final String mimeType;
  final String contentHash;
}

/// Returns the absolute path where a thumbnail is (or will be) stored.
String thumbPath(String libraryPath, String contentHash) => p.join(
      libraryPath,
      kMediashelfDir,
      kThumbDir,
      '$contentHash.jpg',
    );

/// Ensures a thumbnail exists for the given asset.
///
/// Returns the absolute path to the thumbnail file (existing or newly created).
/// Runs on the calling thread — wrap in [generateThumbnailInBackground] for UI use.
String ensureThumbnail(ThumbJob job) {
  final dest = thumbPath(job.libraryPath, job.contentHash);
  if (File(dest).existsSync()) return dest;

  // Ensure thumbnails directory exists
  Directory(p.dirname(dest)).createSync(recursive: true);

  if (isDecodableImage(job.mimeType)) {
    _generateImageThumb(job.absFilePath, dest);
  } else {
    _generatePlaceholder(job.mimeType, job.absFilePath, dest);
  }

  return dest;
}

/// Runs [ensureThumbnail] in a background isolate.
Future<String> generateThumbnailInBackground(ThumbJob job) =>
    Isolate.run(() => ensureThumbnail(job));

// ── Image thumbnail ──────────────────────────────────────────────────────────

void _generateImageThumb(String srcPath, String destPath) {
  try {
    final bytes = File(srcPath).readAsBytesSync();
    final original = img.decodeImage(bytes);
    if (original == null) {
      _generatePlaceholder('image/unknown', srcPath, destPath);
      return;
    }

    // Resize to fit kThumbSize×kThumbSize keeping aspect ratio
    final thumb = img.copyResize(
      original,
      width: kThumbSize,
      height: kThumbSize,
      maintainAspect: true,
      interpolation: img.Interpolation.linear,
    );

    // Center-crop to exactly kThumbSize×kThumbSize
    final cropped = img.copyCrop(
      thumb,
      x: (thumb.width - kThumbSize) ~/ 2,
      y: (thumb.height - kThumbSize) ~/ 2,
      width: kThumbSize,
      height: kThumbSize,
    );

    File(destPath).writeAsBytesSync(
      img.encodeJpg(cropped, quality: kThumbQuality),
    );
  } catch (_) {
    _generatePlaceholder('image/unknown', srcPath, destPath);
  }
}

// ── Placeholder thumbnail ────────────────────────────────────────────────────

/// Category color map — matches Nexus Explorer's visual language.
const _categoryColors = <String, (int, int, int)>{
  'image': (99, 102, 241),   // indigo
  'video': (239, 68, 68),    // red
  'audio': (234, 179, 8),    // yellow
  'document': (59, 130, 246), // blue
  'text': (107, 114, 128),   // gray
  'archive': (168, 85, 247), // purple
  'font': (236, 72, 153),    // pink
  'model': (20, 184, 166),   // teal
  'other': (75, 85, 99),     // dark gray
};

void _generatePlaceholder(
  String mimeType,
  String filePath,
  String destPath,
) {
  final category = categoryFromMime(mimeType);
  final categoryName = category.name;
  final (r, g, b) = _categoryColors[categoryName] ?? (75, 85, 99);

  final image = img.Image(width: kThumbSize, height: kThumbSize);

  // Fill background with category color
  img.fill(image, color: img.ColorRgb8(r, g, b));

  // Draw a darker rounded-rectangle card effect (inner shadow)
  final darkerR = (r * 0.75).round();
  final darkerG = (g * 0.75).round();
  final darkerB = (b * 0.75).round();
  img.fillRect(
    image,
    x1: 16,
    y1: 16,
    x2: kThumbSize - 16,
    y2: kThumbSize - 16,
    color: img.ColorRgb8(darkerR, darkerG, darkerB),
    radius: 8,
  );

  // Draw extension text in the center
  final ext = filePath.contains('.')
      ? filePath.split('.').last.toUpperCase()
      : '?';
  final displayExt = ext.length > 6 ? ext.substring(0, 6) : ext;

  img.drawString(
    image,
    displayExt,
    font: img.arial24,
    x: kThumbSize ~/ 2 - (displayExt.length * 7),
    y: kThumbSize ~/ 2 - 12,
    color: img.ColorRgb8(255, 255, 255),
  );

  File(destPath).writeAsBytesSync(
    img.encodeJpg(image, quality: kThumbQuality),
  );
}

// ── Batch generation ─────────────────────────────────────────────────────────

/// Generates thumbnails for a list of jobs using an isolate pool.
///
/// At most [poolSize] isolates run concurrently.
/// Returns a stream of completed thumbnail paths.
Stream<String> generateThumbnailBatch(
  List<ThumbJob> jobs, {
  int poolSize = kThumbIsolatePoolSize,
}) async* {
  // Process in chunks of [poolSize]
  for (var i = 0; i < jobs.length; i += poolSize) {
    final chunk = jobs.skip(i).take(poolSize).toList();
    final results = await Future.wait(
      chunk.map((job) => generateThumbnailInBackground(job)),
    );
    for (final path in results) {
      yield path;
    }
  }
}
