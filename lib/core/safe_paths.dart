import 'dart:io';

import 'package:path/path.dart' as p;

import 'constants.dart';

class UnsafePathException implements IOException {
  const UnsafePathException(this.message);

  final String message;

  @override
  String toString() => 'UnsafePathException: $message';
}

String normalizeStoredRelativePath(
  String relativePath, {
  String fieldName = 'path',
}) {
  final trimmed = relativePath.trim();
  if (trimmed.isEmpty) {
    throw UnsafePathException('$fieldName must not be empty.');
  }

  final slashNormalized = trimmed.replaceAll('\\', '/');
  if (slashNormalized.startsWith('/') ||
      slashNormalized.startsWith('~/') ||
      RegExp(r'^[A-Za-z]:').hasMatch(slashNormalized)) {
    throw UnsafePathException('$fieldName must be relative: "$relativePath"');
  }

  final normalized = p.posix.normalize(slashNormalized);
  final segments = p.posix.split(normalized).where((part) => part.isNotEmpty);
  if (segments.any((part) => part == '.' || part == '..')) {
    throw UnsafePathException(
      '$fieldName escapes the allowed root: "$relativePath"',
    );
  }

  final result = segments.join('/');
  if (result.isEmpty) {
    throw UnsafePathException('$fieldName must not resolve to the root.');
  }
  return result;
}

String sanitizeFilename(String filename, {String fallback = 'file'}) {
  final trimmed = filename.trim();
  if (trimmed.isEmpty) return fallback;

  final base = p.basename(trimmed.replaceAll('\\', '/')).trim();
  if (base.isEmpty || base == '.' || base == '..') {
    return fallback;
  }

  return base.replaceAll(RegExp(r'[/\\]'), '_');
}

String resolveLibraryRelativePath(
  String libraryPath,
  String relativePath, {
  bool requireExisting = false,
}) {
  final normalized = normalizeStoredRelativePath(relativePath);
  return resolveRelativePathWithinRoot(
    rootPath: libraryPath,
    relativePath: normalized,
    requireExisting: requireExisting,
  );
}

String resolveRelativePathWithinRoot({
  required String rootPath,
  required String relativePath,
  bool requireExisting = false,
}) {
  final rootCanonical = _canonicalizeExistingDirectory(rootPath);
  final candidate = p.normalize(
    p.join(rootCanonical, relativePath.replaceAll('/', p.separator)),
  );

  _ensureAncestorWithinRoot(rootCanonical, candidate);
  _ensureExistingPathWithinRoot(
    rootCanonical,
    candidate,
    requireExisting: requireExisting,
  );
  return candidate;
}

String resolveChildPathInDirectory(
  String directoryPath,
  String filename, {
  bool requireExisting = false,
}) {
  final safeName = sanitizeFilename(filename);
  return resolveRelativePathWithinRoot(
    rootPath: directoryPath,
    relativePath: safeName,
    requireExisting: requireExisting,
  );
}

String resolveThumbPath(String libraryPath, String contentHash) {
  final safeHash = sanitizeFilename(contentHash, fallback: 'thumb');
  return resolveRelativePathWithinRoot(
    rootPath: libraryPath,
    relativePath: '$kMediashelfDir/$kThumbDir/$safeHash.jpg',
  );
}

String resolveVaultStoragePath(String libraryPath, String storageName) {
  final safeName = sanitizeFilename(storageName, fallback: 'vault$kVaultExt');
  return resolveRelativePathWithinRoot(
    rootPath: libraryPath,
    relativePath: '$kMediashelfDir/$kVaultDir/$safeName',
  );
}

String _canonicalizeExistingDirectory(String path) {
  final dir = Directory(path);
  if (!dir.existsSync()) {
    throw UnsafePathException('Directory does not exist: $path');
  }
  return dir.resolveSymbolicLinksSync();
}

void _ensureAncestorWithinRoot(String rootCanonical, String candidate) {
  final ancestor = _nearestExistingAncestor(candidate);
  final resolvedAncestor = ancestor.resolveSymbolicLinksSync();
  if (!_isWithinRoot(rootCanonical, resolvedAncestor)) {
    throw UnsafePathException(
      'Resolved ancestor escapes the allowed root: $candidate',
    );
  }
}

void _ensureExistingPathWithinRoot(
  String rootCanonical,
  String candidate, {
  required bool requireExisting,
}) {
  final type = FileSystemEntity.typeSync(candidate, followLinks: false);
  if (type == FileSystemEntityType.notFound) {
    if (requireExisting) {
      throw UnsafePathException('Path does not exist: $candidate');
    }
    return;
  }

  final resolved = switch (type) {
    FileSystemEntityType.directory => Directory(
      candidate,
    ).resolveSymbolicLinksSync(),
    FileSystemEntityType.file => File(candidate).resolveSymbolicLinksSync(),
    FileSystemEntityType.link => Link(candidate).resolveSymbolicLinksSync(),
    FileSystemEntityType.notFound => candidate,
    _ => candidate,
  };

  if (!_isWithinRoot(rootCanonical, resolved)) {
    throw UnsafePathException(
      'Resolved path escapes the allowed root: $candidate',
    );
  }
}

FileSystemEntity _nearestExistingAncestor(String path) {
  var current = p.normalize(path);
  while (true) {
    final type = FileSystemEntity.typeSync(current, followLinks: false);
    if (type != FileSystemEntityType.notFound) {
      return switch (type) {
        FileSystemEntityType.directory => Directory(current),
        FileSystemEntityType.file => File(current),
        FileSystemEntityType.link => Link(current),
        FileSystemEntityType.notFound => Directory(current),
        _ => Directory(current),
      };
    }

    final parent = p.dirname(current);
    if (parent == current) {
      throw UnsafePathException('Unable to resolve a safe ancestor for $path');
    }
    current = parent;
  }
}

bool _isWithinRoot(String rootCanonical, String candidateCanonical) {
  final root = p.normalize(rootCanonical);
  final candidate = p.normalize(candidateCanonical);
  return candidate == root || p.isWithin(root, candidate);
}
