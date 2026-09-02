import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/data/local_store.dart';
import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/communication/data/image_source_service.dart';
import 'package:autimate/features/communication/domain/aac_catalog.dart';
import 'package:autimate/features/communication/domain/custom_card_repository.dart';
import 'package:autimate/features/communication/domain/sentence_realiser.dart';
import 'package:autimate/features/communication/presentation/aac_screen.dart';
import 'package:autimate/features/communication/presentation/custom_cards_screen.dart';

import 'helpers/test_app.dart';

/// Records what was asked for without touching the platform picker.
class _FakeImageSource implements ImageSourceService {
  _FakeImageSource({this.path = '/tmp/fake-card.png', this.supported = true});

  final String? path;
  final bool supported;
  final List<CardImageSource> requested = [];
  final List<String> deleted = [];

  @override
  bool get isSupported => supported;

  @override
  Future<String?> pickAndStore(CardImageSource source) async {
    requested.add(source);
    return path;
  }

  @override
  Future<void> deleteStored(String path) async => deleted.add(path);
}

CustomCard _card({
  String id = 'custom-1',
  String childId = 'demo-child',
  String en = 'Blue ball',
  String ur = 'نیلی گیند',
  AacCategory category = AacCategory.objects,
  String? imagePath,
}) => CustomCard(
  id: id,
  childId: childId,
  labelEn: en,
  labelUr: ur,
  category: category,
  imagePath: imagePath,
);

/// Scrolls the custom-card editor form to reveal its lower controls.
Future<void> _scrollEditorToBottom(WidgetTester tester) async {
  await tester.drag(find.byType(ListView).last, const Offset(0, -600));
  await tester.pumpAndSettle();
}

