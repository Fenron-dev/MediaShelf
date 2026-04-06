/// Top-level directory inside a library folder that holds all MediaShelf data.
const String kMediashelfDir = '.mediashelf';

/// Sub-directory for cached thumbnail images.
const String kThumbDir = 'thumbnails';

/// SQLite database filename.
const String kDbFilename = 'index.db';

/// Thumbnail dimensions (width & height, square crop).
const int kThumbSize = 256;

/// JPEG quality for thumbnails (0–100).
const int kThumbQuality = 85;

/// Maximum concurrent thumbnail generation isolates.
const int kThumbIsolatePoolSize = 4;

/// Debounce duration for filesystem watcher events.
const Duration kWatcherDebounce = Duration(milliseconds: 800);

/// Default thumbnail grid cell size in logical pixels.
const double kDefaultThumbnailSize = 180.0;

/// Minimum window width to show the 3-panel desktop layout.
const double kDesktopBreakpoint = 900.0;

/// Minimum window width to show the detail panel alongside the grid.
const double kDetailPanelBreakpoint = 1100.0;

/// Default sidebar width.
const double kSidebarWidth = 240.0;

/// Default detail panel width.
const double kDetailPanelWidth = 300.0;

/// Asset page size for paginated queries.
const int kPageSize = 100;

/// Color labels — same set as Nexus Explorer for schema compatibility.
const List<String> kColorLabels = ['red', 'yellow', 'green', 'blue', 'purple'];

/// Smart-filter JSON logic values.
const String kLogicAnd = 'AND';
const String kLogicOr = 'OR';

/// Sub-directory inside `.mediashelf` that holds encrypted vault files.
const String kVaultDir = 'vault';

/// File extension for encrypted vault files on disk.
const String kVaultExt = '.enc';
