# AutiMate — Visual & Experience Redesign Prompt

> **How to use:** paste everything below the divider into Claude Code (or your agent) as a single
> prompt, from the repository root. It is written to be self-contained: it carries the audit
> findings, the design system spec, the per-screen work, and the acceptance gates, so the agent
> does not have to re-derive any of it.
>
> It is deliberately long. Do **not** trim the "Non-negotiable constraints" section — that is what
> stops a redesign from silently breaking the 146 passing tests.

---

You are redesigning the visual layer of **AutiMate**, an offline-first Flutter app for autistic
children (primary user: a non-verbal or minimally verbal child, roughly ages 4–12) and their
caregivers. The app currently *works* but looks like an internal admin tool. Your job is to give it
a real, coherent, beautiful design system — one built for a disabled child's eyes, attention, and
nervous system, not for a design-award screenshot.

Work in the repository at `mobile/`. Read before you write. Ship in reviewable slices.

---

## 1. What already exists (verified audit — trust this, don't re-derive)

**Baseline state:** `flutter analyze` → no issues. `flutter test` → 146 tests pass. Branch `AI`.

**Structure:** feature-first Flutter. `lib/core/{config,data,providers,services,theme}`,
`lib/features/<feature>/{domain,data,presentation}`, `lib/shared/widgets/app_widgets.dart`.
State is a single `AppState extends ChangeNotifier` (`core/services/app_services.dart`, 555 lines)
handed down through constructors, with a Riverpod `ProviderContainer` as the composition root.
Localization is ARB-driven (`lib/l10n/app_en.arb`, `app_ur.arb`, 268 keys) with generated
delegates. Zero hard-coded user-facing strings — keep it that way.

**The visual problems, precisely:**

| # | Finding | Evidence |
|---|---|---|
| V1 | **No assets at all.** No `assets/` directory; the `assets:` and `fonts:` blocks in `pubspec.yaml` are still commented out. Every single visual in the app is a monochrome Material icon glyph. | `mobile/pubspec.yaml:78–95` |
| V2 | **The theme is 36 lines.** One `ColorScheme.fromSeed(0xFF0F766E)`, two scaffold background colours, a card shape, an input border. No `textTheme`, no dark theme, no button/chip/navigation themes, no spacing, radius, or motion tokens. | `lib/core/theme/app_theme.dart` |
| V3 | **`fontFamily: 'sans'` names a family that is never declared**, so it silently falls back to the platform default. Urdu therefore renders in whatever the OS supplies — unverified, and Nastaliq is not guaranteed. | `app_theme.dart:19` + no `fonts:` in pubspec |
| V4 | **Every screen is the same skeleton:** `Scaffold` → `AppBar(title: Text)` → `ListView(padding: EdgeInsets.all(16 or 20))` → default `Card` → `ListTile`. A five-year-old's AAC board and the caregiver's analytics dashboard are styled identically. | all 20 files under `features/*/presentation/` |
| V5 | **AAC symbol tiles are too small and uncoded.** `maxCrossAxisExtent: 180, mainAxisExtent: 132`, with `Icon(size: 32)` — the symbol occupies roughly a quarter of the tile; the rest is two lines of text. No colour coding by word class. | `features/communication/presentation/aac_screen.dart:186–232` |
| V6 | **The six emotions are drawn with stock Material icons.** The existing checklist already admits this. | `features/emotion_recognition/` |
| V7 | **Feedback is text in a card.** Stars, correct/incorrect, and session completion are all rendered as `Text` inside `StatePanel`. There is no reward moment. | `shared/widgets/app_widgets.dart:60` |
| V8 | **Motion is essentially absent.** Exactly one `AnimationController` exists in the whole app (the calming screen). Sensory mode only swaps the page-transition builder. No `AnimatedSwitcher`, no implicit animations on state change. | `features/sensory_support/presentation/calm_activities_screen.dart:188` |
| V9 | **No dark theme**, despite `android/app/src/main/res/values-night/` existing. | `AppTheme.light()` is the only entry point |
| V10 | **No app icon, no splash screen**, and the Android label is lowercase `"autimate"`. | `android/app/src/main/AndroidManifest.xml:3` |
| V11 | **Touch-target sizing is hand-rolled per call site** as `ConstrainedBox(minHeight: 64)` rather than being a theme guarantee. | ~12 occurrences across screens |

