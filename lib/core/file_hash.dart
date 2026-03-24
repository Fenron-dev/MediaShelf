import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Computes the MD5 hash of a file by streaming it in 64 KB chunks.
///
/// Returns the hex string (32 chars), matching Nexus Explorer's `md5::compute`.
/// Should be called via [computeFileHash] which wraps this in an isolate.
String _md5OfFile(String filePath) {
  final file = File(filePath);
  final md5 = md5Digest();
  final sink = md5.startChunkedConversion(_HashSink());

  final stream = file.openSync();
  const chunkSize = 65536; // 64 KB
  while (true) {
    final chunk = stream.readSync(chunkSize);
    if (chunk.isEmpty) break;
    sink.add(chunk);
  }
  stream.closeSync();
  sink.close();

  return (sink as _HashSink)._result;
}

class _HashSink implements Sink<Digest> {
  String _result = '';

  @override
  void add(Digest digest) {
    _result = digest.toString();
  }

  @override
  void close() {}
}

// Helper to create MD5 Hash object
Hash md5Digest() => md5;

/// Computes the MD5 hash of [filePath] in a background isolate.
///
/// Safe to call from the UI thread.
Future<String> computeFileHash(String filePath) {
  return compute(_md5OfFile, filePath);
}

/// Synchronous MD5 hash — use only from within isolates (e.g. scanner).
String computeFileHashSync(String filePath) {
  final file = File(filePath);
  final bytes = file.readAsBytesSync();
  return md5.convert(bytes).toString();
}

/// Efficient chunked synchronous hash for large files — use from isolates.
String computeFileHashSyncChunked(String filePath) {
  final file = File(filePath);
  final raf = file.openSync();
  final output = _HashSink();
  final input = md5.startChunkedConversion(output);

  const chunkSize = 65536;
  Uint8List chunk;
  do {
    chunk = raf.readSync(chunkSize);
    if (chunk.isNotEmpty) input.add(chunk);
  } while (chunk.length == chunkSize);

  raf.closeSync();
  input.close();
  return output._result;
}
