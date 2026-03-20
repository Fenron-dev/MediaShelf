/// Encapsulates all active filter and sort state for the asset grid.
///
/// The JSON representation of [smartFilterRules] is compatible with
/// Nexus Explorer's `{logic, rules}` format for cross-app library access.
class AssetFilter {
  const AssetFilter({
    this.searchQuery = '',
    this.dirFilter = '',
    this.includeSubdirs = true,
    this.collectionId,
    this.tagFilter,
    this.ratingMin = 0,
    this.colorLabel = '',
    this.mimeType = '',
    this.extension = '',
    this.hasResume = ResumeFilter.all,
    this.dateFrom = '',
    this.dateTo = '',
    this.sortBy = SortBy.name,
    this.sortDir = SortDir.asc,
    this.randomMode = false,
    this.statusFilter = 'ok',
  });

  final String searchQuery;
  final String dirFilter;
  final bool includeSubdirs;
  final String? collectionId;
  final String? tagFilter;
  final int ratingMin;
  final String colorLabel;
  final String mimeType;
  final String extension;
  final ResumeFilter hasResume;
  final String dateFrom;
  final String dateTo;
  final SortBy sortBy;
  final SortDir sortDir;
  final bool randomMode;
  final String statusFilter;

  AssetFilter copyWith({
    String? searchQuery,
    String? dirFilter,
    bool? includeSubdirs,
    String? collectionId,
    bool clearCollectionId = false,
    String? tagFilter,
    bool clearTagFilter = false,
    int? ratingMin,
    String? colorLabel,
    String? mimeType,
    String? extension,
    ResumeFilter? hasResume,
    String? dateFrom,
    String? dateTo,
    SortBy? sortBy,
    SortDir? sortDir,
    bool? randomMode,
    String? statusFilter,
  }) {
    return AssetFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      dirFilter: dirFilter ?? this.dirFilter,
      includeSubdirs: includeSubdirs ?? this.includeSubdirs,
      collectionId: clearCollectionId ? null : (collectionId ?? this.collectionId),
      tagFilter: clearTagFilter ? null : (tagFilter ?? this.tagFilter),
      ratingMin: ratingMin ?? this.ratingMin,
      colorLabel: colorLabel ?? this.colorLabel,
      mimeType: mimeType ?? this.mimeType,
      extension: extension ?? this.extension,
      hasResume: hasResume ?? this.hasResume,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortBy: sortBy ?? this.sortBy,
      sortDir: sortDir ?? this.sortDir,
      randomMode: randomMode ?? this.randomMode,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      dirFilter.isNotEmpty ||
      collectionId != null ||
      tagFilter != null ||
      ratingMin > 0 ||
      colorLabel.isNotEmpty ||
      mimeType.isNotEmpty ||
      extension.isNotEmpty ||
      hasResume != ResumeFilter.all ||
      dateFrom.isNotEmpty ||
      dateTo.isNotEmpty;
}

enum ResumeFilter { all, hasResume, noResume }

enum SortBy { name, date, size, rating, extension, indexedAt, random }

enum SortDir { asc, desc }
