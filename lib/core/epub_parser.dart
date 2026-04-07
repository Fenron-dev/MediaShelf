import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';

/// A parsed chapter from an ePub file.
class EpubChapter {
  const EpubChapter({
    required this.index,
    required this.title,
    required this.htmlContent,
  });

  final int index;
  final String title;
  final String htmlContent;
}

/// Lightweight ePub parser — uses [archive] to unzip the epub,
/// reads the OPF spine, and extracts chapter HTML content.
class EpubParser {
  EpubParser._({
    required this.title,
    required this.author,
    required this.chapters,
  });

  final String title;
  final String author;
  final List<EpubChapter> chapters;

  /// Parse the epub file at [filePath]. Throws on invalid format.
  static Future<EpubParser> parse(String filePath) async {
    final bytes = await File(filePath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    // Step 1: find OPF path from META-INF/container.xml
    final containerFile = _findFile(archive, 'META-INF/container.xml');
    final container = XmlDocument.parse(
      String.fromCharCodes(containerFile.content as List<int>),
    );
    final opfPath = container
        .findAllElements('rootfile')
        .first
        .getAttribute('full-path')!;
    final opfDir = p.dirname(opfPath);

    // Step 2: parse OPF
    final opfFile = _findFile(archive, opfPath);
    final opf = XmlDocument.parse(
      String.fromCharCodes(opfFile.content as List<int>),
    );

    // Metadata
    final bookTitle = opf
            .findAllElements('dc:title')
            .firstOrNull
            ?.innerText ??
        p.basenameWithoutExtension(filePath);
    final bookAuthor = opf
            .findAllElements('dc:creator')
            .firstOrNull
            ?.innerText ??
        '';

    // Manifest: id -> href
    final manifest = <String, String>{};
    for (final item in opf.findAllElements('item')) {
      final id = item.getAttribute('id') ?? '';
      final href = item.getAttribute('href') ?? '';
      manifest[id] = href;
    }

    // Spine: ordered list of idrefs
    final spineItems = opf
        .findAllElements('itemref')
        .map((e) => e.getAttribute('idref') ?? '')
        .where((id) => id.isNotEmpty && manifest.containsKey(id))
        .toList();

    // Step 3: read chapter HTML
    final chapters = <EpubChapter>[];
    for (var i = 0; i < spineItems.length; i++) {
      final href = manifest[spineItems[i]]!;
      // href may be relative to opfDir
      final fullPath =
          opfDir.isEmpty ? href : p.posix.join(opfDir, href);
      // Strip any fragment (#...) from href
      final cleanPath = fullPath.split('#').first;
      final chapterFile = _findFileCaseInsensitive(archive, cleanPath);
      if (chapterFile == null) continue;

      final html = String.fromCharCodes(chapterFile.content as List<int>);
      final chapterTitle = _extractTitle(html) ?? 'Kapitel ${i + 1}';
      chapters.add(
        EpubChapter(index: i, title: chapterTitle, htmlContent: html),
      );
    }

    return EpubParser._(
      title: bookTitle,
      author: bookAuthor,
      chapters: chapters,
    );
  }

  static ArchiveFile _findFile(Archive archive, String path) {
    final norm = _normPath(path);
    return archive.files.firstWhere(
      (f) => _normPath(f.name) == norm,
      orElse: () => throw Exception('ePub: file not found: $path'),
    );
  }

  static ArchiveFile? _findFileCaseInsensitive(Archive archive, String path) {
    final norm = _normPath(path).toLowerCase();
    try {
      return archive.files.firstWhere(
        (f) => _normPath(f.name).toLowerCase() == norm,
      );
    } catch (_) {
      return null;
    }
  }

  static String _normPath(String path) =>
      path.replaceAll('\\', '/').replaceAll(RegExp(r'^/'), '');

  /// Extract the page title from the HTML <title> tag or first heading.
  static String? _extractTitle(String html) {
    final titleMatch = RegExp(
      r'<title[^>]*>(.*?)</title>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (titleMatch != null) {
      final t = titleMatch.group(1)?.trim() ?? '';
      if (t.isNotEmpty) return t;
    }
    final hMatch = RegExp(
      r'<h[123][^>]*>(.*?)</h[123]>',
      caseSensitive: false,
      dotAll: true,
    ).firstMatch(html);
    if (hMatch != null) {
      // Strip inner tags
      return hMatch.group(1)?.replaceAll(RegExp(r'<[^>]+>'), '').trim();
    }
    return null;
  }
}
