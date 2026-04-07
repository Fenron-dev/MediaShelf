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

  static Future<void> _beforeDialog() async {
    if (!_isDesktop) return;
    await windowManager.minimize();
    await Future.delayed(const Duration(milliseconds: 120));
  }

  static Future<void> _afterDialog() async {
    if (!_isDesktop) return;
    await windowManager.restore();
    await windowManager.maximize();
    await windowManager.focus();
  }

  /// Replacement for [FilePicker.platform.getDirectoryPath].
  static Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
  }) async {
    await _beforeDialog();
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: dialogTitle,
      lockParentWindow: lockParentWindow,
    );
    await _afterDialog();
    return result;
  }

  /// Replacement for [FilePicker.platform.pickFiles].
  static Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    bool allowMultiple = false,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    bool withData = false,
  }) async {
    await _beforeDialog();
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: dialogTitle,
      allowMultiple: allowMultiple,
      type: type,
      allowedExtensions: allowedExtensions,
      withData: withData,
    );
    await _afterDialog();
    return result;
  }

  /// Replacement for [FilePicker.platform.saveFile].
  static Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    await _beforeDialog();
    final result = await FilePicker.platform.saveFile(
      dialogTitle: dialogTitle,
      fileName: fileName,
      type: type,
      allowedExtensions: allowedExtensions,
    );
    await _afterDialog();
    return result;
  }
}
