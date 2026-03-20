import 'package:flutter/material.dart';

import '../../core/constants.dart';
import 'desktop_shell.dart';
import 'mobile_shell.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= kDesktopBreakpoint
        ? const DesktopShell()
        : const MobileShell();
  }
}
