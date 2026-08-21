# AutiMate

AutiMate is an offline-first Flutter support tool for autistic children and their caregivers. It supports communication, emotion learning, predictable routines, sensory regulation, and explainable progress tracking. It is not a diagnostic, screening, or treatment application.

## Current status

The `mobile/` directory contains the runnable application skeleton and P0 dummy flows. It currently uses mock repositories so the app can run without Firebase credentials. The full product scope and the six-day vertical-slice sprint are documented in the existing planning files.

## Run the app

```powershell
cd mobile
flutter pub get
flutter analyze
flutter test
flutter run
```

Android is the primary target; iOS is best-effort. The separate `tools/urdu_tts_probe` app is retained for verifying offline Urdu voice availability on a physical Android device.

## Architecture

The app uses feature-based Flutter organization with presentation, state, domain contracts, and data adapters kept separate. See [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md), [AI-INTEGRATION.md](AI-INTEGRATION.md), and [DEVELOPMENT-ROADMAP.md](DEVELOPMENT-ROADMAP.md).

## Configuration

Copy `.env.example` to the environment used by the team when backend integration begins. Secrets and Firebase configuration must stay outside source control. No credentials are required for the current mock-first skeleton.

## Scope guardrails

- No open-ended child-facing generative chat.
- No clinical or behavioural diagnosis claims.
- Camera frames for future expression practice remain on-device and are discarded.
- Child-facing P0 features must work offline and support English/Urdu with RTL.
