# Project Structure

## Repository layout

- `mobile/` - Android/iOS Flutter application.
- `mobile/lib/core/` - app-wide theme, services, providers, config, domain contracts, and backend boundaries.
- `mobile/lib/core/data/` - durable offline stores (`KeyValueStore`, local progress repository, offline sync queue).
- `mobile/lib/core/providers/` - Riverpod composition root wiring repositories and app state.
- `mobile/lib/core/theme/` - the design system: colour, typography, spacing, and motion tokens (see below).
- `mobile/lib/features/` - feature-owned presentation and business logic.
- `mobile/lib/l10n/` - English/Urdu ARB files and generated localization classes.
- `mobile/lib/shared/widgets/` - the shared component library.
- `mobile/assets/icon/` - generated launcher, adaptive, and splash art.
- `mobile/assets/fonts/` - bundled type: Lexend and Noto Nastaliq Urdu, both SIL OFL, with licences.
- `mobile/assets/audio/` - the three generated ambient loops.
- `mobile/lib/core/data/firebase/` - Firestore adapters, paths, codec, and sync backend.
- `mobile/test/goldens/` - 16 committed golden images for the design system.
- `mobile/tool/make_icon.py` - regenerates the icon art from the mascot geometry.
- `mobile/tool/make_ambient_audio.py` - regenerates the ambient loops.
- `docs/diagrams/` - source architecture and product diagrams.
- `tools/urdu_tts_probe/` - throwaway physical-device Urdu TTS verification app.

## Flutter layers

Each feature keeps UI in `presentation/`, feature models and rules in `domain/` or `logic/`, and persistence behind `data/` repositories. Screens do not call Firebase, camera, image picker, or AI inference directly.

`AppState` provides the state boundary consumed by screens; Riverpod providers in `core/providers/app_providers.dart` are the composition root that builds it from the key-value store, TTS service, and repositories. Tests inject in-memory implementations directly through constructors.

---

## Design system

The theme is a token system in `lib/core/theme/`, not a single file. Screens consume tokens; they never hard-code a colour, a gap, or a duration.

| File | Owns |
|---|---|
| `app_colors.dart` | `AppPalette` — surfaces, six module accents, the AAC word-class palette, success/attention. Registered as a `ThemeExtension`, read via `context.palette`. |
| `app_typography.dart` | Two type scales (child and caregiver) plus the Urdu metrics, and the `ChildTextScale` wrapper. |
| `app_spacing.dart` | `AppSpacing`, `AppRadius`, `AppTouch`, `AppElevation`. |
| `app_motion.dart` | Durations, curves, and `AppMotion.resolve` — the single gate every animation passes through. |
| `app_theme.dart` | Assembles `ThemeData` for `light()` and `dark()`, each in normal and sensory mode. |

### Two UI tiers

The app is deliberately two products in one shell.

**Child tier** — home, AAC, emotion practice, routines, gamification, stories, learning, calm. Large type (20 dp body floor), 64 dp touch targets, illustration-led, at most about six interactive elements per viewport, one dominant action in a fixed position. Wrapped in `ChildTextScale`.

**Caregiver tier** — dashboard, settings, routine editor, custom-card editor, support-level picker, parent gate. Standard Material 3 density, 16 dp body floor, 56 dp targets, real data density.

The size difference is itself a signal: a caregiver glancing at the device can tell which mode it is in without reading a word.

### Rules the system enforces

- **Colour is never the only channel.** Every accent is paired with an icon, a border, and a label. Earned vs. locked badges, done vs. pending routine steps, and selected vs. unselected states all differ by at least two of {fill, border, icon, scale}.
- **Module accents do the wayfinding.** Communicate = teal, Emotions = apricot, Routine = indigo, Learning = violet, Sensory = sage, Progress = ochre. A child learns "the green tile is my routine" before they can read the word, so each module keeps its colour on every surface it owns.
- **The AAC board uses the Fitzgerald key.** Word-class colour coding (carrier / people / verbs / descriptors / nouns / needs) is an established AAC convention that speeds visual scanning and teaches sentence structure implicitly. It is drawn as a top band plus a border so the symbol keeps a light ground.
- **Sensory mode is measurable, not cosmetic.** It desaturates every accent by 40%, flattens all elevation to zero and substitutes a hairline outline, softens the ground, removes splash, and collapses transform motion to zero. `test/design_system_test.dart` asserts each of these.
- **Reduced motion honours the OS too.** `AppMotion.resolve` returns `Duration.zero` for either sensory mode or `MediaQuery.disableAnimations`, so a device already configured for reduced motion gets it here without a caregiver finding the toggle.
- **Ambient motion is opt-in.** The mascot does not breathe by default: in an app for sensory-sensitive children, something moving perpetually in the corner is a cost, not a delight.
- **No flashing, strobing, or luminance change above 3 Hz** anywhere, ever.
- **Errorless framing.** A wrong answer gets a calm redirect, never a red X, a buzzer, or a penalty. Red is reserved for caregiver-facing danger.
- **Every semantic colour pair is contrast-tested.** `theme_contrast_test.dart` covers the Material scheme; `design_system_test.dart` covers every accent and tint across light/dark × normal/sensory at 4.5:1.

