import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/main.dart';

void main() {
  testWidgets('first run lands on onboarding and completes into the shell', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      AutiMateApp(appState: AppState(MockAuthRepository(), MockTtsService())),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('onboard-name')), findsOneWidget);
    expect(find.text('AutiMate'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('onboard-level-Intermediate')));
    await tester.enterText(
      find.byKey(const ValueKey('onboard-name')),
      'Zoya',
    );
    await tester.enterText(find.byKey(const ValueKey('onboard-pin')), '1357');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('onboard-start')));
    await tester.pumpAndSettle();

    expect(find.text('AutiMate'), findsOneWidget);
    expect(find.text('Zoya'), findsOneWidget);
    expect(tester.any(find.byKey(const ValueKey('onboard-start'))), isFalse);

    await tester.tap(find.text('Communicate'));
    await tester.pump();
    expect(find.text('Sentence'), findsOneWidget);
    expect(find.text('Core words'), findsOneWidget);
  });
}
