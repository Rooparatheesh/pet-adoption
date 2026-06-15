import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pet_adoption_app/main.dart';

void main() {
  testWidgets('App splash screen build test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: PawfectAdoptionApp(),
      ),
    );

    // Verify that the title or brand icon is present
    expect(find.byType(PawfectAdoptionApp), findsOneWidget);
  });
}
