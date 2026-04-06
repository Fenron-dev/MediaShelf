/// Pure function: derives suggested EmuVR tags from an asset's basename.
///
/// Tokenises the basename on underscores, hyphens, dots and spaces,
/// then matches tokens against a keyword table.
List<String> suggestEmuvrTags(String basename) {
  final lower = basename.toLowerCase();
  final tags = <String>{};

  // Console keywords → EmuVR/Console tag
  const consolePrefixes = [
    'n64', 'nintendo64', 'snes', 'nes', 'gameboy', 'gb', 'gba', 'gbc',
    'nds', 'ds', 'wii', 'gamecube', 'gc',
    'ps1', 'ps2', 'ps3', 'ps4', 'psx', 'playstation',
    'saturn', 'dreamcast', 'genesis', 'megadrive',
    'xbox', '360',
    'atari', 'intellivision', 'colecovision',
    'pce', 'pcengine', 'turbografx',
    'console',
  ];

  // Cartridge / media keywords → EmuVR/Cart tag
  const cartPrefixes = [
    'cart', 'cartridge', 'cassette', 'module',
    'card', 'pak', 'pack',
  ];

  for (final kw in consolePrefixes) {
    if (lower.contains(kw)) {
      tags.add('EmuVR/Console');
      break;
    }
  }

  for (final kw in cartPrefixes) {
    if (lower.contains(kw)) {
      tags.add('EmuVR/Cart');
      break;
    }
  }

  return tags.toList();
}
