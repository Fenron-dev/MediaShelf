import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'asset_list_provider.dart';
import 'library_provider.dart';

// ── FolderNode ────────────────────────────────────────────────────────────────

class FolderNode {
  const FolderNode({
    required this.name,
    required this.fullPath,
    required this.children,
    this.fileCount = 0,
  });

  /// Display name (the last path segment).
  final String name;

  /// Full relative path ending with '/', e.g. "Fotos/Urlaub/".
  final String fullPath;

  final List<FolderNode> children;
  final int fileCount;

  /// Total count including all descendant directories.
  int get totalCount =>
      fileCount + children.fold(0, (sum, c) => sum + c.totalCount);
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// Derives the folder tree from unique directory paths in the DB.
/// Re-fetches whenever [scanVersionProvider] changes (after each scan).
final folderTreeProvider = FutureProvider<List<FolderNode>>((ref) async {
  // Re-run when a scan completes or meta changes
  ref.watch(scanVersionProvider);

  final dao = ref.watch(assetsDaoProvider);
  final paths = await dao.getDirPaths();
  final counts = await dao.getDirCounts();
  return _buildTree(paths, counts);
});

// ── Tree builder ──────────────────────────────────────────────────────────────

List<FolderNode> _buildTree(List<String> dirPaths, Map<String, int> counts) {
  // Build a map: fullPath → node (temporarily mutable children list)
  final Map<String, _MutableNode> nodes = {};

  for (final path in dirPaths) {
    // path e.g. "Fotos/Urlaub/" — walk every ancestor
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();
    for (var i = 0; i < segments.length; i++) {
      final cumPath =
          '${segments.sublist(0, i + 1).join('/')}/';
      nodes.putIfAbsent(
        cumPath,
        () => _MutableNode(
          name: segments[i],
          fullPath: cumPath,
          fileCount: counts[cumPath] ?? 0,
        ),
      );
    }
  }

  // Link children to parents
  final roots = <_MutableNode>[];
  for (final node in nodes.values) {
    final parentPath = _parentPath(node.fullPath);
    if (parentPath == null) {
      roots.add(node);
    } else {
      nodes[parentPath]?.children.add(node);
    }
  }

  // Sort recursively and convert to immutable FolderNode
  roots.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return roots.map(_toNode).toList();
}

FolderNode _toNode(_MutableNode m) {
  m.children.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  return FolderNode(
    name: m.name,
    fullPath: m.fullPath,
    children: m.children.map(_toNode).toList(),
    fileCount: m.fileCount,
  );
}

String? _parentPath(String fullPath) {
  // "A/B/C/" → "A/B/"
  final stripped = fullPath.substring(0, fullPath.length - 1); // remove trailing /
  final idx = stripped.lastIndexOf('/');
  if (idx < 0) return null;
  return '${stripped.substring(0, idx)}/';
}

class _MutableNode {
  _MutableNode({required this.name, required this.fullPath, this.fileCount = 0});
  final String name;
  final String fullPath;
  int fileCount;
  final List<_MutableNode> children = [];
}
