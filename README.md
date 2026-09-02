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
- **Design system** — colour, typography, spacing, and motion tokens with a
  deliberate child/caregiver two-tier split. See the design-system section of
  [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md).

Verified: `flutter analyze` clean, **184 tests passing**.

Firebase is not connected; mock/local repositories run behind provider
boundaries and an offline last-write-wins sync queue is ready for the future
Firestore adapter. Remaining work and its blockers are tracked honestly in
[PROJECT-CHECKLIST-V2.md](PROJECT-CHECKLIST-V2.md).

## Run the app

```powershell
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

Android is the primary target; iOS is best-effort. The separate `tools/urdu_tts_probe` app is retained for verifying offline Urdu voice availability on a physical Android device.

### Fonts

The design system is written against Lexend (Latin) and Noto Nastaliq Urdu.
Neither binary is committed — see [mobile/assets/fonts/README.md](mobile/assets/fonts/README.md)
for the two-minute activation. Until then the app renders in the platform
default, which is deliberate: Flutter fails the build on a declared font
asset whose file is missing.

### Regenerating the app icon

```powershell
cd mobile
python tool/make_icon.py
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

## Architecture

The app uses feature-based Flutter organization with presentation, state, domain contracts, and data adapters kept separate. See [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) (including the design system and the dependency justification list), [AI-INTEGRATION.md](AI-INTEGRATION.md), and [DEVELOPMENT-ROADMAP.md](DEVELOPMENT-ROADMAP.md). [DEMO-SCRIPT.md](DEMO-SCRIPT.md) walks the app against objectives O1–O8.

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
