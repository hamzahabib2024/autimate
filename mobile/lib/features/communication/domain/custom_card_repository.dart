import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/data/local_store.dart';
import 'aac_catalog.dart';
import 'sentence_realiser.dart';

/// A vocabulary card a caregiver created for one child.
///
/// Local-first by design: [imagePath] points at a file inside the app
/// documents directory, not a remote URL. That keeps custom cards working
/// with no network and no Firebase Storage decision, while [toJson] leaves
/// room for a `imageUrl` sibling later — a remote source becomes a drop-in
/// alternative rather than a migration.
@immutable
class CustomCard {
  const CustomCard({
    required this.id,
    required this.childId,
    required this.labelEn,
    required this.labelUr,
    required this.category,
    this.imagePath,
    this.iconCodePoint,
    this.spokenEn,
    this.spokenUr,
    this.audioPathEn,
    this.audioPathUr,
    this.pos = PartOfSpeech.noun,
  });

  final String id;
  final String childId;
  final String labelEn;
  final String labelUr;
  final AacCategory category;

  /// Absolute path to a copied image in the app documents directory.
  final String? imagePath;

  /// Fallback glyph when the caregiver picked a symbol instead of a photo.
  final int? iconCodePoint;

  /// Optional spoken form, used instead of the label when speaking.
  final String? spokenEn;
  final String? spokenUr;

  /// Recorded caregiver voice, per language. When present it is played
  /// instead of synthesising — a real voice beats TTS, and on a device with
  /// a poor Urdu voice it is the difference between usable and not.
  final String? audioPathEn;
  final String? audioPathUr;

  /// The clip for [language], or null to fall back to TTS.
  String? audioFor(AppLanguage language) =>
      language == AppLanguage.ur ? audioPathUr : audioPathEn;

  bool get hasRecordedAudio =>
      (audioPathEn?.isNotEmpty ?? false) || (audioPathUr?.isNotEmpty ?? false);

  /// Every stored clip, for cleanup when the card is deleted.
  List<String> get audioPaths => [
    if (audioPathEn?.isNotEmpty ?? false) audioPathEn!,
    if (audioPathUr?.isNotEmpty ?? false) audioPathUr!,
  ];

  final PartOfSpeech pos;

  String speechFor(AppLanguage language) => language == AppLanguage.ur
      ? (spokenUr?.isNotEmpty == true ? spokenUr! : labelUr)
      : (spokenEn?.isNotEmpty == true ? spokenEn! : labelEn);

  /// Projects into the shared [AacCard] shape so custom cards flow through
  /// the grid, the sentence strip, the realiser, and the frequent-cards
  /// ranking with no special-casing anywhere downstream.
  AacCard toAacCard() => AacCard(
    category: category,
    icon: iconCodePoint == null
        ? Icons.photo_outlined
        : IconData(iconCodePoint!, fontFamily: 'MaterialIcons'),
    grammar: CardGrammar(
      id: id,
      labelEn: labelEn,
      labelUr: labelUr,
      pos: pos,
      isCountable: true,
      startsWithVowelSound: _startsWithVowel(labelEn),
      urduGender: UrduGender.masculine,
      urduSubject: '',
      urduVerbMasculine: '',
      urduVerbFeminine: '',
      noArticle: false,
    ),
  );

  static bool _startsWithVowel(String value) {
    if (value.isEmpty) return false;
    return 'aeiouAEIOU'.contains(value[0]);
  }

  CustomCard copyWith({
    String? labelEn,
    String? labelUr,
    AacCategory? category,
    String? imagePath,
    int? iconCodePoint,
    String? spokenEn,
    String? spokenUr,
    String? audioPathEn,
    String? audioPathUr,
  }) => CustomCard(
    id: id,
    childId: childId,
    labelEn: labelEn ?? this.labelEn,
    labelUr: labelUr ?? this.labelUr,
    category: category ?? this.category,
    imagePath: imagePath ?? this.imagePath,
    iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    spokenEn: spokenEn ?? this.spokenEn,
    spokenUr: spokenUr ?? this.spokenUr,
    audioPathEn: audioPathEn ?? this.audioPathEn,
    audioPathUr: audioPathUr ?? this.audioPathUr,
    pos: pos,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'childId': childId,
    'labelEn': labelEn,
    'labelUr': labelUr,
    'category': category.name,
    'imagePath': imagePath,
    'iconCodePoint': iconCodePoint,
    'spokenEn': spokenEn,
    'spokenUr': spokenUr,
    'audioPathEn': audioPathEn,
    'audioPathUr': audioPathUr,
    'pos': pos.name,
  };

  static CustomCard fromJson(Map<String, dynamic> json) => CustomCard(
    id: json['id'] as String? ?? '',
    childId: json['childId'] as String? ?? '',
    labelEn: json['labelEn'] as String? ?? '',
    labelUr: json['labelUr'] as String? ?? '',
    category: AacCategory.values.firstWhere(
      (value) => value.name == json['category'],
      orElse: () => AacCategory.objects,
    ),
    imagePath: json['imagePath'] as String?,
    iconCodePoint: json['iconCodePoint'] as int?,
    spokenEn: json['spokenEn'] as String?,
    spokenUr: json['spokenUr'] as String?,
    audioPathEn: json['audioPathEn'] as String?,
    audioPathUr: json['audioPathUr'] as String?,
    pos: PartOfSpeech.values.firstWhere(
      (value) => value.name == json['pos'],
      orElse: () => PartOfSpeech.noun,
    ),
  );
}

abstract interface class CustomCardRepository {
  Future<List<CustomCard>> cardsFor(String childId);
  Future<void> save(CustomCard card);
  Future<void> delete(String cardId);
}

/// Durable [CustomCardRepository] over the shared key-value boundary.
class LocalCustomCardRepository implements CustomCardRepository {
  LocalCustomCardRepository(this._store);

  static const String _key = 'autimate.aac.customCards.v1';

  final KeyValueStore _store;

  Future<List<CustomCard>> _all() async {
    final raw = await _store.read(_key);
    if (raw == null || raw.isEmpty) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(CustomCard.fromJson)
        .toList();
  }

  Future<void> _write(List<CustomCard> cards) => _store.write(
    _key,
    jsonEncode([for (final card in cards) card.toJson()]),
  );

  @override
  Future<List<CustomCard>> cardsFor(String childId) async {
    final all = await _all();
    return all.where((card) => card.childId == childId).toList();
  }

  @override
  Future<void> save(CustomCard card) async {
    final all = await _all();
    final index = all.indexWhere((existing) => existing.id == card.id);
    if (index >= 0) {
      all[index] = card;
    } else {
      all.add(card);
    }
    await _write(all);
  }

  @override
  Future<void> delete(String cardId) async {
    final all = await _all();
    all.removeWhere((card) => card.id == cardId);
    await _write(all);
  }
}

/// In-memory repository for tests and for runs with no durable store.
class InMemoryCustomCardRepository implements CustomCardRepository {
  final List<CustomCard> _cards = [];

  @override
  Future<List<CustomCard>> cardsFor(String childId) async =>
      _cards.where((card) => card.childId == childId).toList();

  @override
  Future<void> save(CustomCard card) async {
    final index = _cards.indexWhere((existing) => existing.id == card.id);
    if (index >= 0) {
      _cards[index] = card;
    } else {
      _cards.add(card);
    }
  }

  @override
  Future<void> delete(String cardId) async {
    _cards.removeWhere((card) => card.id == cardId);
  }
}
