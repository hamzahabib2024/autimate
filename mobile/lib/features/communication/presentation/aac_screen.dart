import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/services/tts_service.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/aac_catalog.dart';
import '../domain/card_ranker.dart';
import '../domain/sentence_realiser.dart';

class AacScreen extends StatefulWidget {
  const AacScreen({required this.appState, super.key});

  final AppState appState;

  @override
  State<AacScreen> createState() => _AacScreenState();
}

class _AacScreenState extends State<AacScreen> {
  final List<CardGrammar> _strip = [];
  final List<CardUsageEvent> _usage = [];
  final SentenceRealiser _realiser = RuleBasedSentenceRealiser();
  final CardRanker _ranker = RecencyWeightedCardRanker();

  SpeakerProfile get _speaker =>
      const SpeakerProfile(gender: UrduGender.masculine);

  AppLanguage get _language => widget.appState.locale.languageCode == 'ur'
      ? AppLanguage.ur
      : AppLanguage.en;

  String get _sentence => _realiser.realise(_strip, _speaker, _language).text;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final sentence = _sentence;
        final frequent = _ranker.rank(_usage);
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.communicateTitle),
            actions: [
              IconButton(
                tooltip: l10n.speakSentenceTooltip,
                onPressed: _strip.isEmpty ? null : _speakSentence,
                icon: const Icon(Icons.volume_up),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.sentenceHeader,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          liveRegion: true,
                          label: l10n.sentenceHeader,
                          child: Text(
                            sentence.isEmpty
                                ? l10n.tapCardToBuild
                                : sentence,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      if (_strip.isNotEmpty)
                        IconButton(
                          tooltip: l10n.clearSentenceTooltip,
                          onPressed: () => setState(_strip.clear),
                          icon: const Icon(Icons.clear),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.frequentlyUsed,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                frequent.isEmpty
                    ? l10n.recentCardsHint
                    : frequent.join('  •  '),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.coreWords,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 180,
                  mainAxisExtent: 132,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: aacCards.length,
                itemBuilder: (context, index) {
                  final card = aacCards[index];
                  return Semantics(
                    button: true,
                    label:
                        '${card.labelEn}, ${card.labelUr}',
                    child: Card(
                      child: InkWell(
                        onTap: () => _addCard(card),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(_iconFor(card.id), size: 32),
                              const SizedBox(height: 4),
                              Text(
                                card.labelEn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(card.labelUr),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 64),
                child: FilledButton.icon(
                  onPressed: _strip.isEmpty ? null : _speakSentence,
                  icon: const Icon(Icons.volume_up),
                  label: Text(l10n.speakSentenceTooltip),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addCard(CardGrammar card) {
    final usage = CardUsageEvent(cardId: card.id, usedAt: DateTime.now());
    setState(() {
      _strip.add(card);
      _usage.add(usage);
    });
    widget.appState.recordCardUsage(usage);
    final tts = widget.appState.ttsService;
    if (tts is QueuedTtsService) {
      tts.speak(
        _language == AppLanguage.ur ? card.labelUr : card.labelEn,
        widget.appState.locale,
      );
    }
  }

  void _speakSentence() {
    if (_sentence.isEmpty) return;
    widget.appState.ttsService.speak(_sentence, widget.appState.locale);
  }

  IconData _iconFor(String id) => switch (id) {
    'i_want' => Icons.touch_app,
    'i_feel' => Icons.psychology_alt_outlined,
    'apple' => Icons.apple,
    'water' => Icons.water_drop,
    'happy' => Icons.sentiment_satisfied,
    'help' => Icons.pan_tool_outlined,
    'finished' => Icons.check_circle_outline,
    _ => Icons.image_outlined,
  };
}
