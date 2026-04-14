import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/drivethrurpg_scraper.dart';
import '../domain/drivethrurpg_metadata.dart';

// ── Scraper singleton ─────────────────────────────────────────────────────────

final drivethrurpgScraperProvider = Provider<DriveThruRpgScraper>(
  (_) => DriveThruRpgScraper(),
);

// ── Search state ──────────────────────────────────────────────────────────────

class DriveThruRpgSearchNotifier
    extends AutoDisposeAsyncNotifier<List<DriveThruRpgSearchResult>> {
  @override
  Future<List<DriveThruRpgSearchResult>> build() async => [];

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncData([]);
      return;
    }
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(drivethrurpgScraperProvider).search(query.trim()),
    );
  }

  void clear() => state = const AsyncData([]);
}

final drivethrurpgSearchProvider = AutoDisposeAsyncNotifierProvider<
    DriveThruRpgSearchNotifier, List<DriveThruRpgSearchResult>>(
  DriveThruRpgSearchNotifier.new,
);

// ── Product metadata fetch ────────────────────────────────────────────────────

class DriveThruRpgFetchNotifier
    extends AutoDisposeAsyncNotifier<DriveThruRpgMetadata?> {
  @override
  Future<DriveThruRpgMetadata?> build() async => null;

  Future<void> fetchByUrl(String url) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(drivethrurpgScraperProvider).fetchMetadata(url),
    );
  }

  void clear() => state = const AsyncData(null);
}

final drivethrurpgFetchProvider = AutoDisposeAsyncNotifierProvider<
    DriveThruRpgFetchNotifier, DriveThruRpgMetadata?>(
  DriveThruRpgFetchNotifier.new,
);
