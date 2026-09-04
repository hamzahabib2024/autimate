import 'package:flutter/material.dart';

/// The colour a thing actually is.
///
/// **Why this is separate from the Fitzgerald key.** The word-class colour
/// says what job a word does in a sentence — it is a teaching device, and it
/// belongs on the tile's band and border where it stays consistent across a
/// whole category. But a child does not recognise an apple because it is a
/// noun. They recognise it because it is *red*.
///
/// So the two coexist deliberately and never compete:
///
/// * The **band and border** keep the word class. Grammar stays learnable.
/// * The **symbol itself** takes the real-world colour, on a soft disc of
///   the same hue. Recognition gets faster.
///
/// This is not decoration. For a pre-literate child, natural colour is often
/// the single strongest recognition cue on the card, and drawing a red apple
/// in orange because "orange means noun" would be optimising for the adult's
/// model of the system over the child's ability to use it.
///
/// **Where a thing has no obvious colour** — "finished", "help", "I want" —
/// there is no entry here and the tile falls back to its word-class colour.
/// Inventing a colour for an abstract word would teach a association that
/// means nothing outside this app.
class SymbolColors {
  const SymbolColors._();

  /// Real-world colour per card id.
  ///
  /// Chosen to be recognisable rather than photographic, and all darkened
  /// enough to clear 4.5:1 on the tile's light ground **and** to still clear
  /// it after sensory mode takes 40% of the saturation out. A true banana
  /// yellow fails both; a darkened one still reads as yellow.
  static const Map<String, Color> _byCardId = {
    // Food
    'apple': Color(0xFFC0392B), // red
    'banana': Color(0xFF846A0E), // yellow, darkened to stay legible
    'rice': Color(0xFF736347), // warm off-white, darkened to read

    // Drinks
    'water': Color(0xFF2F6BA8), // blue
    'milk': Color(0xFF586475), // cool grey-white, darkened to read
    'juice': Color(0xFFA85827), // orange

    // Places
    'park': Color(0xFF3F7A46), // green
    'home': Color(0xFF8A5A2B), // brick
    'school_place': Color(0xFF4A5FA8), // school blue

    // Objects
    'ball': Color(0xFFC0392B), // classic red ball
    'book': Color(0xFF2F6BA8),
    'toy': Color(0xFF9A4265),

    // Activities
    'walk': Color(0xFF3F7A46),
    'story': Color(0xFF6A4A9E),
    'play': Color(0xFFA85827),

    // Needs — kept literal where a colour genuinely helps.
    'toilet': Color(0xFF2F6BA8),
    'rest': Color(0xFF6A4A9E),
  };

  /// Emotions are coloured by the convention children's books use, not by
  /// any claim about what a feeling *is*. The face carries the meaning; the
  /// colour only helps pick it out of a grid.
  static const Map<String, Color> _byEmotion = {
    'happy': Color(0xFF856B0F), // warm yellow, darkened
    'sad': Color(0xFF2F6BA8), // blue
    'angry': Color(0xFFC0392B), // red
    'surprised': Color(0xFF6A4A9E), // violet
    'scared': Color(0xFF6B5B8F), // muted purple
    'fine': Color(0xFF4C7A5B), // calm green
  };

  /// The natural colour for [cardId], or null when the thing has no obvious
  /// colour and the word-class hue should be used instead.
  static Color? forCard(String cardId) =>
      _byCardId[cardId] ?? _byEmotion[cardId];

  /// True when this card carries a real-world colour.
  static bool has(String cardId) => forCard(cardId) != null;

  /// Every card id with a natural colour. Used by tests to check contrast.
  static Iterable<String> get coloured =>
      [..._byCardId.keys, ..._byEmotion.keys];
}
