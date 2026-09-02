import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import 'expression_screen.dart';
import '../domain/emotion_activity_engine.dart';

class EmotionScreen extends StatefulWidget {
  const EmotionScreen({super.key, this.appState});

  final AppState? appState;

  @override
  State<EmotionScreen> createState() => _EmotionScreenState();
}

class _EmotionScreenState extends State<EmotionScreen> {
  late final DeterministicEmotionActivityEngine _engine;
  EmotionQuestion? _question;
  AnswerOutcome? _outcome;
  SessionResult? _result;
  SupportLevel? _levelAtStart;
  bool _dismissedLevelChange = false;

  @override
  void initState() {
    super.initState();
    final appState = widget.appState;
    _engine = DeterministicEmotionActivityEngine(
      childId: _boundChildId,
      parentLocked:
          appState?.isSupportLockedFor(_boundChildId) ?? false,
      parentOverride: appState?.supportOverrideFor(_boundChildId),
    );
    _question = _engine.start(
      level:
          appState?.effectiveSupportFor(_boundChildId) ??
          SupportLevel.beginner,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _speakPrompt());
  }

  /// Sessions must be recorded against the profile that is active.
  String get _boundChildId =>
      widget.appState?.selectedChild.id ?? 'demo-child';

  void _rebindChild() {
    final appState = widget.appState;
    if (appState == null) return;
    if (_engine.childId == appState.selectedChild.id) return;
    _engine.updateChildId(appState.selectedChild.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appState = widget.appState;
    if (appState == null) return _buildBody(context, l10n, null);
    _rebindChild();
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final currentLevel = appState.effectiveSupportFor(_boundChildId);
        _levelAtStart ??= currentLevel;
        final levelChanged =
            !_dismissedLevelChange &&
            _result == null &&
            _levelAtStart != currentLevel;
        return _buildBody(context, l10n,
            levelChanged ? currentLevel : null);
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    AppLocalizations l10n,
    SupportLevel? changedToLevel,
  ) {
    final question = _question;
    final result = _result;
    final palette = context.palette;
    final reduced = AppMotion.reduced(
      context,
      sensoryMode: widget.appState?.sensoryMode ?? false,
    );
    return ChildTextScale(
      child: Scaffold(
      appBar: AppBar(title: Text(l10n.emotionPracticeTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (changedToLevel != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      key: const ValueKey('level-change-prompt'),
                      l10n.levelChangedPrompt(
                        switch (changedToLevel) {
                          SupportLevel.intermediate =>
                            l10n.intermediateSupportLevel,
                          SupportLevel.advanced =>
                            l10n.advancedSupportLevel,
                          _ => l10n.beginnerSupportLevel,
                        },
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 64),
                      child: FilledButton.icon(
                        key: const ValueKey('level-restart'),
                        onPressed: () {
                          setState(() {
                            _dismissedLevelChange = true;
                            _levelAtStart = changedToLevel;
                          });
                          _restart();
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.levelRestartAction),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      key: const ValueKey('level-continue'),
                      onPressed: () =>
                          setState(() => _dismissedLevelChange = true),
                      child: Text(l10n.levelContinueAction),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (result != null) ...[
            if (result.starsAwarded > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Column(
                  children: [
                    RewardStar(
                      key: const ValueKey('reward-star'),
                      sensoryMode: widget.appState?.sensoryMode ?? false,
                    ),
                    Text(
                      l10n.starEarned,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            StatePanel(
              accent: palette.emotions,
              title: l10n.sessionComplete,
              message: l10n.sessionSummary(
                result.score,
                result.total,
                result.starsAwarded,
              ),
              icon: Icons.stars_outlined,
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: FilledButton(
                onPressed: _restart,
                child: Text(l10n.practiseAgain),
              ),
            ),
          ] else if (question != null) ...[
            Text(
              l10n.questionProgress(question.index, question.total),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.whichFaceFeels(_label(l10n, question.answer)),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm,
                ),
                child: Center(
                  child: EmotionFace(
                    key: ValueKey('emotion-face-${question.answer.name}'),
                    emotion: question.answer,
                    size: 148,
                    animate: !reduced,
                  ),
                ),
              ),
            ),
            if (_outcome != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    _outcome!.correct
                        ? l10n.answerCorrect
                        : l10n.answerIncorrect,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _outcome!.correct
                          ? palette.success
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            if (question.hintVisible)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Text(l10n.beginnerHint),
              ),
            const SizedBox(height: 20),
            ...question.choices.map(
              (emotion) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: AppTouch.child + 8,
                  ),
                  child: FilledButton.tonal(
                    key: ValueKey('emotion-answer-${emotion.name}'),
                    onPressed:
                        _outcome == null ? () => _answer(emotion) : null,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Beginner support turns identification into
                        // matching: the same flag that reveals the hint
                        // also shows the face beside each word.
                        if (question.hintVisible) ...[
                          EmotionFace(
                            emotion: emotion,
                            size: 44,
                            animate: false,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Flexible(
                          child: Text(
                            _label(l10n, emotion),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          StatePanel(
            accent: palette.emotions,
            title: l10n.cameraPracticeTitle,
            message: l10n.cameraPracticeMessage,
            icon: Icons.camera_alt_outlined,
          ),
          const SizedBox(height: 12),
          if (widget.appState != null)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ExpressionPracticeScreen(
                      appState: widget.appState!,
                    ),
                  ),
                ),
                child: Text(l10n.expressionTitle),
              ),
            ),
        ],
      ),
      ),
    );
  }

  /// Beginner support reads the question aloud so reading skill never
  /// gates emotion practice.
  Future<void> _speakPrompt() async {
    final appState = widget.appState;
    final question = _question;
    if (appState == null || question == null || _result != null) return;
    if (appState.effectiveSupportFor(_boundChildId) !=
        SupportLevel.beginner) {
      return;
    }
    if (!mounted) return;
    await appState.ttsService.speak(
      AppLocalizations.of(context).whichFaceFeels(
        _label(AppLocalizations.of(context), question.answer),
      ),
      appState.locale,
    );
  }

  void _answer(EmotionLabel emotion) {
    setState(() => _outcome = _engine.submit(emotion));
    Future<void>.delayed(const Duration(milliseconds: 650), () {
      if (!mounted || _outcome == null) return;
      final next = _engine.next();
      setState(() {
        _outcome = null;
        _question = next;
        if (next == null) _result = _engine.finish();
      });
      if (_result != null && widget.appState != null) {
        // Session history keeps the engine's raw score; the star payout
        // follows the caregiver's reward-frequency policy.
        widget.appState!.recordSession(_result!);
        widget.appState!.recordSessionCompleted(
          childId: _boundChildId,
          level: _result!.levelPlayed,
        );
      } else {
        unawaited(_speakPrompt());
      }
    });
  }

  void _restart() {
    setState(() {
      _result = null;
      _outcome = null;
      _question = _engine.start(
        level:
            widget.appState?.effectiveSupportFor(_boundChildId) ??
            SupportLevel.beginner,
      );
    });
    unawaited(_speakPrompt());
  }

  String _label(AppLocalizations l10n, EmotionLabel emotion) =>
      switch (emotion) {
        EmotionLabel.happy => l10n.emotionHappy,
        EmotionLabel.sad => l10n.emotionSad,
        EmotionLabel.angry => l10n.emotionAngry,
        EmotionLabel.surprised => l10n.emotionSurprised,
        EmotionLabel.scared => l10n.emotionScared,
        EmotionLabel.neutral => l10n.emotionNeutral,
      };
}
