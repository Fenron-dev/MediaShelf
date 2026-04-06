/// Maps file extensions to MIME types.
///
/// Mirrors the coverage in Nexus Explorer's Rust backend.
/// Extensions are lowercase without a leading dot.
const Map<String, String> _extensionMimeMap = {
  // ── Images ────────────────────────────────────────────────────────────────
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'png': 'image/png',
  'gif': 'image/gif',
  'webp': 'image/webp',
  'bmp': 'image/bmp',
  'tiff': 'image/tiff',
  'tif': 'image/tiff',
  'svg': 'image/svg+xml',
  'ico': 'image/x-icon',
  'heic': 'image/heic',
  'avif': 'image/avif',
  'jxl': 'image/jxl',
  'raw': 'image/x-raw',
  'cr2': 'image/x-canon-cr2',
  'nef': 'image/x-nikon-nef',
  'arw': 'image/x-sony-arw',
  'dng': 'image/x-adobe-dng',

  // ── Videos ────────────────────────────────────────────────────────────────
  'mp4': 'video/mp4',
  'm4v': 'video/mp4',
  'mov': 'video/quicktime',
  'avi': 'video/x-msvideo',
  'mkv': 'video/x-matroska',
  'webm': 'video/webm',
  'flv': 'video/x-flv',
  'wmv': 'video/x-ms-wmv',
  'mpeg': 'video/mpeg',
  'mpg': 'video/mpeg',
  '3gp': 'video/3gpp',
  'ts': 'video/mp2t',
  'm2ts': 'video/mp2t',
  'mts': 'video/mp2t',

  // ── Audio ─────────────────────────────────────────────────────────────────
  'mp3': 'audio/mpeg',
  'flac': 'audio/flac',
  'ogg': 'audio/ogg',
  'oga': 'audio/ogg',
  'opus': 'audio/opus',
  'wav': 'audio/wav',
  'wave': 'audio/wav',
  'aac': 'audio/aac',
  'm4a': 'audio/mp4',
  'm4b': 'audio/mp4',   // audiobook
  'm4r': 'audio/mp4',   // ringtone
  'mp4a': 'audio/mp4',
  'caf': 'audio/x-caf',
  'wma': 'audio/x-ms-wma',
  'aiff': 'audio/aiff',
  'aif': 'audio/aiff',
  'aifc': 'audio/aiff',
  'alac': 'audio/x-alac',
  'ape': 'audio/x-ape',
  'wv': 'audio/x-wavpack',
  'mka': 'audio/x-matroska',
  'spx': 'audio/ogg',
  'mid': 'audio/midi',
  'midi': 'audio/midi',

  // ── Documents ─────────────────────────────────────────────────────────────
  'pdf': 'application/pdf',
  'epub': 'application/epub+zip',
  'doc': 'application/msword',
  'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  'xls': 'application/vnd.ms-excel',
  'xlsx': 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  'ppt': 'application/vnd.ms-powerpoint',
  'pptx': 'application/vnd.openxmlformats-officedocument.presentationml.presentation',
  'odt': 'application/vnd.oasis.opendocument.text',
  'ods': 'application/vnd.oasis.opendocument.spreadsheet',
  'odp': 'application/vnd.oasis.opendocument.presentation',
  'rtf': 'application/rtf',

  // ── Text / Code ───────────────────────────────────────────────────────────
  'txt': 'text/plain',
  'md': 'text/markdown',
  'markdown': 'text/markdown',
  'html': 'text/html',
  'htm': 'text/html',
  'css': 'text/css',
  'js': 'text/javascript',
  'json': 'application/json',
  'xml': 'application/xml',
  'yaml': 'text/yaml',
  'yml': 'text/yaml',
  'toml': 'text/toml',
  'csv': 'text/csv',
  'sh': 'application/x-sh',
  'bat': 'application/x-bat',
  'py': 'text/x-python',
  'dart': 'text/x-dart',
  'rs': 'text/x-rust',
  'go': 'text/x-go',
  'java': 'text/x-java',
  'kt': 'text/x-kotlin',
  'swift': 'text/x-swift',
  'cpp': 'text/x-c++src',
  'c': 'text/x-csrc',
  'h': 'text/x-chdr',
  'sql': 'application/sql',

  // ── Archives ──────────────────────────────────────────────────────────────
  'zip': 'application/zip',
  'tar': 'application/x-tar',
  'gz': 'application/gzip',
  '7z': 'application/x-7z-compressed',
  'rar': 'application/x-rar-compressed',

  // ── Fonts ─────────────────────────────────────────────────────────────────
  'ttf': 'font/ttf',
  'otf': 'font/otf',
  'woff': 'font/woff',
  'woff2': 'font/woff2',

  // ── 3D / Design ───────────────────────────────────────────────────────────
  'psd': 'image/vnd.adobe.photoshop',
  'ai': 'application/postscript',
  'sketch': 'application/zip',
  'fig': 'application/octet-stream',
  'blend': 'application/octet-stream',
  'fbx': 'application/octet-stream',
  'obj': 'model/obj',
  'mtl': 'model/mtl',
  'stl': 'model/stl',
  'glb': 'model/gltf-binary',
  'gltf': 'model/gltf+json',
};

/// Broad category derived from MIME type — used for icon selection and filters.
enum MimeCategory {
  image,
  video,
  audio,
  document,
  text,
  archive,
  font,
  model,
  other,
}

/// Returns the MIME type for [extension] (without leading dot, case-insensitive).
///
/// Falls back to `application/octet-stream` for unknown extensions.
String mimeTypeFromExtension(String extension) {
  return _extensionMimeMap[extension.toLowerCase()] ??
      'application/octet-stream';
}

/// Returns the [MimeCategory] for a given MIME type string.
MimeCategory categoryFromMime(String mimeType) {
  if (mimeType.startsWith('image/')) return MimeCategory.image;
  if (mimeType.startsWith('video/')) return MimeCategory.video;
  if (mimeType.startsWith('audio/')) return MimeCategory.audio;
  if (mimeType.startsWith('font/')) return MimeCategory.font;
  if (mimeType.startsWith('model/')) return MimeCategory.model;
  if (mimeType.startsWith('text/')) return MimeCategory.text;
  if (const {
    'application/pdf',
    'application/epub+zip',
    'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/vnd.ms-excel',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-powerpoint',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    'application/rtf',
  }.contains(mimeType)) {
    return MimeCategory.document;
  }
  if (const {
    'application/zip',
    'application/x-tar',
    'application/gzip',
    'application/x-7z-compressed',
    'application/x-rar-compressed',
  }.contains(mimeType)) {
    return MimeCategory.archive;
  }
  return MimeCategory.other;
}

/// Returns true if the MIME type corresponds to an image that can be
/// decoded by the `image` Dart package (used for thumbnail generation).
bool isDecodableImage(String mimeType) {
  return const {
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp',
    'image/bmp',
    'image/tiff',
  }.contains(mimeType);
}

/// Returns true for video MIME types.
bool isVideo(String mimeType) => mimeType.startsWith('video/');

/// Returns true for audio MIME types.
bool isAudio(String mimeType) => mimeType.startsWith('audio/');

/// Returns true if the file is a subtitle/caption file.
bool isSubtitle(String extension) {
  return const {'srt', 'vtt', 'ass', 'ssa'}.contains(extension.toLowerCase());
}
