# Project Structure

## Repository layout

- `mobile/` - Android/iOS Flutter application.
- `mobile/lib/core/` - app-wide theme, services, providers, config, domain contracts, and backend boundaries.
- `mobile/lib/core/data/` - durable offline stores (`KeyValueStore`, local progress repository, offline sync queue).
- `mobile/lib/core/providers/` - Riverpod composition root wiring repositories and app state.
- `mobile/lib/features/` - feature-owned presentation and future business logic.
- `mobile/lib/l10n/` - English/Urdu ARB files and generated localization classes.
- `mobile/lib/shared/` - reusable accessible widgets.
- `docs/diagrams/` - source architecture and product diagrams.
- `tools/urdu_tts_probe/` - throwaway physical-device Urdu TTS verification app.

## Flutter layers

Each feature keeps UI in `presentation/`, feature models and rules in `domain/` or `logic/`, and persistence behind `data/` repositories. Screens do not call Firebase, camera, or AI inference directly.

`AppState` provides the state boundary consumed by screens; Riverpod providers in `core/providers/app_providers.dart` are the composition root that builds it from the key-value store, TTS service, and repositories. Tests inject in-memory implementations directly through constructors.

## Current feature folders

- `authentication` - parent sign-in screen and child-profile session boundary.
- `communication` - AAC card grid, sentence strip, bilingual realiser, and TTS actions.
- `emotion_recognition` - six-emotion activity engine, adaptive levels, and P1 camera placeholder.
- `routines` - per-day routine completion with spoken transition warnings.
- `parent_dashboard` - data-backed weekly aggregation and caregiver observation logging.
- `gamification` - star total surface connected to recorded sessions.
- `sensory_support` - quick sensory-mode controls.
- `progress` - progress models and repository contracts with local/Firestore implementations.
- `settings` - language, RTL, sensory mode, support level, privacy, and sign-out (persisted).
- `ai` - replaceable AI engine and expression-practice contracts.
- `home` - app shell, navigation, feature overview, and designed-but-not-built placeholders.

Social communication, interest-based learning, flexibility training, notifications, and custom AAC content are represented in the home/settings placeholders and roadmap, but are not falsely presented as complete sprint features.

## Data flow

`Presentation -> state/controller -> use case/service -> repository -> data source/API client`

Local persistence runs through `KeyValueStore` (shared_preferences) so everything works offline. Firebase Authentication, Firestore, Storage, OS-level local notifications, camera, and ML Kit remain integration adapters to be added behind the existing contracts; the offline sync queue already implements last-write-wins drain semantics for the future Firestore adapter.
