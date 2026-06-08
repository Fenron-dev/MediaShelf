import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mediashelf/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app boots into welcome screen', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const ProviderScope(child: MediaShelfApp()));
    await tester.pumpAndSettle();

    expect(find.text('MediaShelf'), findsOneWidget);
    expect(find.text('Open Library'), findsOneWidget);
  });
}
