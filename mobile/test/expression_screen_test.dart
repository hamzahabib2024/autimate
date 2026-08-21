import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:autimate/core/services/app_services.dart';
import 'package:autimate/features/ai/domain/ai_contracts.dart';
import 'package:autimate/features/ai/domain/expression_practice_engine.dart';
import 'package:autimate/features/emotion_recognition/presentation/expression_screen.dart';

import 'helpers/test_app.dart';

class FakeExpressionService implements ExpressionPracticeService {
  final StreamController<ExpressionReading> controller =
      StreamController<ExpressionReading>.broadcast();
  bool supported = true;

  @override
  Future<bool> isSupported() async => supported;

  @override
  Stream<ExpressionReading> start() => controller.stream;

  @override
  Future<void> stop() async {}
}

void main() {
  AppState appState() => AppState(MockAuthRepository(), MockTtsService());

  testWidgets('unsupported devices see the unsupported state', (tester) async {
    final service = FakeExpressionService()..supported = false;
    await tester.pumpWidget(
      testApp(
        ExpressionPracticeScreen(
          appState: appState(),
          service: service,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Expression practice is not available on this device.'),
      findsOneWidget,
    );
  });

  testWidgets('loading state offers the start action', (tester) async {
    final service = FakeExpressionService();
    await tester.pumpWidget(
      testApp(
        ExpressionPracticeScreen(appState: appState(), service: service),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Start practice'), findsOneWidget);
  });

  testWidgets('practicing shows progress and awards stars on completion', (
    tester,
  ) async {
    final service = FakeExpressionService();
    var ticks = 0;
    // Every engine.feed call advances 100 ms so holds complete in tests.
    final engine = ExpressionSessionEngine(
      config: const ExpressionPracticeConfig(repsTarget: 1),
      clock: () => DateTime(2026, 8, 22, 10)
          .add(Duration(milliseconds: 100 * ticks++)),
    );
    final state = appState();
    final starsBefore = state.stars;

    await tester.pumpWidget(
      testApp(
        ExpressionPracticeScreen(
          appState: state,
          service: service,
          engine: engine,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Start practice'));
    await tester.pumpAndSettle();

    expect(find.text('Hold a big smile for one second'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);

    for (var i = 0; i < 12; i++) {
      service.controller.add(_reading(0.9));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pumpAndSettle();

    expect(find.text('Great smiling! 1 stars earned'), findsOneWidget);
    expect(state.stars, starsBefore + 1);
  });
}

ExpressionReading _reading(double smile) => ExpressionReading(
  faceDetected: true,
  smile: smile,
  leftEyeOpen: 0.9,
  rightEyeOpen: 0.9,
  headTiltDegrees: 0,
);
