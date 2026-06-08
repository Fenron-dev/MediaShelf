import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:mediashelf/core/safe_paths.dart';

void main() {
  group('safe paths', () {
    test('resolves a valid library-relative path', () async {
      final root = await Directory.systemTemp.createTemp('mediashelf_safe_');
      addTearDown(() => root.delete(recursive: true));

      final resolved = resolveLibraryRelativePath(root.path, 'docs/file.pdf');
      expect(
        resolved,
        endsWith(
          '${Platform.pathSeparator}docs${Platform.pathSeparator}file.pdf',
        ),
      );
    });

    test('rejects traversal paths', () async {
      final root = await Directory.systemTemp.createTemp('mediashelf_safe_');
      addTearDown(() => root.delete(recursive: true));

      expect(
        () => resolveLibraryRelativePath(root.path, '../escape.txt'),
        throwsA(isA<UnsafePathException>()),
      );
    });

    test('rejects symlink escapes', () async {
      final root = await Directory.systemTemp.createTemp('mediashelf_safe_');
      final outside = await Directory.systemTemp.createTemp(
        'mediashelf_outside_',
      );
      addTearDown(() => root.delete(recursive: true));
      addTearDown(() => outside.delete(recursive: true));

      final linkedDir = Directory(
        '${root.path}${Platform.pathSeparator}linked',
      );
      await Link(linkedDir.path).create(outside.path);

      expect(
        () => resolveLibraryRelativePath(root.path, 'linked/secret.txt'),
        throwsA(isA<UnsafePathException>()),
      );
    });
  });
}
