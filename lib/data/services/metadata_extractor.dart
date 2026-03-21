// ignore_for_file: avoid_catches_without_on_clauses
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

/// Extracted media metadata from a file.
class MediaMetadata {
  const MediaMetadata({
    this.mediaTitle,
    this.artist,
    this.album,
    this.genre,
    this.trackNumber,
    this.bitrate,
    this.sampleRate,
    this.author,
    this.publisher,
    this.pageCount,
    this.captureDate,
    this.cameraModel,
    this.durationMs,
    this.width,
    this.height,
  });

  final String? mediaTitle;
  final String? artist;
  final String? album;
  final String? genre;
  final int? trackNumber;
  final int? bitrate;
  final int? sampleRate;
  final String? author;
  final String? publisher;
  final int? pageCount;
  final String? captureDate;
  final String? cameraModel;
  final int? durationMs;
  final int? width;
  final int? height;

  bool get isEmpty =>
      mediaTitle == null &&
      artist == null &&
      album == null &&
      genre == null &&
      trackNumber == null &&
      bitrate == null &&
      sampleRate == null &&
      author == null &&
      publisher == null &&
      pageCount == null &&
      captureDate == null &&
      cameraModel == null &&
      durationMs == null &&
      width == null &&
      height == null;
}

/// Pure-Dart metadata extractor. Safe to call from any isolate.
Future<MediaMetadata> extractMetadata(String filePath, String mimeType) async {
  try {
    if (mimeType.startsWith('audio/mpeg') || filePath.endsWith('.mp3')) {
      return _readMp3(filePath);
    }
    if (mimeType == 'audio/mp4' ||
        mimeType == 'audio/x-m4a' ||
        mimeType == 'audio/m4b' ||
        mimeType == 'video/mp4' ||
        mimeType == 'video/m4v' ||
        filePath.endsWith('.m4a') ||
        filePath.endsWith('.m4b') ||
        filePath.endsWith('.mp4') ||
        filePath.endsWith('.m4v')) {
      return _readMp4(filePath);
    }
    if (mimeType == 'application/pdf' || filePath.endsWith('.pdf')) {
      return _readPdf(filePath);
    }
    if (mimeType == 'application/epub+zip' || filePath.endsWith('.epub')) {
      return _readEpub(filePath);
    }
    if (mimeType.startsWith('image/')) {
      return _readImageExif(filePath);
    }
  } catch (_) {}
  return const MediaMetadata();
}

// ── MP3 / ID3v2 ──────────────────────────────────────────────────────────────

MediaMetadata _readMp3(String path) {
  final file = File(path);
  final raf = file.openSync();
  try {
    final header = raf.readSync(10);
    if (header.length < 10) return const MediaMetadata();
    // Check ID3v2 magic
    if (header[0] != 0x49 || header[1] != 0x44 || header[2] != 0x33) {
      return const MediaMetadata();
    }
    // Total tag size (sync-safe int, 4 bytes)
    final tagSize = ((header[6] & 0x7F) << 21) |
        ((header[7] & 0x7F) << 14) |
        ((header[8] & 0x7F) << 7) |
        (header[9] & 0x7F);

    final tagBytes = raf.readSync(tagSize);
    final frames = _parseId3v2Frames(tagBytes);

    String? title = _id3Text(frames['TIT2']);
    String? artist = _id3Text(frames['TPE1']) ?? _id3Text(frames['TPE2']);
    String? album = _id3Text(frames['TALB']);
    String? genre = _id3Text(frames['TCON']);
    String? track = _id3Text(frames['TRCK']);
    String? year = _id3Text(frames['TYER']) ?? _id3Text(frames['TDRC']);

    int? trackNum;
    if (track != null) {
      trackNum = int.tryParse(track.split('/').first.trim());
    }

    // Estimate duration from CBR header in audio frames
    int? durationMs;
    try {
      final audioStart = tagSize + 10;
      raf.setPositionSync(audioStart);
      final frameHeader = raf.readSync(4);
      if (frameHeader.length == 4 &&
          frameHeader[0] == 0xFF &&
          (frameHeader[1] & 0xE0) == 0xE0) {
        final bitrateIndex = (frameHeader[2] >> 4) & 0xF;
        final sampleIndex = (frameHeader[2] >> 2) & 0x3;
        const bitrates = [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0];
        const sampleRates = [44100, 48000, 32000, 0];
        final br = bitrates[bitrateIndex];
        final sr = sampleRates[sampleIndex];
        if (br > 0 && sr > 0) {
          final fileSize = file.lengthSync();
          final audioSize = fileSize - audioStart;
          durationMs = ((audioSize * 8) / (br * 1000) * 1000).round();
        }
      }
    } catch (_) {}

    return MediaMetadata(
      mediaTitle: title,
      artist: artist,
      album: album,
      genre: _cleanGenre(genre),
      trackNumber: trackNum,
      captureDate: year,
      durationMs: durationMs,
    );
  } finally {
    raf.closeSync();
  }
}

