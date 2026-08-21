import 'dart:math' as math;

class CardUsageEvent {
  const CardUsageEvent({required this.cardId, required this.usedAt});

  final String cardId;
  final DateTime usedAt;
}

class RankedCard {
  const RankedCard({required this.cardId, required this.score});

  final String cardId;
  final double score;
}

abstract interface class CardRanker {
  List<String> rank(List<CardUsageEvent> history, {int limit = 8});
  List<RankedCard> rankWithScores(
    List<CardUsageEvent> history, {
    int limit = 8,
  });
}

class RecencyWeightedCardRanker implements CardRanker {
  static const double halfLifeDays = 7;
  static final double _lambda = math.log(2) / halfLifeDays;

  @override
  List<String> rank(List<CardUsageEvent> history, {int limit = 8}) =>
      rankWithScores(history, limit: limit).map((card) => card.cardId).toList();

  @override
  List<RankedCard> rankWithScores(
    List<CardUsageEvent> history, {
    int limit = 8,
  }) {
    if (limit <= 0 || history.isEmpty) return const [];
    final reference = history
        .map((event) => event.usedAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    final scores = <String, double>{};
    for (final event in history) {
      final ageDays = math.max(
        0,
        reference.difference(event.usedAt).inMilliseconds /
            Duration.millisecondsPerDay,
      );
      scores.update(
        event.cardId,
        (score) => score + math.exp(-_lambda * ageDays),
        ifAbsent: () => math.exp(-_lambda * ageDays),
      );
    }
    final ranked =
        scores.entries
            .map((entry) => RankedCard(cardId: entry.key, score: entry.value))
            .toList()
          ..sort((a, b) {
            final scoreOrder = b.score.compareTo(a.score);
            return scoreOrder == 0 ? a.cardId.compareTo(b.cardId) : scoreOrder;
          });
    return ranked.take(limit).toList();
  }
}
