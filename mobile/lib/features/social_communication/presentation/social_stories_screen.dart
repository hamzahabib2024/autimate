import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../../emotion_recognition/domain/emotion_activity_engine.dart';
import '../domain/conversation_engine.dart';
import '../domain/social_content.dart';
import '../domain/social_models.dart';

/// Social communication hub: authored stories plus scripted conversation
/// practice. All content is fixed and bilingual; there is no generative
/// chat anywhere behind this screen.
class SocialStoriesScreen extends StatelessWidget {
  const SocialStoriesScreen({required this.appState, super.key});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.socialStoriesTileTitle),
          bottom: TabBar(
            tabs: [
              Tab(key: const ValueKey('tab-stories'), text: l10n.tabStories),
              Tab(
                key: const ValueKey('tab-conversations'),
                text: l10n.tabConversations,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _StoriesList(appState: appState),
            _ConversationsList(appState: appState),
          ],
        ),
      ),
    );
  }
}

class _StoriesList extends StatelessWidget {
  const _StoriesList({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final story in socialStories) ...[
          Card(
            child: ListTile(
              key: ValueKey('story-${story.id}'),
              leading: const Icon(Icons.auto_stories_outlined),
              title: Text(
                appState.locale.languageCode == 'ur'
                    ? story.titleUr
                    : story.titleEn,
              ),
              subtitle: Text(l10n(context).storyPagesCount(story.pages.length)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _StoryReader(
                    appState: appState,
                    story: story,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  AppLocalizations l10n(BuildContext context) => AppLocalizations.of(context);
}

class _StoryReader extends StatefulWidget {
  const _StoryReader({required this.appState, required this.story});

  final AppState appState;
  final SocialStory story;

  @override
  State<_StoryReader> createState() => _StoryReaderState();
}

class _StoryReaderState extends State<_StoryReader> {
  int _page = 0;
  int _questionIndex = 0;
  bool? _lastAnswerCorrect;
  bool _finished = false;
  SupportLevel? _levelAtStart;
  bool _dismissedLevelChange = false;

  bool get _isUrdu => widget.appState.locale.languageCode == 'ur';

  void _narrate(String text) {
    widget.appState.ttsService.speak(text, widget.appState.locale);
  }

  void _goToPage(int page) {
    // One past the last content page is the comprehension check.
    setState(() {
      _page = page.clamp(0, widget.story.pages.length);
    });
    if (_page < widget.story.pages.length) {
      final story = widget.story;
      _narrate(
        _isUrdu ? story.pages[_page].textUr : story.pages[_page].textEn,
      );
    } else {
      unawaited(_speakQuestionIfNeeded());
    }
  }

  /// Beginner support reads comprehension questions aloud so reading
  /// skill never gates understanding.
  Future<void> _speakQuestionIfNeeded() async {
    if (!mounted || _finished) return;
    final appState = widget.appState;
    if (appState.effectiveSupportFor(appState.selectedChild.id) !=
        SupportLevel.beginner) {
      return;
    }
    final question = widget.story.questions[_questionIndex];
    await appState.ttsService.speak(
      _isUrdu ? question.promptUr : question.promptEn,
      appState.locale,
    );
  }

  void _answerQuestion(int index) {
    final question = widget.story.questions[_questionIndex];
    setState(() {
      _lastAnswerCorrect = question.isCorrect(index);
      if (_lastAnswerCorrect ?? false) {
        // Advancing clears the praise so it cannot linger under an
        // unanswered question.
        _lastAnswerCorrect = null;
        if (_questionIndex < widget.story.questions.length - 1) {
          _questionIndex++;
          unawaited(_speakQuestionIfNeeded());
        } else {
          if (!_finished) {
            widget.appState.recordSessionCompleted(
              childId: widget.appState.selectedChild.id,
              level: _levelAtStart ??
                  widget.appState.effectiveSupportFor(
                    widget.appState.selectedChild.id,
                  ),
            );
          }
          _finished = true;
        }
      }
    });
  }

  void _restart() {
    setState(() {
      _page = 0;
      _questionIndex = 0;
      _lastAnswerCorrect = null;
      _finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final story = widget.story;
    return Scaffold(
      appBar: AppBar(title: Text(_isUrdu ? story.titleUr : story.titleEn)),
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, _) {
          // Live support-level changes get a restart prompt, never a
          // silent mid-story difficulty switch.
          final currentLevel = widget.appState.effectiveSupportFor(
            widget.appState.selectedChild.id,
          );
          _levelAtStart ??= currentLevel;
          final levelChanged =
              !_dismissedLevelChange && _levelAtStart != currentLevel;
          if (_finished) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events_outlined, size: 56),
                    const SizedBox(height: 12),
                    Text(l10n.sessionComplete,
                        style: Theme.of(context).textTheme.headlineSmall),
                    Text(l10n.starsEarned(widget.appState.stars)),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 64),
                      child: FilledButton(
                        onPressed: _restart,
                        child: Text(l10n.practiseAgain),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (levelChanged) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.tune, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      key: const ValueKey('level-change-prompt'),
                      l10n.levelChangedPrompt(
                        _levelLabel(l10n, currentLevel),
                      ),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 64),
                      child: FilledButton.icon(
                        key: const ValueKey('level-restart'),
                        onPressed: () {
                          setState(() {
                            _page = 0;
                            _questionIndex = 0;
                            _lastAnswerCorrect = null;
                            _finished = false;
                            _dismissedLevelChange = true;
                          });
                        },
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.levelRestartAction),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      key: const ValueKey('level-continue'),
                      onPressed: () =>
                          setState(() => _dismissedLevelChange = true),
                      child: Text(l10n.levelContinueAction),
                    ),
                  ],
                ),
              ),
            );
          }
          if (_page < story.pages.length) {
            return _buildPage(context, l10n, story.pages[_page]);
          }
          return _buildQuiz(context, l10n, story.questions[_questionIndex]);
        },
      ),
    );
  }

  String _levelLabel(AppLocalizations l10n, SupportLevel level) =>
      switch (level) {
        SupportLevel.intermediate => l10n.intermediateSupportLevel,
        SupportLevel.advanced => l10n.advancedSupportLevel,
        _ => l10n.beginnerSupportLevel,
      };

  Widget _buildPage(
    BuildContext context,
    AppLocalizations l10n,
    StoryPage page,
  ) {
    final isLastContentPage = _page == widget.story.pages.length - 1;
    return ListView(
      key: const ValueKey('reader-page'),
      padding: const EdgeInsets.all(24),
      children: [
        Semantics(
          header: true,
          child: Center(
            child: Container(
              width: 168,
              height: 168,
              decoration: BoxDecoration(
                color: context.palette.accentTint(
                  context.palette.routine,
                  0.86,
                ),
                shape: BoxShape.circle,
                border: Border.all(color: context.palette.routine, width: 2),
              ),
              child: Icon(
                page.icon,
                size: 88,
                color: context.palette.routine,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          _isUrdu ? page.textUr : page.textEn,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: OutlinedButton.icon(
            onPressed: () =>
                _narrate(_isUrdu ? page.textUr : page.textEn),
            icon: const Icon(Icons.volume_up_outlined),
            label: Text(l10n.narrateTooltip),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_page > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _goToPage(_page - 1),
                  icon: const Icon(Icons.arrow_back),
                  label: Text(l10n.previousPageTooltip),
                ),
              ),
            const Spacer(),
            Expanded(
              child: FilledButton.icon(
                key: const ValueKey('reader-next'),
                onPressed: () => _goToPage(_page + 1),
                icon: Icon(isLastContentPage
                    ? Icons.quiz_outlined
                    : Icons.arrow_forward),
                label: Text(
                  isLastContentPage
                      ? l10n.comprehensionTitle
                      : l10n.nextPageTooltip,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuiz(
    BuildContext context,
    AppLocalizations l10n,
    ComprehensionQuestion question,
  ) {
    final lastFeedback = _lastAnswerCorrect;
    return ListView(
      key: const ValueKey('quiz-page'),
      padding: const EdgeInsets.all(24),
      children: [
        // Escape hatch so the child can re-read before answering.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            key: const ValueKey('quiz-back'),
            onPressed: () => _goToPage(widget.story.pages.length - 1),
            icon: const Icon(Icons.arrow_back),
            label: Text(l10n.previousPageTooltip),
          ),
        ),
        Semantics(
          header: true,
          child: Text(l10n.comprehensionTitle,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: 12),
        Text(
          _isUrdu ? question.promptUr : question.promptEn,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < question.optionsEn.length; i++) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: FilledButton.tonal(
              key: ValueKey('quiz-option-$i'),
              onPressed: () => _answerQuestion(i),
              child: Text(
                _isUrdu ? question.optionsUr[i] : question.optionsEn[i],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (lastFeedback != null)
          Text(
            lastFeedback ? l10n.answerCorrect : l10n.answerIncorrect,
            style: TextStyle(
              color: lastFeedback
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.error,
            ),
          ),
      ],
    );
  }
}

enum _AvatarMood { neutral, happy, thinking }

class _RolePlayAvatar extends StatelessWidget {
  const _RolePlayAvatar({required this.mood});

  final _AvatarMood mood;

  @override
  Widget build(BuildContext context) {
    // Reusing EmotionFace here means the role-play partner and the emotion
    // stimulus are literally the same character, and its expression can
    // tween between moods instead of cutting to a different glyph.
    final emotion = switch (mood) {
      _AvatarMood.happy => EmotionLabel.happy,
      _AvatarMood.thinking => EmotionLabel.neutral,
      _AvatarMood.neutral => EmotionLabel.neutral,
    };
    return EmotionFace(emotion: emotion, size: 60);
  }
}

class _ConversationsList extends StatelessWidget {
  const _ConversationsList({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.conversationHint, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 12),
        for (final script in conversationScripts) ...[
          Card(
            child: ListTile(
              key: ValueKey('script-${script.id}'),
              leading: const Icon(Icons.forum_outlined),
              title: Text(
                appState.locale.languageCode == 'ur'
                    ? script.titleUr
                    : script.titleEn,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => _ConversationRunner(
                    appState: appState,
                    script: script,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _ConversationRunner extends StatefulWidget {
  const _ConversationRunner({required this.appState, required this.script});

  final AppState appState;
  final ConversationScript script;

  @override
  State<_ConversationRunner> createState() => _ConversationRunnerState();
}

class _ConversationRunnerState extends State<_ConversationRunner> {
  late final ConversationEngine _engine =
      ConversationEngine(script: widget.script)..reset();
  String? _feedback;

  bool get _isUrdu => widget.appState.locale.languageCode == 'ur';

  _AvatarMood get _mood {
    if (_engine.completed) return _AvatarMood.happy;
    if (_engine.triesOnCurrentStep > 0) return _AvatarMood.thinking;
    return _AvatarMood.neutral;
  }

  void _choose(ConversationOption option) {
    final outcome = _engine.choose(option);
    setState(() {
      // Only unexpected replies keep a persistent banner; fitting replies
      // advance (the avatar mood and completion celebration give praise).
      _feedback =
          outcome.advanced || outcome.completed ? null : 'retry';
    });
    if (outcome.completed) {
      widget.appState.awardStars(1);
      widget.appState.ttsService.speak(
        _isUrdu ? 'شاباش!' : 'Well done!',
        widget.appState.locale,
      );
    }
  }

  void _restart() {
    setState(() {
      _engine.reset();
      _feedback = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isUrdu ? widget.script.titleUr : widget.script.titleEn,
        ),
      ),
      body: AnimatedBuilder(
        animation: widget.appState,
        builder: (context, _) {
          if (_engine.completed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _RolePlayAvatar(mood: _mood),
                    const SizedBox(height: 16),
                    Text(
                      l10n.conversationComplete,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 64),
                      child: FilledButton(
                        onPressed: _restart,
                        child: Text(l10n.practiseAgain),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          final step = _engine.current!;
          final feedback = _feedback;
          return ListView(
            key: const ValueKey('conversation-run'),
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RolePlayAvatar(mood: _mood),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text(
                          _isUrdu
                              ? step.partnerLineUr
                              : step.partnerLineEn,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (var i = 0; i < step.options.length; i++) ...[
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 64),
                  child: OutlinedButton(
                    key: ValueKey('reply-$i'),
                    onPressed: () => _choose(step.options[i]),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Text(
                        _isUrdu
                            ? step.options[i].replyUr
                            : step.options[i].replyEn,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (feedback == 'retry')
                Text(
                  l10n.gentleRetry,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