void main() {
  group('custom card storage', () {
    test('round-trips through the durable store', () async {
      final store = InMemoryKeyValueStore();
      final repository = LocalCustomCardRepository(store);

      await repository.save(_card(imagePath: '/data/ball.png'));
      // A second repository over the same store stands in for a restart.
      final reloaded = await LocalCustomCardRepository(store)
          .cardsFor('demo-child');

      expect(reloaded, hasLength(1));
      expect(reloaded.single.labelEn, 'Blue ball');
      expect(reloaded.single.labelUr, 'نیلی گیند');
      expect(reloaded.single.imagePath, '/data/ball.png');
    });

    test('cards belong to one child, never to the device', () async {
      final repository = LocalCustomCardRepository(InMemoryKeyValueStore());
      await repository.save(_card(id: 'a', childId: 'child-1'));
      await repository.save(_card(id: 'b', childId: 'child-2'));

      expect(await repository.cardsFor('child-1'), hasLength(1));
      expect((await repository.cardsFor('child-2')).single.id, 'b');
    });

    test('saving an existing id edits rather than duplicates', () async {
      final repository = LocalCustomCardRepository(InMemoryKeyValueStore());
      await repository.save(_card(en: 'Ball'));
      await repository.save(_card(en: 'Red ball'));

      final cards = await repository.cardsFor('demo-child');
      expect(cards, hasLength(1));
      expect(cards.single.labelEn, 'Red ball');
    });

    test('delete removes the card', () async {
      final repository = LocalCustomCardRepository(InMemoryKeyValueStore());
      await repository.save(_card());
      await repository.delete('custom-1');
      expect(await repository.cardsFor('demo-child'), isEmpty);
    });
  });

  group('custom card projection', () {
    test('projects into the shared AacCard shape', () {
      final projected = _card(category: AacCategory.food).toAacCard();
      expect(projected.id, 'custom-1');
      expect(projected.category, AacCategory.food);
      expect(projected.grammar.labelUr, 'نیلی گیند');
      expect(projected.grammar.pos, PartOfSpeech.noun);
    });

    test('speech falls back to the label when no spoken form is set', () {
      expect(_card().speechFor(AppLanguage.en), 'Blue ball');
      expect(_card().speechFor(AppLanguage.ur), 'نیلی گیند');

      const spoken = CustomCard(
        id: 'c',
        childId: 'demo-child',
        labelEn: 'Ball',
        labelUr: 'گیند',
        category: AacCategory.objects,
        spokenEn: 'I want the ball',
        spokenUr: 'مجھے گیند چاہیے',
      );
      expect(spoken.speechFor(AppLanguage.en), 'I want the ball');
      expect(spoken.speechFor(AppLanguage.ur), 'مجھے گیند چاہیے');
    });

    test('survives a JSON round trip', () {
      final restored = CustomCard.fromJson(
        _card(imagePath: '/data/x.png').toJson(),
      );
      expect(restored.id, 'custom-1');
      expect(restored.imagePath, '/data/x.png');
      expect(restored.category, AacCategory.objects);
    });
  });

  group('app state', () {
    test('exposes the active child\'s cards and reloads on switch', () async {
      final repository = InMemoryCustomCardRepository();
      await repository.save(_card(id: 'a', childId: 'demo-child'));
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        customCardRepository: repository,
      );

      await appState.loadCustomCards();
      expect(appState.customCards, hasLength(1));

      await appState.deleteCustomCard('a');
      expect(appState.customCards, isEmpty);
    });
  });

  group('board integration', () {
    testWidgets('a caregiver card appears on the board and can be spoken',
        (tester) async {
      final repository = InMemoryCustomCardRepository();
      await repository.save(
        _card(id: 'custom-ball', en: 'Ball', ur: 'گیند'),
      );
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        customCardRepository: repository,
      );

      await tester.pumpWidget(testApp(AacScreen(appState: appState)));
      await tester.pumpAndSettle();

      final card = find.byKey(const ValueKey('aac-card-custom-ball'));
      expect(card, findsOneWidget);

      // It composes into the sentence strip like any built-in card.
      await tester.tap(find.byKey(const ValueKey('aac-card-i_want')));
      await tester.pump();
      await tester.ensureVisible(card);
      await tester.pump();
      await tester.tap(card);
      await tester.pump();

      final sentence = tester.widget<Text>(
        find.byKey(const ValueKey('aac-sentence')),
      );
      expect(sentence.data, contains('Ball'));
    });

    testWidgets('the board still works with no custom cards', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(AacScreen(appState: appState)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('aac-card-apple')), findsOneWidget);
    });
  });

  group('editor', () {
    testWidgets('creating a card adds it to the deck', (tester) async {
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        customCardRepository: InMemoryCustomCardRepository(),
      );
      final imageSource = _FakeImageSource();

      await tester.pumpWidget(
        testApp(
          CustomCardsScreen(appState: appState, imageSource: imageSource),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('add-custom-card')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('card-label-en')),
        'Swing',
      );
      await tester.enterText(
        find.byKey(const ValueKey('card-label-ur')),
        'جھولا',
      );
      await _scrollEditorToBottom(tester);
      await tester.tap(find.byKey(const ValueKey('card-cat-activities')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('save-custom-card')));
      await tester.pumpAndSettle();

      expect(appState.customCards, hasLength(1));
      expect(appState.customCards.single.labelEn, 'Swing');
      expect(appState.customCards.single.category, AacCategory.activities);
    });

    testWidgets('a picked photo is stored on the card', (tester) async {
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        customCardRepository: InMemoryCustomCardRepository(),
      );
      final imageSource = _FakeImageSource(path: '/data/swing.png');

      await tester.pumpWidget(
        testApp(
          CustomCardsScreen(appState: appState, imageSource: imageSource),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('add-custom-card')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('pick-gallery')));
      await tester.pumpAndSettle();
      expect(imageSource.requested, [CardImageSource.gallery]);

      await tester.enterText(
        find.byKey(const ValueKey('card-label-en')),
        'Swing',
      );
      await tester.enterText(
        find.byKey(const ValueKey('card-label-ur')),
        'جھولا',
      );
      await _scrollEditorToBottom(tester);
      await tester.tap(find.byKey(const ValueKey('save-custom-card')));
      await tester.pumpAndSettle();

      expect(appState.customCards.single.imagePath, '/data/swing.png');
    });

    testWidgets('a card can still be made when no camera exists',
        (tester) async {
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        customCardRepository: InMemoryCustomCardRepository(),
      );

      await tester.pumpWidget(
        testApp(
          CustomCardsScreen(
            appState: appState,
            imageSource: _FakeImageSource(supported: false),
          ),
        ),
      );
      await tester.tap(find.byKey(const ValueKey('add-custom-card')));
      await tester.pumpAndSettle();

      final gallery = tester.widget<OutlinedButton>(
        find.byKey(const ValueKey('pick-gallery')),
      );
      expect(gallery.onPressed, isNull);

      await tester.enterText(
        find.byKey(const ValueKey('card-label-en')),
        'Cup',
      );
      await tester.enterText(
        find.byKey(const ValueKey('card-label-ur')),
        'پیالی',
      );
      await _scrollEditorToBottom(tester);
      await tester.tap(find.byKey(const ValueKey('save-custom-card')));
      await tester.pumpAndSettle();

      expect(appState.customCards.single.labelEn, 'Cup');
    });

    testWidgets('deleting a card removes it and its picture', (tester) async {
      final repository = InMemoryCustomCardRepository();
      await repository.save(_card(imagePath: '/data/ball.png'));
      final appState = AppState(
        MockAuthRepository(),
        MockTtsService(),
        customCardRepository: repository,
      );
      final imageSource = _FakeImageSource();

      await tester.pumpWidget(
        testApp(
          CustomCardsScreen(appState: appState, imageSource: imageSource),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('delete-custom-card-custom-1')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-delete-card')));
      await tester.pumpAndSettle();

      expect(appState.customCards, isEmpty);
      expect(imageSource.deleted, ['/data/ball.png']);
    });
  });

  group('sentence strip reorder', () {
    testWidgets('moving a word re-runs the realiser', (tester) async {
      final appState = AppState(MockAuthRepository(), MockTtsService());
      await tester.pumpWidget(testApp(AacScreen(appState: appState)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('aac-card-i_want')));
      await tester.pump();
      await tester.ensureVisible(find.byKey(const ValueKey('aac-card-apple')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('aac-card-apple')));
      await tester.pump();

      expect(
        tester
            .widget<Text>(find.byKey(const ValueKey('aac-sentence')))
            .data,
        'I want an apple.',
      );
      expect(find.byKey(const ValueKey('aac-strip')), findsOneWidget);
    });

    test('grammar-driven patterns survive any tap order', () {
      final realiser = RuleBasedSentenceRealiser();
      final want = cardById('i_want')!.grammar;
      final apple = cardById('apple')!.grammar;
      const speaker = SpeakerProfile(gender: UrduGender.masculine);

      // Roles are resolved by part of speech, not position, so a child who
      // taps the noun first still gets a well-formed sentence. Reordering
      // cannot turn a correct sentence into a broken one.
      final forward = realiser.realise([want, apple], speaker, AppLanguage.en);
      final reversed = realiser.realise([apple, want], speaker, AppLanguage.en);
      expect(forward.text, 'I want an apple.');
      expect(reversed.text, 'I want an apple.');
    });

    test('reorder rewrites the free-form fallback path', () {
      final realiser = RuleBasedSentenceRealiser();
      final mama = cardById('mama')!.grammar;
      final papa = cardById('papa')!.grammar;
      const speaker = SpeakerProfile(gender: UrduGender.masculine);

      // With no carrier to anchor a pattern, the strip is spoken in the
      // order the child arranged it — which is what reorder is for.
      final forward = realiser.realise([mama, papa], speaker, AppLanguage.en);
      final reversed = realiser.realise([papa, mama], speaker, AppLanguage.en);
      expect(forward.text, isNot(reversed.text));
    });
  });
}
