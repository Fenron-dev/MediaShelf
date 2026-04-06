import '../../../data/database/app_database.dart';
import '../domain/emuvr_asset_group.dart';

/// Name of the custom property definition used to mark .obj assets as
/// EmuVR group heads.
const kEmuvrPrimaryAssetProp = 'EmuVR/PrimaryAsset';

// ── Group detection ───────────────────────────────────────────────────────────

/// Scans a flat list of assets and groups together files that share the same
/// basename (case-insensitive, ignoring extension).
///
/// Returns only groups that contain at least one .obj file. Companion files
/// without a corresponding .obj are ignored.
List<EmuvrAssetGroup> detectGroups(List<Asset> assets) {
  final byBasename = <String, List<Asset>>{};
  for (final asset in assets) {
    final base = _basenameOf(asset.filename);
    (byBasename[base] ??= []).add(asset);
  }

  final groups = <EmuvrAssetGroup>[];
  for (final files in byBasename.values) {
    final obj = files.where((a) => a.extension == 'obj').firstOrNull;
    if (obj == null) continue;
    groups.add(EmuvrAssetGroup(
      objAsset: obj,
      mtlAsset: files.where((a) => a.extension == 'mtl').firstOrNull,
      textures: files
          .where((a) => const {'png', 'jpg', 'jpeg'}.contains(a.extension))
          .toList(),
      iniAsset: files.where((a) => a.extension == 'ini').firstOrNull,
    ));
  }
  return groups;
}

// ── Group resolution ──────────────────────────────────────────────────────────

/// Returns the EmuVR group that [asset] belongs to, or null if it isn't
/// part of any EmuVR group.
///
/// Works for both the primary .obj and its companions.
Future<EmuvrAssetGroup?> resolveGroup(
  Asset asset,
  AssetsDao assetsDao,
  AssetLinksDao assetLinksDao,
  PropertiesDao propertiesDao,
) async {
  final primaryPropId = await _getOrNullPrimaryPropId(propertiesDao);
  if (primaryPropId == null) return null;

  Asset? objAsset;

  if (asset.extension == 'obj') {
    if (await _isPrimary(asset.id, primaryPropId, propertiesDao)) {
      objAsset = asset;
    }
  } else {
    final linked = await assetLinksDao.getLinkedAssets(asset.id);
    for (final candidate in linked) {
      if (candidate.extension == 'obj' &&
          await _isPrimary(candidate.id, primaryPropId, propertiesDao)) {
        objAsset = candidate;
        break;
      }
    }
  }

  if (objAsset == null) return null;

  final companions = await assetLinksDao.getLinkedAssets(objAsset.id);
  return EmuvrAssetGroup(
    objAsset: objAsset,
    mtlAsset: companions.where((a) => a.extension == 'mtl').firstOrNull,
    textures: companions
        .where((a) => const {'png', 'jpg', 'jpeg'}.contains(a.extension))
        .toList(),
    iniAsset: companions.where((a) => a.extension == 'ini').firstOrNull,
  );
}

// ── Mark as primary ───────────────────────────────────────────────────────────

/// Marks [objAssetId] as the head of an EmuVR group by setting the
/// EmuVR/PrimaryAsset custom property to 'true'.
///
/// Creates the property definition if it doesn't exist yet.
Future<void> markAsPrimary(
  String objAssetId,
  PropertiesDao propertiesDao,
) async {
  final propId = await _getOrCreatePrimaryPropId(propertiesDao);
  await propertiesDao.setPropertyValue(objAssetId, propId, 'true');
}

// ── Helpers ───────────────────────────────────────────────────────────────────

String _basenameOf(String filename) {
  final dot = filename.lastIndexOf('.');
  if (dot <= 0) return filename.toLowerCase();
  return filename.substring(0, dot).toLowerCase();
}

Future<bool> _isPrimary(
  String assetId,
  String primaryPropId,
  PropertiesDao propertiesDao,
) async {
  final props = await propertiesDao
      .watchPropertiesForAsset(assetId)
      .first;
  return props.any(
    (p) => p.propertyId == primaryPropId && p.valueText == 'true',
  );
}

Future<String?> _getOrNullPrimaryPropId(PropertiesDao dao) async {
  final defs = await dao.getAllDefinitions();
  return defs
      .where((d) => d.name == kEmuvrPrimaryAssetProp)
      .firstOrNull
      ?.id;
}

Future<String> _getOrCreatePrimaryPropId(PropertiesDao dao) async {
  final existing = await _getOrNullPrimaryPropId(dao);
  if (existing != null) return existing;

  await dao.createDefinition(
    name: kEmuvrPrimaryAssetProp,
    fieldType: 'boolean',
    sortOrder: 999,
  );
  // Re-fetch to get the generated ID
  final defs = await dao.getAllDefinitions();
  return defs.firstWhere((d) => d.name == kEmuvrPrimaryAssetProp).id;
}
