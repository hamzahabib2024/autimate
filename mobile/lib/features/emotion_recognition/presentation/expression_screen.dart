import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../ai/data/simulated_expression_service.dart';
import '../../ai/domain/ai_contracts.dart';
import '../../ai/domain/expression_practice_engine.dart';

enum ExpressionPhase {
  checking,
  unsupported,
  permissionDenied,
  loading,
  error,
  practicing,
  complete,
}

class ExpressionPracticeScreen extends StatefulWidget {
  const ExpressionPracticeScreen({
    required this.appState,
    this.service,
    this.engine,
    super.key,
  });

  final AppState appState;

  /// Overridable for tests; defaults to the offline simulated source until
  /// the ML Kit camera adapter lands on physical hardware.
  final ExpressionPracticeService? service;

  /// Overridable for tests so time-dependent holds are deterministic.
  final ExpressionSessionEngine? engine;

  @override
  State<ExpressionPracticeScreen> createState() =>
      _ExpressionPracticeScreenState();
}

class _ExpressionPracticeScreenState extends State<ExpressionPracticeScreen> {
  late final ExpressionPracticeService _service;
  late final ExpressionSessionEngine _engine;

  StreamSubscription<ExpressionReading>? _subscription;
  ExpressionPhase _phase = ExpressionPhase.checking;
  double _smoothedSmile = 0;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? SimulatedExpressionService();
    _engine = widget.engine ?? ExpressionSessionEngine();
    _checkSupport();
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_service.stop());
    super.dispose();
  }

  Future<void> _checkSupport() async {
    setState(() => _phase = ExpressionPhase.checking);
    try {
      final supported = await _service.isSupported();
      if (!mounted) return;
      // The future camera adapter reports permission denial through
      // [markPermissionDenied]; the simulated source is always usable.
      setState(() => _phase =
          supported ? ExpressionPhase.loading : ExpressionPhase.unsupported);
    } catch (_) {
      if (mounted) setState(() => _phase = ExpressionPhase.error);
    }
  }

  void markPermissionDenied() {
    if (mounted) setState(() => _phase = ExpressionPhase.permissionDenied);
  }

  Future<void> _start() async {
    setState(() {
      _phase = ExpressionPhase.practicing;
      _engine.restart();
      _smoothedSmile = 0;
      _holding = false;
    });
    try {
      final frames = _service.start();
      await _subscription?.cancel();
      _subscription = frames.listen(
        _onReading,
        onError: (Object _) {
          if (mounted) setState(() => _phase = ExpressionPhase.error);
        },
      );
    } catch (_) {
      if (mounted) setState(() => _phase = ExpressionPhase.error);
    }
  }

  void _onReading(ExpressionReading reading) {
    final feedback = _engine.feed(reading);
    if (!mounted) return;
    setState(() {
      _smoothedSmile = feedback.smoothedSmile;
      _holding = feedback.holding;
    });
    if (feedback.starAwarded) widget.appState.awardStars(1);
    if (feedback.sessionComplete) {
      unawaited(_subscription?.cancel());
      unawaited(_service.stop());
      setState(() => _phase = ExpressionPhase.complete);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.expressionTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          switch (_phase) {
            ExpressionPhase.checking => const Center(
              child: CircularProgressIndicator(),
            ),
            ExpressionPhase.loading => Column(
              children: [
                StatePanel(
                  title: l10n.expressionTitle,
                  message: l10n.expressionHoldSmile,
                  icon: Icons.sentiment_very_satisfied_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton(
                    onPressed: _start,
                    child: Text(l10n.expressionStart),
                  ),
                ),
              ],
            ),
            ExpressionPhase.unsupported => StatePanel(
              title: l10n.expressionTitle,
              message: l10n.expressionUnsupported,
              icon: Icons.videocam_off_outlined,
            ),
            ExpressionPhase.permissionDenied => StatePanel(
              title: l10n.expressionTitle,
              message: l10n.expressionPermissionDenied,
              icon: Icons.no_photography_outlined,
            ),
            ExpressionPhase.error => StatePanel(
              title: l10n.expressionTitle,
              message: l10n.expressionCameraError,
              icon: Icons.error_outline,
            ),
            ExpressionPhase.complete => Column(
              children: [
                StatePanel(
                  title: l10n.expressionSessionComplete(_engine.starsEarned),
                  message: l10n.expressionPrivacyNote,
                  icon: Icons.stars_outlined,
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: FilledButton(
                    onPressed: _start,
                    child: Text(l10n.practiseAgain),
                  ),
                ),
              ],
            ),
            ExpressionPhase.practicing => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.expressionHoldSmile,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Card(
                  child: SizedBox(
                    height: 160,
                    child: Center(
                      child: AnimatedScale(
                        scale: _holding ? 1.15 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.sentiment_very_satisfied,
                          size: 110,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Semantics(
                  label: l10n.expressionHoldSmile,
                  value: '${(_smoothedSmile * 100).round()}%',
                  child: LinearProgressIndicator(
                    value: _smoothedSmile.clamp(0, 1),
                    minHeight: 12,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.expressionSmileProgress(
                    _engine.starsEarned,
                    _engine.config.repsTarget,
                  ),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          },
          const SizedBox(height: 24),
          StatePanel(
            title: l10n.expressionPrivacyTitle,
            message: l10n.expressionPrivacyNote,
            icon: Icons.shield_outlined,
          ),
        ],
      ),
    );
  }
}