Map<String, Uint8List> _parseId3v2Frames(Uint8List data) {
  final frames = <String, Uint8List>{};
  var pos = 0;
  while (pos + 10 <= data.length) {
    final id = String.fromCharCodes(data.sublist(pos, pos + 4));
    if (id == '\x00\x00\x00\x00') break;
    // Skip non-ASCII frame IDs
    if (!RegExp(r'^[A-Z0-9]{4}$').hasMatch(id)) { pos++; continue; }
    final size = (data[pos + 4] << 24) |
        (data[pos + 5] << 16) |
        (data[pos + 6] << 8) |
        data[pos + 7];
    if (size <= 0 || pos + 10 + size > data.length) break;
    frames[id] = data.sublist(pos + 10, pos + 10 + size);
    pos += 10 + size;
  }
  return frames;
}

String? _id3Text(Uint8List? data) {
  if (data == null || data.isEmpty) return null;
  try {
    final encoding = data[0];
    final content = data.sublist(1);
    String text;
    if (encoding == 1 || encoding == 2) {
      text = const Utf16Decoder().decodeUtf16(content);
    } else {
      text = latin1.decode(content, allowInvalid: true);
      // Try UTF-8 if latin1 looks wrong
      try { text = utf8.decode(content); } catch (_) {}
    }
    return text.replaceAll('\x00', '').trim().isEmpty
        ? null
        : text.replaceAll('\x00', '').trim();
  } catch (_) {
    return null;
  }
}

String? _cleanGenre(String? genre) {
  if (genre == null) return null;
  // ID3v1 numeric genre like "(17)" → try to resolve
  final match = RegExp(r'^\((\d+)\)').firstMatch(genre);
  if (match != null) {
    final idx = int.tryParse(match.group(1)!);
    if (idx != null && idx < _id3Genres.length) return _id3Genres[idx];
  }
  return genre.trim().isEmpty ? null : genre.trim();
}

const _id3Genres = [
  'Blues','Classic Rock','Country','Dance','Disco','Funk','Grunge','Hip-Hop',
  'Jazz','Metal','New Age','Oldies','Other','Pop','R&B','Rap','Reggae','Rock',
  'Techno','Industrial','Alternative','Ska','Death Metal','Pranks','Soundtrack',
  'Euro-Techno','Ambient','Trip-Hop','Vocal','Jazz+Funk','Fusion','Trance',
  'Classical','Instrumental','Acid','House','Game','Sound Clip','Gospel','Noise',
  'AlternRock','Bass','Soul','Punk','Space','Meditative','Instrumental Pop',
  'Instrumental Rock','Ethnic','Gothic','Darkwave','Techno-Industrial',
  'Electronic','Pop-Folk','Eurodance','Dream','Southern Rock','Comedy',
  'Cult','Gangsta','Top 40','Christian Rap','Pop/Funk','Jungle',
  'Native American','Cabaret','New Wave','Psychadelic','Rave','Showtunes',
  'Trailer','Lo-Fi','Tribal','Acid Punk','Acid Jazz','Polka','Retro',
  'Musical','Rock & Roll','Hard Rock',
];

