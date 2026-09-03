import 'dart:convert';

import '../../../core/data/local_store.dart';
import 'sentence_realiser.dart';

/// A whole sentence a caregiver saved for one-tap reuse.
///
/// **The concern this design takes seriously.** A phrase bank can discourage
/// generative language: if "I want juice" is one button, the child never
/// builds it, and building it is the skill. That is a real and well-known
/// objection in AAC practice, not a hypothetical.
///
/// Three deliberate answers:
///
/// 1. A phrase stores its **component card ids**, not just text. Tapping it
///    loads the cards into the strip rather than speaking a canned line, so
///    the child still sees the sentence assembled from its parts.
/// 2. [speakImmediately] is opt-in per phrase and off by default. The
///    caregiver chooses the shortcut deliberately, phrase by phrase, for the
///    cases where speed genuinely matters — pain, the toilet, distress.
/// 3. The bank is small and caregiver-curated. There is no auto-saving of
///    frequent sentences, because that would grow the shortcut set silently
///    and quietly replace composition with selection.
class SavedPhrase {
  const SavedPhrase({
    required this.id,
    required this.childId,
    required this.cardIds,
    required this.labelEn,
    required this.labelUr,
    this.speakImmediately = false,
    this.urgent = false,
  });

  final String id;
  final String childId;

  /// The cards this phrase is made of, in order. Loading them into the strip
  /// is what keeps the phrase a shortcut rather than a substitute.
  final List<String> cardIds;

  final String labelEn;
  final String labelUr;

  /// Speak on tap instead of only loading the strip. Off by default.
  final bool speakImmediately;

  /// Marks a phrase that matters in a hurry — pain, the toilet, help.
  /// Urgent phrases sort first and are the ones worth putting on a
  /// home-screen widget.
  final bool urgent;

  String labelFor(AppLanguage language) =>
      language == AppLanguage.ur ? labelUr : labelEn;

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'cardIds': cardIds,
    'labelEn': labelEn,
    'labelUr': labelUr,
    'speakImmediately': speakImmediately,
    'urgent': urgent,
  };

  static SavedPhrase fromJson(Map<String, dynamic> json) => SavedPhrase(
    id: json['id'] as String? ?? '',
    childId: json['childId'] as String? ?? '',
    cardIds: [
      for (final id in (json['cardIds'] as List? ?? const []))
        if (id is String) id,
    ],
    labelEn: json['labelEn'] as String? ?? '',
    labelUr: json['labelUr'] as String? ?? '',
    speakImmediately: json['speakImmediately'] as bool? ?? false,
    urgent: json['urgent'] as bool? ?? false,
  );

  SavedPhrase copyWith({
    String? labelEn,
    String? labelUr,
    List<String>? cardIds,
    bool? speakImmediately,
    bool? urgent,
  }) => SavedPhrase(
    id: id,
    childId: childId,
    cardIds: cardIds ?? this.cardIds,
    labelEn: labelEn ?? this.labelEn,
    labelUr: labelUr ?? this.labelUr,
    speakImmediately: speakImmediately ?? this.speakImmediately,
    urgent: urgent ?? this.urgent,
  );
}

abstract interface class PhraseBankRepository {
  Future<List<SavedPhrase>> phrasesFor(String childId);
  Future<void> save(SavedPhrase phrase);
  Future<void> delete(String phraseId);
}

/// Durable phrase bank over the shared key-value boundary.
class LocalPhraseBankRepository implements PhraseBankRepository {
  LocalPhraseBankRepository(this._store);

  static const String _key = 'autimate.aac.phrases.v1';

  /// A deliberate ceiling. A phrase bank that grows without limit stops
  /// being a shortcut list and becomes a second, worse board.
  static const int maxPerChild = 12;

  final KeyValueStore _store;

  Future<List<SavedPhrase>> _all() async {
    final raw = await _store.read(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(SavedPhrase.fromJson)
        .toList();
  }

  Future<void> _write(List<SavedPhrase> phrases) => _store.write(
    _key,
    jsonEncode([for (final phrase in phrases) phrase.toJson()]),
  );

  @override
  Future<List<SavedPhrase>> phrasesFor(String childId) async {
    final phrases = (await _all())
        .where((phrase) => phrase.childId == childId)
        .toList();
    // Urgent first, then insertion order — a phrase needed in a hurry
    // should not be somewhere down a list.
    phrases.sort((a, b) {
      if (a.urgent == b.urgent) return 0;
      return a.urgent ? -1 : 1;
    });
    return List.unmodifiable(phrases);
  }

  @override
  Future<void> save(SavedPhrase phrase) async {
    final all = await _all();
    final index = all.indexWhere((existing) => existing.id == phrase.id);
    if (index >= 0) {
      all[index] = phrase;
    } else {
      final owned = all.where((p) => p.childId == phrase.childId).length;
      if (owned >= maxPerChild) return;
      all.add(phrase);
    }
    await _write(all);
  }

  @override
  Future<void> delete(String phraseId) async {
    final all = await _all();
    all.removeWhere((phrase) => phrase.id == phraseId);
    await _write(all);
  }
}

/// In-memory bank for tests and runs with no durable store.
class InMemoryPhraseBankRepository implements PhraseBankRepository {
  final List<SavedPhrase> _phrases = [];

  @override
  Future<List<SavedPhrase>> phrasesFor(String childId) async {
    final owned =
        _phrases.where((phrase) => phrase.childId == childId).toList();
    owned.sort((a, b) {
      if (a.urgent == b.urgent) return 0;
      return a.urgent ? -1 : 1;
    });
    return List.unmodifiable(owned);
  }

  @override
  Future<void> save(SavedPhrase phrase) async {
    final index = _phrases.indexWhere((existing) => existing.id == phrase.id);
    if (index >= 0) {
      _phrases[index] = phrase;
      return;
    }
    final owned =
        _phrases.where((p) => p.childId == phrase.childId).length;
    if (owned >= LocalPhraseBankRepository.maxPerChild) return;
    _phrases.add(phrase);
  }

  @override
  Future<void> delete(String phraseId) async {
    _phrases.removeWhere((phrase) => phrase.id == phraseId);
  }
}
