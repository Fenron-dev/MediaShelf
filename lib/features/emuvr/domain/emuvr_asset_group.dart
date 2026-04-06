import '../../../data/database/app_database.dart';

/// A logical EmuVR asset group: one primary .obj file plus its companions.
///
/// These files share the same basename (e.g. "n64.obj", "n64.mtl", "n64.png")
/// and are imported together as a single unit. In the DAM they are represented
/// as linked assets with the .obj file being the primary.
class EmuvrAssetGroup {
  final Asset objAsset;
  final Asset? mtlAsset;
  final List<Asset> textures;   // .png / .jpg / .jpeg
  final Asset? iniAsset;

  const EmuvrAssetGroup({
    required this.objAsset,
    this.mtlAsset,
    this.textures = const [],
    this.iniAsset,
  });

  /// All companion assets (everything except the primary .obj).
  List<Asset> get companions => [
        ?mtlAsset,
        ...textures,
        ?iniAsset,
      ];

  /// All assets in this group, including the primary.
  List<Asset> get all => [objAsset, ...companions];
}