// ── MP4 / M4A / M4B ──────────────────────────────────────────────────────────

MediaMetadata _readMp4(String path) {
  final file = File(path);
  final bytes = file.readAsBytesSync();
  final atoms = _parseAtoms(bytes, 0, bytes.length);

  // Walk moov → udta → meta → ilst
  final moov = _findAtom(atoms, 'moov');
  if (moov == null) return const MediaMetadata();

  String? title;
  String? artist;
  String? album;
  String? genre;
  int? trackNum;
  String? year;
  int? durationMs;
  int? sampleRate;

  // Duration from mvhd box
  final mvhd = _findAtomIn(bytes, moov, 'mvhd');
  if (mvhd != null) {
    final start = mvhd['start']! + 8;
    if (start + 24 <= bytes.length) {
      final version = bytes[start];
      if (version == 0 && start + 20 <= bytes.length) {
        final timeScale = _readUint32(bytes, start + 12);
        final duration = _readUint32(bytes, start + 16);
        if (timeScale > 0) {
          durationMs = ((duration / timeScale) * 1000).round();
        }
      }
    }
  }

  // Tags from ilst
  final udta = _findAtomIn(bytes, moov, 'udta');
  if (udta != null) {
    final meta = _findAtomIn(bytes, udta, 'meta');
    if (meta != null) {
      // meta has a 4-byte version/flags header before its children
      final metaStart = meta['start']! + 8 + 4;
      final metaEnd = meta['start']! + meta['size']!;
      final metaAtoms = _parseAtoms(bytes, metaStart, metaEnd);
      final ilst = metaAtoms['ilst'];
      if (ilst != null) {
        final ilstAtoms = _parseAtoms(bytes, ilst['start']! + 8, ilst['start']! + ilst['size']!);

        title = _readIlstText(bytes, ilstAtoms['\u00a9nam']);
        artist = _readIlstText(bytes, ilstAtoms['\u00a9ART']) ??
            _readIlstText(bytes, ilstAtoms['aART']);
        album = _readIlstText(bytes, ilstAtoms['\u00a9alb']);
        genre = _readIlstText(bytes, ilstAtoms['\u00a9gen']) ??
            _readIlstText(bytes, ilstAtoms['gnre']);
        year = _readIlstText(bytes, ilstAtoms['\u00a9day']);

        // Track number from trkn
        final trknAtom = ilstAtoms['trkn'];
        if (trknAtom != null) {
          final dataStart = trknAtom['start']! + 8 + 8 + 4; // atom header + data header + version/flags
          if (dataStart + 2 <= bytes.length) {
            trackNum = _readUint16(bytes, dataStart);
            if (trackNum == 0) trackNum = null;
          }
        }
      }
    }
  }

  return MediaMetadata(
    mediaTitle: title,
    artist: artist,
    album: album,
    genre: genre,
    trackNumber: trackNum,
    captureDate: year?.substring(0, year.length > 4 ? 4 : year.length),
    durationMs: durationMs,
    sampleRate: sampleRate,
  );
}

// Simple atom/box parser
Map<String, Map<String, int>> _parseAtoms(Uint8List bytes, int start, int end) {
  final atoms = <String, Map<String, int>>{};
  var pos = start;
  while (pos + 8 <= end) {
    final size = _readUint32(bytes, pos);
    if (size < 8 || pos + size > end + 1) break;
    final name = String.fromCharCodes(bytes.sublist(pos + 4, pos + 8));
    atoms[name] = {'start': pos, 'size': size};
    pos += size;
  }
  return atoms;
}

Map<String, int>? _findAtom(Map<String, Map<String, int>> atoms, String name) =>
    atoms[name];

Map<String, int>? _findAtomIn(
    Uint8List bytes, Map<String, int> parent, String name) {
  final start = parent['start']! + 8;
  final end = parent['start']! + parent['size']!;
  final children = _parseAtoms(bytes, start, end);
  return children[name];
}

