import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/main.dart';

void main() {
  testWidgets('renders the home shell and opens communication', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      AutiMateApp(appState: AppState(MockAuthRepository(), MockTtsService())),
    );

    expect(find.text('AutiMate'), findsOneWidget);
    await tester.tap(find.text('Communicate'));
    await tester.pump();
    expect(find.text('Sentence'), findsOneWidget);
    expect(find.text('Core words'), findsOneWidget);
  });
}
