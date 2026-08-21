import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/presentation/aac_screen.dart';
import 'package:autimate/features/emotion_recognition/presentation/emotion_screen.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('AAC builds an English sentence from semantic cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      testApp(
        AacScreen(appState: AppState(MockAuthRepository(), MockTtsService())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tap a card to build a sentence'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('aac-card-i_want')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('aac-card-apple')));
    await tester.pump();

    expect(find.text('I want an apple.'), findsOneWidget);
    expect(find.text('Frequently used'), findsOneWidget);
  });

  testWidgets('emotion activity presents choices and feedback', (tester) async {
    await tester.pumpWidget(testApp(const EmotionScreen()));

    expect(find.textContaining('Question 1 of 5'), findsOneWidget);
    expect(find.textContaining('Which face feels'), findsOneWidget);
    expect(find.byType(FilledButton), findsWidgets);

    final prompt = tester.widget<Text>(find.textContaining('Which face feels'));
    final answer = prompt.data!
        .replaceFirst('Which face feels ', '')
        .replaceFirst('?', '');
    await tester.tap(find.widgetWithText(FilledButton, answer));
    await tester.pump();
    expect(find.textContaining('That is right.'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 700));
  });
}