### Artwork is drawn in code

`EmotionFace` and `Mascot` are parameterised `CustomPainter`s rather than bitmaps. This buys four things the project actually needs: zero asset weight for an offline-first build, automatic recolouring with the theme, expressions that *tween* between one another instead of cutting, and artwork that is assertable in a unit test. `EmotionFace` serves as both the Module 3 emotion stimulus and the Module 2 role-play character, so the child meets one consistent face throughout.

The launcher icon and splash are generated from the same mascot geometry by `mobile/tool/make_icon.py`, so the home-screen icon is the character inside the app.

---

## Current feature folders

- `authentication` - parent sign-in screen and child-profile session boundary.
- `communication` - AAC board, sentence strip with reorder, bilingual realiser, TTS actions, and caregiver-authored custom cards.
- `emotion_recognition` - six-emotion activity engine, adaptive levels, and the camera expression-practice pipeline.
- `routines` - per-day routine completion, editor, countdowns, and flexibility training.
- `parent_dashboard` - data-backed weekly aggregation, emotion trend, and caregiver observation logging.
- `gamification` - stars, badges, streaks, and the progress ring.
- `sensory_support` - sensory mode, screen brightness, breathing, and calming activities.
- `social_communication` - authored stories, comprehension checks, scripted conversation practice, role-play.
- `learning` - interest profile, deterministic interest→topic mapping, themed activities.
- `progress` - progress models and repository contracts.
- `settings` - language, sensory mode, support level, profiles, parent lock, privacy, sign-out.
- `ai` - replaceable AI engine and expression-practice contracts.
- `home` - app shell and navigation.
- `onboarding` - first-run profile creation.

## Data flow

`Presentation -> state/controller -> use case/service -> repository -> data source/API client`

Local persistence runs through `KeyValueStore` (shared_preferences) so everything works offline. Firebase Authentication, Firestore, Storage, OS-level local notifications, and ML Kit remain integration adapters to be added behind the existing contracts; the offline sync queue already implements last-write-wins drain semantics for the future Firestore adapter.

---

## Dependency justification

The project adds a dependency only when nothing already present can do the job, and every one is written down here.

### Runtime

| Package | Why it is needed |
|---|---|
| `flutter_riverpod` | Composition root and provider boundaries; nothing in Flutter core supplies scoped dependency injection with test overrides. |
| `flutter_tts` | Platform text-to-speech in English and Urdu. The AAC board's entire purpose depends on it. |
| `shared_preferences` | The durable key-value store behind every offline repository. |
| `crypto` | SHA-256 hashing for the caregiver PIN. Nothing in the existing set provides secure hashing. |
| `image_picker` | Caregiver custom cards need a photo of the child's own object or person. Used only behind `ImageSourceService`, never called from a screen. |
| `path_provider` | Custom-card images are copied into the app documents directory so they survive restarts and stay offline-first. Only the platform can report that directory. |
| `audioplayers` | Plays the bundled calming loops. Nothing else in the set reaches the platform audio output, and the gentle-sound option was a silent no-op without it. Used only behind `AmbientSoundService`. |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Module 11. All three sit behind the existing repository interfaces and are constructed **only** when credentials are present, so the app stays fully runnable without them. |

### Build-time only (never shipped in the app)

| Package | Why it is needed |
|---|---|
| `flutter_launcher_icons` | Generates the launcher and adaptive icons from one source image so the Android density buckets cannot drift apart by hand. |
| `flutter_native_splash` | Writes the native splash so the first frame is the app's own calm ground. A white launch flash is exactly the kind of sudden luminance change this app exists to avoid. |
| `fake_cloud_firestore` | An in-memory Firestore so the backend adapters are covered by real tests with no live project, credentials, or emulator. |
| `flutter_lints` | Lint set. |

### Audio

Three ambient loops, generated rather than sourced, because the constraints
are specific: no transients, energy below ~1 kHz, seamless loop seams, and
fades at both file edges. Volume is bounded by `AmbientVolumePolicy` — the
caregiver's preference is a fraction of a ceiling rather than of full
output, so the loudest possible level is capped by construction, and sensory
mode lowers the ceiling again on already-playing audio.

### Backend

Firebase sits entirely behind the existing repository interfaces. Two gates,
deliberately distinct: `AppConfig.firebaseConfigured` says credentials are
present; `FirebaseBootstrap` says Firebase actually initialised. Only the
second switches the app off local repositories. Data is modelled as
`children/{childId}` with a `caregiverIds` array — a child is shared, not
owned — which is what makes per-child therapist assignment possible. See
[FIREBASE-SETUP.md](FIREBASE-SETUP.md).

### Deliberately not added

- **No animation library.** Flutter's implicit animations plus `CustomPainter` cover every motion in the design system, and an external library would make the reduced-motion gate harder to enforce centrally.
- **No UI kit.** Material 3 plus the token system is the design language.
- **No SVG runtime.** Artwork is drawn in code.
- **No runtime font loading.** Fonts are bundled assets; the app is offline-first.
