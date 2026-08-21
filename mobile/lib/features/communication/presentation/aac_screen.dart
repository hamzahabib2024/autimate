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
  final List<CardUsageEvent> _durableUsage = [];
  final SentenceRealiser _realiser = RuleBasedSentenceRealiser();
  final CardRanker _ranker = RecencyWeightedCardRanker();

  AacCategory? _category;

  SpeakerProfile get _speaker =>
      const SpeakerProfile(gender: UrduGender.masculine);

  AppLanguage get _language => widget.appState.locale.languageCode == 'ur'
      ? AppLanguage.ur
      : AppLanguage.en;

  String get _sentence => _realiser.realise(_strip, _speaker, _language).text;

  @override
  void initState() {
    super.initState();
    _loadDurableUsage();
  }

  /// Restores the frequent-cards ranking across restarts.
  Future<void> _loadDurableUsage() async {
    final events = await widget.appState.progressRepository.getCardUsage(
      widget.appState.children.first.id,
    );
    if (!mounted || events.isEmpty) return;
    setState(() => _durableUsage.addAll(events));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final sentence = _sentence;
        final frequentIds = _ranker.rank([..._durableUsage, ..._usage]);
        final frequentCards = frequentIds
            .map(cardById)
            .whereType<AacCard>()
            .toList();
        final visibleDeck = [
          ...aacDeck.where((card) => card.category == null),
          ...aacDeck.where(
            (card) =>
                card.category != null &&
                (_category == null || card.category == _category),
          ),
        ];
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
                            key: ValueKey('aac-sentence'),
                            sentence.isEmpty ? l10n.tapCardToBuild : sentence,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                      if (_strip.isNotEmpty)
                        IconButton(
                          tooltip: l10n.removeLastWordTooltip,
                          onPressed: _removeLastCard,
                          icon: const Icon(Icons.backspace_outlined),
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
              frequentCards.isEmpty
                  ? Text(
                      l10n.recentCardsHint,
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final card in frequentCards)
                          ActionChip(
                            key: ValueKey('aac-frequent-${card.id}'),
                            onPressed: () => _addCard(card.grammar),
                            label: Text(
                              _language == AppLanguage.ur
                                  ? card.grammar.labelUr
                                  : card.grammar.labelEn,
                            ),
                          ),
                      ],
                    ),
              const SizedBox(height: 20),
              Text(
                l10n.coreWords,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      key: const ValueKey('aac-cat-all'),
                      label: Text(l10n.allCategories),
                      selected: _category == null,
                      onSelected: (_) => setState(() => _category = null),
                    ),
                    const SizedBox(width: 8),
                    for (final category in AacCategory.values) ...[
                      ChoiceChip(
                        key: ValueKey('aac-cat-${category.name}'),
                        label: Text(_categoryLabel(l10n, category)),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
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
                itemCount: visibleDeck.length,
                itemBuilder: (context, index) {
                  final card = visibleDeck[index];
                  return Semantics(
                    key: ValueKey('aac-card-${card.id}'),
                    button: true,
                    label: '${card.grammar.labelEn}, ${card.grammar.labelUr}',
                    child: Card(
                      child: InkWell(
                        onTap: () => _addCard(card.grammar),
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(card.icon, size: 32),
                              const SizedBox(height: 4),
                              Text(
                                card.grammar.labelEn,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(card.grammar.labelUr),
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
                  key: const ValueKey('aac-speak'),
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

  void _removeLastCard() {
    setState(() {
      if (_strip.isNotEmpty) _strip.removeLast();
    });
  }

  void _speakSentence() {
    if (_sentence.isEmpty) return;
    widget.appState.ttsService.speak(_sentence, widget.appState.locale);
  }

  String _categoryLabel(AppLocalizations l10n, AacCategory category) =>
      switch (category) {
        AacCategory.food => l10n.aacCategoryFood,
        AacCategory.drinks => l10n.aacCategoryDrinks,
        AacCategory.emotions => l10n.aacCategoryEmotions,
        AacCategory.activities => l10n.aacCategoryActivities,
        AacCategory.people => l10n.aacCategoryPeople,
        AacCategory.places => l10n.aacCategoryPlaces,
        AacCategory.needs => l10n.aacCategoryNeeds,
        AacCategory.objects => l10n.aacCategoryObjects,
      };
}
