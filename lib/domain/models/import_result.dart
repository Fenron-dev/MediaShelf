import '../../data/database/app_database.dart';

// ── Duplicate resolution choice ───────────────────────────────────────────────

enum DuplicateChoice {
  /// Copy the file anyway (may be renamed if dest path already exists).
  importCopy,

  /// Add the existing asset to the import collection — no new file copy.
  link,

  /// Skip this file entirely.
  skip,
}

// ── A single file to be imported ──────────────────────────────────────────────

class ImportItem {
  const ImportItem({
    required this.sourcePath,
    required this.destRelPath,
  });

  /// Absolute path of the source file on disk.
  final String sourcePath;

  /// Relative destination path inside the library root (forward slashes).
  final String destRelPath;
}

// ── A duplicate found during analysis ────────────────────────────────────────

class DuplicateInfo {
  DuplicateInfo({
    required this.sourcePath,
    required this.existingAsset,
    required this.destRelPath,
    this.choice = DuplicateChoice.link,
  });

  final String sourcePath;

  /// The asset already in the library that has the same MD5.
  final Asset existingAsset;

  /// Where this file *would* land in the library (relative path).
  final String destRelPath;

  /// Resolved by the user in the duplicate dialog.
  DuplicateChoice choice;
}

// ── The full plan returned by ImportService.analyze() ────────────────────────

class ImportPlan {
  const ImportPlan({
    required this.toCopy,
    required this.toRename,
    required this.duplicates,
    required this.libraryPath,
    required this.stripPrefix,
  });

  /// Files that are genuinely new — destination path is free.
  final List<ImportItem> toCopy;

  /// Files whose destination path is taken — will be auto-renamed (_2, _3…).
  final List<ImportItem> toRename;

  /// Files whose MD5 matches an existing asset at a *different* path.
  final List<DuplicateInfo> duplicates;

  /// Absolute path to the library root.
  final String libraryPath;

  /// The path prefix that was stripped from source paths.
  final String stripPrefix;

  bool get hasDuplicates => duplicates.isNotEmpty;
  int get totalFiles => toCopy.length + toRename.length + duplicates.length;
}

// ── Result of ImportService.execute() ────────────────────────────────────────

class ImportResult {
  const ImportResult({
    required this.copied,
    required this.renamed,
    required this.linked,
    required this.skipped,
    required this.errors,
  });

  final int copied;
  final int renamed;
  final int linked;
  final int skipped;
  final List<String> errors;

  int get total => copied + renamed + linked;
}

// ── Result of ExportService.export() ─────────────────────────────────────────

class ExportResult {
  const ExportResult({
    required this.exported,
    required this.errors,
  });

  final int exported;
  final List<String> errors;
}
