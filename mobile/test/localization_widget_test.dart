import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/presentation/aac_screen.dart';

import 'helpers/test_app.dart';

void main() {
  testWidgets('Urdu locale renders the AAC screen with RTL direction', (
    tester,
  ) async {
    final appState = AppState(MockAuthRepository(), MockTtsService());
    appState.setLocale(const Locale('ur'));

    await tester.pumpWidget(
      testApp(AacScreen(appState: appState), locale: const Locale('ur')),
    );

    expect(find.text('بات کریں'), findsOneWidget);
    expect(find.text('جملہ'), findsOneWidget);
    expect(find.text('بنیادی الفاظ'), findsOneWidget);

    final context = tester.element(find.text('جملہ'));
    expect(Directionality.of(context), TextDirection.rtl);
  });

  testWidgets('English locale keeps LTR direction', (tester) async {
    await tester.pumpWidget(
      testApp(
        AacScreen(appState: AppState(MockAuthRepository(), MockTtsService())),
      ),
    );

    final context = tester.element(find.text('Sentence'));
    expect(Directionality.of(context), TextDirection.ltr);
  });
}