String? _readIlstText(Uint8List bytes, Map<String, int>? atom) {
  if (atom == null) return null;
  // Find 'data' child inside this atom
  final start = atom['start']! + 8;
  final end = atom['start']! + atom['size']!;
  final children = _parseAtoms(bytes, start, end);
  final data = children['data'];
  if (data == null) return null;
  // data: 4 bytes size, 4 "data", 4 type (1=utf8), 4 locale, then text
  final textStart = data['start']! + 16;
  final textEnd = data['start']! + data['size']!;
  if (textStart >= textEnd) return null;
  try {
    return utf8.decode(bytes.sublist(textStart, textEnd)).trim();
  } catch (_) {
    return null;
  }
}

int _readUint32(Uint8List bytes, int offset) {
  if (offset + 4 > bytes.length) return 0;
  return (bytes[offset] << 24) |
      (bytes[offset + 1] << 16) |
      (bytes[offset + 2] << 8) |
      bytes[offset + 3];
}

int _readUint16(Uint8List bytes, int offset) {
  if (offset + 2 > bytes.length) return 0;
  return (bytes[offset] << 8) | bytes[offset + 1];
}

// ── PDF ───────────────────────────────────────────────────────────────────────

MediaMetadata _readPdf(String path) {
  final file = File(path);
  final raf = file.openSync();
  final size = raf.lengthSync();
  try {
    // Read head (first 64 KB) and tail (last 256 KB) — Info dict can be anywhere
    final headSize = size < 65536 ? size : 65536;
    raf.setPositionSync(0);
    final head = raf.readSync(headSize);
    final headStr = latin1.decode(head, allowInvalid: true);

    final tailBytes = size < 262144 ? size : 262144;
    final tailOffset = size - tailBytes;
    raf.setPositionSync(tailOffset);
    final tail = raf.readSync(tailBytes);
    final tailStr = latin1.decode(tail, allowInvalid: true);

    // /Count — page count (largest match wins to avoid /Count in sub-dicts)
    int? pageCount;
    for (final src in [tailStr, headStr]) {
      int best = 0;
      for (final m in RegExp(r'/Count\s+(\d+)').allMatches(src)) {
        final v = int.tryParse(m.group(1)!) ?? 0;
        if (v > best) best = v;
      }
      if (best > 0) {
        pageCount = best;
        break;
      }
    }

    // /Title and /Author — check both head and tail, prefer non-empty result
    String? title;
    String? author;
    for (final src in [headStr, tailStr]) {
      title ??= _pdfInfoField(src, 'Title');
      author ??= _pdfInfoField(src, 'Author');
      if (title != null && author != null) break;
    }

    return MediaMetadata(
      mediaTitle: title?.isEmpty == true ? null : title,
      author: author?.isEmpty == true ? null : author,
      pageCount: pageCount,
    );
  } finally {
    raf.closeSync();
  }
}