---

## 2. Non-negotiable constraints

Violating any of these makes the work unmergeable. Read them twice.

1. **All 146 tests must still pass, unmodified where possible.** Tests assert on `ValueKey`s
   (`aac-card-milk`, `aac-speak`, `answer-0`, `badge-first-session`, `progress-ring`,
   `offline-banner`, `breathing-cue`, `onboard-start`, `level-option-advanced`, …). **Never rename,
   move, or delete a `ValueKey` that a test finds.** When you replace a widget, carry its key onto
   the replacement. Run `grep -rho "ValueKey('[^']*')" test/*.dart | sort -u` and treat that list as
   a public API.
2. **`AppTheme.light({required bool sensoryMode})` must keep its signature** — `test/theme_contrast_test.dart`
   iterates it and asserts WCAG AA on `onSurface/surface`, `onSurface/scaffoldBackground`,
   `onPrimary/primary`, `onPrimaryContainer/primaryContainer`, `onSecondaryContainer/secondaryContainer`,
   and 3:1 for `primary/surface`. Add a `dark()` alongside it; do not replace it.
3. **Every WCAG AA pair you introduce must be added to that contrast test.** New semantic colours
   (module accents, AAC word-class colours, success/attention states) get asserted, in both sensory
   modes and both brightnesses. The test is the design system's guardrail — grow it.
4. **Zero hard-coded user-facing strings.** New copy goes into `app_en.arb` **and** `app_ur.arb`,
   then `flutter gen-l10n`. Urdu translations must be real Urdu, not English placeholders.
5. **RTL must survive.** Use `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end` —
   never `left`/`right`. `test/localization_widget_test.dart` checks directionality.
6. **Sensory mode must stay measurably different**, not cosmetically different: reduced motion,
   flat surfaces, lower contrast ceiling, softer colour, quieter TTS. Assert the difference in tests.
7. **No flashing, strobing, or high-frequency motion anywhere. Ever.** Nothing that changes
   luminance faster than 3 Hz. This is a hard safety rule for this user group, not a preference.
8. **Dependency discipline.** The project justifies every dependency in-repo. Fonts are bundled
   assets (no runtime download, the app is offline-first). Acceptable new *dev* dependencies:
   `flutter_launcher_icons`, `flutter_native_splash`. Do not add an animation library, a UI kit, or
   an SVG runtime without writing the justification into `PROJECT-STRUCTURE.md` first — Flutter's
   built-in implicit animations and `CustomPainter` cover everything specified below.
9. **Offline-first.** No network calls for fonts, images, or anything else.
10. **No clinical or diagnostic framing** in any new copy or iconography.

---

## 3. Design principles for this specific user

These are the *reasons* behind the spec. When a detail below is ambiguous, resolve it with these.

- **Predictability beats novelty.** The same layout skeleton on every child screen. A control never
  moves between screens. The back affordance is always in the same place. Surprise is a cost here,
  not a delight.
- **Low arousal by default.** Desaturated, warm-neutral grounds. No pure `#FFFFFF` full-bleed
  backgrounds (glare) and no large fills of saturated red or yellow. Saturation is a scarce
  resource spent only on meaning.
- **Symbol dominance on child surfaces.** The picture is the content; the word is the caption.
  Target ≥ 55% of a symbol tile's area for the symbol itself.
- **Colour is never the only channel.** Every colour-coded thing also carries a distinct shape,
  icon, border treatment, or label. Assume a colour-blind child and a greyscale printout.
- **State must be unmistakable.** Selected / pressed / disabled differ by *at least two* of
  {fill, border weight, scale, icon}. A 5% tint change is invisible to many of these users.
- **One primary action per screen**, visually dominant and always in the same position.
- **Clutter ceiling.** No more than ~6 interactive elements in a child-screen viewport at once.
  If content exceeds that, paginate or group — do not shrink.
- **Errorless framing.** A wrong answer gets a calm redirect and a retry, never a red X, a buzzer,
  a shake, or a score penalty. Reserve red for genuine caregiver-facing danger only.
