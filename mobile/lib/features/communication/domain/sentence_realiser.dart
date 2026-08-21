enum AppLanguage { en, ur }

enum PartOfSpeech { carrier, pronoun, verb, noun, adjective, quantifier }

enum UrduGender { masculine, feminine }

class CardGrammar {
  const CardGrammar({
    required this.id,
    required this.labelEn,
    required this.labelUr,
    required this.pos,
    required this.isCountable,
    required this.startsWithVowelSound,
    required this.urduGender,
    this.urduSubject = '',
    this.urduVerbMasculine = '',
    this.urduVerbFeminine = '',
    this.noArticle = false,
  });

  final String id;
  final String labelEn;
  final String labelUr;
  final PartOfSpeech pos;
  final bool isCountable;
  final bool startsWithVowelSound;
  final UrduGender urduGender;
  final String urduSubject;
  final String urduVerbMasculine;
  final String urduVerbFeminine;

  /// Names of people and places take no article in English.
  final bool noArticle;
}

class SpeakerProfile {
  const SpeakerProfile({required this.gender});

  final UrduGender gender;
}

class RealisedSentence {
  const RealisedSentence({required this.text, required this.language});

  final String text;
  final AppLanguage language;
}

abstract interface class SentenceRealiser {
  RealisedSentence realise(
    List<CardGrammar> strip,
    SpeakerProfile speaker,
    AppLanguage language,
  );
}

class RuleBasedSentenceRealiser implements SentenceRealiser {
  @override
  RealisedSentence realise(
    List<CardGrammar> strip,
    SpeakerProfile speaker,
    AppLanguage language,
  ) {
    if (strip.isEmpty) {
      return RealisedSentence(text: '', language: language);
    }
    return language == AppLanguage.en
        ? RealisedSentence(text: _english(strip), language: language)
        : RealisedSentence(text: _urdu(strip, speaker), language: language);
  }

  String _english(List<CardGrammar> strip) {
    if (strip.length == 1) return '${_capitalise(strip.single.labelEn)}.';

    final carrier = _first(strip, PartOfSpeech.carrier);
    final object = _first(strip, PartOfSpeech.noun);
    final adjective = _first(strip, PartOfSpeech.adjective);
    if (carrier?.id == 'i_want' && object != null) {
      final article = object.noArticle
          ? ''
          : object.isCountable
          ? (object.startsWithVowelSound ? 'an' : 'a')
          : 'some';
      final phrase = article.isEmpty
          ? object.labelEn
          : '$article ${object.labelEn}';
      return 'I want $phrase.';
    }
    if (carrier?.id == 'i_feel' && adjective != null) {
      return 'I feel ${adjective.labelEn}.';
    }

    return '${_capitalise(strip.map((card) => card.labelEn).join(' '))}.';
  }

  String _urdu(List<CardGrammar> strip, SpeakerProfile speaker) {
    if (strip.length == 1) return '${strip.single.labelUr}.';

    final carrier = _first(strip, PartOfSpeech.carrier);
    final object = _first(strip, PartOfSpeech.noun);
    final adjective = _first(strip, PartOfSpeech.adjective);
    if (carrier?.id == 'i_want' && object != null) {
      final subject = carrier!.urduSubject.isEmpty
          ? 'میں'
          : carrier.urduSubject;
      final verb = speaker.gender == UrduGender.feminine
          ? carrier.urduVerbFeminine
          : carrier.urduVerbMasculine;
      return '$subject ${object.labelUr} ${verb.isEmpty ? carrier.labelUr : verb}.';
    }
    if (carrier?.id == 'i_feel' && adjective != null) {
      final subject = carrier!.urduSubject.isEmpty
          ? 'میں'
          : carrier.urduSubject;
      final verb = speaker.gender == UrduGender.feminine
          ? carrier.urduVerbFeminine
          : carrier.urduVerbMasculine;
      return '$subject ${adjective.labelUr} ${verb.isEmpty ? 'ہوں' : verb}.';
    }

    return '${strip.map((card) => card.labelUr).join(' ')}.';
  }

  CardGrammar? _first(List<CardGrammar> cards, PartOfSpeech pos) {
    for (final card in cards) {
      if (card.pos == pos) return card;
    }
    return null;
  }

  String _capitalise(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
