import 'package:flutter/material.dart';

/// Semantic colour tokens layered on top of the Material `ColorScheme`.
///
/// The scheme itself still comes from `ColorScheme.fromSeed`, which
/// guarantees the Material contrast relationships. This extension adds the
/// meanings Material has no role for: which module a surface belongs to,
/// and which word class an AAC card carries.
///
/// Two rules govern every value here:
///
/// 1. **Colour is never the only channel.** Each accent is paired in the UI
///    with an icon, a border, and a label, so a colour-blind child or a
///    greyscale printout loses nothing.
/// 2. **Saturation is a scarce resource.** Grounds are warm neutrals; strong
///    colour appears only where it carries meaning. Sensory mode desaturates
///    everything further via [desaturate].
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.card,
    required this.sunken,
    required this.outline,
    required this.communicate,
    required this.emotions,
    required this.routine,
    required this.learning,
    required this.sensory,
    required this.progress,
    required this.wordCarrier,
    required this.wordPeople,
    required this.wordVerb,
    required this.wordDescriptor,
    required this.wordNoun,
    required this.wordNeed,
    required this.success,
    required this.attention,
    required this.onAccent,
    required this.accentTint,
  });

  // --- Surfaces -----------------------------------------------------------

  /// Page ground. Never pure white — full-brightness white is a glare
  /// source and a reported discomfort for many autistic users.
  final Color canvas;

  /// Raised content surface.
  final Color card;

  /// Recessed wells (sentence strip, inactive tracks).
  final Color sunken;

  /// Hairline borders. Carries the hierarchy in sensory mode, where every
  /// elevation drops to zero.
  final Color outline;

  // --- Module accents -----------------------------------------------------
  //
  // Wayfinding. A child learns "green means routine" long before they can
  // read the word, so each module keeps its colour on every surface it
  // touches: the home tile, the app bar, the section headers.

  final Color communicate;
  final Color emotions;
  final Color routine;
  final Color learning;
  final Color sensory;
  final Color progress;

  // --- AAC word classes (Fitzgerald key) ----------------------------------
  //
  // An established AAC convention, not decoration: colour-coding by word
  // class speeds visual scanning and teaches sentence structure implicitly.
  // Applied as a top band plus a border so the symbol keeps a light ground.

  final Color wordCarrier;
  final Color wordPeople;
  final Color wordVerb;
  final Color wordDescriptor;
  final Color wordNoun;
  final Color wordNeed;

  // --- States -------------------------------------------------------------

  /// Completion and correctness. Never paired with a competing red.
  final Color success;

  /// Caregiver-facing attention only. Deliberately not used on any
  /// child-facing surface — this app has no error state a child can enter.
  final Color attention;

  /// Foreground for text sitting directly on an accent fill.
  final Color onAccent;

  /// Blends an accent toward the card colour for large tinted areas.
  final Color Function(Color accent, double amount) accentTint;

  /// The six module accents in a fixed order, for iteration in tests.
  List<Color> get moduleAccents => [
    communicate,
    emotions,
    routine,
    learning,
    sensory,
    progress,
  ];

  /// The six word-class colours in a fixed order, for iteration in tests.
  List<Color> get wordClasses => [
    wordCarrier,
    wordPeople,
    wordVerb,
    wordDescriptor,
    wordNoun,
    wordNeed,
  ];

  static Color _tintOn(Color surface) => surface;

  /// Mixes [accent] toward [surface] by [amount] (0 = accent, 1 = surface).
  static Color mix(Color accent, Color surface, double amount) =>
      Color.lerp(accent, surface, amount.clamp(0.0, 1.0))!;

  /// Pulls saturation out of a colour without shifting its hue, used for
  /// the sensory-mode variants.
  static Color desaturate(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation * (1 - amount)).clamp(0.0, 1.0))
        .toColor();
  }

  /// Light palette. [sensoryMode] softens the ground and desaturates every
  /// accent by 40%, which is a visible reduction rather than a token one.
  factory AppPalette.light({required bool sensoryMode}) {
    Color a(Color value) =>
        sensoryMode ? desaturate(value, 0.40) : value;
    final card = sensoryMode
        ? const Color(0xFFFAFBF9)
        : const Color(0xFFFFFFFF);
    return AppPalette(
      canvas: sensoryMode
          ? const Color(0xFFF1F3F0)
          : const Color(0xFFF6F7F5),
      card: card,
      sunken: sensoryMode
          ? const Color(0xFFE7EAE6)
          : const Color(0xFFECEFEB),
      outline: sensoryMode
          ? const Color(0xFFC9D0CA)
          : const Color(0xFFD5DBD6),
      communicate: a(const Color(0xFF0F766E)),
      emotions: a(const Color(0xFFA85B22)),
      routine: a(const Color(0xFF3F51A8)),
      learning: a(const Color(0xFF6A4A9E)),
      sensory: a(const Color(0xFF4C7A5B)),
      progress: a(const Color(0xFF8A6A1F)),
      wordCarrier: a(const Color(0xFF9A4265)),
      wordPeople: a(const Color(0xFF8A6E10)),
      wordVerb: a(const Color(0xFF3F7A46)),
      wordDescriptor: a(const Color(0xFF2F6BA8)),
      wordNoun: a(const Color(0xFFA8551F)),
      wordNeed: a(const Color(0xFF9A4265)),
      success: a(const Color(0xFF3F7A46)),
      attention: a(const Color(0xFF9A4A1E)),
      onAccent: const Color(0xFFFFFFFF),
      accentTint: (accent, amount) => mix(accent, _tintOn(card), amount),
    );
  }

  /// Dark palette. Accents are lightened rather than reused, because the
  /// light-theme values sit far too close to the dark ground to clear AA.
  factory AppPalette.dark({required bool sensoryMode}) {
    Color a(Color value) =>
        sensoryMode ? desaturate(value, 0.40) : value;
    final card = sensoryMode
        ? const Color(0xFF171D22)
        : const Color(0xFF1A2026);
    return AppPalette(
      canvas: sensoryMode
          ? const Color(0xFF0F1317)
          : const Color(0xFF12161A),
      card: card,
      sunken: const Color(0xFF0D1114),
      outline: sensoryMode
          ? const Color(0xFF283036)
          : const Color(0xFF2C353C),
      communicate: a(const Color(0xFF5FD3C6)),
      emotions: a(const Color(0xFFE9A56E)),
      routine: a(const Color(0xFF9EAEF2)),
      learning: a(const Color(0xFFC2A6EC)),
      sensory: a(const Color(0xFF8FC79E)),
      progress: a(const Color(0xFFE0C079)),
      wordCarrier: a(const Color(0xFFE9A8BE)),
      wordPeople: a(const Color(0xFFDCC167)),
      wordVerb: a(const Color(0xFF8FC79E)),
      wordDescriptor: a(const Color(0xFF95BEE8)),
      wordNoun: a(const Color(0xFFE9A87E)),
      wordNeed: a(const Color(0xFFE9A8BE)),
      success: a(const Color(0xFF8FC79E)),
      attention: a(const Color(0xFFE9A07E)),
      onAccent: const Color(0xFF0B0F12),
      accentTint: (accent, amount) => mix(accent, _tintOn(card), amount),
    );
  }

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? card,
    Color? sunken,
    Color? outline,
    Color? communicate,
    Color? emotions,
    Color? routine,
    Color? learning,
    Color? sensory,
    Color? progress,
    Color? wordCarrier,
    Color? wordPeople,
    Color? wordVerb,
    Color? wordDescriptor,
    Color? wordNoun,
    Color? wordNeed,
    Color? success,
    Color? attention,
    Color? onAccent,
    Color Function(Color, double)? accentTint,
  }) => AppPalette(
    canvas: canvas ?? this.canvas,
    card: card ?? this.card,
    sunken: sunken ?? this.sunken,
    outline: outline ?? this.outline,
    communicate: communicate ?? this.communicate,
    emotions: emotions ?? this.emotions,
    routine: routine ?? this.routine,
    learning: learning ?? this.learning,
    sensory: sensory ?? this.sensory,
    progress: progress ?? this.progress,
    wordCarrier: wordCarrier ?? this.wordCarrier,
    wordPeople: wordPeople ?? this.wordPeople,
    wordVerb: wordVerb ?? this.wordVerb,
    wordDescriptor: wordDescriptor ?? this.wordDescriptor,
    wordNoun: wordNoun ?? this.wordNoun,
    wordNeed: wordNeed ?? this.wordNeed,
    success: success ?? this.success,
    attention: attention ?? this.attention,
    onAccent: onAccent ?? this.onAccent,
    accentTint: accentTint ?? this.accentTint,
  );

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      canvas: l(canvas, other.canvas),
      card: l(card, other.card),
      sunken: l(sunken, other.sunken),
      outline: l(outline, other.outline),
      communicate: l(communicate, other.communicate),
      emotions: l(emotions, other.emotions),
      routine: l(routine, other.routine),
      learning: l(learning, other.learning),
      sensory: l(sensory, other.sensory),
      progress: l(progress, other.progress),
      wordCarrier: l(wordCarrier, other.wordCarrier),
      wordPeople: l(wordPeople, other.wordPeople),
      wordVerb: l(wordVerb, other.wordVerb),
      wordDescriptor: l(wordDescriptor, other.wordDescriptor),
      wordNoun: l(wordNoun, other.wordNoun),
      wordNeed: l(wordNeed, other.wordNeed),
      success: l(success, other.success),
      attention: l(attention, other.attention),
      onAccent: l(onAccent, other.onAccent),
      accentTint: t < 0.5 ? accentTint : other.accentTint,
    );
  }
}

/// Convenience accessor so screens read `context.palette` rather than
/// spelling out the extension lookup every time.
extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ??
      AppPalette.light(sensoryMode: false);
}
