// ignore_for_file: avoid_catches_without_on_clauses
import 'dart:convert';

import 'package:html/dom.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import '../domain/drivethrurpg_metadata.dart';

/// Scrapes product information from DriveThruRPG.
///
/// Uses the German locale base URL by default (`/de/`) but falls back to the
/// product's canonical URL if the user provides a full link.
class DriveThruRpgScraper {
  static const _baseUrl = 'https://www.drivethrurpg.com';

  // Mimic a real browser so the server does not return a bot-block page.
  static const _headers = {
    'User-Agent':
        'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 '
        '(KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36',
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'Accept-Language': 'de-DE,de;q=0.9,en-US;q=0.8,en;q=0.7',
  };

  // ── Public API ──────────────────────────────────────────────────────────────

  /// Searches DriveThruRPG for [query] and returns up to 20 results.
  Future<List<DriveThruRpgSearchResult>> search(String query) async {
    final uri = Uri.parse(
      '$_baseUrl/de/search?keywords=${Uri.encodeComponent(query)}'
      '&search_type=products',
    );
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode != 200) return [];
    return _parseSearchResults(response.body);
  }

  /// Fetches full metadata for a product identified by [productUrl].
  ///
  /// Accepts both full DTRPG URLs and bare product IDs.
  Future<DriveThruRpgMetadata> fetchMetadata(String productUrl) async {
    final uri = _resolveUrl(productUrl);
    final response = await http.get(uri, headers: _headers).timeout(
      const Duration(seconds: 15),
    );
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode} für $productUrl');
    }
    return _parseProductPage(response.body, uri.toString());
  }

  // ── URL helper ──────────────────────────────────────────────────────────────

  Uri _resolveUrl(String input) {
    final trimmed = input.trim();
    // Already a full DTRPG URL
    if (trimmed.startsWith('http')) return Uri.parse(trimmed);
    // Bare numeric ID → build canonical URL
    if (RegExp(r'^\d+$').hasMatch(trimmed)) {
      return Uri.parse('$_baseUrl/de/product/$trimmed');
    }
    return Uri.parse(trimmed);
  }

  // ── Search result parsing ───────────────────────────────────────────────────

  List<DriveThruRpgSearchResult> _parseSearchResults(String body) {
    final doc = html_parser.parse(body);
    final results = <DriveThruRpgSearchResult>[];

    // DTRPG renders search results in rows / cards. We look for any element
    // that carries a product link, then collect siblings for title / publisher.
    // The selectors below cover several layout generations of the site.
    final productLinks = doc.querySelectorAll(
      'a[href*="/product/"], a[href*="/de/product/"]',
    );

    final seen = <String>{};

    for (final link in productLinks) {
      final href = link.attributes['href'] ?? '';
      final idMatch = RegExp(r'/product/(\d+)').firstMatch(href);
      if (idMatch == null) continue;

      final productId = idMatch.group(1)!;
      if (!seen.add(productId)) continue; // deduplicate

      final title = _cleanText(link.text);
      if (title.isEmpty) continue;
      // Skip navigation / non-product links (very short or suspiciously generic)
      if (title.length < 3) continue;

      final productUrl = href.startsWith('http')
          ? href
          : '$_baseUrl$href';

      // Look for publisher and cover image in the surrounding card container
      final card = _closestCard(link);
      final publisher = card != null
          ? _extractPublisherFromCard(card)
          : '';
      final coverUrl = card != null
          ? _extractCoverFromCard(card, productId)
          : null;
      final price = card != null ? _extractPriceFromCard(card) : null;
      final author = card != null ? _extractAuthorFromCard(card) : null;

      results.add(DriveThruRpgSearchResult(
        productId: productId,
        title: title,
        publisher: publisher,
        author: author,
        coverUrl: coverUrl,
        productUrl: productUrl,
        price: price,
      ));

      if (results.length >= 20) break;
    }

    return results;
  }

  // Walk up the DOM to find a reasonable card/row container for [el].
  Element? _closestCard(Element el) {
    var current = el.parent;
    for (var i = 0; i < 6 && current != null; i++) {
      final cls = current.className;
      if (cls.contains('product') ||
          cls.contains('card') ||
          cls.contains('item') ||
          cls.contains('row') ||
          current.localName == 'li' ||
          current.localName == 'tr') {
        return current;
      }
      current = current.parent;
    }
    return el.parent?.parent; // fallback: two levels up
  }

  String _extractPublisherFromCard(Element card) {
    // Try data attribute first
    final pub = card.attributes['data-pub-name'] ??
        card.attributes['data-publisher'];
    if (pub != null) return _cleanText(pub);

    // Look for publisher links / spans
    for (final sel in [
      'a[href*="/publisher/"]',
      '[class*="publisher"]',
      '[class*="brand"]',
      '[itemprop="brand"]',
    ]) {
      final el = card.querySelector(sel);
      if (el != null) {
        final t = _cleanText(el.text);
        if (t.isNotEmpty) return t;
      }
    }
    return '';
  }

  String? _extractCoverFromCard(Element card, String productId) {
    for (final sel in ['img[src*="/$productId"]', 'img[data-src*="/$productId"]', 'img']) {
      final img = card.querySelector(sel);
      if (img != null) {
        return img.attributes['src'] ??
            img.attributes['data-src'] ??
            img.attributes['data-lazy-src'];
      }
    }
    return null;
  }

  String? _extractPriceFromCard(Element card) {
    for (final sel in [
      '[class*="price"]',
      '[itemprop="price"]',
      '[class*="cost"]',
    ]) {
      final el = card.querySelector(sel);
      if (el != null) {
        final t = _cleanText(el.text);
        if (t.isNotEmpty) return t;
      }
    }
    return null;
  }

  String? _extractAuthorFromCard(Element card) {
    for (final sel in [
      '[itemprop="author"]',
      '[class*="author"]',
      'a[href*="/browse/author/"]',
    ]) {
      final el = card.querySelector(sel);
      if (el != null) {
        final t = _cleanText(el.text);
        if (t.isNotEmpty) return t;
      }
    }
    return null;
  }

  // ── Product page parsing ────────────────────────────────────────────────────

  DriveThruRpgMetadata _parseProductPage(String body, String productUrl) {
    final doc = html_parser.parse(body);

    // 1. Try JSON-LD (most reliable)
    final meta = _parseJsonLd(doc, productUrl);
    if (meta != null) return meta;

    // 2. Fallback: OpenGraph + HTML DOM
    return _parseFromDom(doc, productUrl);
  }

  DriveThruRpgMetadata? _parseJsonLd(Document doc, String productUrl) {
    final scripts = doc.querySelectorAll('script[type="application/ld+json"]');
    for (final script in scripts) {
      try {
        final raw = script.text.trim();
        if (raw.isEmpty) continue;
        final decoded = jsonDecode(raw);
        final data = decoded is List ? decoded.first as Map : decoded as Map;

        // Accept Product, Book, or anything that has a 'name'
        final types = (data['@type'] is List
                ? (data['@type'] as List).cast<String>()
                : [data['@type']?.toString() ?? ''])
            .map((t) => t.toLowerCase())
            .toList();

        if (types.any((t) =>
            t.contains('product') || t.contains('book') || t.contains('item'))) {
          return _metaFromJsonLd(data, productUrl);
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }

  DriveThruRpgMetadata _metaFromJsonLd(Map data, String productUrl) {
    String? title = data['name']?.toString();

    // Authors: can be Person, list of Persons, or plain string
    final authorRaw = data['author'];
    final authors = <String>[];
    if (authorRaw is Map) {
      final n = authorRaw['name']?.toString();
      if (n != null) authors.add(n);
    } else if (authorRaw is List) {
      for (final a in authorRaw) {
        final n = a is Map ? a['name']?.toString() : a?.toString();
        if (n != null) authors.add(n);
      }
    } else if (authorRaw is String) {
      authors.add(authorRaw);
    }

    // Publisher / brand
    String? publisher;
    for (final key in ['publisher', 'brand', 'creator', 'copyrightHolder']) {
      final raw = data[key];
      if (raw is Map) {
        publisher = raw['name']?.toString();
      } else if (raw is String) {
        publisher = raw;
      }
      if (publisher != null) break;
    }

    final description = _stripHtml(data['description']?.toString());
    final coverUrl = _resolveImageUrl(data['image']);
    final pageCount = _parseInt(data['numberOfPages']);

    // Categories / genre
    final cats = <String>[];
    final genre = data['genre'];
    if (genre is String) cats.add(genre);
    if (genre is List) cats.addAll(genre.cast<String>());

    final rating = _parseDouble(data['aggregateRating']?['ratingValue']);
    final ratingCount = _parseInt(data['aggregateRating']?['reviewCount'] ??
        data['aggregateRating']?['ratingCount']);

    final sku = data['sku']?.toString() ?? data['productID']?.toString();

    return DriveThruRpgMetadata(
      title: title,
      publisher: publisher,
      authors: authors,
      description: description,
      coverUrl: coverUrl,
      pageCount: pageCount,
      categories: cats,
      productUrl: productUrl,
      sku: sku,
      rating: rating,
      ratingCount: ratingCount,
    );
  }

  DriveThruRpgMetadata _parseFromDom(Document doc, String productUrl) {
    // OG tags
    String? title = _ogContent(doc, 'og:title') ??
        doc.querySelector('h1')?.text.trim();
    String? coverUrl = _ogContent(doc, 'og:image');
    String? description =
        _stripHtml(_ogContent(doc, 'og:description') ??
            doc.querySelector('meta[name="description"]')?.attributes['content']);

    // Publisher
    String? publisher;
    for (final sel in [
      'a[href*="/publisher/"]',
      '[itemprop="brand"] [itemprop="name"]',
      '[class*="publisher"]',
    ]) {
      final el = doc.querySelector(sel);
      if (el != null) {
        publisher = _cleanText(el.text);
        break;
      }
    }

    // Authors
    final authors = <String>[];
    for (final el in doc.querySelectorAll(
      '[itemprop="author"], a[href*="/browse/author/"], [class*="author"]',
    )) {
      final t = _cleanText(el.text);
      if (t.isNotEmpty && !authors.contains(t)) authors.add(t);
    }

    // Page count — look for "Seiten", "Pages" in product info table
    int? pageCount;
    for (final el in doc.querySelectorAll('td, li, span, div')) {
      final text = el.text;
      final m = RegExp(
        r'(\d+)\s*(Seiten?|Pages?)',
        caseSensitive: false,
      ).firstMatch(text);
      if (m != null) {
        pageCount = int.tryParse(m.group(1)!);
        break;
      }
    }

    // Categories
    final cats = <String>[];
    for (final el in doc.querySelectorAll(
      'a[href*="/category/"], a[href*="/browse/category/"], [itemprop="category"]',
    )) {
      final t = _cleanText(el.text);
      if (t.isNotEmpty && !cats.contains(t)) cats.add(t);
    }

    // Rating
    double? rating;
    int? ratingCount;
    final ratingEl = doc.querySelector('[itemprop="ratingValue"]');
    if (ratingEl != null) {
      rating = _parseDouble(ratingEl.attributes['content'] ?? ratingEl.text);
    }
    final countEl = doc.querySelector('[itemprop="reviewCount"], [itemprop="ratingCount"]');
    if (countEl != null) {
      ratingCount = _parseInt(countEl.attributes['content'] ?? countEl.text);
    }

    return DriveThruRpgMetadata(
      title: _cleanText(title ?? '').isEmpty ? null : _cleanText(title ?? ''),
      publisher: publisher,
      authors: authors,
      description: description,
      coverUrl: coverUrl,
      pageCount: pageCount,
      categories: cats,
      productUrl: productUrl,
      rating: rating,
      ratingCount: ratingCount,
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String? _ogContent(Document doc, String property) {
    final el = doc.querySelector('meta[property="$property"]');
    return el?.attributes['content'];
  }

  String _cleanText(String text) =>
      text.replaceAll(RegExp(r'\s+'), ' ').trim();

  String? _stripHtml(String? html) {
    if (html == null) return null;
    return html_parser
        .parse(html)
        .documentElement
        ?.text
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _resolveImageUrl(dynamic value) {
    if (value is String) {
      return value.startsWith('//') ? 'https:$value' : value;
    }
    if (value is List && value.isNotEmpty) {
      final first = value.first;
      if (first is String) {
        return first.startsWith('//') ? 'https:$first' : first;
      }
      if (first is Map) {
        final url = first['url']?.toString();
        if (url != null) {
          return url.startsWith('//') ? 'https:$url' : url;
        }
      }
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString().replaceAll(RegExp(r'[^\d]'), ''));
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.'));
  }
}
