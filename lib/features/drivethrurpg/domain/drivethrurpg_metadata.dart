/// A single result item from a DriveThruRPG search.
class DriveThruRpgSearchResult {
  const DriveThruRpgSearchResult({
    required this.productId,
    required this.title,
    required this.publisher,
    this.author,
    this.coverUrl,
    required this.productUrl,
    this.price,
  });

  final String productId;
  final String title;
  final String publisher;
  final String? author;
  final String? coverUrl;
  final String productUrl;
  final String? price;
}

/// Full metadata scraped from a DriveThruRPG product page.
class DriveThruRpgMetadata {
  const DriveThruRpgMetadata({
    this.title,
    this.publisher,
    this.authors = const [],
    this.description,
    this.coverUrl,
    this.pageCount,
    this.categories = const [],
    this.system,
    required this.productUrl,
    this.sku,
    this.rating,
    this.ratingCount,
  });

  final String? title;
  final String? publisher;
  final List<String> authors;
  final String? description;
  final String? coverUrl;
  final int? pageCount;
  final List<String> categories;

  /// Game system (e.g. "D&D 5e", "Pathfinder 2e").
  final String? system;

  final String productUrl;
  final String? sku;
  final double? rating;
  final int? ratingCount;

  String get authorsDisplay => authors.join(', ');
}
