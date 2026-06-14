import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediashelf/app.dart';
import 'package:mediashelf/providers/app_info_provider.dart';
import 'package:mediashelf/ui/widgets/app_info_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots into welcome screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MediaShelfApp()));
    await tester.pumpAndSettle();

    expect(find.text('MediaShelf'), findsOneWidget);
    expect(find.text('Open Library'), findsOneWidget);
  });

  testWidgets('app info shows package version and build number', (
    tester,
  ) async {
    final packageInfo = PackageInfo(
      appName: 'MediaShelf',
      packageName: 'com.example.mediashelf',
      version: '0.5.6',
      buildNumber: '1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appInfoProvider.overrideWith((ref) async => packageInfo)],
        child: const MaterialApp(home: Scaffold(body: AppInfoPanel())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Version 0.5.6 (Build 1)'), findsOneWidget);
  });
}
