import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

/// Wrapper around [FilePicker] that ensures the native file-picker dialog
/// appears in front of the MediaShelf window on all desktop platforms.
///
/// **Strategy (minimize/restore):**
/// 1. Minimize the window so the OS removes it from the foreground.
/// 2. Wait 120 ms for the minimize animation to settle.
/// 3. Open the FilePicker dialog — the OS places it at the top of the stack.
/// 4. After the dialog closes, restore + maximize + focus the window.
///
/// On non-desktop platforms (Android, iOS) the minimize/restore calls are
/// skipped and the plain FilePicker API is used directly.
class FilePickerHelper {
  FilePickerHelper._();

  static bool get _isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;
  static bool get _shouldMinimizeDesktopWindow => Platform.isLinux;

  static bool _effectiveLockParentWindow(bool lockParentWindow) =>
      lockParentWindow || Platform.isWindows;

  static Future<bool> _beforeDialog() async {
    if (!_isDesktop) return false;

    var restoreMaximized = false;
    if (Platform.isMacOS && await windowManager.isMaximized()) {
      restoreMaximized = true;
      await windowManager.unmaximize();
    }

    if (_shouldMinimizeDesktopWindow) {
      await windowManager.minimize();
      await Future.delayed(const Duration(milliseconds: 120));
    }

    await windowManager.focus();
    return restoreMaximized;
  }

  static Future<void> _afterDialog(bool restoreMaximized) async {
    if (!_isDesktop) return;

    if (_shouldMinimizeDesktopWindow) {
      await windowManager.restore();
      await windowManager.maximize();
      await windowManager.focus();
      return;
    }

    if (Platform.isMacOS && restoreMaximized) {
      await windowManager.maximize();
      await windowManager.focus();
    }
  }

  /// Replacement for [FilePicker.platform.getDirectoryPath].
  static Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
  }) async {
    final restoreMaximized = await _beforeDialog();
    try {
      return await FilePicker.platform.getDirectoryPath(
        dialogTitle: dialogTitle,
        lockParentWindow: _effectiveLockParentWindow(lockParentWindow),
      );
    } finally {
      await _afterDialog(restoreMaximized);
    }
  }

  /// Replacement for [FilePicker.platform.pickFiles].
  static Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    bool allowMultiple = false,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool withData = false,
    bool lockParentWindow = false,
  }) async {
    final restoreMaximized = await _beforeDialog();
    try {
      return await FilePicker.platform.pickFiles(
        dialogTitle: dialogTitle,
        allowMultiple: allowMultiple,
        type: type,
        allowedExtensions: allowedExtensions,
        withData: withData,
        lockParentWindow: _effectiveLockParentWindow(lockParentWindow),
      );
    } finally {
      await _afterDialog(restoreMaximized);
    }
  }

  /// Replacement for [FilePicker.platform.saveFile].
  static Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool lockParentWindow = false,
  }) async {
    final restoreMaximized = await _beforeDialog();
    try {
      return await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: fileName,
        type: type,
        allowedExtensions: allowedExtensions,
        lockParentWindow: _effectiveLockParentWindow(lockParentWindow),
      );
    } finally {
      await _afterDialog(restoreMaximized);
    }
  }
}
