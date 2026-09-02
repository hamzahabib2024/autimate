# AutiMate

AutiMate is an offline-first Flutter support tool for autistic children and their caregivers. It supports communication, emotion learning, predictable routines, sensory regulation, and explainable progress tracking. It is not a diagnostic, screening, or treatment application.

## Current status

The `mobile/` directory contains the runnable application. All child and
caregiver flows work offline:

- **Communication (AAC)** — bilingual sentence realisation, platform TTS,
  Fitzgerald-key colour coding, drag-to-reorder sentence strip, and
  caregiver-authored custom cards with photos from the gallery or camera.
- **Emotion practice** — six emotions drawn in code as a parameterised face
  painter, adaptive levels, stars, and session recording.
- **Routines** — visual timeline, editor, spoken transition warnings,
  countdowns, and flexibility training.
- **Social stories and conversation practice** — authored, bilingual, fixed
  branching; no generative chat.
- **Interest-based learning** — deterministic, explainable interest→topic
  mapping.
- **Sensory support** — sensory mode, dark theme, guided breathing, calming
  patterns.
- **Caregiver dashboard** — weekly aggregation, emotion accuracy trend, and
  observation logging, all from recorded data.
- **Gamification** — stars, badges, streaks, and a progress ring, framed
  cooperatively with no leaderboard anywhere.
- **Ambient sound** — three generated calming loops with a volume ceiling
  that sensory mode lowers further; nothing autoplays, everything fades.
- **Design system** — colour, typography, spacing, and motion tokens with a
  deliberate child/caregiver two-tier split. See the design-system section of
  [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md).

Verified: `flutter analyze` clean, **245 tests passing**, 82.8% line coverage.

The **Firebase backend is built and tested** — auth, Firestore adapters, and
the sync drain — and needs only credentials to switch on. See
[FIREBASE-SETUP.md](FIREBASE-SETUP.md). With no credentials the app runs
fully offline against local repositories, which is the default and the
demo mode.

Remaining work and its blockers are tracked honestly in
[PROJECT-CHECKLIST-V2.md](PROJECT-CHECKLIST-V2.md), with a coverage gap
review in [COVERAGE-REVIEW.md](COVERAGE-REVIEW.md) and a self-review in
[SECURITY-PRIVACY-REVIEW.md](SECURITY-PRIVACY-REVIEW.md).

## Run the app

```powershell
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

Android is the primary target; iOS is best-effort. The separate `tools/urdu_tts_probe` app is retained for verifying offline Urdu voice availability on a physical Android device.

### Regenerating assets

```powershell
cd mobile
python tool/make_icon.py            # launcher icon + splash from the mascot
dart run flutter_launcher_icons
dart run flutter_native_splash:create
python tool/make_ambient_audio.py   # the three calming loops
```

### Golden tests

```powershell
flutter test --update-goldens test/golden_design_test.dart
```

Regenerate deliberately and read the diff — a golden that changes without
anyone intending it is the point of the file.

## Architecture

The app uses feature-based Flutter organization with presentation, state, domain contracts, and data adapters kept separate. See [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) (including the design system and the dependency justification list), [FIREBASE-SETUP.md](FIREBASE-SETUP.md), [AI-INTEGRATION.md](AI-INTEGRATION.md), and [DEVELOPMENT-ROADMAP.md](DEVELOPMENT-ROADMAP.md). [DEMO-SCRIPT.md](DEMO-SCRIPT.md) walks the app against objectives O1–O8; [DEMO-VIDEO-SCRIPT.md](DEMO-VIDEO-SCRIPT.md) is the three-minute recorded cut.

## Configuration

Copy `.env.example` to the environment used by the team when backend integration begins. Values are injected at build time, for example:

```powershell
flutter run --dart-define=AUTIMATE_FIREBASE_PROJECT_ID=your-project
```

Secrets and Firebase configuration must stay outside source control. With no values supplied the app runs fully offline against local repositories.

## Scope guardrails

- No open-ended child-facing generative chat.
- No clinical or behavioural diagnosis claims.
- Camera frames for expression practice remain on-device and are discarded.
- Custom-card photos are stored in app-private storage and never uploaded.
- No flashing, strobing, or luminance change above 3 Hz anywhere.
- No competitive or ranked gamification.
- Child-facing P0 features must work offline and support English/Urdu with RTL.
