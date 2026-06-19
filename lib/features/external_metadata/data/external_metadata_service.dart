import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/external_metadata_models.dart';

class ExternalMetadataService {
  const ExternalMetadataService._();

  static const instance = ExternalMetadataService._();

  static const _httpHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0 Mobile Safari/537.36',
    'Accept': 'application/json,*/*',
  };

  Future<List<ExternalMetadataCandidate>> search({
    required ExternalMetadataSource source,
    required String query,
    bool adult = false,
  }) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return [];

    if (source.isAniList) {
      final direct = _parseAniListUrl(normalized);
      if (direct != null) {
        final record = await _fetchAniListById(
          source: direct.source,
          id: direct.id,
        );
        return record == null
            ? const []
            : [
                ExternalMetadataCandidate(
                  source: direct.source,
                  id: direct.id.toString(),
                  title: record.title,
                  subtitle: _aniListSubtitle(record),
                  thumbnailUrl: record.imageUrl,
                  sourceUrl: record.sourceUrl,
                  record: record,
                ),
              ];
      }

      return _searchAniList(source: source, query: normalized, adult: adult);
    }

    final geekDirect = _parseGeekDoUrl(normalized);
    if (geekDirect != null) {
      final record = await _fetchGeekDoById(
        source: geekDirect.source,
        id: geekDirect.id,
        subtype: geekDirect.subtype,
      );
      return record == null
          ? const []
          : [
              ExternalMetadataCandidate(
                source: geekDirect.source,
                id: geekDirect.id,
                title: record.title,
                subtitle: _geekSubtitle(record),
                thumbnailUrl: record.imageUrl,
                sourceUrl: record.sourceUrl,
                record: record,
              ),
            ];
    }

    return _searchGeekDo(source: source, query: normalized);
  }

  Future<ExternalMetadataRecord?> fetchCandidate(
    ExternalMetadataCandidate candidate,
  ) async {
    if (candidate.record != null) return candidate.record;

    if (candidate.source.isAniList) {
      return _fetchAniListById(
        source: candidate.source,
        id: int.tryParse(candidate.id) ?? -1,
      );
    }

    return _fetchGeekDoById(
      source: candidate.source,
      id: candidate.id,
      subtype: candidate.source.geekDoSubtype,
    );
  }

  Future<List<ExternalMetadataCandidate>> _searchAniList({
    required ExternalMetadataSource source,
    required String query,
    required bool adult,
  }) async {
    const gql = r'''
      query ($search: String, $type: MediaType, $adult: Boolean) {
        Page(page: 1, perPage: 10) {
          media(search: $search, type: $type, isAdult: $adult, sort: SEARCH_MATCH) {
            id
            siteUrl
            title { romaji english native }
            description(asHtml: false)
            coverImage { extraLarge large }
            genres
            averageScore
            type
            format
            status
            episodes
            chapters
            startDate { year }
            studios(isMain: true) { nodes { name } }
            isAdult
          }
        }
      }
    ''';

    final response = await http
        .post(
          Uri.parse('https://graphql.anilist.co'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'query': gql,
            'variables': {
              'search': query,
              'type': source.aniListType,
              'adult': adult,
            },
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return const [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final media = (data['data']?['Page']?['media'] as List?) ?? const [];
    return media
        .map((item) => _buildAniListCandidate(
              source: source,
              item: item as Map<String, dynamic>,
            ))
        .whereType<ExternalMetadataCandidate>()
        .toList();
  }

  Future<ExternalMetadataRecord?> _fetchAniListById({
    required ExternalMetadataSource source,
    required int id,
  }) async {
    if (id <= 0) return null;

    const gql = r'''
      query ($id: Int, $type: MediaType) {
        Media(id: $id, type: $type) {
          id
          siteUrl
          title { romaji english native }
          description(asHtml: false)
          coverImage { extraLarge large }
          bannerImage
          genres
          averageScore
          type
          format
          status
          episodes
          chapters
          startDate { year }
          studios(isMain: true) { nodes { name } }
          isAdult
        }
      }
    ''';

    final response = await http
        .post(
          Uri.parse('https://graphql.anilist.co'),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'query': gql,
            'variables': {'id': id, 'type': source.aniListType},
          }),
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final media = data['data']?['Media'] as Map<String, dynamic>?;
    if (media == null) return null;

    return _buildAniListRecord(source: source, media: media);
  }

  ExternalMetadataCandidate? _buildAniListCandidate({
    required ExternalMetadataSource source,
    required Map<String, dynamic> item,
  }) {
    final record = _buildAniListRecord(source: source, media: item);
    return ExternalMetadataCandidate(
      source: source,
      id: item['id']?.toString() ?? '',
      title: record.title,
      subtitle: _aniListSubtitle(record),
      thumbnailUrl: record.imageUrl,
      sourceUrl: record.sourceUrl,
      record: record,
    );
  }

  ExternalMetadataRecord _buildAniListRecord({
    required ExternalMetadataSource source,
    required Map<String, dynamic> media,
  }) {
    final titleObj = media['title'] as Map<String, dynamic>?;
    final title = _firstNonEmpty([
      titleObj?['english'] as String?,
      titleObj?['romaji'] as String?,
      titleObj?['native'] as String?,
      'AniList',
    ]) ??
        'AniList';

    final rawDescription = (media['description'] as String?) ?? '';
    final description = _cleanHtml(rawDescription);

    final cover = media['coverImage'] as Map<String, dynamic>?;
    final imageUrl = _firstNonEmpty([
      cover?['extraLarge'] as String?,
      cover?['large'] as String?,
      media['bannerImage'] as String?,
    ]);

    final genres = (media['genres'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList() ??
        const <String>[];

    final year = (media['startDate'] as Map?)?['year'] as int?;
    final studioNodes =
        ((media['studios'] as Map<String, dynamic>?)?['nodes'] as List?) ??
            const [];
    final studio = studioNodes.isNotEmpty
        ? (studioNodes.first as Map<String, dynamic>)['name'] as String?
        : null;

    final facts = <String, String>{};
    if (media['type'] != null) facts['Typ'] = media['type'].toString();
    if (media['format'] != null) facts['Format'] = media['format'].toString();
    if (media['status'] != null) facts['Status'] = media['status'].toString();
    if (year != null) facts['Jahr'] = year.toString();
    final episodes = media['episodes'];
    if (episodes != null) facts['Episoden'] = episodes.toString();
    final chapters = media['chapters'];
    if (chapters != null) facts['Kapitel'] = chapters.toString();
    if (studio != null && studio.isNotEmpty) facts['Studio'] = studio;
    final score = media['averageScore'];
    if (score != null) facts['Score'] = score.toString();
    final adult = media['isAdult'] as bool?;
    if (adult == true) facts['Adult'] = 'true';

    return ExternalMetadataRecord(
      source: source,
      title: title,
      description: description,
      imageUrl: imageUrl,
      sourceUrl: (media['siteUrl'] as String?)?.trim().isNotEmpty == true
          ? media['siteUrl'] as String?
          : _aniListUrl(source, media['id']),
      tags: genres,
      creator: studio,
      publisher: null,
      year: year,
      kindLabel: source.isAniList ? source.label : null,
      isAdult: adult,
      facts: facts,
    );
  }

  Future<List<ExternalMetadataCandidate>> _searchGeekDo({
    required ExternalMetadataSource source,
    required String query,
  }) async {
    final uri = Uri.parse(
      'https://api.geekdo.com/api/search?q=${Uri.encodeComponent(query)}'
      '&objecttype=thing&nosession=1',
    );

    final response = await http.get(uri, headers: _httpHeaders).timeout(
      const Duration(seconds: 10),
    );
    if (response.statusCode != 200) return const [];

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final items = (data['items'] as List?) ?? const [];
    final matches = <ExternalMetadataCandidate>[];

    for (final raw in items) {
      final item = raw as Map<String, dynamic>;
      final subtype = item['subtype']?.toString() ?? '';
      if (!_matchesGeekSubtype(source, subtype)) continue;
      final id = item['objectid']?.toString() ?? '';
      if (id.isEmpty) continue;

      final title = item['name']?.toString() ?? '';
      if (title.isEmpty) continue;

      final year = item['yearpublished']?.toString() ?? '';
      final subtitle = [
        _prettyGeekSubtype(subtype),
        if (year.isNotEmpty) year,
      ].join(' · ');

      matches.add(
        ExternalMetadataCandidate(
          source: source,
          id: id,
          title: title,
          subtitle: subtitle.isEmpty ? null : subtitle,
          sourceUrl: _geekDoUrl(source, id, subtype),
        ),
      );
    }

    return matches;
  }

  Future<ExternalMetadataRecord?> _fetchGeekDoById({
    required ExternalMetadataSource source,
    required String id,
    required String subtype,
  }) async {
    if (id.isEmpty) return null;

    final uri = Uri.parse(
      'https://api.geekdo.com/api/geekitems?objectid=$id&objecttype=thing',
    );
    final response = await http.get(uri, headers: _httpHeaders).timeout(
      const Duration(seconds: 10),
    );
    if (response.statusCode != 200) return null;

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final item = data['item'] as Map<String, dynamic>?;
    if (item == null) return null;

    final itemSubtype = item['subtype']?.toString().trim().isNotEmpty == true
        ? item['subtype'].toString()
        : subtype;
    final name = item['name']?.toString() ?? 'GeekDo';
    final description = _cleanHtml(item['description']?.toString() ?? '');
    final shortDescription = _cleanHtml(item['short_description']?.toString() ?? '');
    final finalDescription = description.isNotEmpty ? description : shortDescription;

    final image = _firstNonEmpty([
      item['imageurl'] as String?,
      (item['images'] as Map<String, dynamic>?)?['original'] as String?,
    ]);

    final links = (item['links'] as Map<String, dynamic>?) ?? const {};
    List<String> names(String key) => ((links[key] as List?) ?? const [])
        .map((entry) => (entry as Map)['name']?.toString() ?? '')
        .where((value) => value.isNotEmpty)
        .toList();

    final categories = <String>[
      ...names('boardgamecategory'),
      ...names('boardgamesubdomain'),
      ...names('videogamegenre'),
      ...names('videogametheme'),
      ...names('rpgcategory'),
      ...names('rpggenre'),
      ...names('rpgsetting'),
    ];
    final mechanics = <String>[
      ...names('boardgamemechanic'),
      ...names('rpgmechanic'),
    ];
    final designers = <String>[
      ...names('boardgamedesigner'),
      ...names('videogamedeveloper'),
      ...names('videogamecompany'),
      ...names('rpgdesigner'),
      ...names('rpgartist'),
    ];
    final publishers = <String>[
      ...names('boardgamepublisher'),
      ...names('videogamepublisher'),
      ...names('rpgpublisher'),
    ];
    final platforms = names('videogameplatform');

    final year = int.tryParse(item['yearpublished']?.toString() ?? '');
    final minPlayers = item['minplayers']?.toString() ?? '';
    final maxPlayers = item['maxplayers']?.toString() ?? '';
    final minPlaytime = item['minplaytime']?.toString() ?? '';
    final maxPlaytime = item['maxplaytime']?.toString() ?? '';

    final facts = <String, String>{};
    if (itemSubtype.isNotEmpty) facts['Typ'] = _prettyGeekSubtype(itemSubtype);
    if (year != null) facts['Jahr'] = year.toString();
    if (minPlayers.isNotEmpty || maxPlayers.isNotEmpty) {
      facts['Spieler'] = minPlayers == maxPlayers
          ? minPlayers
          : '$minPlayers–$maxPlayers';
    }
    if (minPlaytime.isNotEmpty || maxPlaytime.isNotEmpty) {
      facts['Dauer'] = minPlaytime == maxPlaytime
          ? minPlaytime
          : '$minPlaytime–$maxPlaytime';
    }
    if (platforms.isNotEmpty) facts['Plattformen'] = platforms.join(', ');

    final creator = designers.isNotEmpty ? designers.join(', ') : null;
    final publisher = publishers.isNotEmpty ? publishers.join(', ') : null;
    final tags = <String>[
      ...categories,
      ...mechanics,
      ...platforms,
    ];

    return ExternalMetadataRecord(
      source: source,
      title: name,
      description: finalDescription,
      imageUrl: image,
      sourceUrl: _geekDoUrl(source, id, itemSubtype),
      tags: _unique(tags),
      creator: creator,
      publisher: publisher,
      year: year,
      kindLabel: _prettyGeekSubtype(itemSubtype),
      facts: facts,
    );
  }

  bool _matchesGeekSubtype(ExternalMetadataSource source, String subtype) {
    switch (source) {
      case ExternalMetadataSource.boardGameGeek:
        return subtype == 'boardgame' || subtype == 'boardgameexpansion';
      case ExternalMetadataSource.videoGameGeek:
        return subtype == 'videogame';
      case ExternalMetadataSource.rpgGeek:
        return subtype == 'rpgitem' || subtype == 'rpg';
      case ExternalMetadataSource.anilistAnime:
      case ExternalMetadataSource.anilistManga:
        return false;
    }
  }

  String _prettyGeekSubtype(String subtype) => switch (subtype) {
        'boardgameexpansion' => 'Expansion',
        'boardgame' => 'Board Game',
        'videogame' => 'Video Game',
        'rpgitem' => 'RPG Item',
        'rpg' => 'RPG',
        _ => subtype.isEmpty ? 'GeekDo' : subtype,
      };

  String _geekDoUrl(
    ExternalMetadataSource source,
    String id,
    String subtype,
  ) {
    final host = source == ExternalMetadataSource.videoGameGeek
        ? 'videogamegeek.com'
        : source == ExternalMetadataSource.rpgGeek
            ? 'rpggeek.com'
            : 'boardgamegeek.com';
    final path = source == ExternalMetadataSource.videoGameGeek
        ? 'videogame'
        : source == ExternalMetadataSource.rpgGeek
            ? (subtype == 'rpg' ? 'rpg' : 'rpgitem')
            : 'boardgame';
    return 'https://$host/$path/$id';
  }

  String? _aniListUrl(ExternalMetadataSource source, dynamic id) {
    final numeric = id?.toString();
    if (numeric == null || numeric.isEmpty) return null;
    final type = source == ExternalMetadataSource.anilistManga ? 'manga' : 'anime';
    return 'https://anilist.co/$type/$numeric';
  }

  String _aniListSubtitle(ExternalMetadataRecord record) {
    final facts = record.facts;
    final parts = <String>[];
    if (facts['Format'] != null) parts.add(facts['Format']!);
    if (record.year != null) parts.add(record.year.toString());
    return parts.join(' · ');
  }

  String _geekSubtitle(ExternalMetadataRecord record) {
    final parts = <String>[];
    if (record.kindLabel != null && record.kindLabel!.isNotEmpty) {
      parts.add(record.kindLabel!);
    }
    if (record.year != null) parts.add(record.year.toString());
    return parts.join(' · ');
  }

  String _cleanHtml(String value) => value
      .replaceAll(RegExp(r'<[^>]*>'), '')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&mdash;', '—')
      .replaceAll('&ndash;', '–')
      .replaceAll('&rsquo;', "'")
      .replaceAll('&lsquo;', "'")
      .replaceAll('&rdquo;', '"')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&hellip;', '…')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  List<String> _unique(List<String> values) {
    final seen = <String>{};
    final out = <String>[];
    for (final value in values) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) continue;
      if (seen.add(trimmed.toLowerCase())) {
        out.add(trimmed);
      }
    }
    return out;
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  ({ExternalMetadataSource source, int id})? _parseAniListUrl(String input) {
    final uri = Uri.tryParse(input);
    if (uri == null) return null;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    if (!host.contains('anilist.co')) return null;
    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;
    final type = segments.first.toLowerCase();
    final id = int.tryParse(segments[1]);
    if (id == null) return null;
    final ExternalMetadataSource? source = switch (type) {
      'anime' => ExternalMetadataSource.anilistAnime,
      'manga' => ExternalMetadataSource.anilistManga,
      _ => null,
    };
    if (source == null) return null;
    return (source: source, id: id);
  }

  ({ExternalMetadataSource source, String id, String subtype})?
      _parseGeekDoUrl(
    String input,
  ) {
    final uri = Uri.tryParse(input);
    if (uri == null) return null;
    final host = uri.host.toLowerCase().replaceFirst('www.', '');
    if (!host.contains('boardgamegeek.com') &&
        !host.contains('videogamegeek.com') &&
        !host.contains('rpggeek.com')) {
      return null;
    }

    final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return null;

    final type = segments[0].toLowerCase();
    final id = segments[1];
    final source = switch (host) {
      String h when h.contains('videogamegeek.com') =>
        ExternalMetadataSource.videoGameGeek,
      String h when h.contains('rpggeek.com') =>
        ExternalMetadataSource.rpgGeek,
      _ => ExternalMetadataSource.boardGameGeek,
    };

    return (source: source, id: id, subtype: type);
  }
}
