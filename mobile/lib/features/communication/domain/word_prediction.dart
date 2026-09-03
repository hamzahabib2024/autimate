import 'aac_catalog.dart';
import 'card_ranker.dart';
import 'sentence_realiser.dart';

/// Suggests what might come next in the sentence strip.
///
/// **Read the limitation first.** Prediction helps a user who reads. The
/// primary user of this app does not, and for them a shifting row of
/// suggestions is a moving target that breaks the motor memory the board is
/// built on. This is therefore **off by default**, presented as a caregiver
/// option, and rendered in a fixed-height row that never reflows the grid
/// beneath it.
///
/// It earns its place for the child at the top of the literacy ladder, the
/// caregiver composing a longer sentence to model, and the partially literate
/// user for whom three taps beats seven.
///
/// The prediction itself is deliberately transparent rather than learned:
/// grammar rules plus this child's own usage history. A caregiver can be told
/// exactly why a word was offered, which a trained model could not do.
class WordPredictor {
  const WordPredictor({
    this.ranker = const _DefaultRanker(),
    this.maxSuggestions = 4,
  });

  final CardRanker ranker;

  /// Capped low on purpose. A long suggestion row is a second board to
  /// scan, which defeats the point.
  final int maxSuggestions;

  /// Suggests continuations for [strip], drawing on [deck] and [history].
  ///
  /// Ordering is grammar first, frequency second: a word that *fits* beats a
  /// word that is merely common, because offering "milk milk" would teach
  /// the wrong thing.
  List<AacCard> suggest({
    required List<CardGrammar> strip,
    required List<AacCard> deck,
    required List<CardUsageEvent> history,
  }) {
    final used = {for (final card in strip) card.id};
    final candidates = deck.where((card) => !used.contains(card.id)).toList();
    if (candidates.isEmpty) return const [];

    final expected = _expectedRoles(strip);
    final frequency = <String, int>{};
    final ordered = ranker.rank(history, limit: 200);
    for (var i = 0; i < ordered.length; i++) {
      frequency[ordered[i]] = ordered.length - i;
    }

    final scored = <(AacCard, int)>[];
    for (final card in candidates) {
      final grammarScore = expected.contains(card.grammar.pos) ? 1000 : 0;
      // A word that fits nothing is still offered, just far down: an empty
      // suggestion row is worse than an imperfect one.
      scored.add((card, grammarScore + (frequency[card.id] ?? 0)));
    }
    scored.sort((a, b) {
      final byScore = b.$2.compareTo(a.$2);
      return byScore == 0 ? a.$1.id.compareTo(b.$1.id) : byScore;
    });
    return [
      for (final entry in scored.take(maxSuggestions)) entry.$1,
    ];
  }

  /// Which parts of speech would sensibly follow the current strip.
  ///
  /// Mirrors the realiser's own patterns so a suggestion cannot lead the
  /// child somewhere the realiser will not follow.
  Set<PartOfSpeech> _expectedRoles(List<CardGrammar> strip) {
    if (strip.isEmpty) {
      // Nothing yet: offer the openers.
      return {PartOfSpeech.carrier, PartOfSpeech.pronoun};
    }
    final carrier = strip
        .where((card) => card.pos == PartOfSpeech.carrier)
        .firstOrNull;
    final hasNoun = strip.any((card) => card.pos == PartOfSpeech.noun);
    final hasAdjective = strip.any(
      (card) => card.pos == PartOfSpeech.adjective,
    );

    if (carrier?.id == 'i_want') {
      return hasNoun
          ? {PartOfSpeech.adjective, PartOfSpeech.verb}
          : {PartOfSpeech.noun};
    }
    if (carrier?.id == 'i_feel') {
      return hasAdjective
          ? {PartOfSpeech.noun}
          : {PartOfSpeech.adjective};
    }
    // Free-form: a noun or a verb usually continues it.
    return {PartOfSpeech.noun, PartOfSpeech.verb};
  }

  /// Plain-language account of why a word was offered, for the caregiver
  /// screen. Nothing here is a black box.
  String explain(List<CardGrammar> strip, AacCard card) {
    final expected = _expectedRoles(strip);
    return expected.contains(card.grammar.pos)
        ? 'fits after what is already there'
        : 'used often';
  }
}

class _DefaultRanker implements CardRanker {
  const _DefaultRanker();

  @override
  List<String> rank(List<CardUsageEvent> history, {int limit = 8}) =>
      RecencyWeightedCardRanker().rank(history, limit: limit);

  @override
  List<RankedCard> rankWithScores(
    List<CardUsageEvent> history, {
    int limit = 8,
  }) => RecencyWeightedCardRanker().rankWithScores(history, limit: limit);
}
