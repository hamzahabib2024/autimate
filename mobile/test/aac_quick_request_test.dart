import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/core/services/tts_service.dart';
import 'package:autimate/features/communication/domain/sentence_realiser.dart';
import 'package:autimate/features/communication/presentation/aac_screen.dart';
import 'helpers/test_app.dart';

class _CapturingTts implements TtsService {
  final List<String> spoken = [];

  @override
  Future<void> initialise() async {}

  @override
  Future<void> speak(String text, Locale locale) async {
    spoken.add(text);
  }

  @override
  Future<void> stop() async {}
}

/// The AAC page is long; a tall surface keeps every section built so
/// assertions do not fight lazy-list viewport disposal.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 3200);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

Future<void> _tapCard(WidgetTester tester, String id) async {
  await tester.tap(find.byKey(ValueKey('aac-card-$id')));
  await tester.pump();
}

void main() {
  test('people and places take no article in realised requests', () {
    final realiser = RuleBasedSentenceRealiser();
    const speaker = SpeakerProfile(gender: UrduGender.feminine);
    const want = CardGrammar(
      id: 'i_want',
      labelEn: 'I want',
      labelUr: 'چاہتا ہوں',
      pos: PartOfSpeech.carrier,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.masculine,
      urduSubject: 'میں',
      urduVerbMasculine: 'چاہتا ہوں',
      urduVerbFeminine: 'چاہتی ہوں',
    );
    const mama = CardGrammar(
      id: 'mama',
      labelEn: 'Mama',
      labelUr: 'امی',
      pos: PartOfSpeech.noun,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.feminine,
      noArticle: true,
    );
    const help = CardGrammar(
      id: 'help',
      labelEn: 'help',
      labelUr: 'مدد',
      pos: PartOfSpeech.noun,
      isCountable: false,
      startsWithVowelSound: false,
      urduGender: UrduGender.feminine,
    );

    expect(realiser.realise([want, mama], speaker, AppLanguage.en).text,
        'I want Mama.');
    expect(realiser.realise([want, help], speaker, AppLanguage.en).text,
        'I want some help.');
  });

  testWidgets('a request can be built and spoken in three taps', (tester) async {
    _useTallSurface(tester);
    final tts = _CapturingTts();
    await tester.pumpWidget(
      testApp(AacScreen(appState: AppState(MockAuthRepository(), tts))),
    );
    await tester.pumpAndSettle();

    await _tapCard(tester, 'i_want');
    await _tapCard(tester, 'milk');

    expect(find.text('I want some milk.'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('aac-speak')));
    await tester.pump();

    expect(tts.spoken.last, 'I want some milk.');
  });

  testWidgets('backspace removes the last strip word only', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      testApp(
        AacScreen(appState: AppState(MockAuthRepository(), _CapturingTts())),
      ),
    );
    await tester.pumpAndSettle();

    await _tapCard(tester, 'i_want');
    await _tapCard(tester, 'ball');
    expect(find.text('I want a ball.'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove last word'));
    await tester.pump();

    expect(find.text('I want.'), findsOneWidget);
    expect(find.text('I want a ball.'), findsNothing);
  });

  testWidgets('category chips filter the grid but keep carriers', (
    tester,
  ) async {
    _useTallSurface(tester);
    await tester.pumpWidget(
      testApp(
        AacScreen(appState: AppState(MockAuthRepository(), _CapturingTts())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('aac-card-apple')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('aac-cat-drinks')));
    await tester.pump();

    expect(find.byKey(const ValueKey('aac-card-milk')), findsOneWidget);
    expect(find.byKey(const ValueKey('aac-card-i_want')), findsOneWidget);
    expect(find.byKey(const ValueKey('aac-card-apple')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('aac-cat-all')));
    await tester.pump();

    expect(find.byKey(const ValueKey('aac-card-apple')), findsOneWidget);
  });
}
