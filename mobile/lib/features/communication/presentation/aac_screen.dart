import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/services/app_services.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../shared/widgets/app_widgets.dart';
import '../data/image_source_service.dart';
import '../data/voice_recording_service.dart';
import '../domain/aac_catalog.dart';
import '../domain/card_ranker.dart';
import '../domain/custom_card_repository.dart';
import '../domain/sentence_realiser.dart';
import 'custom_cards_screen.dart';

/// The communication board — the app's flagship surface.
///
/// Laid out around one rule: the fastest possible path from intent to
/// speech. The sentence strip sits at the top where composition is visible,
/// the speak button is pinned to the bottom where a thumb already rests,
/// and it never moves between sessions. Objective O1 ("a request in three
/// taps") is measured against this screen.
class AacScreen extends StatefulWidget {
  const AacScreen({
    required this.appState,
    this.imageSource = const UnavailableImageSourceService(),
    this.voiceRecorder = const UnavailableVoiceRecordingService(),
    super.key,
  });

  final AppState appState;

  /// Plays caregiver recordings. Injected so tests and desktop runs never
  /// touch the platform recorder.
  final VoiceRecordingService voiceRecorder;

  /// Injected so widget tests and desktop runs never touch the platform
  /// picker.
  final ImageSourceService imageSource;

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
  String? _durableChildId;

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
    widget.appState.loadCustomCards();
  }

  /// Restores the frequent-cards ranking across restarts and reloads it
  /// whenever the active child profile changes.
  Future<void> _loadDurableUsage() async {
    final childId = widget.appState.selectedChild.id;
    _durableChildId = childId;
    final events =
        await widget.appState.progressRepository.getCardUsage(childId);
    if (!mounted || _durableChildId != childId) return;
    setState(() {
      _durableUsage
        ..clear()
        ..addAll(events);
    });
  }

  /// The built-in deck plus this child's caregiver-authored cards. Custom
  /// cards project into [AacCard] so nothing downstream special-cases them.
  List<AacCard> get _fullDeck => [
    ...aacDeck,
    ...widget.appState.customCards.map((card) => card.toAacCard()),
  ];

  CustomCard? _customFor(String id) {
    for (final card in widget.appState.customCards) {
      if (card.id == id) return card;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        if (_durableChildId != widget.appState.selectedChild.id) {
          _loadDurableUsage();
          widget.appState.loadCustomCards();
        }
        return ChildTextScale(child: _buildBody(context, l10n));
      },
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n) {
    final palette = context.palette;
    final deck = _fullDeck;
    final byId = {for (final card in deck) card.id: card};
    final frequentCards = _ranker
        .rank([..._durableUsage, ..._usage])
        .map((id) => byId[id])
        .whereType<AacCard>()
        .toList();

    // Carriers stay visible under every filter: without "I want" on screen
    // the child cannot form a request, whichever category they are browsing.
    final visibleDeck = [
      ...deck.where((card) => card.category == null),
      ...deck.where(
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
            key: const ValueKey('open-custom-cards'),
            tooltip: l10n.customCardsTitle,
            onPressed: () => CustomCardsScreen.openGated(
              context,
              widget.appState,
              widget.imageSource,
            ),
            icon: const Icon(Icons.add_photo_alternate_outlined),
          ),
          IconButton(
            tooltip: l10n.speakSentenceTooltip,
            onPressed: _strip.isEmpty ? null : _speakSentence,
            icon: const Icon(Icons.volume_up),
          ),
        ],
      ),
      body: Column(
        children: [
          _sentenceStrip(context, l10n),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
              ),
              children: [
                if (frequentCards.isNotEmpty) ...[
                  SectionHeader(
                    title: l10n.frequentlyUsed,
                    accent: palette.communicate,
                  ),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final card in frequentCards)
                        ActionChip(
                          key: ValueKey('aac-frequent-${card.id}'),
                          onPressed: () => _addCard(card.grammar),
                          avatar: Icon(
                            card.icon,
                            size: 20,
                            color: wordClassColor(context, card),
                          ),
                          label: Text(
                            _language == AppLanguage.ur
                                ? card.grammar.labelUr
                                : card.grammar.labelEn,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SectionHeader(
                  title: l10n.coreWords,
                  accent: palette.communicate,
                ),
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
                      const SizedBox(width: AppSpacing.xs),
                      for (final category in AacCategory.values) ...[
                        ChoiceChip(
                          key: ValueKey('aac-cat-${category.name}'),
                          label: Text(categoryLabel(l10n, category)),
                          selected: _category == category,
                          onSelected: (_) =>
                              setState(() => _category = category),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        widget.appState.symbolScale.maxExtent,
                    mainAxisExtent: widget.appState.symbolScale.mainExtent,
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                  ),
                  itemCount: visibleDeck.length,
                  itemBuilder: (context, index) {
                    final card = visibleDeck[index];
                    final custom = _customFor(card.id);
                    return Entrance(
                      index: index,
                      sensoryMode: widget.appState.sensoryMode,
                      child: SymbolTile(
                      key: ValueKey('aac-card-${card.id}'),
                      card: card,
                      showUrdu: _language == AppLanguage.ur,
                      literacy: widget.appState.literacyFor(
                        widget.appState.selectedChild.id,
                      ),
                      sensoryMode: widget.appState.sensoryMode,
                      imagePath: custom?.imagePath,
                      onTap: () => _addCard(card.grammar),
                      onLongPress: custom == null
                          ? null
                          : () => CustomCardsScreen.openGated(
                                context,
                                widget.appState,
                                widget.imageSource,
                              ),
                    ),
                    );
                  },
                ),
              ],
            ),
          ),
          // The one dominant action, pinned so it never moves.
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: PrimaryActionButton(
                key: const ValueKey('aac-speak'),
                label: l10n.speakSentenceTooltip,
                icon: Icons.volume_up,
                accent: palette.communicate,
                onPressed: _strip.isEmpty ? null : _speakSentence,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The composed sentence, with per-word removal and drag-to-reorder.
  Widget _sentenceStrip(BuildContext context, AppLocalizations l10n) {
    final palette = context.palette;
    final sentence = _sentence;
    final reduced =
        AppMotion.reduced(context, sensoryMode: widget.appState.sensoryMode);
    return Material(
      color: palette.sunken,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.sentenceHeader,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Semantics(
                      liveRegion: true,
                      label: l10n.sentenceHeader,
                      child: Text(
                        key: const ValueKey('aac-sentence'),
                        sentence.isEmpty ? l10n.tapCardToBuild : sentence,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  if (_strip.isNotEmpty) ...[
                    IconButton(
                      tooltip: l10n.removeLastWordTooltip,
                      onPressed: _removeLastCard,
                      icon: const Icon(Icons.backspace_outlined),
                    ),
                    IconButton(
                      tooltip: l10n.clearSentenceTooltip,
                      onPressed: () => setState(_strip.clear),
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ],
              ),
              if (_strip.isNotEmpty)
                SizedBox(
                  height: 68,
                  child: ReorderableListView.builder(
                    key: const ValueKey('aac-strip'),
                    scrollDirection: Axis.horizontal,
                    buildDefaultDragHandles: true,
                    proxyDecorator: (child, index, animation) =>
                        Material(color: Colors.transparent, child: child),
                    onReorder: _reorder,
                    itemCount: _strip.length,
                    itemBuilder: (context, index) {
                      final card = _strip[index];
                      return Padding(
                        key: ValueKey('strip-$index-${card.id}'),
                        padding: const EdgeInsetsDirectional.only(
                          end: AppSpacing.xs,
                        ),
                        child: Center(
                          child: InputChip(
                            label: Text(
                              _language == AppLanguage.ur
                                  ? card.labelUr
                                  : card.labelEn,
                            ),
                            onDeleted: () => _removeAt(index),
                            deleteIcon: const Icon(Icons.close, size: 18),
                            deleteButtonTooltipMessage: l10n.removeWordTooltip,
                            backgroundColor: palette.card,
                          ),
                        ),
                      );
                    },
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.xxs),
                  child: Text(
                    l10n.sentenceStripEmpty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              if (_strip.length > 1 && !reduced)
                Text(
                  l10n.reorderSentenceHint,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _addCard(CardGrammar card) {
    final usage = CardUsageEvent(cardId: card.id, usedAt: DateTime.now());
    setState(() {
      _strip.add(card);
      _usage.add(usage);
    });
    widget.appState.recordCardUsage(usage);
    final custom = _customFor(card.id);

    // A caregiver recording wins over synthesis. This is the whole point of
    // the feature: on a device with a poor or missing Urdu voice, the
    // recording is the difference between a usable card and a silent one.
    final clip = custom?.audioFor(_language);
    if (clip != null && clip.isNotEmpty) {
      unawaited(widget.voiceRecorder.play(clip));
      return;
    }

    final tts = widget.appState.ttsService;
    final spoken = custom != null
        ? custom.speechFor(_language)
        : (_language == AppLanguage.ur ? card.labelUr : card.labelEn);
    if (tts is QueuedTtsService) {
      tts.speak(spoken, widget.appState.locale);
    }
  }

  void _removeLastCard() {
    setState(() {
      if (_strip.isNotEmpty) _strip.removeLast();
    });
  }

  void _removeAt(int index) {
    setState(() {
      if (index >= 0 && index < _strip.length) _strip.removeAt(index);
    });
  }

  /// Moving a word re-runs the realiser, so the spoken sentence always
  /// matches the strip the child can see.
  ///
  /// Note that the realiser resolves grammatical roles by part of speech
  /// rather than by position, so reordering a recognised pattern (carrier +
  /// noun) cannot turn a correct sentence into a broken one — a child who
  /// taps "apple" before "I want" still gets "I want an apple." Reorder
  /// changes the output on the free-form path, where the strip is spoken in
  /// the order the child arranged it.
  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final card = _strip.removeAt(oldIndex);
      _strip.insert(target, card);
    });
  }

  void _speakSentence() {
    if (_sentence.isEmpty) return;
    widget.appState.ttsService.speak(_sentence, widget.appState.locale);
  }
}

/// Kept for callers that still resolve a category name directly.
String aacCategoryLabel(AppLocalizations l10n, AacCategory category) =>
    categoryLabel(l10n, category);

/// Loads a stored custom-card picture, or null when there is none.
ImageProvider? customCardImage(String? path) =>
    path == null ? null : FileImage(File(path));
