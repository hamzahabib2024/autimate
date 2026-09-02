/// Transition to Literacy (T2L) support level.
///
/// T2L is one of the few AAC features with direct published efficacy:
/// briefly surfacing the written word when a symbol is selected improved
/// participants' identification of target words, and most **generalised to
/// a text-only display** — that is, it helped them begin reading rather than
/// only helping them communicate.
///
/// The levels form a deliberate progression from symbol-led to text-led.
/// It is a ladder a child climbs over months, not a preference, which is why
/// it is stored per child rather than per device.
///
/// A caution the caregiver UI states plainly: benefit varies enormously by
/// child. Moving up the ladder too early makes the board *harder*, and the
/// cost of that lands on a child who cannot tell you.
enum LiteracyLevel {
  /// No T2L. The board behaves exactly as it always has.
  off,

  /// The word rises briefly above the symbol on selection, then settles.
  /// The published condition, and the right starting point.
  flash,

  /// The word is permanently larger and heavier beside the symbol.
  emphasis,

  /// The symbol fades back and the word leads. The last rung before text.
  fading,

  /// Text only. The symbol is gone.
  textOnly;

  /// How strongly the written word is weighted, 0..1.
  double get wordWeight => switch (this) {
    LiteracyLevel.off => 0.0,
    LiteracyLevel.flash => 0.25,
    LiteracyLevel.emphasis => 0.5,
    LiteracyLevel.fading => 0.8,
    LiteracyLevel.textOnly => 1.0,
  };

  /// Opacity the symbol is drawn at.
  ///
  /// It never reaches zero before [textOnly]: a symbol at 40% is still a
  /// usable cue for a child having a hard day, and removing the fallback
  /// gradually is the whole point of the ladder.
  double get symbolOpacity => switch (this) {
    LiteracyLevel.off || LiteracyLevel.flash => 1.0,
    LiteracyLevel.emphasis => 0.95,
    LiteracyLevel.fading => 0.4,
    LiteracyLevel.textOnly => 0.0,
  };

  /// Label font size for the tile caption.
  double get labelSize => switch (this) {
    LiteracyLevel.off || LiteracyLevel.flash => 17,
    LiteracyLevel.emphasis => 20,
    LiteracyLevel.fading => 23,
    LiteracyLevel.textOnly => 26,
  };

  /// Whether the word animates up on selection.
  bool get flashesOnSelect =>
      this == LiteracyLevel.flash || this == LiteracyLevel.emphasis;

  /// Whether the symbol is drawn at all.
  bool get showsSymbol => this != LiteracyLevel.textOnly;

  /// The next rung, or null at the top.
  LiteracyLevel? get next {
    final index = LiteracyLevel.values.indexOf(this);
    return index >= LiteracyLevel.values.length - 1
        ? null
        : LiteracyLevel.values[index + 1];
  }

  /// The previous rung, or null at the bottom.
  ///
  /// Stepping back must always be possible. A child's reading is not
  /// monotonic, and a level that stopped working needs an exit.
  LiteracyLevel? get previous {
    final index = LiteracyLevel.values.indexOf(this);
    return index <= 0 ? null : LiteracyLevel.values[index - 1];
  }
}

/// Per-child T2L state.
class LiteracyPreference {
  const LiteracyPreference({this.level = LiteracyLevel.off});

  final LiteracyLevel level;

  Map<String, dynamic> toJson() => {'level': level.name};

  static LiteracyPreference fromJson(Map<String, dynamic> json) =>
      LiteracyPreference(
        level: LiteracyLevel.values.firstWhere(
          (value) => value.name == json['level'],
          orElse: () => LiteracyLevel.off,
        ),
      );
}
