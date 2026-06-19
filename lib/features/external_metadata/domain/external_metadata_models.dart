import 'package:flutter/material.dart';

enum ExternalMetadataSource {
  anilistAnime,
  anilistManga,
  boardGameGeek,
  videoGameGeek,
  rpgGeek,
}

extension ExternalMetadataSourceX on ExternalMetadataSource {
  String get label => switch (this) {
        ExternalMetadataSource.anilistAnime => 'AniList Anime',
        ExternalMetadataSource.anilistManga => 'AniList Manga',
        ExternalMetadataSource.boardGameGeek => 'BoardGameGeek',
        ExternalMetadataSource.videoGameGeek => 'VideoGameGeek',
        ExternalMetadataSource.rpgGeek => 'RPGGeek',
      };

  IconData get icon => switch (this) {
        ExternalMetadataSource.anilistAnime => Icons.animation_outlined,
        ExternalMetadataSource.anilistManga => Icons.menu_book_outlined,
        ExternalMetadataSource.boardGameGeek => Icons.casino_outlined,
        ExternalMetadataSource.videoGameGeek => Icons.videogame_asset_outlined,
        ExternalMetadataSource.rpgGeek => Icons.hdr_auto_outlined,
      };

  bool get isAniList =>
      this == ExternalMetadataSource.anilistAnime ||
      this == ExternalMetadataSource.anilistManga;

  String get aniListType => switch (this) {
        ExternalMetadataSource.anilistAnime => 'ANIME',
        ExternalMetadataSource.anilistManga => 'MANGA',
        _ => throw StateError('Not an AniList source'),
      };

  String get geekDoSubtype => switch (this) {
        ExternalMetadataSource.boardGameGeek => 'boardgame',
        ExternalMetadataSource.videoGameGeek => 'videogame',
        ExternalMetadataSource.rpgGeek => 'rpgitem',
        _ => throw StateError('Not a GeekDo source'),
      };
}

class ExternalMetadataCandidate {
  const ExternalMetadataCandidate({
    required this.source,
    required this.id,
    required this.title,
    this.subtitle,
    this.thumbnailUrl,
    this.sourceUrl,
    this.record,
  });

  final ExternalMetadataSource source;
  final String id;
  final String title;
  final String? subtitle;
  final String? thumbnailUrl;
  final String? sourceUrl;
  final ExternalMetadataRecord? record;
}

class ExternalMetadataRecord {
  const ExternalMetadataRecord({
    required this.source,
    required this.title,
    this.description,
    this.imageUrl,
    this.sourceUrl,
    this.tags = const <String>[],
    this.creator,
    this.publisher,
    this.year,
    this.kindLabel,
    this.isAdult,
    this.facts = const <String, String>{},
  });

  final ExternalMetadataSource source;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? sourceUrl;
  final List<String> tags;
  final String? creator;
  final String? publisher;
  final int? year;
  final String? kindLabel;
  final bool? isAdult;
  final Map<String, String> facts;

  String get shortDescription {
    final text = (description ?? '').trim();
    if (text.isEmpty) return '';
    return text.length > 1200 ? '${text.substring(0, 1200)}…' : text;
  }

  String get combinedTags => tags.join(', ');
}