- **Proportionate reward.** A star *grows and settles* over ~600 ms. It does not explode into
  confetti. In sensory mode it simply fades in.
- **Two visual tiers, deliberately different.**
  *Child tier* — large, warm, illustrated, minimal chrome, huge targets, few words.
  *Caregiver tier* — denser, informational, standard Material 3, real data density.
  A caregiver should be able to tell at a glance which mode the device is in.
- **Typography for reading difficulty.** Start-aligned, never justified, never all-caps, sentence
  case, generous line height (1.5 Latin / 1.9 Nastaliq), generous letter spacing on child text.

---

## 4. The design system to build

Create `lib/core/theme/` as a real system, not one file:

```
lib/core/theme/
  app_theme.dart        # light() + dark(), both taking sensoryMode — light() keeps its signature
  app_colors.dart       # semantic tokens + module accents + AAC word-class palette
  app_typography.dart   # child scale + caregiver scale, Latin + Urdu families
  app_spacing.dart      # spacing, radii, elevation, touch-target constants
  app_motion.dart       # durations, curves, and the sensory/OS reduced-motion resolver
```

### 4.1 Colour tokens

Brand seed stays teal `#0F766E` for continuity. Define semantic roles explicitly rather than
relying only on `fromSeed`, and verify every pair against the contrast test.

**Surfaces — light:** canvas `#F6F7F5` (warm off-white, low glare), card `#FFFFFF`,
sunken `#ECEFEB`, outline `#D5DBD6`.
**Surfaces — light + sensory:** canvas `#F1F3F0`, card `#FAFBF9`, sunken `#E7EAE6`.
**Surfaces — dark:** canvas `#12161A`, card `#1A2026`, sunken `#0D1114`, outline `#2C353C`.

**Module accents** (wayfinding — a child learns "green means routine" before they can read the word):

| Module | Accent | Rationale |
|---|---|---|
| Communicate / AAC | Teal `#0F766E` | brand anchor, the flagship surface |
| Emotions | Apricot `#A85B22` | warm, not alarming; distinct from the AAC colour key |
| Routine | Indigo `#3F51A8` | calm, structural |
| Learning | Violet `#6A4A9E` | distinct from routine at a glance |
| Sensory / Calm | Sage `#4C7A5B` | the quiet corner of the app |
| Progress / Rewards | Ochre `#8A6A1F` | "earned", without gold-glitter arousal |

Every accent needs a container/on-container pair that clears AA in all four theme combinations.
Derive them, then **assert them in the contrast test**.

**AAC word-class palette (Fitzgerald key).** This is an established AAC convention, not decoration —
it teaches sentence structure through colour and speeds visual scanning. Map the existing catalog:

| Cards | Class | Colour |
|---|---|---|
| `i_want`, `i_feel` (carriers) | social / carrier | soft rose `#B05B7A` |
| `mama`, `papa`, `teacher` (`people`) | people | amber `#9A7B12` |
| `play`, `walk`, `story` (`activities`) | verbs | green `#3F7A46` |
| `happy`, `sad`, `angry`, `surprised`, `scared`, `fine` (`emotions`) | descriptors | blue `#2F6BA8` |
| `apple`, `banana`, `rice`, `water`, `milk`, `juice`, `home`, `school_place`, `park`, and `objects` | nouns | orange `#A8551F` |
| `help` and the rest of `needs` | needs / social | rose `#B05B7A` |

Apply the colour as a **top band plus a 2 dp border** on the tile, not as the whole tile fill —
the symbol must stay on a light ground for legibility. In sensory mode, drop each colour's
saturation by ~40% and keep the border. Pair every colour with its existing icon so the coding is
redundant, never load-bearing on its own.

### 4.2 Typography

Bundle the fonts under `mobile/assets/fonts/` and declare them in `pubspec.yaml`. Do not fetch at
runtime.

- **Latin:** **Lexend** (OFL) — designed to reduce visual stress and improve reading proficiency;
  the strongest defensible choice for this audience. *Alternative:* **Atkinson Hyperlegible**
  (OFL, Braille Institute) if you prefer maximum character disambiguation. Pick one, document why
  in `PROJECT-STRUCTURE.md`.
