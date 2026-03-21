// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $AssetsTable extends Assets with TableInfo<$AssetsTable, Asset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _filenameMeta = const VerificationMeta(
    'filename',
  );
  @override
  late final GeneratedColumn<String> filename = GeneratedColumn<String>(
    'filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionMeta = const VerificationMeta(
    'extension',
  );
  @override
  late final GeneratedColumn<String> extension = GeneratedColumn<String>(
    'extension',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playbackPositionMsMeta =
      const VerificationMeta('playbackPositionMs');
  @override
  late final GeneratedColumn<int> playbackPositionMs = GeneratedColumn<int>(
    'playback_position_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phashMeta = const VerificationMeta('phash');
  @override
  late final GeneratedColumn<String> phash = GeneratedColumn<String>(
    'phash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('ok'),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _colorLabelMeta = const VerificationMeta(
    'colorLabel',
  );
  @override
  late final GeneratedColumn<String> colorLabel = GeneratedColumn<String>(
    'color_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileCreatedAtMeta = const VerificationMeta(
    'fileCreatedAt',
  );
  @override
  late final GeneratedColumn<int> fileCreatedAt = GeneratedColumn<int>(
    'file_created_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileModifiedAtMeta = const VerificationMeta(
    'fileModifiedAt',
  );
  @override
  late final GeneratedColumn<int> fileModifiedAt = GeneratedColumn<int>(
    'file_modified_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _indexedAtMeta = const VerificationMeta(
    'indexedAt',
  );
  @override
  late final GeneratedColumn<int> indexedAt = GeneratedColumn<int>(
    'indexed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTitleMeta = const VerificationMeta(
    'mediaTitle',
  );
  @override
  late final GeneratedColumn<String> mediaTitle = GeneratedColumn<String>(
    'media_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _trackNumberMeta = const VerificationMeta(
    'trackNumber',
  );
  @override
  late final GeneratedColumn<int> trackNumber = GeneratedColumn<int>(
    'track_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bitrateMeta = const VerificationMeta(
    'bitrate',
  );
  @override
  late final GeneratedColumn<int> bitrate = GeneratedColumn<int>(
    'bitrate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sampleRateMeta = const VerificationMeta(
    'sampleRate',
  );
  @override
  late final GeneratedColumn<int> sampleRate = GeneratedColumn<int>(
    'sample_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _publisherMeta = const VerificationMeta(
    'publisher',
  );
  @override
  late final GeneratedColumn<String> publisher = GeneratedColumn<String>(
    'publisher',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _captureDateMeta = const VerificationMeta(
    'captureDate',
  );
  @override
  late final GeneratedColumn<String> captureDate = GeneratedColumn<String>(
    'capture_date',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cameraModelMeta = const VerificationMeta(
    'cameraModel',
  );
  @override
  late final GeneratedColumn<String> cameraModel = GeneratedColumn<String>(
    'camera_model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    filename,
    extension,
    size,
    mimeType,
    width,
    height,
    durationMs,
    playbackPositionMs,
    contentHash,
    phash,
    status,
    rating,
    colorLabel,
    note,
    sourceUrl,
    fileCreatedAt,
    fileModifiedAt,
    indexedAt,
    mediaTitle,
    artist,
    album,
    genre,
    trackNumber,
    bitrate,
    sampleRate,
    author,
    publisher,
    pageCount,
    captureDate,
    cameraModel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Asset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('filename')) {
      context.handle(
        _filenameMeta,
        filename.isAcceptableOrUnknown(data['filename']!, _filenameMeta),
      );
    } else if (isInserting) {
      context.missing(_filenameMeta);
    }
    if (data.containsKey('extension')) {
      context.handle(
        _extensionMeta,
        extension.isAcceptableOrUnknown(data['extension']!, _extensionMeta),
      );
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('playback_position_ms')) {
      context.handle(
        _playbackPositionMsMeta,
        playbackPositionMs.isAcceptableOrUnknown(
          data['playback_position_ms']!,
          _playbackPositionMsMeta,
        ),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    if (data.containsKey('phash')) {
      context.handle(
        _phashMeta,
        phash.isAcceptableOrUnknown(data['phash']!, _phashMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('color_label')) {
      context.handle(
        _colorLabelMeta,
        colorLabel.isAcceptableOrUnknown(data['color_label']!, _colorLabelMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    }
    if (data.containsKey('file_created_at')) {
      context.handle(
        _fileCreatedAtMeta,
        fileCreatedAt.isAcceptableOrUnknown(
          data['file_created_at']!,
          _fileCreatedAtMeta,
        ),
      );
    }
    if (data.containsKey('file_modified_at')) {
      context.handle(
        _fileModifiedAtMeta,
        fileModifiedAt.isAcceptableOrUnknown(
          data['file_modified_at']!,
          _fileModifiedAtMeta,
        ),
      );
    }
    if (data.containsKey('indexed_at')) {
      context.handle(
        _indexedAtMeta,
        indexedAt.isAcceptableOrUnknown(data['indexed_at']!, _indexedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_indexedAtMeta);
    }
    if (data.containsKey('media_title')) {
      context.handle(
        _mediaTitleMeta,
        mediaTitle.isAcceptableOrUnknown(data['media_title']!, _mediaTitleMeta),
      );
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('track_number')) {
      context.handle(
        _trackNumberMeta,
        trackNumber.isAcceptableOrUnknown(
          data['track_number']!,
          _trackNumberMeta,
        ),
      );
    }
    if (data.containsKey('bitrate')) {
      context.handle(
        _bitrateMeta,
        bitrate.isAcceptableOrUnknown(data['bitrate']!, _bitrateMeta),
      );
    }
    if (data.containsKey('sample_rate')) {
      context.handle(
        _sampleRateMeta,
        sampleRate.isAcceptableOrUnknown(data['sample_rate']!, _sampleRateMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('publisher')) {
      context.handle(
        _publisherMeta,
        publisher.isAcceptableOrUnknown(data['publisher']!, _publisherMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('capture_date')) {
      context.handle(
        _captureDateMeta,
        captureDate.isAcceptableOrUnknown(
          data['capture_date']!,
          _captureDateMeta,
        ),
      );
    }
    if (data.containsKey('camera_model')) {
      context.handle(
        _cameraModelMeta,
        cameraModel.isAcceptableOrUnknown(
          data['camera_model']!,
          _cameraModelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Asset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Asset(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      filename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}filename'],
      )!,
      extension: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extension'],
      ),
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      ),
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      playbackPositionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playback_position_ms'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
      phash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phash'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      )!,
      colorLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_label'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      ),
      fileCreatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_created_at'],
      ),
      fileModifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_modified_at'],
      ),
      indexedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}indexed_at'],
      )!,
      mediaTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_title'],
      ),
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      trackNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_number'],
      ),
      bitrate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bitrate'],
      ),
      sampleRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sample_rate'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      publisher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}publisher'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      captureDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capture_date'],
      ),
      cameraModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}camera_model'],
      ),
    );
  }

  @override
  $AssetsTable createAlias(String alias) {
    return $AssetsTable(attachedDatabase, alias);
  }
}

class Asset extends DataClass implements Insertable<Asset> {
  /// UUID v4, stable identifier.
  final String id;

  /// Relative path from library root, forward slashes on all platforms.
  final String path;
  final String filename;
  final String? extension;

  /// File size in bytes.
  final int? size;
  final String? mimeType;

  /// Image/video width in pixels.
  final int? width;

  /// Image/video height in pixels.
  final int? height;

  /// Duration in milliseconds (audio/video).
  final int? durationMs;

  /// Saved playback position in milliseconds (resume support).
  final int? playbackPositionMs;

  /// MD5 hex string — used for move/rename detection.
  final String? contentHash;

  /// Perceptual hash (for future duplicate/similarity detection).
  final String? phash;

  /// 'ok' | 'missing'
  final String status;

  /// Star rating 0–5.
  final int rating;

  /// One of: red, yellow, green, blue, purple — or null.
  final String? colorLabel;

  /// Short user note / description (also indexed in FTS5).
  final String? note;
  final String? sourceUrl;

  /// Unix timestamp (ms) of OS file creation time.
  final int? fileCreatedAt;

  /// Unix timestamp (ms) of OS file modification time.
  final int? fileModifiedAt;

  /// Unix timestamp (ms) when this record was last scanned/indexed.
  final int indexedAt;

  /// Embedded title (from ID3 / MP4 atom / PDF Info / EPUB OPF).
  final String? mediaTitle;

  /// Artist / performer (audio) or director (video).
  final String? artist;

  /// Album name (audio).
  final String? album;

  /// Genre string.
  final String? genre;

  /// Track number (audio).
  final int? trackNumber;

  /// Bitrate in kbps.
  final int? bitrate;

  /// Sample rate in Hz (audio).
  final int? sampleRate;

  /// Author / creator (ebooks, PDFs, documents).
  final String? author;

  /// Publisher.
  final String? publisher;

  /// Page count (PDF, ebook).
  final int? pageCount;

  /// Capture / creation date from EXIF or metadata (ISO 8601 string).
  final String? captureDate;

  /// Camera make+model from EXIF.
  final String? cameraModel;
  const Asset({
    required this.id,
    required this.path,
    required this.filename,
    this.extension,
    this.size,
    this.mimeType,
    this.width,
    this.height,
    this.durationMs,
    this.playbackPositionMs,
    this.contentHash,
    this.phash,
    required this.status,
    required this.rating,
    this.colorLabel,
    this.note,
    this.sourceUrl,
    this.fileCreatedAt,
    this.fileModifiedAt,
    required this.indexedAt,
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
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['path'] = Variable<String>(path);
    map['filename'] = Variable<String>(filename);
    if (!nullToAbsent || extension != null) {
      map['extension'] = Variable<String>(extension);
    }
    if (!nullToAbsent || size != null) {
      map['size'] = Variable<int>(size);
    }
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    if (!nullToAbsent || playbackPositionMs != null) {
      map['playback_position_ms'] = Variable<int>(playbackPositionMs);
    }
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    if (!nullToAbsent || phash != null) {
      map['phash'] = Variable<String>(phash);
    }
    map['status'] = Variable<String>(status);
    map['rating'] = Variable<int>(rating);
    if (!nullToAbsent || colorLabel != null) {
      map['color_label'] = Variable<String>(colorLabel);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || sourceUrl != null) {
      map['source_url'] = Variable<String>(sourceUrl);
    }
    if (!nullToAbsent || fileCreatedAt != null) {
      map['file_created_at'] = Variable<int>(fileCreatedAt);
    }
    if (!nullToAbsent || fileModifiedAt != null) {
      map['file_modified_at'] = Variable<int>(fileModifiedAt);
    }
    map['indexed_at'] = Variable<int>(indexedAt);
    if (!nullToAbsent || mediaTitle != null) {
      map['media_title'] = Variable<String>(mediaTitle);
    }
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || trackNumber != null) {
      map['track_number'] = Variable<int>(trackNumber);
    }
    if (!nullToAbsent || bitrate != null) {
      map['bitrate'] = Variable<int>(bitrate);
    }
    if (!nullToAbsent || sampleRate != null) {
      map['sample_rate'] = Variable<int>(sampleRate);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || publisher != null) {
      map['publisher'] = Variable<String>(publisher);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    if (!nullToAbsent || captureDate != null) {
      map['capture_date'] = Variable<String>(captureDate);
    }
    if (!nullToAbsent || cameraModel != null) {
      map['camera_model'] = Variable<String>(cameraModel);
    }
    return map;
  }

  AssetsCompanion toCompanion(bool nullToAbsent) {
    return AssetsCompanion(
      id: Value(id),
      path: Value(path),
      filename: Value(filename),
      extension: extension == null && nullToAbsent
          ? const Value.absent()
          : Value(extension),
      size: size == null && nullToAbsent ? const Value.absent() : Value(size),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      playbackPositionMs: playbackPositionMs == null && nullToAbsent
          ? const Value.absent()
          : Value(playbackPositionMs),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
      phash: phash == null && nullToAbsent
          ? const Value.absent()
          : Value(phash),
      status: Value(status),
      rating: Value(rating),
      colorLabel: colorLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(colorLabel),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      sourceUrl: sourceUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceUrl),
      fileCreatedAt: fileCreatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fileCreatedAt),
      fileModifiedAt: fileModifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fileModifiedAt),
      indexedAt: Value(indexedAt),
      mediaTitle: mediaTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaTitle),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      trackNumber: trackNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNumber),
      bitrate: bitrate == null && nullToAbsent
          ? const Value.absent()
          : Value(bitrate),
      sampleRate: sampleRate == null && nullToAbsent
          ? const Value.absent()
          : Value(sampleRate),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      publisher: publisher == null && nullToAbsent
          ? const Value.absent()
          : Value(publisher),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      captureDate: captureDate == null && nullToAbsent
          ? const Value.absent()
          : Value(captureDate),
      cameraModel: cameraModel == null && nullToAbsent
          ? const Value.absent()
          : Value(cameraModel),
    );
  }

  factory Asset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Asset(
      id: serializer.fromJson<String>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      filename: serializer.fromJson<String>(json['filename']),
      extension: serializer.fromJson<String?>(json['extension']),
      size: serializer.fromJson<int?>(json['size']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      playbackPositionMs: serializer.fromJson<int?>(json['playbackPositionMs']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
      phash: serializer.fromJson<String?>(json['phash']),
      status: serializer.fromJson<String>(json['status']),
      rating: serializer.fromJson<int>(json['rating']),
      colorLabel: serializer.fromJson<String?>(json['colorLabel']),
      note: serializer.fromJson<String?>(json['note']),
      sourceUrl: serializer.fromJson<String?>(json['sourceUrl']),
      fileCreatedAt: serializer.fromJson<int?>(json['fileCreatedAt']),
      fileModifiedAt: serializer.fromJson<int?>(json['fileModifiedAt']),
      indexedAt: serializer.fromJson<int>(json['indexedAt']),
      mediaTitle: serializer.fromJson<String?>(json['mediaTitle']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      genre: serializer.fromJson<String?>(json['genre']),
      trackNumber: serializer.fromJson<int?>(json['trackNumber']),
      bitrate: serializer.fromJson<int?>(json['bitrate']),
      sampleRate: serializer.fromJson<int?>(json['sampleRate']),
      author: serializer.fromJson<String?>(json['author']),
      publisher: serializer.fromJson<String?>(json['publisher']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      captureDate: serializer.fromJson<String?>(json['captureDate']),
      cameraModel: serializer.fromJson<String?>(json['cameraModel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'path': serializer.toJson<String>(path),
      'filename': serializer.toJson<String>(filename),
      'extension': serializer.toJson<String?>(extension),
      'size': serializer.toJson<int?>(size),
      'mimeType': serializer.toJson<String?>(mimeType),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationMs': serializer.toJson<int?>(durationMs),
      'playbackPositionMs': serializer.toJson<int?>(playbackPositionMs),
      'contentHash': serializer.toJson<String?>(contentHash),
      'phash': serializer.toJson<String?>(phash),
      'status': serializer.toJson<String>(status),
      'rating': serializer.toJson<int>(rating),
      'colorLabel': serializer.toJson<String?>(colorLabel),
      'note': serializer.toJson<String?>(note),
      'sourceUrl': serializer.toJson<String?>(sourceUrl),
      'fileCreatedAt': serializer.toJson<int?>(fileCreatedAt),
      'fileModifiedAt': serializer.toJson<int?>(fileModifiedAt),
      'indexedAt': serializer.toJson<int>(indexedAt),
      'mediaTitle': serializer.toJson<String?>(mediaTitle),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'genre': serializer.toJson<String?>(genre),
      'trackNumber': serializer.toJson<int?>(trackNumber),
      'bitrate': serializer.toJson<int?>(bitrate),
      'sampleRate': serializer.toJson<int?>(sampleRate),
      'author': serializer.toJson<String?>(author),
      'publisher': serializer.toJson<String?>(publisher),
      'pageCount': serializer.toJson<int?>(pageCount),
      'captureDate': serializer.toJson<String?>(captureDate),
      'cameraModel': serializer.toJson<String?>(cameraModel),
    };
  }

  Asset copyWith({
    String? id,
    String? path,
    String? filename,
    Value<String?> extension = const Value.absent(),
    Value<int?> size = const Value.absent(),
    Value<String?> mimeType = const Value.absent(),
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    Value<int?> playbackPositionMs = const Value.absent(),
    Value<String?> contentHash = const Value.absent(),
    Value<String?> phash = const Value.absent(),
    String? status,
    int? rating,
    Value<String?> colorLabel = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<String?> sourceUrl = const Value.absent(),
    Value<int?> fileCreatedAt = const Value.absent(),
    Value<int?> fileModifiedAt = const Value.absent(),
    int? indexedAt,
    Value<String?> mediaTitle = const Value.absent(),
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> trackNumber = const Value.absent(),
    Value<int?> bitrate = const Value.absent(),
    Value<int?> sampleRate = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<String?> publisher = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    Value<String?> captureDate = const Value.absent(),
    Value<String?> cameraModel = const Value.absent(),
  }) => Asset(
    id: id ?? this.id,
    path: path ?? this.path,
    filename: filename ?? this.filename,
    extension: extension.present ? extension.value : this.extension,
    size: size.present ? size.value : this.size,
    mimeType: mimeType.present ? mimeType.value : this.mimeType,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    playbackPositionMs: playbackPositionMs.present
        ? playbackPositionMs.value
        : this.playbackPositionMs,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
    phash: phash.present ? phash.value : this.phash,
    status: status ?? this.status,
    rating: rating ?? this.rating,
    colorLabel: colorLabel.present ? colorLabel.value : this.colorLabel,
    note: note.present ? note.value : this.note,
    sourceUrl: sourceUrl.present ? sourceUrl.value : this.sourceUrl,
    fileCreatedAt: fileCreatedAt.present
        ? fileCreatedAt.value
        : this.fileCreatedAt,
    fileModifiedAt: fileModifiedAt.present
        ? fileModifiedAt.value
        : this.fileModifiedAt,
    indexedAt: indexedAt ?? this.indexedAt,
    mediaTitle: mediaTitle.present ? mediaTitle.value : this.mediaTitle,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    genre: genre.present ? genre.value : this.genre,
    trackNumber: trackNumber.present ? trackNumber.value : this.trackNumber,
    bitrate: bitrate.present ? bitrate.value : this.bitrate,
    sampleRate: sampleRate.present ? sampleRate.value : this.sampleRate,
    author: author.present ? author.value : this.author,
    publisher: publisher.present ? publisher.value : this.publisher,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    captureDate: captureDate.present ? captureDate.value : this.captureDate,
    cameraModel: cameraModel.present ? cameraModel.value : this.cameraModel,
  );
  Asset copyWithCompanion(AssetsCompanion data) {
    return Asset(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      filename: data.filename.present ? data.filename.value : this.filename,
      extension: data.extension.present ? data.extension.value : this.extension,
      size: data.size.present ? data.size.value : this.size,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      playbackPositionMs: data.playbackPositionMs.present
          ? data.playbackPositionMs.value
          : this.playbackPositionMs,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      phash: data.phash.present ? data.phash.value : this.phash,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      colorLabel: data.colorLabel.present
          ? data.colorLabel.value
          : this.colorLabel,
      note: data.note.present ? data.note.value : this.note,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      fileCreatedAt: data.fileCreatedAt.present
          ? data.fileCreatedAt.value
          : this.fileCreatedAt,
      fileModifiedAt: data.fileModifiedAt.present
          ? data.fileModifiedAt.value
          : this.fileModifiedAt,
      indexedAt: data.indexedAt.present ? data.indexedAt.value : this.indexedAt,
      mediaTitle: data.mediaTitle.present
          ? data.mediaTitle.value
          : this.mediaTitle,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      genre: data.genre.present ? data.genre.value : this.genre,
      trackNumber: data.trackNumber.present
          ? data.trackNumber.value
          : this.trackNumber,
      bitrate: data.bitrate.present ? data.bitrate.value : this.bitrate,
      sampleRate: data.sampleRate.present
          ? data.sampleRate.value
          : this.sampleRate,
      author: data.author.present ? data.author.value : this.author,
      publisher: data.publisher.present ? data.publisher.value : this.publisher,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      captureDate: data.captureDate.present
          ? data.captureDate.value
          : this.captureDate,
      cameraModel: data.cameraModel.present
          ? data.cameraModel.value
          : this.cameraModel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Asset(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('filename: $filename, ')
          ..write('extension: $extension, ')
          ..write('size: $size, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('playbackPositionMs: $playbackPositionMs, ')
          ..write('contentHash: $contentHash, ')
          ..write('phash: $phash, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('colorLabel: $colorLabel, ')
          ..write('note: $note, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('fileCreatedAt: $fileCreatedAt, ')
          ..write('fileModifiedAt: $fileModifiedAt, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('mediaTitle: $mediaTitle, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('bitrate: $bitrate, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('author: $author, ')
          ..write('publisher: $publisher, ')
          ..write('pageCount: $pageCount, ')
          ..write('captureDate: $captureDate, ')
          ..write('cameraModel: $cameraModel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    path,
    filename,
    extension,
    size,
    mimeType,
    width,
    height,
    durationMs,
    playbackPositionMs,
    contentHash,
    phash,
    status,
    rating,
    colorLabel,
    note,
    sourceUrl,
    fileCreatedAt,
    fileModifiedAt,
    indexedAt,
    mediaTitle,
    artist,
    album,
    genre,
    trackNumber,
    bitrate,
    sampleRate,
    author,
    publisher,
    pageCount,
    captureDate,
    cameraModel,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Asset &&
          other.id == this.id &&
          other.path == this.path &&
          other.filename == this.filename &&
          other.extension == this.extension &&
          other.size == this.size &&
          other.mimeType == this.mimeType &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationMs == this.durationMs &&
          other.playbackPositionMs == this.playbackPositionMs &&
          other.contentHash == this.contentHash &&
          other.phash == this.phash &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.colorLabel == this.colorLabel &&
          other.note == this.note &&
          other.sourceUrl == this.sourceUrl &&
          other.fileCreatedAt == this.fileCreatedAt &&
          other.fileModifiedAt == this.fileModifiedAt &&
          other.indexedAt == this.indexedAt &&
          other.mediaTitle == this.mediaTitle &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.genre == this.genre &&
          other.trackNumber == this.trackNumber &&
          other.bitrate == this.bitrate &&
          other.sampleRate == this.sampleRate &&
          other.author == this.author &&
          other.publisher == this.publisher &&
          other.pageCount == this.pageCount &&
          other.captureDate == this.captureDate &&
          other.cameraModel == this.cameraModel);
}

class AssetsCompanion extends UpdateCompanion<Asset> {
  final Value<String> id;
  final Value<String> path;
  final Value<String> filename;
  final Value<String?> extension;
  final Value<int?> size;
  final Value<String?> mimeType;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationMs;
  final Value<int?> playbackPositionMs;
  final Value<String?> contentHash;
  final Value<String?> phash;
  final Value<String> status;
  final Value<int> rating;
  final Value<String?> colorLabel;
  final Value<String?> note;
  final Value<String?> sourceUrl;
  final Value<int?> fileCreatedAt;
  final Value<int?> fileModifiedAt;
  final Value<int> indexedAt;
  final Value<String?> mediaTitle;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> genre;
  final Value<int?> trackNumber;
  final Value<int?> bitrate;
  final Value<int?> sampleRate;
  final Value<String?> author;
  final Value<String?> publisher;
  final Value<int?> pageCount;
  final Value<String?> captureDate;
  final Value<String?> cameraModel;
  final Value<int> rowid;
  const AssetsCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.filename = const Value.absent(),
    this.extension = const Value.absent(),
    this.size = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playbackPositionMs = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.phash = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.colorLabel = const Value.absent(),
    this.note = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.fileCreatedAt = const Value.absent(),
    this.fileModifiedAt = const Value.absent(),
    this.indexedAt = const Value.absent(),
    this.mediaTitle = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.bitrate = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.author = const Value.absent(),
    this.publisher = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.captureDate = const Value.absent(),
    this.cameraModel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetsCompanion.insert({
    required String id,
    required String path,
    required String filename,
    this.extension = const Value.absent(),
    this.size = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.playbackPositionMs = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.phash = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.colorLabel = const Value.absent(),
    this.note = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.fileCreatedAt = const Value.absent(),
    this.fileModifiedAt = const Value.absent(),
    required int indexedAt,
    this.mediaTitle = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.trackNumber = const Value.absent(),
    this.bitrate = const Value.absent(),
    this.sampleRate = const Value.absent(),
    this.author = const Value.absent(),
    this.publisher = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.captureDate = const Value.absent(),
    this.cameraModel = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       path = Value(path),
       filename = Value(filename),
       indexedAt = Value(indexedAt);
  static Insertable<Asset> custom({
    Expression<String>? id,
    Expression<String>? path,
    Expression<String>? filename,
    Expression<String>? extension,
    Expression<int>? size,
    Expression<String>? mimeType,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationMs,
    Expression<int>? playbackPositionMs,
    Expression<String>? contentHash,
    Expression<String>? phash,
    Expression<String>? status,
    Expression<int>? rating,
    Expression<String>? colorLabel,
    Expression<String>? note,
    Expression<String>? sourceUrl,
    Expression<int>? fileCreatedAt,
    Expression<int>? fileModifiedAt,
    Expression<int>? indexedAt,
    Expression<String>? mediaTitle,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? genre,
    Expression<int>? trackNumber,
    Expression<int>? bitrate,
    Expression<int>? sampleRate,
    Expression<String>? author,
    Expression<String>? publisher,
    Expression<int>? pageCount,
    Expression<String>? captureDate,
    Expression<String>? cameraModel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (filename != null) 'filename': filename,
      if (extension != null) 'extension': extension,
      if (size != null) 'size': size,
      if (mimeType != null) 'mime_type': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'duration_ms': durationMs,
      if (playbackPositionMs != null)
        'playback_position_ms': playbackPositionMs,
      if (contentHash != null) 'content_hash': contentHash,
      if (phash != null) 'phash': phash,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (colorLabel != null) 'color_label': colorLabel,
      if (note != null) 'note': note,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (fileCreatedAt != null) 'file_created_at': fileCreatedAt,
      if (fileModifiedAt != null) 'file_modified_at': fileModifiedAt,
      if (indexedAt != null) 'indexed_at': indexedAt,
      if (mediaTitle != null) 'media_title': mediaTitle,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (genre != null) 'genre': genre,
      if (trackNumber != null) 'track_number': trackNumber,
      if (bitrate != null) 'bitrate': bitrate,
      if (sampleRate != null) 'sample_rate': sampleRate,
      if (author != null) 'author': author,
      if (publisher != null) 'publisher': publisher,
      if (pageCount != null) 'page_count': pageCount,
      if (captureDate != null) 'capture_date': captureDate,
      if (cameraModel != null) 'camera_model': cameraModel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetsCompanion copyWith({
    Value<String>? id,
    Value<String>? path,
    Value<String>? filename,
    Value<String?>? extension,
    Value<int?>? size,
    Value<String?>? mimeType,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? durationMs,
    Value<int?>? playbackPositionMs,
    Value<String?>? contentHash,
    Value<String?>? phash,
    Value<String>? status,
    Value<int>? rating,
    Value<String?>? colorLabel,
    Value<String?>? note,
    Value<String?>? sourceUrl,
    Value<int?>? fileCreatedAt,
    Value<int?>? fileModifiedAt,
    Value<int>? indexedAt,
    Value<String?>? mediaTitle,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? genre,
    Value<int?>? trackNumber,
    Value<int?>? bitrate,
    Value<int?>? sampleRate,
    Value<String?>? author,
    Value<String?>? publisher,
    Value<int?>? pageCount,
    Value<String?>? captureDate,
    Value<String?>? cameraModel,
    Value<int>? rowid,
  }) {
    return AssetsCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      filename: filename ?? this.filename,
      extension: extension ?? this.extension,
      size: size ?? this.size,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      playbackPositionMs: playbackPositionMs ?? this.playbackPositionMs,
      contentHash: contentHash ?? this.contentHash,
      phash: phash ?? this.phash,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      colorLabel: colorLabel ?? this.colorLabel,
      note: note ?? this.note,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      fileCreatedAt: fileCreatedAt ?? this.fileCreatedAt,
      fileModifiedAt: fileModifiedAt ?? this.fileModifiedAt,
      indexedAt: indexedAt ?? this.indexedAt,
      mediaTitle: mediaTitle ?? this.mediaTitle,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      author: author ?? this.author,
      publisher: publisher ?? this.publisher,
      pageCount: pageCount ?? this.pageCount,
      captureDate: captureDate ?? this.captureDate,
      cameraModel: cameraModel ?? this.cameraModel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (filename.present) {
      map['filename'] = Variable<String>(filename.value);
    }
    if (extension.present) {
      map['extension'] = Variable<String>(extension.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (playbackPositionMs.present) {
      map['playback_position_ms'] = Variable<int>(playbackPositionMs.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (phash.present) {
      map['phash'] = Variable<String>(phash.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (colorLabel.present) {
      map['color_label'] = Variable<String>(colorLabel.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (fileCreatedAt.present) {
      map['file_created_at'] = Variable<int>(fileCreatedAt.value);
    }
    if (fileModifiedAt.present) {
      map['file_modified_at'] = Variable<int>(fileModifiedAt.value);
    }
    if (indexedAt.present) {
      map['indexed_at'] = Variable<int>(indexedAt.value);
    }
    if (mediaTitle.present) {
      map['media_title'] = Variable<String>(mediaTitle.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (trackNumber.present) {
      map['track_number'] = Variable<int>(trackNumber.value);
    }
    if (bitrate.present) {
      map['bitrate'] = Variable<int>(bitrate.value);
    }
    if (sampleRate.present) {
      map['sample_rate'] = Variable<int>(sampleRate.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (publisher.present) {
      map['publisher'] = Variable<String>(publisher.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (captureDate.present) {
      map['capture_date'] = Variable<String>(captureDate.value);
    }
    if (cameraModel.present) {
      map['camera_model'] = Variable<String>(cameraModel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetsCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('filename: $filename, ')
          ..write('extension: $extension, ')
          ..write('size: $size, ')
          ..write('mimeType: $mimeType, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('playbackPositionMs: $playbackPositionMs, ')
          ..write('contentHash: $contentHash, ')
          ..write('phash: $phash, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('colorLabel: $colorLabel, ')
          ..write('note: $note, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('fileCreatedAt: $fileCreatedAt, ')
          ..write('fileModifiedAt: $fileModifiedAt, ')
          ..write('indexedAt: $indexedAt, ')
          ..write('mediaTitle: $mediaTitle, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('trackNumber: $trackNumber, ')
          ..write('bitrate: $bitrate, ')
          ..write('sampleRate: $sampleRate, ')
          ..write('author: $author, ')
          ..write('publisher: $publisher, ')
          ..write('pageCount: $pageCount, ')
          ..write('captureDate: $captureDate, ')
          ..write('cameraModel: $cameraModel, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final String id;
  final String name;

  /// Optional hex color for tag display (e.g. '#ff5733').
  final String? color;
  const Tag({required this.id, required this.name, this.color});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      name: Value(name),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
    );
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<String?>(json['color']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<String?>(color),
    };
  }

  Tag copyWith({
    String? id,
    String? name,
    Value<String?> color = const Value.absent(),
  }) => Tag(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color.present ? color.value : this.color,
  );
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> color;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    required String id,
    required String name,
    this.color = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Tag> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? color,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? color,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetTagsTable extends AssetTags
    with TableInfo<$AssetTagsTable, AssetTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [assetId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId, tagId};
  @override
  AssetTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetTag(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $AssetTagsTable createAlias(String alias) {
    return $AssetTagsTable(attachedDatabase, alias);
  }
}

class AssetTag extends DataClass implements Insertable<AssetTag> {
  final String assetId;
  final String tagId;
  const AssetTag({required this.assetId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  AssetTagsCompanion toCompanion(bool nullToAbsent) {
    return AssetTagsCompanion(assetId: Value(assetId), tagId: Value(tagId));
  }

  factory AssetTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetTag(
      assetId: serializer.fromJson<String>(json['assetId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  AssetTag copyWith({String? assetId, String? tagId}) =>
      AssetTag(assetId: assetId ?? this.assetId, tagId: tagId ?? this.tagId);
  AssetTag copyWithCompanion(AssetTagsCompanion data) {
    return AssetTag(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetTag(')
          ..write('assetId: $assetId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetTag &&
          other.assetId == this.assetId &&
          other.tagId == this.tagId);
}

class AssetTagsCompanion extends UpdateCompanion<AssetTag> {
  final Value<String> assetId;
  final Value<String> tagId;
  final Value<int> rowid;
  const AssetTagsCompanion({
    this.assetId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetTagsCompanion.insert({
    required String assetId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : assetId = Value(assetId),
       tagId = Value(tagId);
  static Insertable<AssetTag> custom({
    Expression<String>? assetId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetTagsCompanion copyWith({
    Value<String>? assetId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return AssetTagsCompanion(
      assetId: assetId ?? this.assetId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetTagsCompanion(')
          ..write('assetId: $assetId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionsTable extends Collections
    with TableInfo<$CollectionsTable, Collection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isSmartFilterMeta = const VerificationMeta(
    'isSmartFilter',
  );
  @override
  late final GeneratedColumn<bool> isSmartFilter = GeneratedColumn<bool>(
    'is_smart_filter',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_smart_filter" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _smartFilterQueryMeta = const VerificationMeta(
    'smartFilterQuery',
  );
  @override
  late final GeneratedColumn<String> smartFilterQuery = GeneratedColumn<String>(
    'smart_filter_query',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isMirrorMeta = const VerificationMeta(
    'isMirror',
  );
  @override
  late final GeneratedColumn<bool> isMirror = GeneratedColumn<bool>(
    'is_mirror',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_mirror" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    parentId,
    isSmartFilter,
    smartFilterQuery,
    sortOrder,
    isMirror,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Collection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('is_smart_filter')) {
      context.handle(
        _isSmartFilterMeta,
        isSmartFilter.isAcceptableOrUnknown(
          data['is_smart_filter']!,
          _isSmartFilterMeta,
        ),
      );
    }
    if (data.containsKey('smart_filter_query')) {
      context.handle(
        _smartFilterQueryMeta,
        smartFilterQuery.isAcceptableOrUnknown(
          data['smart_filter_query']!,
          _smartFilterQueryMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('is_mirror')) {
      context.handle(
        _isMirrorMeta,
        isMirror.isAcceptableOrUnknown(data['is_mirror']!, _isMirrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Collection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Collection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      isSmartFilter: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_smart_filter'],
      )!,
      smartFilterQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}smart_filter_query'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isMirror: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_mirror'],
      )!,
    );
  }

  @override
  $CollectionsTable createAlias(String alias) {
    return $CollectionsTable(attachedDatabase, alias);
  }
}

class Collection extends DataClass implements Insertable<Collection> {
  final String id;
  final String name;

  /// Parent collection id — enables hierarchical collections.
  final String? parentId;

  /// When true, [smartFilterQuery] is a JSON rule set.
  final bool isSmartFilter;

  /// JSON string: `{"logic":"AND","rules":[...]}` — same format as Nexus Explorer.
  final String? smartFilterQuery;
  final int sortOrder;

  /// Auto-created mirror collection from an imported folder structure.
  final bool isMirror;
  const Collection({
    required this.id,
    required this.name,
    this.parentId,
    required this.isSmartFilter,
    this.smartFilterQuery,
    required this.sortOrder,
    required this.isMirror,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['is_smart_filter'] = Variable<bool>(isSmartFilter);
    if (!nullToAbsent || smartFilterQuery != null) {
      map['smart_filter_query'] = Variable<String>(smartFilterQuery);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_mirror'] = Variable<bool>(isMirror);
    return map;
  }

  CollectionsCompanion toCompanion(bool nullToAbsent) {
    return CollectionsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      isSmartFilter: Value(isSmartFilter),
      smartFilterQuery: smartFilterQuery == null && nullToAbsent
          ? const Value.absent()
          : Value(smartFilterQuery),
      sortOrder: Value(sortOrder),
      isMirror: Value(isMirror),
    );
  }

  factory Collection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Collection(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      isSmartFilter: serializer.fromJson<bool>(json['isSmartFilter']),
      smartFilterQuery: serializer.fromJson<String?>(json['smartFilterQuery']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isMirror: serializer.fromJson<bool>(json['isMirror']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'isSmartFilter': serializer.toJson<bool>(isSmartFilter),
      'smartFilterQuery': serializer.toJson<String?>(smartFilterQuery),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isMirror': serializer.toJson<bool>(isMirror),
    };
  }

  Collection copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    bool? isSmartFilter,
    Value<String?> smartFilterQuery = const Value.absent(),
    int? sortOrder,
    bool? isMirror,
  }) => Collection(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    isSmartFilter: isSmartFilter ?? this.isSmartFilter,
    smartFilterQuery: smartFilterQuery.present
        ? smartFilterQuery.value
        : this.smartFilterQuery,
    sortOrder: sortOrder ?? this.sortOrder,
    isMirror: isMirror ?? this.isMirror,
  );
  Collection copyWithCompanion(CollectionsCompanion data) {
    return Collection(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      isSmartFilter: data.isSmartFilter.present
          ? data.isSmartFilter.value
          : this.isSmartFilter,
      smartFilterQuery: data.smartFilterQuery.present
          ? data.smartFilterQuery.value
          : this.smartFilterQuery,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isMirror: data.isMirror.present ? data.isMirror.value : this.isMirror,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Collection(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('isSmartFilter: $isSmartFilter, ')
          ..write('smartFilterQuery: $smartFilterQuery, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isMirror: $isMirror')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    parentId,
    isSmartFilter,
    smartFilterQuery,
    sortOrder,
    isMirror,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Collection &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.isSmartFilter == this.isSmartFilter &&
          other.smartFilterQuery == this.smartFilterQuery &&
          other.sortOrder == this.sortOrder &&
          other.isMirror == this.isMirror);
}

class CollectionsCompanion extends UpdateCompanion<Collection> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<bool> isSmartFilter;
  final Value<String?> smartFilterQuery;
  final Value<int> sortOrder;
  final Value<bool> isMirror;
  final Value<int> rowid;
  const CollectionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.isSmartFilter = const Value.absent(),
    this.smartFilterQuery = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isMirror = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    this.isSmartFilter = const Value.absent(),
    this.smartFilterQuery = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isMirror = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Collection> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<bool>? isSmartFilter,
    Expression<String>? smartFilterQuery,
    Expression<int>? sortOrder,
    Expression<bool>? isMirror,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (isSmartFilter != null) 'is_smart_filter': isSmartFilter,
      if (smartFilterQuery != null) 'smart_filter_query': smartFilterQuery,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isMirror != null) 'is_mirror': isMirror,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<bool>? isSmartFilter,
    Value<String?>? smartFilterQuery,
    Value<int>? sortOrder,
    Value<bool>? isMirror,
    Value<int>? rowid,
  }) {
    return CollectionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      isSmartFilter: isSmartFilter ?? this.isSmartFilter,
      smartFilterQuery: smartFilterQuery ?? this.smartFilterQuery,
      sortOrder: sortOrder ?? this.sortOrder,
      isMirror: isMirror ?? this.isMirror,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (isSmartFilter.present) {
      map['is_smart_filter'] = Variable<bool>(isSmartFilter.value);
    }
    if (smartFilterQuery.present) {
      map['smart_filter_query'] = Variable<String>(smartFilterQuery.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isMirror.present) {
      map['is_mirror'] = Variable<bool>(isMirror.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('isSmartFilter: $isSmartFilter, ')
          ..write('smartFilterQuery: $smartFilterQuery, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isMirror: $isMirror, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CollectionAssetsTable extends CollectionAssets
    with TableInfo<$CollectionAssetsTable, CollectionAsset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CollectionAssetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES collections (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [collectionId, assetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'collection_assets';
  @override
  VerificationContext validateIntegrity(
    Insertable<CollectionAsset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId, assetId};
  @override
  CollectionAsset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CollectionAsset(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
    );
  }

  @override
  $CollectionAssetsTable createAlias(String alias) {
    return $CollectionAssetsTable(attachedDatabase, alias);
  }
}

class CollectionAsset extends DataClass implements Insertable<CollectionAsset> {
  final String collectionId;
  final String assetId;
  const CollectionAsset({required this.collectionId, required this.assetId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<String>(collectionId);
    map['asset_id'] = Variable<String>(assetId);
    return map;
  }

  CollectionAssetsCompanion toCompanion(bool nullToAbsent) {
    return CollectionAssetsCompanion(
      collectionId: Value(collectionId),
      assetId: Value(assetId),
    );
  }

  factory CollectionAsset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CollectionAsset(
      collectionId: serializer.fromJson<String>(json['collectionId']),
      assetId: serializer.fromJson<String>(json['assetId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<String>(collectionId),
      'assetId': serializer.toJson<String>(assetId),
    };
  }

  CollectionAsset copyWith({String? collectionId, String? assetId}) =>
      CollectionAsset(
        collectionId: collectionId ?? this.collectionId,
        assetId: assetId ?? this.assetId,
      );
  CollectionAsset copyWithCompanion(CollectionAssetsCompanion data) {
    return CollectionAsset(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CollectionAsset(')
          ..write('collectionId: $collectionId, ')
          ..write('assetId: $assetId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(collectionId, assetId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CollectionAsset &&
          other.collectionId == this.collectionId &&
          other.assetId == this.assetId);
}

class CollectionAssetsCompanion extends UpdateCompanion<CollectionAsset> {
  final Value<String> collectionId;
  final Value<String> assetId;
  final Value<int> rowid;
  const CollectionAssetsCompanion({
    this.collectionId = const Value.absent(),
    this.assetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CollectionAssetsCompanion.insert({
    required String collectionId,
    required String assetId,
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       assetId = Value(assetId);
  static Insertable<CollectionAsset> custom({
    Expression<String>? collectionId,
    Expression<String>? assetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (assetId != null) 'asset_id': assetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CollectionAssetsCompanion copyWith({
    Value<String>? collectionId,
    Value<String>? assetId,
    Value<int>? rowid,
  }) {
    return CollectionAssetsCompanion(
      collectionId: collectionId ?? this.collectionId,
      assetId: assetId ?? this.assetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CollectionAssetsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('assetId: $assetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PropertyDefinitionsTable extends PropertyDefinitions
    with TableInfo<$PropertyDefinitionsTable, PropertyDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PropertyDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldTypeMeta = const VerificationMeta(
    'fieldType',
  );
  @override
  late final GeneratedColumn<String> fieldType = GeneratedColumn<String>(
    'field_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsJsonMeta = const VerificationMeta(
    'optionsJson',
  );
  @override
  late final GeneratedColumn<String> optionsJson = GeneratedColumn<String>(
    'options_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fieldType,
    optionsJson,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'property_definitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PropertyDefinition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('field_type')) {
      context.handle(
        _fieldTypeMeta,
        fieldType.isAcceptableOrUnknown(data['field_type']!, _fieldTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldTypeMeta);
    }
    if (data.containsKey('options_json')) {
      context.handle(
        _optionsJsonMeta,
        optionsJson.isAcceptableOrUnknown(
          data['options_json']!,
          _optionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PropertyDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PropertyDefinition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fieldType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field_type'],
      )!,
      optionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options_json'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $PropertyDefinitionsTable createAlias(String alias) {
    return $PropertyDefinitionsTable(attachedDatabase, alias);
  }
}

class PropertyDefinition extends DataClass
    implements Insertable<PropertyDefinition> {
  final String id;
  final String name;
  final String fieldType;

  /// JSON array of option strings for 'select' / 'multiselect' fields.
  final String? optionsJson;
  final int sortOrder;
  const PropertyDefinition({
    required this.id,
    required this.name,
    required this.fieldType,
    this.optionsJson,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['field_type'] = Variable<String>(fieldType);
    if (!nullToAbsent || optionsJson != null) {
      map['options_json'] = Variable<String>(optionsJson);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  PropertyDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return PropertyDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      fieldType: Value(fieldType),
      optionsJson: optionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(optionsJson),
      sortOrder: Value(sortOrder),
    );
  }

  factory PropertyDefinition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PropertyDefinition(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fieldType: serializer.fromJson<String>(json['fieldType']),
      optionsJson: serializer.fromJson<String?>(json['optionsJson']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fieldType': serializer.toJson<String>(fieldType),
      'optionsJson': serializer.toJson<String?>(optionsJson),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  PropertyDefinition copyWith({
    String? id,
    String? name,
    String? fieldType,
    Value<String?> optionsJson = const Value.absent(),
    int? sortOrder,
  }) => PropertyDefinition(
    id: id ?? this.id,
    name: name ?? this.name,
    fieldType: fieldType ?? this.fieldType,
    optionsJson: optionsJson.present ? optionsJson.value : this.optionsJson,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  PropertyDefinition copyWithCompanion(PropertyDefinitionsCompanion data) {
    return PropertyDefinition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fieldType: data.fieldType.present ? data.fieldType.value : this.fieldType,
      optionsJson: data.optionsJson.present
          ? data.optionsJson.value
          : this.optionsJson,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PropertyDefinition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, fieldType, optionsJson, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PropertyDefinition &&
          other.id == this.id &&
          other.name == this.name &&
          other.fieldType == this.fieldType &&
          other.optionsJson == this.optionsJson &&
          other.sortOrder == this.sortOrder);
}

class PropertyDefinitionsCompanion extends UpdateCompanion<PropertyDefinition> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> fieldType;
  final Value<String?> optionsJson;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const PropertyDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fieldType = const Value.absent(),
    this.optionsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PropertyDefinitionsCompanion.insert({
    required String id,
    required String name,
    required String fieldType,
    this.optionsJson = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       fieldType = Value(fieldType);
  static Insertable<PropertyDefinition> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fieldType,
    Expression<String>? optionsJson,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fieldType != null) 'field_type': fieldType,
      if (optionsJson != null) 'options_json': optionsJson,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PropertyDefinitionsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? fieldType,
    Value<String?>? optionsJson,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return PropertyDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fieldType: fieldType ?? this.fieldType,
      optionsJson: optionsJson ?? this.optionsJson,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fieldType.present) {
      map['field_type'] = Variable<String>(fieldType.value);
    }
    if (optionsJson.present) {
      map['options_json'] = Variable<String>(optionsJson.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PropertyDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fieldType: $fieldType, ')
          ..write('optionsJson: $optionsJson, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AssetPropertiesTable extends AssetProperties
    with TableInfo<$AssetPropertiesTable, AssetProperty> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetPropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES assets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _propertyIdMeta = const VerificationMeta(
    'propertyId',
  );
  @override
  late final GeneratedColumn<String> propertyId = GeneratedColumn<String>(
    'property_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES property_definitions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [assetId, propertyId, valueText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<AssetProperty> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_assetIdMeta);
    }
    if (data.containsKey('property_id')) {
      context.handle(
        _propertyIdMeta,
        propertyId.isAcceptableOrUnknown(data['property_id']!, _propertyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_propertyIdMeta);
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {assetId, propertyId};
  @override
  AssetProperty map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetProperty(
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      )!,
      propertyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}property_id'],
      )!,
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
    );
  }

  @override
  $AssetPropertiesTable createAlias(String alias) {
    return $AssetPropertiesTable(attachedDatabase, alias);
  }
}

class AssetProperty extends DataClass implements Insertable<AssetProperty> {
  final String assetId;
  final String propertyId;

  /// All values stored as text; interpretation depends on [PropertyDefinitions.fieldType].
  final String? valueText;
  const AssetProperty({
    required this.assetId,
    required this.propertyId,
    this.valueText,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['asset_id'] = Variable<String>(assetId);
    map['property_id'] = Variable<String>(propertyId);
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    return map;
  }

  AssetPropertiesCompanion toCompanion(bool nullToAbsent) {
    return AssetPropertiesCompanion(
      assetId: Value(assetId),
      propertyId: Value(propertyId),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
    );
  }

  factory AssetProperty.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetProperty(
      assetId: serializer.fromJson<String>(json['assetId']),
      propertyId: serializer.fromJson<String>(json['propertyId']),
      valueText: serializer.fromJson<String?>(json['valueText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'assetId': serializer.toJson<String>(assetId),
      'propertyId': serializer.toJson<String>(propertyId),
      'valueText': serializer.toJson<String?>(valueText),
    };
  }

  AssetProperty copyWith({
    String? assetId,
    String? propertyId,
    Value<String?> valueText = const Value.absent(),
  }) => AssetProperty(
    assetId: assetId ?? this.assetId,
    propertyId: propertyId ?? this.propertyId,
    valueText: valueText.present ? valueText.value : this.valueText,
  );
  AssetProperty copyWithCompanion(AssetPropertiesCompanion data) {
    return AssetProperty(
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      propertyId: data.propertyId.present
          ? data.propertyId.value
          : this.propertyId,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetProperty(')
          ..write('assetId: $assetId, ')
          ..write('propertyId: $propertyId, ')
          ..write('valueText: $valueText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(assetId, propertyId, valueText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetProperty &&
          other.assetId == this.assetId &&
          other.propertyId == this.propertyId &&
          other.valueText == this.valueText);
}

class AssetPropertiesCompanion extends UpdateCompanion<AssetProperty> {
  final Value<String> assetId;
  final Value<String> propertyId;
  final Value<String?> valueText;
  final Value<int> rowid;
  const AssetPropertiesCompanion({
    this.assetId = const Value.absent(),
    this.propertyId = const Value.absent(),
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetPropertiesCompanion.insert({
    required String assetId,
    required String propertyId,
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : assetId = Value(assetId),
       propertyId = Value(propertyId);
  static Insertable<AssetProperty> custom({
    Expression<String>? assetId,
    Expression<String>? propertyId,
    Expression<String>? valueText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (assetId != null) 'asset_id': assetId,
      if (propertyId != null) 'property_id': propertyId,
      if (valueText != null) 'value_text': valueText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetPropertiesCompanion copyWith({
    Value<String>? assetId,
    Value<String>? propertyId,
    Value<String?>? valueText,
    Value<int>? rowid,
  }) {
    return AssetPropertiesCompanion(
      assetId: assetId ?? this.assetId,
      propertyId: propertyId ?? this.propertyId,
      valueText: valueText ?? this.valueText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (propertyId.present) {
      map['property_id'] = Variable<String>(propertyId.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetPropertiesCompanion(')
          ..write('assetId: $assetId, ')
          ..write('propertyId: $propertyId, ')
          ..write('valueText: $valueText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ActivityLogTable extends ActivityLog
    with TableInfo<$ActivityLogTable, ActivityLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ActivityLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetIdMeta = const VerificationMeta(
    'assetId',
  );
  @override
  late final GeneratedColumn<String> assetId = GeneratedColumn<String>(
    'asset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _assetPathMeta = const VerificationMeta(
    'assetPath',
  );
  @override
  late final GeneratedColumn<String> assetPath = GeneratedColumn<String>(
    'asset_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _assetFilenameMeta = const VerificationMeta(
    'assetFilename',
  );
  @override
  late final GeneratedColumn<String> assetFilename = GeneratedColumn<String>(
    'asset_filename',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<int> occurredAt = GeneratedColumn<int>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    assetId,
    assetPath,
    assetFilename,
    occurredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'activity_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ActivityLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('asset_id')) {
      context.handle(
        _assetIdMeta,
        assetId.isAcceptableOrUnknown(data['asset_id']!, _assetIdMeta),
      );
    }
    if (data.containsKey('asset_path')) {
      context.handle(
        _assetPathMeta,
        assetPath.isAcceptableOrUnknown(data['asset_path']!, _assetPathMeta),
      );
    } else if (isInserting) {
      context.missing(_assetPathMeta);
    }
    if (data.containsKey('asset_filename')) {
      context.handle(
        _assetFilenameMeta,
        assetFilename.isAcceptableOrUnknown(
          data['asset_filename']!,
          _assetFilenameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_assetFilenameMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ActivityLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ActivityLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      assetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_id'],
      ),
      assetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_path'],
      )!,
      assetFilename: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}asset_filename'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $ActivityLogTable createAlias(String alias) {
    return $ActivityLogTable(attachedDatabase, alias);
  }
}

class ActivityLogData extends DataClass implements Insertable<ActivityLogData> {
  final int id;
  final String eventType;

  /// May be null for 'deleted' events where the record no longer exists.
  final String? assetId;
  final String assetPath;
  final String assetFilename;

  /// Unix timestamp in milliseconds.
  final int occurredAt;
  const ActivityLogData({
    required this.id,
    required this.eventType,
    this.assetId,
    required this.assetPath,
    required this.assetFilename,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || assetId != null) {
      map['asset_id'] = Variable<String>(assetId);
    }
    map['asset_path'] = Variable<String>(assetPath);
    map['asset_filename'] = Variable<String>(assetFilename);
    map['occurred_at'] = Variable<int>(occurredAt);
    return map;
  }

  ActivityLogCompanion toCompanion(bool nullToAbsent) {
    return ActivityLogCompanion(
      id: Value(id),
      eventType: Value(eventType),
      assetId: assetId == null && nullToAbsent
          ? const Value.absent()
          : Value(assetId),
      assetPath: Value(assetPath),
      assetFilename: Value(assetFilename),
      occurredAt: Value(occurredAt),
    );
  }

  factory ActivityLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ActivityLogData(
      id: serializer.fromJson<int>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      assetId: serializer.fromJson<String?>(json['assetId']),
      assetPath: serializer.fromJson<String>(json['assetPath']),
      assetFilename: serializer.fromJson<String>(json['assetFilename']),
      occurredAt: serializer.fromJson<int>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'eventType': serializer.toJson<String>(eventType),
      'assetId': serializer.toJson<String?>(assetId),
      'assetPath': serializer.toJson<String>(assetPath),
      'assetFilename': serializer.toJson<String>(assetFilename),
      'occurredAt': serializer.toJson<int>(occurredAt),
    };
  }

  ActivityLogData copyWith({
    int? id,
    String? eventType,
    Value<String?> assetId = const Value.absent(),
    String? assetPath,
    String? assetFilename,
    int? occurredAt,
  }) => ActivityLogData(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    assetId: assetId.present ? assetId.value : this.assetId,
    assetPath: assetPath ?? this.assetPath,
    assetFilename: assetFilename ?? this.assetFilename,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  ActivityLogData copyWithCompanion(ActivityLogCompanion data) {
    return ActivityLogData(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      assetId: data.assetId.present ? data.assetId.value : this.assetId,
      assetPath: data.assetPath.present ? data.assetPath.value : this.assetPath,
      assetFilename: data.assetFilename.present
          ? data.assetFilename.value
          : this.assetFilename,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogData(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('assetId: $assetId, ')
          ..write('assetPath: $assetPath, ')
          ..write('assetFilename: $assetFilename, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventType, assetId, assetPath, assetFilename, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ActivityLogData &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.assetId == this.assetId &&
          other.assetPath == this.assetPath &&
          other.assetFilename == this.assetFilename &&
          other.occurredAt == this.occurredAt);
}

class ActivityLogCompanion extends UpdateCompanion<ActivityLogData> {
  final Value<int> id;
  final Value<String> eventType;
  final Value<String?> assetId;
  final Value<String> assetPath;
  final Value<String> assetFilename;
  final Value<int> occurredAt;
  const ActivityLogCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.assetId = const Value.absent(),
    this.assetPath = const Value.absent(),
    this.assetFilename = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  ActivityLogCompanion.insert({
    this.id = const Value.absent(),
    required String eventType,
    this.assetId = const Value.absent(),
    required String assetPath,
    required String assetFilename,
    required int occurredAt,
  }) : eventType = Value(eventType),
       assetPath = Value(assetPath),
       assetFilename = Value(assetFilename),
       occurredAt = Value(occurredAt);
  static Insertable<ActivityLogData> custom({
    Expression<int>? id,
    Expression<String>? eventType,
    Expression<String>? assetId,
    Expression<String>? assetPath,
    Expression<String>? assetFilename,
    Expression<int>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (assetId != null) 'asset_id': assetId,
      if (assetPath != null) 'asset_path': assetPath,
      if (assetFilename != null) 'asset_filename': assetFilename,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  ActivityLogCompanion copyWith({
    Value<int>? id,
    Value<String>? eventType,
    Value<String?>? assetId,
    Value<String>? assetPath,
    Value<String>? assetFilename,
    Value<int>? occurredAt,
  }) {
    return ActivityLogCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      assetId: assetId ?? this.assetId,
      assetPath: assetPath ?? this.assetPath,
      assetFilename: assetFilename ?? this.assetFilename,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (assetId.present) {
      map['asset_id'] = Variable<String>(assetId.value);
    }
    if (assetPath.present) {
      map['asset_path'] = Variable<String>(assetPath.value);
    }
    if (assetFilename.present) {
      map['asset_filename'] = Variable<String>(assetFilename.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<int>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ActivityLogCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('assetId: $assetId, ')
          ..write('assetPath: $assetPath, ')
          ..write('assetFilename: $assetFilename, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AssetsTable assets = $AssetsTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $AssetTagsTable assetTags = $AssetTagsTable(this);
  late final $CollectionsTable collections = $CollectionsTable(this);
  late final $CollectionAssetsTable collectionAssets = $CollectionAssetsTable(
    this,
  );
  late final $PropertyDefinitionsTable propertyDefinitions =
      $PropertyDefinitionsTable(this);
  late final $AssetPropertiesTable assetProperties = $AssetPropertiesTable(
    this,
  );
  late final $ActivityLogTable activityLog = $ActivityLogTable(this);
  late final AssetsDao assetsDao = AssetsDao(this as AppDatabase);
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final CollectionsDao collectionsDao = CollectionsDao(
    this as AppDatabase,
  );
  late final ActivityDao activityDao = ActivityDao(this as AppDatabase);
  late final PropertiesDao propertiesDao = PropertiesDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    assets,
    tags,
    assetTags,
    collections,
    collectionAssets,
    propertyDefinitions,
    assetProperties,
    activityLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asset_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tags',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asset_tags', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'collections',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_assets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('collection_assets', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'assets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asset_properties', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'property_definitions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('asset_properties', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$AssetsTableCreateCompanionBuilder =
    AssetsCompanion Function({
      required String id,
      required String path,
      required String filename,
      Value<String?> extension,
      Value<int?> size,
      Value<String?> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      Value<int?> playbackPositionMs,
      Value<String?> contentHash,
      Value<String?> phash,
      Value<String> status,
      Value<int> rating,
      Value<String?> colorLabel,
      Value<String?> note,
      Value<String?> sourceUrl,
      Value<int?> fileCreatedAt,
      Value<int?> fileModifiedAt,
      required int indexedAt,
      Value<String?> mediaTitle,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> genre,
      Value<int?> trackNumber,
      Value<int?> bitrate,
      Value<int?> sampleRate,
      Value<String?> author,
      Value<String?> publisher,
      Value<int?> pageCount,
      Value<String?> captureDate,
      Value<String?> cameraModel,
      Value<int> rowid,
    });
typedef $$AssetsTableUpdateCompanionBuilder =
    AssetsCompanion Function({
      Value<String> id,
      Value<String> path,
      Value<String> filename,
      Value<String?> extension,
      Value<int?> size,
      Value<String?> mimeType,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      Value<int?> playbackPositionMs,
      Value<String?> contentHash,
      Value<String?> phash,
      Value<String> status,
      Value<int> rating,
      Value<String?> colorLabel,
      Value<String?> note,
      Value<String?> sourceUrl,
      Value<int?> fileCreatedAt,
      Value<int?> fileModifiedAt,
      Value<int> indexedAt,
      Value<String?> mediaTitle,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> genre,
      Value<int?> trackNumber,
      Value<int?> bitrate,
      Value<int?> sampleRate,
      Value<String?> author,
      Value<String?> publisher,
      Value<int?> pageCount,
      Value<String?> captureDate,
      Value<String?> cameraModel,
      Value<int> rowid,
    });

final class $$AssetsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetsTable, Asset> {
  $$AssetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssetTagsTable, List<AssetTag>>
  _assetTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetTags,
    aliasName: $_aliasNameGenerator(db.assets.id, db.assetTags.assetId),
  );

  $$AssetTagsTableProcessedTableManager get assetTagsRefs {
    final manager = $$AssetTagsTableTableManager(
      $_db,
      $_db.assetTags,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assetTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CollectionAssetsTable, List<CollectionAsset>>
  _collectionAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionAssets,
    aliasName: $_aliasNameGenerator(db.assets.id, db.collectionAssets.assetId),
  );

  $$CollectionAssetsTableProcessedTableManager get collectionAssetsRefs {
    final manager = $$CollectionAssetsTableTableManager(
      $_db,
      $_db.collectionAssets,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionAssetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AssetPropertiesTable, List<AssetProperty>>
  _assetPropertiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetProperties,
    aliasName: $_aliasNameGenerator(db.assets.id, db.assetProperties.assetId),
  );

  $$AssetPropertiesTableProcessedTableManager get assetPropertiesRefs {
    final manager = $$AssetPropertiesTableTableManager(
      $_db,
      $_db.assetProperties,
    ).filter((f) => f.assetId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetPropertiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AssetsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playbackPositionMs => $composableBuilder(
    column: $table.playbackPositionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phash => $composableBuilder(
    column: $table.phash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorLabel => $composableBuilder(
    column: $table.colorLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileCreatedAt => $composableBuilder(
    column: $table.fileCreatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileModifiedAt => $composableBuilder(
    column: $table.fileModifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaTitle => $composableBuilder(
    column: $table.mediaTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bitrate => $composableBuilder(
    column: $table.bitrate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get captureDate => $composableBuilder(
    column: $table.captureDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cameraModel => $composableBuilder(
    column: $table.cameraModel,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetTagsRefs(
    Expression<bool> Function($$AssetTagsTableFilterComposer f) f,
  ) {
    final $$AssetTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTags,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTagsTableFilterComposer(
            $db: $db,
            $table: $db.assetTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> collectionAssetsRefs(
    Expression<bool> Function($$CollectionAssetsTableFilterComposer f) f,
  ) {
    final $$CollectionAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionAssets,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionAssetsTableFilterComposer(
            $db: $db,
            $table: $db.collectionAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> assetPropertiesRefs(
    Expression<bool> Function($$AssetPropertiesTableFilterComposer f) f,
  ) {
    final $$AssetPropertiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetProperties,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetPropertiesTableFilterComposer(
            $db: $db,
            $table: $db.assetProperties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filename => $composableBuilder(
    column: $table.filename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extension => $composableBuilder(
    column: $table.extension,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playbackPositionMs => $composableBuilder(
    column: $table.playbackPositionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phash => $composableBuilder(
    column: $table.phash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorLabel => $composableBuilder(
    column: $table.colorLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileCreatedAt => $composableBuilder(
    column: $table.fileCreatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileModifiedAt => $composableBuilder(
    column: $table.fileModifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get indexedAt => $composableBuilder(
    column: $table.indexedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaTitle => $composableBuilder(
    column: $table.mediaTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bitrate => $composableBuilder(
    column: $table.bitrate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get publisher => $composableBuilder(
    column: $table.publisher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get captureDate => $composableBuilder(
    column: $table.captureDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cameraModel => $composableBuilder(
    column: $table.cameraModel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetsTable> {
  $$AssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get filename =>
      $composableBuilder(column: $table.filename, builder: (column) => column);

  GeneratedColumn<String> get extension =>
      $composableBuilder(column: $table.extension, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playbackPositionMs => $composableBuilder(
    column: $table.playbackPositionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phash =>
      $composableBuilder(column: $table.phash, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get colorLabel => $composableBuilder(
    column: $table.colorLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<int> get fileCreatedAt => $composableBuilder(
    column: $table.fileCreatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileModifiedAt => $composableBuilder(
    column: $table.fileModifiedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get indexedAt =>
      $composableBuilder(column: $table.indexedAt, builder: (column) => column);

  GeneratedColumn<String> get mediaTitle => $composableBuilder(
    column: $table.mediaTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get trackNumber => $composableBuilder(
    column: $table.trackNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bitrate =>
      $composableBuilder(column: $table.bitrate, builder: (column) => column);

  GeneratedColumn<int> get sampleRate => $composableBuilder(
    column: $table.sampleRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get publisher =>
      $composableBuilder(column: $table.publisher, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get captureDate => $composableBuilder(
    column: $table.captureDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get cameraModel => $composableBuilder(
    column: $table.cameraModel,
    builder: (column) => column,
  );

  Expression<T> assetTagsRefs<T extends Object>(
    Expression<T> Function($$AssetTagsTableAnnotationComposer a) f,
  ) {
    final $$AssetTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTags,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.assetTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> collectionAssetsRefs<T extends Object>(
    Expression<T> Function($$CollectionAssetsTableAnnotationComposer a) f,
  ) {
    final $$CollectionAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionAssets,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> assetPropertiesRefs<T extends Object>(
    Expression<T> Function($$AssetPropertiesTableAnnotationComposer a) f,
  ) {
    final $$AssetPropertiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetProperties,
      getReferencedColumn: (t) => t.assetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetPropertiesTableAnnotationComposer(
            $db: $db,
            $table: $db.assetProperties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetsTable,
          Asset,
          $$AssetsTableFilterComposer,
          $$AssetsTableOrderingComposer,
          $$AssetsTableAnnotationComposer,
          $$AssetsTableCreateCompanionBuilder,
          $$AssetsTableUpdateCompanionBuilder,
          (Asset, $$AssetsTableReferences),
          Asset,
          PrefetchHooks Function({
            bool assetTagsRefs,
            bool collectionAssetsRefs,
            bool assetPropertiesRefs,
          })
        > {
  $$AssetsTableTableManager(_$AppDatabase db, $AssetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> filename = const Value.absent(),
                Value<String?> extension = const Value.absent(),
                Value<int?> size = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> playbackPositionMs = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> phash = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String?> colorLabel = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> fileCreatedAt = const Value.absent(),
                Value<int?> fileModifiedAt = const Value.absent(),
                Value<int> indexedAt = const Value.absent(),
                Value<String?> mediaTitle = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> bitrate = const Value.absent(),
                Value<int?> sampleRate = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> captureDate = const Value.absent(),
                Value<String?> cameraModel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion(
                id: id,
                path: path,
                filename: filename,
                extension: extension,
                size: size,
                mimeType: mimeType,
                width: width,
                height: height,
                durationMs: durationMs,
                playbackPositionMs: playbackPositionMs,
                contentHash: contentHash,
                phash: phash,
                status: status,
                rating: rating,
                colorLabel: colorLabel,
                note: note,
                sourceUrl: sourceUrl,
                fileCreatedAt: fileCreatedAt,
                fileModifiedAt: fileModifiedAt,
                indexedAt: indexedAt,
                mediaTitle: mediaTitle,
                artist: artist,
                album: album,
                genre: genre,
                trackNumber: trackNumber,
                bitrate: bitrate,
                sampleRate: sampleRate,
                author: author,
                publisher: publisher,
                pageCount: pageCount,
                captureDate: captureDate,
                cameraModel: cameraModel,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String path,
                required String filename,
                Value<String?> extension = const Value.absent(),
                Value<int?> size = const Value.absent(),
                Value<String?> mimeType = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<int?> playbackPositionMs = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<String?> phash = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rating = const Value.absent(),
                Value<String?> colorLabel = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String?> sourceUrl = const Value.absent(),
                Value<int?> fileCreatedAt = const Value.absent(),
                Value<int?> fileModifiedAt = const Value.absent(),
                required int indexedAt,
                Value<String?> mediaTitle = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> trackNumber = const Value.absent(),
                Value<int?> bitrate = const Value.absent(),
                Value<int?> sampleRate = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<String?> publisher = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<String?> captureDate = const Value.absent(),
                Value<String?> cameraModel = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetsCompanion.insert(
                id: id,
                path: path,
                filename: filename,
                extension: extension,
                size: size,
                mimeType: mimeType,
                width: width,
                height: height,
                durationMs: durationMs,
                playbackPositionMs: playbackPositionMs,
                contentHash: contentHash,
                phash: phash,
                status: status,
                rating: rating,
                colorLabel: colorLabel,
                note: note,
                sourceUrl: sourceUrl,
                fileCreatedAt: fileCreatedAt,
                fileModifiedAt: fileModifiedAt,
                indexedAt: indexedAt,
                mediaTitle: mediaTitle,
                artist: artist,
                album: album,
                genre: genre,
                trackNumber: trackNumber,
                bitrate: bitrate,
                sampleRate: sampleRate,
                author: author,
                publisher: publisher,
                pageCount: pageCount,
                captureDate: captureDate,
                cameraModel: cameraModel,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$AssetsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                assetTagsRefs = false,
                collectionAssetsRefs = false,
                assetPropertiesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (assetTagsRefs) db.assetTags,
                    if (collectionAssetsRefs) db.collectionAssets,
                    if (assetPropertiesRefs) db.assetProperties,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (assetTagsRefs)
                        await $_getPrefetchedData<
                          Asset,
                          $AssetsTable,
                          AssetTag
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._assetTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).assetTagsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (collectionAssetsRefs)
                        await $_getPrefetchedData<
                          Asset,
                          $AssetsTable,
                          CollectionAsset
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._collectionAssetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).collectionAssetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (assetPropertiesRefs)
                        await $_getPrefetchedData<
                          Asset,
                          $AssetsTable,
                          AssetProperty
                        >(
                          currentTable: table,
                          referencedTable: $$AssetsTableReferences
                              ._assetPropertiesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AssetsTableReferences(
                                db,
                                table,
                                p0,
                              ).assetPropertiesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.assetId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$AssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetsTable,
      Asset,
      $$AssetsTableFilterComposer,
      $$AssetsTableOrderingComposer,
      $$AssetsTableAnnotationComposer,
      $$AssetsTableCreateCompanionBuilder,
      $$AssetsTableUpdateCompanionBuilder,
      (Asset, $$AssetsTableReferences),
      Asset,
      PrefetchHooks Function({
        bool assetTagsRefs,
        bool collectionAssetsRefs,
        bool assetPropertiesRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({
      required String id,
      required String name,
      Value<String?> color,
      Value<int> rowid,
    });
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> color,
      Value<int> rowid,
    });

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, Tag> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AssetTagsTable, List<AssetTag>>
  _assetTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetTags,
    aliasName: $_aliasNameGenerator(db.tags.id, db.assetTags.tagId),
  );

  $$AssetTagsTableProcessedTableManager get assetTagsRefs {
    final manager = $$AssetTagsTableTableManager(
      $_db,
      $_db.assetTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_assetTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetTagsRefs(
    Expression<bool> Function($$AssetTagsTableFilterComposer f) f,
  ) {
    final $$AssetTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTagsTableFilterComposer(
            $db: $db,
            $table: $db.assetTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  Expression<T> assetTagsRefs<T extends Object>(
    Expression<T> Function($$AssetTagsTableAnnotationComposer a) f,
  ) {
    final $$AssetTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.assetTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, $$TagsTableReferences),
          Tag,
          PrefetchHooks Function({bool assetTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  TagsCompanion(id: id, name: name, color: color, rowid: rowid),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> color = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                name: name,
                color: color,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TagsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({assetTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (assetTagsRefs) db.assetTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assetTagsRefs)
                    await $_getPrefetchedData<Tag, $TagsTable, AssetTag>(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences
                          ._assetTagsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).assetTagsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, $$TagsTableReferences),
      Tag,
      PrefetchHooks Function({bool assetTagsRefs})
    >;
typedef $$AssetTagsTableCreateCompanionBuilder =
    AssetTagsCompanion Function({
      required String assetId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$AssetTagsTableUpdateCompanionBuilder =
    AssetTagsCompanion Function({
      Value<String> assetId,
      Value<String> tagId,
      Value<int> rowid,
    });

final class $$AssetTagsTableReferences
    extends BaseReferences<_$AppDatabase, $AssetTagsTable, AssetTag> {
  $$AssetTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AssetsTable _assetIdTable(_$AppDatabase db) => db.assets.createAlias(
    $_aliasNameGenerator(db.assetTags.assetId, db.assets.id),
  );

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias($_aliasNameGenerator(db.assetTags.tagId, db.tags.id));

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssetTagsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetTagsTable> {
  $$AssetTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetTagsTable> {
  $$AssetTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetTagsTable> {
  $$AssetTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetTagsTable,
          AssetTag,
          $$AssetTagsTableFilterComposer,
          $$AssetTagsTableOrderingComposer,
          $$AssetTagsTableAnnotationComposer,
          $$AssetTagsTableCreateCompanionBuilder,
          $$AssetTagsTableUpdateCompanionBuilder,
          (AssetTag, $$AssetTagsTableReferences),
          AssetTag,
          PrefetchHooks Function({bool assetId, bool tagId})
        > {
  $$AssetTagsTableTableManager(_$AppDatabase db, $AssetTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assetId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetTagsCompanion(
                assetId: assetId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assetId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => AssetTagsCompanion.insert(
                assetId: assetId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssetTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable: $$AssetTagsTableReferences
                                    ._assetIdTable(db),
                                referencedColumn: $$AssetTagsTableReferences
                                    ._assetIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (tagId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.tagId,
                                referencedTable: $$AssetTagsTableReferences
                                    ._tagIdTable(db),
                                referencedColumn: $$AssetTagsTableReferences
                                    ._tagIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssetTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetTagsTable,
      AssetTag,
      $$AssetTagsTableFilterComposer,
      $$AssetTagsTableOrderingComposer,
      $$AssetTagsTableAnnotationComposer,
      $$AssetTagsTableCreateCompanionBuilder,
      $$AssetTagsTableUpdateCompanionBuilder,
      (AssetTag, $$AssetTagsTableReferences),
      AssetTag,
      PrefetchHooks Function({bool assetId, bool tagId})
    >;
typedef $$CollectionsTableCreateCompanionBuilder =
    CollectionsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      Value<bool> isSmartFilter,
      Value<String?> smartFilterQuery,
      Value<int> sortOrder,
      Value<bool> isMirror,
      Value<int> rowid,
    });
typedef $$CollectionsTableUpdateCompanionBuilder =
    CollectionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<bool> isSmartFilter,
      Value<String?> smartFilterQuery,
      Value<int> sortOrder,
      Value<bool> isMirror,
      Value<int> rowid,
    });

final class $$CollectionsTableReferences
    extends BaseReferences<_$AppDatabase, $CollectionsTable, Collection> {
  $$CollectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CollectionAssetsTable, List<CollectionAsset>>
  _collectionAssetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.collectionAssets,
    aliasName: $_aliasNameGenerator(
      db.collections.id,
      db.collectionAssets.collectionId,
    ),
  );

  $$CollectionAssetsTableProcessedTableManager get collectionAssetsRefs {
    final manager = $$CollectionAssetsTableTableManager(
      $_db,
      $_db.collectionAssets,
    ).filter((f) => f.collectionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _collectionAssetsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CollectionsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSmartFilter => $composableBuilder(
    column: $table.isSmartFilter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get smartFilterQuery => $composableBuilder(
    column: $table.smartFilterQuery,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isMirror => $composableBuilder(
    column: $table.isMirror,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> collectionAssetsRefs(
    Expression<bool> Function($$CollectionAssetsTableFilterComposer f) f,
  ) {
    final $$CollectionAssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionAssets,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionAssetsTableFilterComposer(
            $db: $db,
            $table: $db.collectionAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSmartFilter => $composableBuilder(
    column: $table.isSmartFilter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get smartFilterQuery => $composableBuilder(
    column: $table.smartFilterQuery,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isMirror => $composableBuilder(
    column: $table.isMirror,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CollectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionsTable> {
  $$CollectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<bool> get isSmartFilter => $composableBuilder(
    column: $table.isSmartFilter,
    builder: (column) => column,
  );

  GeneratedColumn<String> get smartFilterQuery => $composableBuilder(
    column: $table.smartFilterQuery,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isMirror =>
      $composableBuilder(column: $table.isMirror, builder: (column) => column);

  Expression<T> collectionAssetsRefs<T extends Object>(
    Expression<T> Function($$CollectionAssetsTableAnnotationComposer a) f,
  ) {
    final $$CollectionAssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.collectionAssets,
      getReferencedColumn: (t) => t.collectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionAssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.collectionAssets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CollectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionsTable,
          Collection,
          $$CollectionsTableFilterComposer,
          $$CollectionsTableOrderingComposer,
          $$CollectionsTableAnnotationComposer,
          $$CollectionsTableCreateCompanionBuilder,
          $$CollectionsTableUpdateCompanionBuilder,
          (Collection, $$CollectionsTableReferences),
          Collection,
          PrefetchHooks Function({bool collectionAssetsRefs})
        > {
  $$CollectionsTableTableManager(_$AppDatabase db, $CollectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<bool> isSmartFilter = const Value.absent(),
                Value<String?> smartFilterQuery = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isMirror = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                isSmartFilter: isSmartFilter,
                smartFilterQuery: smartFilterQuery,
                sortOrder: sortOrder,
                isMirror: isMirror,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<bool> isSmartFilter = const Value.absent(),
                Value<String?> smartFilterQuery = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isMirror = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                isSmartFilter: isSmartFilter,
                smartFilterQuery: smartFilterQuery,
                sortOrder: sortOrder,
                isMirror: isMirror,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionAssetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (collectionAssetsRefs) db.collectionAssets,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (collectionAssetsRefs)
                    await $_getPrefetchedData<
                      Collection,
                      $CollectionsTable,
                      CollectionAsset
                    >(
                      currentTable: table,
                      referencedTable: $$CollectionsTableReferences
                          ._collectionAssetsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$CollectionsTableReferences(
                            db,
                            table,
                            p0,
                          ).collectionAssetsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.collectionId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$CollectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionsTable,
      Collection,
      $$CollectionsTableFilterComposer,
      $$CollectionsTableOrderingComposer,
      $$CollectionsTableAnnotationComposer,
      $$CollectionsTableCreateCompanionBuilder,
      $$CollectionsTableUpdateCompanionBuilder,
      (Collection, $$CollectionsTableReferences),
      Collection,
      PrefetchHooks Function({bool collectionAssetsRefs})
    >;
typedef $$CollectionAssetsTableCreateCompanionBuilder =
    CollectionAssetsCompanion Function({
      required String collectionId,
      required String assetId,
      Value<int> rowid,
    });
typedef $$CollectionAssetsTableUpdateCompanionBuilder =
    CollectionAssetsCompanion Function({
      Value<String> collectionId,
      Value<String> assetId,
      Value<int> rowid,
    });

final class $$CollectionAssetsTableReferences
    extends
        BaseReferences<_$AppDatabase, $CollectionAssetsTable, CollectionAsset> {
  $$CollectionAssetsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CollectionsTable _collectionIdTable(_$AppDatabase db) =>
      db.collections.createAlias(
        $_aliasNameGenerator(
          db.collectionAssets.collectionId,
          db.collections.id,
        ),
      );

  $$CollectionsTableProcessedTableManager get collectionId {
    final $_column = $_itemColumn<String>('collection_id')!;

    final manager = $$CollectionsTableTableManager(
      $_db,
      $_db.collections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_collectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AssetsTable _assetIdTable(_$AppDatabase db) => db.assets.createAlias(
    $_aliasNameGenerator(db.collectionAssets.assetId, db.assets.id),
  );

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CollectionAssetsTableFilterComposer
    extends Composer<_$AppDatabase, $CollectionAssetsTable> {
  $$CollectionAssetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CollectionsTableFilterComposer get collectionId {
    final $$CollectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableFilterComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionAssetsTableOrderingComposer
    extends Composer<_$AppDatabase, $CollectionAssetsTable> {
  $$CollectionAssetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CollectionsTableOrderingComposer get collectionId {
    final $$CollectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableOrderingComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionAssetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CollectionAssetsTable> {
  $$CollectionAssetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$CollectionsTableAnnotationComposer get collectionId {
    final $$CollectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.collectionId,
      referencedTable: $db.collections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CollectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.collections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CollectionAssetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CollectionAssetsTable,
          CollectionAsset,
          $$CollectionAssetsTableFilterComposer,
          $$CollectionAssetsTableOrderingComposer,
          $$CollectionAssetsTableAnnotationComposer,
          $$CollectionAssetsTableCreateCompanionBuilder,
          $$CollectionAssetsTableUpdateCompanionBuilder,
          (CollectionAsset, $$CollectionAssetsTableReferences),
          CollectionAsset,
          PrefetchHooks Function({bool collectionId, bool assetId})
        > {
  $$CollectionAssetsTableTableManager(
    _$AppDatabase db,
    $CollectionAssetsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CollectionAssetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CollectionAssetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CollectionAssetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collectionId = const Value.absent(),
                Value<String> assetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CollectionAssetsCompanion(
                collectionId: collectionId,
                assetId: assetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectionId,
                required String assetId,
                Value<int> rowid = const Value.absent(),
              }) => CollectionAssetsCompanion.insert(
                collectionId: collectionId,
                assetId: assetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CollectionAssetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({collectionId = false, assetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (collectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.collectionId,
                                referencedTable:
                                    $$CollectionAssetsTableReferences
                                        ._collectionIdTable(db),
                                referencedColumn:
                                    $$CollectionAssetsTableReferences
                                        ._collectionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable:
                                    $$CollectionAssetsTableReferences
                                        ._assetIdTable(db),
                                referencedColumn:
                                    $$CollectionAssetsTableReferences
                                        ._assetIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CollectionAssetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CollectionAssetsTable,
      CollectionAsset,
      $$CollectionAssetsTableFilterComposer,
      $$CollectionAssetsTableOrderingComposer,
      $$CollectionAssetsTableAnnotationComposer,
      $$CollectionAssetsTableCreateCompanionBuilder,
      $$CollectionAssetsTableUpdateCompanionBuilder,
      (CollectionAsset, $$CollectionAssetsTableReferences),
      CollectionAsset,
      PrefetchHooks Function({bool collectionId, bool assetId})
    >;
typedef $$PropertyDefinitionsTableCreateCompanionBuilder =
    PropertyDefinitionsCompanion Function({
      required String id,
      required String name,
      required String fieldType,
      Value<String?> optionsJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$PropertyDefinitionsTableUpdateCompanionBuilder =
    PropertyDefinitionsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> fieldType,
      Value<String?> optionsJson,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$PropertyDefinitionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PropertyDefinitionsTable,
          PropertyDefinition
        > {
  $$PropertyDefinitionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$AssetPropertiesTable, List<AssetProperty>>
  _assetPropertiesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.assetProperties,
    aliasName: $_aliasNameGenerator(
      db.propertyDefinitions.id,
      db.assetProperties.propertyId,
    ),
  );

  $$AssetPropertiesTableProcessedTableManager get assetPropertiesRefs {
    final manager = $$AssetPropertiesTableTableManager(
      $_db,
      $_db.assetProperties,
    ).filter((f) => f.propertyId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _assetPropertiesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PropertyDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $PropertyDefinitionsTable> {
  $$PropertyDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> assetPropertiesRefs(
    Expression<bool> Function($$AssetPropertiesTableFilterComposer f) f,
  ) {
    final $$AssetPropertiesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetProperties,
      getReferencedColumn: (t) => t.propertyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetPropertiesTableFilterComposer(
            $db: $db,
            $table: $db.assetProperties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PropertyDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PropertyDefinitionsTable> {
  $$PropertyDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fieldType => $composableBuilder(
    column: $table.fieldType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PropertyDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PropertyDefinitionsTable> {
  $$PropertyDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get fieldType =>
      $composableBuilder(column: $table.fieldType, builder: (column) => column);

  GeneratedColumn<String> get optionsJson => $composableBuilder(
    column: $table.optionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> assetPropertiesRefs<T extends Object>(
    Expression<T> Function($$AssetPropertiesTableAnnotationComposer a) f,
  ) {
    final $$AssetPropertiesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.assetProperties,
      getReferencedColumn: (t) => t.propertyId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetPropertiesTableAnnotationComposer(
            $db: $db,
            $table: $db.assetProperties,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PropertyDefinitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PropertyDefinitionsTable,
          PropertyDefinition,
          $$PropertyDefinitionsTableFilterComposer,
          $$PropertyDefinitionsTableOrderingComposer,
          $$PropertyDefinitionsTableAnnotationComposer,
          $$PropertyDefinitionsTableCreateCompanionBuilder,
          $$PropertyDefinitionsTableUpdateCompanionBuilder,
          (PropertyDefinition, $$PropertyDefinitionsTableReferences),
          PropertyDefinition,
          PrefetchHooks Function({bool assetPropertiesRefs})
        > {
  $$PropertyDefinitionsTableTableManager(
    _$AppDatabase db,
    $PropertyDefinitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PropertyDefinitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PropertyDefinitionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PropertyDefinitionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fieldType = const Value.absent(),
                Value<String?> optionsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertyDefinitionsCompanion(
                id: id,
                name: name,
                fieldType: fieldType,
                optionsJson: optionsJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String fieldType,
                Value<String?> optionsJson = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertyDefinitionsCompanion.insert(
                id: id,
                name: name,
                fieldType: fieldType,
                optionsJson: optionsJson,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PropertyDefinitionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetPropertiesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (assetPropertiesRefs) db.assetProperties,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (assetPropertiesRefs)
                    await $_getPrefetchedData<
                      PropertyDefinition,
                      $PropertyDefinitionsTable,
                      AssetProperty
                    >(
                      currentTable: table,
                      referencedTable: $$PropertyDefinitionsTableReferences
                          ._assetPropertiesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PropertyDefinitionsTableReferences(
                            db,
                            table,
                            p0,
                          ).assetPropertiesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.propertyId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PropertyDefinitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PropertyDefinitionsTable,
      PropertyDefinition,
      $$PropertyDefinitionsTableFilterComposer,
      $$PropertyDefinitionsTableOrderingComposer,
      $$PropertyDefinitionsTableAnnotationComposer,
      $$PropertyDefinitionsTableCreateCompanionBuilder,
      $$PropertyDefinitionsTableUpdateCompanionBuilder,
      (PropertyDefinition, $$PropertyDefinitionsTableReferences),
      PropertyDefinition,
      PrefetchHooks Function({bool assetPropertiesRefs})
    >;
typedef $$AssetPropertiesTableCreateCompanionBuilder =
    AssetPropertiesCompanion Function({
      required String assetId,
      required String propertyId,
      Value<String?> valueText,
      Value<int> rowid,
    });
typedef $$AssetPropertiesTableUpdateCompanionBuilder =
    AssetPropertiesCompanion Function({
      Value<String> assetId,
      Value<String> propertyId,
      Value<String?> valueText,
      Value<int> rowid,
    });

final class $$AssetPropertiesTableReferences
    extends
        BaseReferences<_$AppDatabase, $AssetPropertiesTable, AssetProperty> {
  $$AssetPropertiesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AssetsTable _assetIdTable(_$AppDatabase db) => db.assets.createAlias(
    $_aliasNameGenerator(db.assetProperties.assetId, db.assets.id),
  );

  $$AssetsTableProcessedTableManager get assetId {
    final $_column = $_itemColumn<String>('asset_id')!;

    final manager = $$AssetsTableTableManager(
      $_db,
      $_db.assets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_assetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $PropertyDefinitionsTable _propertyIdTable(_$AppDatabase db) =>
      db.propertyDefinitions.createAlias(
        $_aliasNameGenerator(
          db.assetProperties.propertyId,
          db.propertyDefinitions.id,
        ),
      );

  $$PropertyDefinitionsTableProcessedTableManager get propertyId {
    final $_column = $_itemColumn<String>('property_id')!;

    final manager = $$PropertyDefinitionsTableTableManager(
      $_db,
      $_db.propertyDefinitions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_propertyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AssetPropertiesTableFilterComposer
    extends Composer<_$AppDatabase, $AssetPropertiesTable> {
  $$AssetPropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );

  $$AssetsTableFilterComposer get assetId {
    final $$AssetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableFilterComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PropertyDefinitionsTableFilterComposer get propertyId {
    final $$PropertyDefinitionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.propertyId,
      referencedTable: $db.propertyDefinitions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PropertyDefinitionsTableFilterComposer(
            $db: $db,
            $table: $db.propertyDefinitions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AssetPropertiesTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetPropertiesTable> {
  $$AssetPropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );

  $$AssetsTableOrderingComposer get assetId {
    final $$AssetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableOrderingComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PropertyDefinitionsTableOrderingComposer get propertyId {
    final $$PropertyDefinitionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.propertyId,
          referencedTable: $db.propertyDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PropertyDefinitionsTableOrderingComposer(
                $db: $db,
                $table: $db.propertyDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AssetPropertiesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetPropertiesTable> {
  $$AssetPropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);

  $$AssetsTableAnnotationComposer get assetId {
    final $$AssetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.assetId,
      referencedTable: $db.assets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AssetsTableAnnotationComposer(
            $db: $db,
            $table: $db.assets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$PropertyDefinitionsTableAnnotationComposer get propertyId {
    final $$PropertyDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.propertyId,
          referencedTable: $db.propertyDefinitions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PropertyDefinitionsTableAnnotationComposer(
                $db: $db,
                $table: $db.propertyDefinitions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$AssetPropertiesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AssetPropertiesTable,
          AssetProperty,
          $$AssetPropertiesTableFilterComposer,
          $$AssetPropertiesTableOrderingComposer,
          $$AssetPropertiesTableAnnotationComposer,
          $$AssetPropertiesTableCreateCompanionBuilder,
          $$AssetPropertiesTableUpdateCompanionBuilder,
          (AssetProperty, $$AssetPropertiesTableReferences),
          AssetProperty,
          PrefetchHooks Function({bool assetId, bool propertyId})
        > {
  $$AssetPropertiesTableTableManager(
    _$AppDatabase db,
    $AssetPropertiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetPropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetPropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetPropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> assetId = const Value.absent(),
                Value<String> propertyId = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetPropertiesCompanion(
                assetId: assetId,
                propertyId: propertyId,
                valueText: valueText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String assetId,
                required String propertyId,
                Value<String?> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AssetPropertiesCompanion.insert(
                assetId: assetId,
                propertyId: propertyId,
                valueText: valueText,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AssetPropertiesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({assetId = false, propertyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (assetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.assetId,
                                referencedTable:
                                    $$AssetPropertiesTableReferences
                                        ._assetIdTable(db),
                                referencedColumn:
                                    $$AssetPropertiesTableReferences
                                        ._assetIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (propertyId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.propertyId,
                                referencedTable:
                                    $$AssetPropertiesTableReferences
                                        ._propertyIdTable(db),
                                referencedColumn:
                                    $$AssetPropertiesTableReferences
                                        ._propertyIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AssetPropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AssetPropertiesTable,
      AssetProperty,
      $$AssetPropertiesTableFilterComposer,
      $$AssetPropertiesTableOrderingComposer,
      $$AssetPropertiesTableAnnotationComposer,
      $$AssetPropertiesTableCreateCompanionBuilder,
      $$AssetPropertiesTableUpdateCompanionBuilder,
      (AssetProperty, $$AssetPropertiesTableReferences),
      AssetProperty,
      PrefetchHooks Function({bool assetId, bool propertyId})
    >;
typedef $$ActivityLogTableCreateCompanionBuilder =
    ActivityLogCompanion Function({
      Value<int> id,
      required String eventType,
      Value<String?> assetId,
      required String assetPath,
      required String assetFilename,
      required int occurredAt,
    });
typedef $$ActivityLogTableUpdateCompanionBuilder =
    ActivityLogCompanion Function({
      Value<int> id,
      Value<String> eventType,
      Value<String?> assetId,
      Value<String> assetPath,
      Value<String> assetFilename,
      Value<int> occurredAt,
    });

class $$ActivityLogTableFilterComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetPath => $composableBuilder(
    column: $table.assetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get assetFilename => $composableBuilder(
    column: $table.assetFilename,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ActivityLogTableOrderingComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetId => $composableBuilder(
    column: $table.assetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetPath => $composableBuilder(
    column: $table.assetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get assetFilename => $composableBuilder(
    column: $table.assetFilename,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ActivityLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $ActivityLogTable> {
  $$ActivityLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get assetId =>
      $composableBuilder(column: $table.assetId, builder: (column) => column);

  GeneratedColumn<String> get assetPath =>
      $composableBuilder(column: $table.assetPath, builder: (column) => column);

  GeneratedColumn<String> get assetFilename => $composableBuilder(
    column: $table.assetFilename,
    builder: (column) => column,
  );

  GeneratedColumn<int> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$ActivityLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ActivityLogTable,
          ActivityLogData,
          $$ActivityLogTableFilterComposer,
          $$ActivityLogTableOrderingComposer,
          $$ActivityLogTableAnnotationComposer,
          $$ActivityLogTableCreateCompanionBuilder,
          $$ActivityLogTableUpdateCompanionBuilder,
          (
            ActivityLogData,
            BaseReferences<_$AppDatabase, $ActivityLogTable, ActivityLogData>,
          ),
          ActivityLogData,
          PrefetchHooks Function()
        > {
  $$ActivityLogTableTableManager(_$AppDatabase db, $ActivityLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ActivityLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ActivityLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ActivityLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> assetId = const Value.absent(),
                Value<String> assetPath = const Value.absent(),
                Value<String> assetFilename = const Value.absent(),
                Value<int> occurredAt = const Value.absent(),
              }) => ActivityLogCompanion(
                id: id,
                eventType: eventType,
                assetId: assetId,
                assetPath: assetPath,
                assetFilename: assetFilename,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String eventType,
                Value<String?> assetId = const Value.absent(),
                required String assetPath,
                required String assetFilename,
                required int occurredAt,
              }) => ActivityLogCompanion.insert(
                id: id,
                eventType: eventType,
                assetId: assetId,
                assetPath: assetPath,
                assetFilename: assetFilename,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ActivityLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ActivityLogTable,
      ActivityLogData,
      $$ActivityLogTableFilterComposer,
      $$ActivityLogTableOrderingComposer,
      $$ActivityLogTableAnnotationComposer,
      $$ActivityLogTableCreateCompanionBuilder,
      $$ActivityLogTableUpdateCompanionBuilder,
      (
        ActivityLogData,
        BaseReferences<_$AppDatabase, $ActivityLogTable, ActivityLogData>,
      ),
      ActivityLogData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db, _db.assets);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$AssetTagsTableTableManager get assetTags =>
      $$AssetTagsTableTableManager(_db, _db.assetTags);
  $$CollectionsTableTableManager get collections =>
      $$CollectionsTableTableManager(_db, _db.collections);
  $$CollectionAssetsTableTableManager get collectionAssets =>
      $$CollectionAssetsTableTableManager(_db, _db.collectionAssets);
  $$PropertyDefinitionsTableTableManager get propertyDefinitions =>
      $$PropertyDefinitionsTableTableManager(_db, _db.propertyDefinitions);
  $$AssetPropertiesTableTableManager get assetProperties =>
      $$AssetPropertiesTableTableManager(_db, _db.assetProperties);
  $$ActivityLogTableTableManager get activityLog =>
      $$ActivityLogTableTableManager(_db, _db.activityLog);
}
