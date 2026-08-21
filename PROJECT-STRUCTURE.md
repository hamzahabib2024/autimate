# Project Structure

## Repository layout

- `mobile/` - Android/iOS Flutter application.
- `mobile/lib/core/` - app-wide theme, services, domain contracts, and backend boundaries.
- `mobile/lib/features/` - feature-owned presentation and future business logic.
- `mobile/lib/shared/` - reusable accessible widgets.
- `docs/diagrams/` - source architecture and product diagrams.
- `tools/urdu_tts_probe/` - throwaway physical-device Urdu TTS verification app.

## Flutter layers

Each feature keeps UI in `presentation/`, feature models and rules in `domain/` or `logic/`, and persistence behind `data/` repositories. Screens do not call Firebase, camera, or AI inference directly.

`AppState` currently provides the smallest state boundary needed for the skeleton. The documented team standard is Riverpod; it can replace this bootstrap state object when the shared dependency setup begins.

## Current feature folders

- `authentication` - parent sign-in placeholder and child-profile session boundary.
- `communication` - AAC card grid, sentence strip, and TTS action placeholder.
- `emotion_recognition` - six-emotion activity placeholder and P1 camera placeholder.
- `routines` - visual daily schedule placeholder.
- `parent_dashboard` - explainable progress metrics and chart placeholder.
- `settings` - language, RTL, sensory mode, support level, privacy, and sign-out.
- `ai` - replaceable AI engine and expression-practice contracts.
- `home` - app shell, navigation, feature overview, and designed-but-not-built placeholders.

Social communication, interest-based learning, flexibility training, gamification, notifications, and custom AAC content are represented in the home/settings placeholders and roadmap, but are not falsely presented as complete sprint features.

## Data flow

`Presentation -> state/controller -> use case/service -> repository -> data source/API client`

The current repository implementations are mocks. Firebase Authentication, Firestore, Storage, local notifications, platform TTS, camera, and ML Kit are integration adapters to be added behind the existing contracts.
