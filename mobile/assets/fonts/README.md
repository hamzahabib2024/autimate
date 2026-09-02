# Bundled fonts

The design system is written against two families. Neither is committed
here — font binaries do not belong in the repository, and the app is
offline-first so nothing may be fetched at runtime. Drop the files in, flip
two constants, and the whole app picks them up.

## What to download

| Family | Use | Licence | Files needed |
|---|---|---|---|
| **Lexend** | All Latin text | SIL OFL 1.1 | `Lexend-Regular.ttf`, `Lexend-Medium.ttf`, `Lexend-SemiBold.ttf`, `Lexend-Bold.ttf` |
| **Noto Nastaliq Urdu** | All Urdu text | SIL OFL 1.1 | `NotoNastaliqUrdu-Regular.ttf`, `NotoNastaliqUrdu-Bold.ttf` |

Both are on Google Fonts. Download the static TTFs (not the variable
build) and place them in this directory.

**Why Lexend:** it is drawn specifically to reduce visual stress and improve
reading proficiency, which is the strongest defensible choice for a
child-facing literacy-adjacent app. *Atkinson Hyperlegible* (Braille
Institute, also OFL) is the alternative if maximum character
disambiguation matters more than reading flow; swap the family name and
nothing else changes.

**Why Noto Nastaliq Urdu:** Nastaliq is the script Urdu readers in Pakistan
expect. Device coverage is not guaranteed, so it must be bundled rather
than assumed. It stacks ligatures diagonally and needs far more vertical
room than Latin at the same point size — `AppTypography` already applies a
1.9 line height and a 1.08 size bump for Urdu, so do not reuse the Latin
metrics.

## Activation

1. Put the `.ttf` files in this directory.
2. Uncomment the `fonts:` block in `mobile/pubspec.yaml`.
3. In `lib/core/theme/app_typography.dart`, set:

   ```dart
   static const String? latinFamily = 'Lexend';
   static const String? urduFamily = 'NotoNastaliqUrdu';
   ```

4. `flutter pub get && flutter run`.

Until then both constants are `null` and the app renders in the platform
default. That is deliberate: Flutter fails the build outright on a declared
font asset whose file is missing, and a broken build is worse than a
temporary fallback.

## Verify on device

Nastaliq rendering is the one part of this that cannot be checked in a
widget test. On a physical Android device, confirm that:

- ascenders and descenders are not clipped in the AAC sentence strip or the
  social-story reader,
- the Urdu label on an AAC symbol tile still fits one line,
- the caregiver dashboard stays readable at the denser caregiver scale.
