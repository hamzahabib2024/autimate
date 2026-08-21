import 'package:flutter/material.dart';

import 'sentence_realiser.dart';

/// Vocabulary categories from the project scope document.
enum AacCategory {
  food,
  drinks,
  emotions,
  activities,
  people,
  places,
  needs,
  objects,
}

/// A vocabulary card pairing grammar metadata with presentation data.
class AacCard {
  const AacCard({
    required this.grammar,
    required this.icon,
    this.category,
  });

  final CardGrammar grammar;
  final IconData icon;

  /// Null for carrier phrases, which stay visible under every filter.
  final AacCategory? category;

  String get id => grammar.id;
}

AacCard _card({
  required String id,
  required String en,
  required String ur,
  required IconData icon,
  AacCategory? category,
  PartOfSpeech pos = PartOfSpeech.noun,
  bool countable = true,
  bool vowel = false,
  UrduGender gender = UrduGender.masculine,
  bool noArticle = false,
  String subject = '',
  String verbM = '',
  String verbF = '',
}) {
  return AacCard(
    category: category,
    icon: icon,
    grammar: CardGrammar(
      id: id,
      labelEn: en,
      labelUr: ur,
      pos: pos,
      isCountable: countable,
      startsWithVowelSound: vowel,
      urduGender: gender,
      urduSubject: subject,
      urduVerbMasculine: verbM,
      urduVerbFeminine: verbF,
      noArticle: noArticle,
    ),
  );
}

/// Full starter vocabulary: two carrier phrases plus every scoped category.
final List<AacCard> aacDeck = [
  _card(
    id: 'i_want',
    en: 'I want',
    ur: 'چاہتا ہوں',
    icon: Icons.touch_app,
    pos: PartOfSpeech.carrier,
    countable: false,
    subject: 'میں',
    verbM: 'چاہتا ہوں',
    verbF: 'چاہتی ہوں',
  ),
  _card(
    id: 'i_feel',
    en: 'I feel',
    ur: 'محسوس کرتا ہوں',
    icon: Icons.psychology_alt_outlined,
    pos: PartOfSpeech.carrier,
    countable: false,
    subject: 'میں',
    verbM: 'ہوں',
    verbF: 'ہوں',
  ),
  _card(
    id: 'apple',
    en: 'apple',
    ur: 'سیب',
    icon: Icons.apple,
    category: AacCategory.food,
    vowel: true,
  ),
  _card(
    id: 'banana',
    en: 'banana',
    ur: 'کیلا',
    icon: Icons.eco,
    category: AacCategory.food,
  ),
  _card(
    id: 'rice',
    en: 'rice',
    ur: 'چاول',
    icon: Icons.rice_bowl,
    category: AacCategory.food,
    countable: false,
  ),
  _card(
    id: 'water',
    en: 'water',
    ur: 'پانی',
    icon: Icons.water_drop,
    category: AacCategory.drinks,
    countable: false,
  ),
  _card(
    id: 'milk',
    en: 'milk',
    ur: 'دودھ',
    icon: Icons.local_cafe,
    category: AacCategory.drinks,
    countable: false,
  ),
  _card(
    id: 'juice',
    en: 'juice',
    ur: 'جوس',
    icon: Icons.local_drink,
    category: AacCategory.drinks,
  ),
  _card(
    id: 'happy',
    en: 'happy',
    ur: 'خوش',
    icon: Icons.sentiment_satisfied,
    category: AacCategory.emotions,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'sad',
    en: 'sad',
    ur: 'اداس',
    icon: Icons.sentiment_dissatisfied,
    category: AacCategory.emotions,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'angry',
    en: 'angry',
    ur: 'ناراض',
    icon: Icons.mood_bad,
    category: AacCategory.emotions,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'surprised',
    en: 'surprised',
    ur: 'حیران',
    icon: Icons.auto_awesome,
    category: AacCategory.emotions,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'scared',
    en: 'scared',
    ur: 'خوفزدہ',
    icon: Icons.warning_amber,
    category: AacCategory.emotions,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'fine',
    en: 'fine',
    ur: 'ٹھیک',
    icon: Icons.sentiment_neutral,
    category: AacCategory.emotions,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'play',
    en: 'play',
    ur: 'کھیل',
    icon: Icons.sports_esports,
    category: AacCategory.activities,
    countable: false,
  ),
  _card(
    id: 'walk',
    en: 'walk',
    ur: 'سیر',
    icon: Icons.directions_walk,
    category: AacCategory.activities,
    gender: UrduGender.feminine,
  ),
  _card(
    id: 'story',
    en: 'story',
    ur: 'کہانی',
    icon: Icons.auto_stories,
    category: AacCategory.activities,
    gender: UrduGender.feminine,
  ),
  _card(
    id: 'mama',
    en: 'Mama',
    ur: 'امی',
    icon: Icons.child_care,
    category: AacCategory.people,
    countable: false,
    gender: UrduGender.feminine,
    noArticle: true,
  ),
  _card(
    id: 'papa',
    en: 'Papa',
    ur: 'ابو',
    icon: Icons.man,
    category: AacCategory.people,
    countable: false,
    noArticle: true,
  ),
  _card(
    id: 'teacher',
    en: 'teacher',
    ur: 'استاد',
    icon: Icons.school,
    category: AacCategory.people,
    countable: false,
    noArticle: true,
  ),
  _card(
    id: 'home',
    en: 'home',
    ur: 'گھر',
    icon: Icons.home,
    category: AacCategory.places,
    countable: false,
    noArticle: true,
  ),
  _card(
    id: 'school_place',
    en: 'school',
    ur: 'اسکول',
    icon: Icons.location_city,
    category: AacCategory.places,
    countable: false,
    noArticle: true,
  ),
  _card(
    id: 'park',
    en: 'park',
    ur: 'پارک',
    icon: Icons.park,
    category: AacCategory.places,
    countable: false,
    noArticle: true,
  ),
  _card(
    id: 'help',
    en: 'help',
    ur: 'مدد',
    icon: Icons.pan_tool_outlined,
    category: AacCategory.needs,
    countable: false,
    gender: UrduGender.feminine,
  ),
  _card(
    id: 'toilet',
    en: 'toilet',
    ur: 'ٹائلٹ',
    icon: Icons.wc,
    category: AacCategory.needs,
    countable: false,
    noArticle: true,
  ),
  _card(
    id: 'rest',
    en: 'rest',
    ur: 'آرام',
    icon: Icons.self_improvement,
    category: AacCategory.needs,
    countable: false,
    gender: UrduGender.feminine,
  ),
  _card(
    id: 'finished',
    en: 'finished',
    ur: 'ختم',
    icon: Icons.check_circle_outline,
    category: AacCategory.needs,
    pos: PartOfSpeech.adjective,
    countable: false,
  ),
  _card(
    id: 'ball',
    en: 'ball',
    ur: 'گیند',
    icon: Icons.sports_soccer,
    category: AacCategory.objects,
    gender: UrduGender.feminine,
  ),
  _card(
    id: 'book',
    en: 'book',
    ur: 'کتاب',
    icon: Icons.book,
    category: AacCategory.objects,
    gender: UrduGender.feminine,
  ),
  _card(
    id: 'toy',
    en: 'toy',
    ur: 'کھلونا',
    icon: Icons.toys,
    category: AacCategory.objects,
  ),
];

/// Looks a deck card up by its grammar id.
AacCard? cardById(String id) {
  for (final card in aacDeck) {
    if (card.id == id) return card;
  }
  return null;
}