/// Extracts a PDF Info dictionary field value.
/// Handles both literal strings `/Field (text)` and
/// hex strings `/Field <FEFF...>` (UTF-16BE with BOM).
String? _pdfInfoField(String src, String field) {
  // Literal string: /Title (Some text)
  final litMatch = RegExp('/$field\\s*\\(').firstMatch(src);
  if (litMatch != null) {
    // Read until unescaped closing paren
    final start = litMatch.end;
    final buf = StringBuffer();
    var i = start;
    var depth = 1;
    while (i < src.length && depth > 0) {
      final ch = src[i];
      if (ch == '\\' && i + 1 < src.length) {
        buf.write(src[i + 1]);
        i += 2;
        continue;
      }
      if (ch == '(') depth++;
      else if (ch == ')') { depth--; if (depth == 0) break; }
      if (depth > 0) buf.write(ch);
      i++;
    }
    final text = buf.toString().trim();
    if (text.isNotEmpty) return text;
  }

  // Hex string: /Title <FEFF0048...>
  final hexMatch = RegExp('/$field\\s*<([0-9A-Fa-f\\s]+)>').firstMatch(src);
  if (hexMatch != null) {
    final hex = hexMatch.group(1)!.replaceAll(RegExp(r'\s'), '');
    final bytes = <int>[];
    for (var i = 0; i + 1 < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    if (bytes.length >= 2 &&
        ((bytes[0] == 0xFE && bytes[1] == 0xFF) ||
         (bytes[0] == 0xFF && bytes[1] == 0xFE))) {
      // UTF-16
      final text = const Utf16Decoder().decodeUtf16(bytes).trim();
      if (text.isNotEmpty) return text;
    } else {
      // Latin-1 hex
      try {
        final text = latin1.decode(bytes).trim();
        if (text.isNotEmpty) return text;
      } catch (_) {}
    }
  }
  return null;
}

// ── EPUB ─────────────────────────────────────────────────────────────────────

MediaMetadata _readEpub(String path) {
  // EPUB is a ZIP file. We parse it without an external zip library
  // by reading the local file headers to find container.xml and the OPF.
  try {
    final bytes = File(path).readAsBytesSync();
    // Find container.xml content
    final containerContent = _zipReadFile(bytes, 'META-INF/container.xml');
    if (containerContent == null) return const MediaMetadata();

    final containerStr = utf8.decode(containerContent, allowMalformed: true);
    // Extract OPF path from rootfile full-path="..."
    final opfMatch =
        RegExp(r'full-path="([^"]+)"').firstMatch(containerStr);
    if (opfMatch == null) return const MediaMetadata();

    final opfPath = opfMatch.group(1)!;
    final opfContent = _zipReadFile(bytes, opfPath);
    if (opfContent == null) return const MediaMetadata();

    final opfStr = utf8.decode(opfContent, allowMalformed: true);
    String? title = _xmlText(opfStr, 'dc:title');
    String? creator = _xmlText(opfStr, 'dc:creator');
    String? publisher = _xmlText(opfStr, 'dc:publisher');
    String? date = _xmlText(opfStr, 'dc:date');

    return MediaMetadata(
      mediaTitle: title,
      author: creator,
      publisher: publisher,
      captureDate: date?.substring(0, date.length > 4 ? 4 : date.length),
    );
  } catch (_) {
    return const MediaMetadata();
  }
}

String? _xmlText(String xml, String tag) {
  final match =
      RegExp('<$tag[^>]*>([^<]+)</$tag>').firstMatch(xml);
  return match?.group(1)?.trim();
}

/// Very small ZIP local-file reader (no dart:io ZIP support in isolates).
Uint8List? _zipReadFile(Uint8List zip, String filename) {
  // Local file header signature: PK\x03\x04
  var pos = 0;
  while (pos + 30 <= zip.length) {
    if (zip[pos] != 0x50 || zip[pos + 1] != 0x4B ||
        zip[pos + 2] != 0x03 || zip[pos + 3] != 0x04) {
      pos++;
      continue;
    }
    final nameLen = _readUint16(zip, pos + 26);
    final extraLen = _readUint16(zip, pos + 28);
    if (pos + 30 + nameLen > zip.length) break;
    final name = utf8.decode(zip.sublist(pos + 30, pos + 30 + nameLen),
        allowMalformed: true);
    final compressedSize = _readUint32(zip, pos + 18);
    final compression = _readUint16(zip, pos + 8);
    final dataStart = pos + 30 + nameLen + extraLen;

    if (name == filename) {
      if (compression == 0) {
        // Stored (no compression)
        return zip.sublist(dataStart, dataStart + compressedSize);
      }
      // For deflated files, fall back (would need inflate)
      return null;
    }
    pos = dataStart + compressedSize;
  }
  return null;
}

// ── Image EXIF ────────────────────────────────────────────────────────────────

MediaMetadata _readImageExif(String path) {
  try {
    final bytes = File(path).readAsBytesSync();
    // Only JPEG has EXIF via APP1 marker
    if (bytes.length < 4 || bytes[0] != 0xFF || bytes[1] != 0xD8) {
      return const MediaMetadata();
    }
    // Find APP1 (0xFFE1) segment
    var pos = 2;
    while (pos + 4 <= bytes.length) {
      if (bytes[pos] != 0xFF) { pos++; continue; }
      final marker = bytes[pos + 1];
      final segLen = (bytes[pos + 2] << 8) | bytes[pos + 3];
      if (marker == 0xE1) {
        // APP1 — check for "Exif\x00\x00"
        if (pos + 10 <= bytes.length &&
            bytes[pos + 4] == 0x45 && bytes[pos + 5] == 0x78 &&
            bytes[pos + 6] == 0x69 && bytes[pos + 7] == 0x66) {
          final exifStart = pos + 10;
          return _parseExif(bytes, exifStart);
        }
      }
      pos += 2 + segLen;
    }
  } catch (_) {}
  return const MediaMetadata();
}

MediaMetadata _parseExif(Uint8List bytes, int start) {
  if (start + 8 > bytes.length) return const MediaMetadata();
  final bigEndian = bytes[start] == 0x4D && bytes[start + 1] == 0x4D;

  int r16(int offset) {
    final o = start + offset;
    if (o + 2 > bytes.length) return 0;
    return bigEndian
        ? (bytes[o] << 8) | bytes[o + 1]
        : (bytes[o + 1] << 8) | bytes[o];
  }

  int r32(int offset) {
    final o = start + offset;
    if (o + 4 > bytes.length) return 0;
    return bigEndian
        ? (bytes[o] << 24) | (bytes[o + 1] << 16) | (bytes[o + 2] << 8) | bytes[o + 3]
        : (bytes[o + 3] << 24) | (bytes[o + 2] << 16) | (bytes[o + 1] << 8) | bytes[o];
  }

  String? readAscii(int valueOffset, int count) {
    final o = start + valueOffset;
    if (o + count > bytes.length) return null;
    return latin1.decode(bytes.sublist(o, o + count - 1)).trim();
  }

  final ifdOffset = r32(4);
  final numEntries = r16(ifdOffset);
  String? make;
  String? model;
  String? dateTime;
  int? width;
  int? height;

  for (var i = 0; i < numEntries; i++) {
    final entryOffset = ifdOffset + 2 + i * 12;
    if (entryOffset + 12 > bytes.length - start) break;
    final tag = r16(entryOffset);
    final count = r32(entryOffset + 4);
    final valueOrOffset = r32(entryOffset + 8);

    switch (tag) {
      case 0x010F: // Make
        if (count <= 4) {
          make = latin1.decode(bytes.sublist(start + entryOffset + 8, start + entryOffset + 8 + count - 1)).trim();
        } else {
          make = readAscii(valueOrOffset, count);
        }
      case 0x0110: // Model
        if (count <= 4) {
          model = latin1.decode(bytes.sublist(start + entryOffset + 8, start + entryOffset + 8 + count - 1)).trim();
        } else {
          model = readAscii(valueOrOffset, count);
        }
      case 0x0132: // DateTime
      case 0x9003: // DateTimeOriginal
        if (count == 20 && dateTime == null) {
          dateTime = readAscii(valueOrOffset, count);
        }
      case 0xA002: // PixelXDimension
        width = valueOrOffset;
      case 0xA003: // PixelYDimension
        height = valueOrOffset;
    }
  }

  final cameraModel = [make, model].whereType<String>().join(' ').trim();

  return MediaMetadata(
    cameraModel: cameraModel.isEmpty ? null : cameraModel,
    captureDate: dateTime,
    width: width,
    height: height,
  );
}

// UTF-16 decoder (minimal, for ID3v2)
class Utf16Decoder {
  const Utf16Decoder();

  String decodeUtf16(List<int> bytes) {
    if (bytes.length < 2) return '';
    bool bigEndian = true;
    int start = 0;
    // Check BOM
    if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
      bigEndian = false;
      start = 2;
    } else if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
      start = 2;
    }
    final buffer = StringBuffer();
    for (var i = start; i + 1 < bytes.length; i += 2) {
      final code = bigEndian
          ? (bytes[i] << 8) | bytes[i + 1]
          : (bytes[i + 1] << 8) | bytes[i];
      if (code == 0) break;
      buffer.writeCharCode(code);
    }
    return buffer.toString();
  }
}