- **Urdu:** **Noto Nastaliq Urdu** (OFL) for child-facing text, with **Noto Naskh Arabic** as the
  dense-UI fallback. Nastaliq needs ~1.9 line height and a larger size than the Latin equivalent —
  build that into the Urdu text theme, don't reuse the Latin metrics. Verify no clipping of
  ascenders/descenders in the sentence strip and story reader.

Two scales, resolved by which tier a screen belongs to:

| Role | Child tier | Caregiver tier |
|---|---|---|
| display | 40 / 48 | — |
| headline | 32 / 40 | 24 / 32 |
| title | 24 / 32 | 18 / 24 |
| body | 20 / 30 | 16 / 24 |
| label | 18 / 24 | 14 / 20 |

Minimum body size anywhere in the app: 16. Minimum on any child-facing surface: 20.

### 4.3 Spacing, radii, targets

Spacing scale `4, 8, 12, 16, 20, 24, 32, 40, 48` as named constants. Radii: `sm 12`, `md 20`,
`lg 28` (child cards), `pill 999`. Elevation `0 / 1 / 3` in normal mode; **always 0 in sensory mode**,
replaced by a 1 dp outline so the hierarchy survives without shadow.

Move the minimum touch target into the theme (`FilledButtonThemeData`, `IconButtonThemeData`,
`ListTileThemeData`) as **56 dp caregiver / 64 dp child**, then delete the hand-rolled
`ConstrainedBox(minHeight: 64)` wrappers — but only where a test does not depend on the wrapper's
position in the tree. Verify by running the suite after each removal.

### 4.4 Motion

```
fast   120ms   base 240ms   slow 400ms   breath 4000ms
curve  Curves.easeOutCubic   (never elastic, never bounce)
```

Build one resolver and route **all** animation through it:

```dart
Duration AppMotion.resolve(BuildContext context, Duration d) =>
    (sensoryMode || MediaQuery.of(context).disableAnimations)
        ? Duration.zero
        : d;
```

Honouring `MediaQuery.disableAnimations` means the OS-level "remove animations" accessibility
setting works too — that is a real requirement for this audience, not a nicety. In sensory mode,
transform-based motion goes to zero; opacity cross-fades may remain at 200 ms.

### 4.5 Shared component library

Extend `lib/shared/widgets/` (split it — 117 lines in one file will not hold this):

- `ChildActionCard` — the big home tile: accent-tinted, illustration-led, ≥ 96 dp tall, one line.
- `SymbolTile` — the AAC card: word-class band + border, symbol ≥ 55% of area, label beneath,
  pressed state = scale 0.96 + border thickens. **Carries the existing `aac-card-<id>` key.**
- `SentenceStrip` — horizontal chip row with per-word remove, animated insert, prominent speak button.
- `PrimaryActionButton` — the one dominant action; fixed position per screen.
- `ProgressRing` — replaces the private `_RingPainter` in the gamification screen; animated sweep;
  **keeps the `progress-ring` key.**
- `RewardStar` — the gentle award moment (scale 0.6→1.0 + fade over 600 ms; fade only in sensory mode).
- `EmotionFace` — see §5.2.
- `SectionHeader`, `EmptyState`, `CaregiverStatTile`, `Mascot`.

---

## 5. Two pieces of custom artwork to build in code

Do **not** ship bitmap art for these. Both should be parameterised `CustomPainter`s: zero asset
weight, theme-aware, animatable, deterministic, and unit-testable.

### 5.1 The mascot

One calm, simple 2D character used consistently in onboarding, empty states, reward moments, and
the Module 2 role-play. Rounded geometry, no teeth, no wide eyes, no sudden motion. It is the app's
only "personality" — using it everywhere is what makes the product feel designed rather than assembled.

### 5.2 `EmotionFace` — solves V6 *and* an open Module 2 item at once

A single painter parameterised by `(browAngle, eyeOpenness, mouthCurve, blush)` renders all six
target emotions (happy, sad, angry, surprised, scared, neutral) and every role-play expression
state, and can **tween between them**. This closes "real artwork for the six emotions" (Module 3)
and "2D role-play character with expression states" (Module 2) with one testable widget, and it
keeps the emotion stimulus consistent across every screen the child meets it on — which matters
more for learning than illustration polish does.

