import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/library_provider.dart';
import '../data/emuvr_group_service.dart';
import '../domain/emuvr_asset_group.dart';

/// Resolves the EmuVR group for the given asset ID.
///
/// Returns null if the asset is not part of any EmuVR group.
/// Keyed by asset ID so each detail panel maintains its own cached value.
final emuvrGroupProvider =
    FutureProvider.family<EmuvrAssetGroup?, String>((ref, assetId) async {
  final assetsDao = ref.watch(assetsDaoProvider);
  final linksDao = ref.watch(assetLinksDaoProvider);
  final propsDao = ref.watch(propertiesDaoProvider);

  final asset = await assetsDao.getById(assetId);
  if (asset == null) return null;

  return resolveGroup(asset, assetsDao, linksDao, propsDao);
});