Write unit tests asserting each of the six emotions maps to distinct parameter sets.

---

## 6. Screen-by-screen work

Deliver in this order, one reviewable commit per screen, running `flutter analyze && flutter test`
after each.

1. **`app_theme.dart` + tokens + `pubspec` fonts/assets.** Nothing visual yet. Extend
   `theme_contrast_test.dart` to cover every new pair in light/dark × normal/sensory. Gate: all
   146 tests still green.
2. **`app_shell.dart`** — home. Child tier. Accent-coded `ChildActionCard`s, a real profile header
   (mascot avatar, name, stars, streak), module colours doing the wayfinding. The settings gear
   stays exactly where it is.
3. **`aac_screen.dart`** — the flagship. Sentence strip becomes prominent and animated; tiles get
   the Fitzgerald key, larger symbols, unmistakable press states; the speak button becomes the one
   dominant action, always bottom-anchored and reachable. Preserve every `aac-*` key. Re-verify the
   "request in ≤ 3 taps" test still passes.
4. **`emotion_screen.dart` + `expression_screen.dart`** — `EmotionFace` as the stimulus; answer
   options as large face cards; errorless feedback; `RewardStar` on the session summary.
5. **`routines_screen.dart`** — a visual timeline with clear now/next/done states, completion ring,
   calm countdown banners. This screen is a child's anxiety regulator; predictability is the whole
   point.
6. **`gamification_screen.dart`** — animate `ProgressRing`, give badges earned/locked states with
   real visual weight, keep the cooperative framing copy.
7. **`social_stories_screen.dart` + `learning_path_screen.dart`** — illustrated story pages using
   the mascot and `EmotionFace`, clear reading progress, comfortable Urdu line heights.
8. **`sensory_support_screen.dart` + `calm_activities_screen.dart`** — the calmest surfaces in the
   app; the existing breathing animation gets a proper gradient-free pace circle.
9. **Caregiver tier** — `dashboard_screen.dart`, `settings_screen.dart`, `routine_editor_screen.dart`,
   `support_level_screen.dart`, `parent_gate_screen.dart`. Deliberately denser and more
   informational. Real chart styling for the emotion trend and weekly bars.
10. **`onboarding_screen.dart` + `auth_screen.dart`** — first impression; mascot-led, one decision
    per step.
11. **Dark theme** wired through `main.dart` (`theme`, `darkTheme`, `themeMode` from `AppState`,
    persisted like the other settings).
12. **App icon, adaptive icon, splash, and the `"autimate"` → `"AutiMate"` label fix.**

---

## 7. Acceptance criteria

- [ ] `flutter analyze` → no issues.
- [ ] `flutter test` → **≥ 146 tests pass**, none deleted or weakened to accommodate the redesign.
- [ ] `theme_contrast_test.dart` covers every new semantic pair across light/dark × normal/sensory.
- [ ] A test asserts sensory mode measurably changes motion duration, elevation, and saturation.
- [ ] A test asserts `AppMotion.resolve` returns `Duration.zero` when `disableAnimations` is set.
- [ ] No `left`/`right` edge insets or alignments in new code; RTL tests pass.
- [ ] No hard-coded user-facing strings; `app_en.arb` and `app_ur.arb` stay in sync; Urdu is real Urdu.
- [ ] No new runtime dependencies without a written justification in `PROJECT-STRUCTURE.md`.
- [ ] Every child-facing interactive target ≥ 64 dp; caregiver ≥ 56 dp.
- [ ] Nothing anywhere flashes, strobes, or changes luminance above 3 Hz.
- [ ] App icon and splash present; Android label reads `AutiMate`.
- [ ] `PROJECT-STRUCTURE.md` gains a "Design system" section documenting the tokens and the two tiers.

## 8. Working method

Read the file before you change it. Change one screen at a time. Run `flutter analyze && flutter test`
after every screen and **stop and fix immediately** if the count drops below 146 — do not accumulate
breakage. Where a design decision has a real trade-off (font choice, whether a colour band or a full
fill reads better for the AAC tiles), state the trade-off in one line and pick the option that
serves the child's legibility, then move on. Do not ask for approval between screens; deliver the
whole sequence.
