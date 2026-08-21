# AutiMate Development Checklist

This is the canonical progress tracker. Update the checkbox only when the work is implemented and verified. `P0` is demo-critical, `P1` is the next priority, and `P2` is deferred until the vertical slice is stable.

## Current Snapshot

- Branch: `AI`
- Latest implementation area: P1 expression-practice signal pipeline (busy-flag throttle, EMA alpha 0.3, one-second hold star award) with full UI states, simulated offline source, Firestore Security Rules, and WCAG AA contrast verification
- Static analysis: PASS (`flutter analyze`, no issues)
- Automated tests: PASS, 56 tests (domain logic, TTS contracts, app-shell navigation, AAC, emotion flows, persistence round-trips, offline sync queue, routine completion, weekly aggregation, settings persistence, EN/UR localization incl. RTL, expression engine/screen, theme contrast)
- Android APK/device verification: BLOCKED because no Android SDK/device is available in the current environment
- Urdu offline speech: UNKNOWN until `tools/urdu_tts_probe` runs on physical Android hardware
- Firebase: NOT CONNECTED; mock/local repositories are active behind provider boundaries, an offline last-write-wins sync queue is ready for the future adapter, and deployable Security Rules now exist at `firestore.rules`

## P0 - Demo-Critical

### Foundation

- [x] Repository documentation audited. Evidence: project Markdown, DOCX/PDF documents, diagrams.
- [x] Flutter project created under `mobile/`.
- [x] Feature-based architecture created.
- [x] Theme and shared accessibility widgets created.
- [x] Navigation shell created.
- [x] Mock repository/service boundaries created.
- [x] Riverpod providers adopted at integration boundaries (`core/providers/app_providers.dart`, `ProviderContainer` in `main.dart`) without rewriting domain logic.
- [x] Environment configuration connected through `--dart-define` (`core/config/app_config.dart`, aligned `.env.example`). Safe defaults keep the app fully offline without credentials.
- [x] English/Urdu ARB localization created (`lib/l10n/app_en.arb`, `app_ur.arb`) and hard-coded UI strings removed from every screen.

### D3 Speech and Logic

- [x] `QueuedTtsService` with platform adapter.
- [x] English locale resolution.
- [x] Urdu locale resolution ladder: `ur-PK`, `ur-IN`, `ur`.
- [x] Queue ordering.
- [x] Barge-in and stop behavior.
- [x] Warm initialization before first app frame.
- [x] Sensory-mode rate and volume controls.
- [x] Non-throwing unavailable/error states.
- [ ] Physical English/Urdu speech verification.
- [ ] Offline Urdu verification.
- [ ] Speech-start latency measurement.
- [x] Semantic `CardGrammar` model with `pos`, countability, vowel-sound, and Urdu gender metadata.
- [x] English sentence realiser.
- [x] Urdu SOV sentence realiser with gender agreement.
- [x] Empty and single-card sentence handling.
- [x] Recency-weighted card ranking with top-eight selection.
- [x] Six-emotion activity engine and confusability matrix.
- [x] Beginner/intermediate/advanced choice behavior.
- [x] Session scoring, stars, and result object.
- [x] Adaptive promotion/demotion rules.
- [x] Parent lock and parent override.

### Child Experience Integration

- [x] AAC semantic card grid connected to sentence realiser.
- [x] AAC card tap connected to TTS.
- [x] AAC sentence speak action connected to TTS.
- [x] Emotion screen connected to the activity engine.
- [x] Emotion session completion awards stars in app state.
- [x] Persist AAC usage and emotion results beyond the current widget session through `InMemoryProgressRepository`.
- [x] Durable offline persistence: sessions, card usage, observations, routine completion, language/sensory/stars settings survive restarts (`LocalProgressRepository`, `LocalRoutineRepository`, `KeyValueStore` over `shared_preferences`).
- [x] Routine completion state per calendar day with reset, plus in-app spoken transition warnings while the routine screen is open (`RoutineReminderEngine`).
- [x] Offline persistence for AAC, routines, and progress.
- [ ] Firestore sync drain of the offline queue (blocked on Firebase credentials; queue contract and LWW logic are implemented and tested).

### Verification

- [x] `flutter analyze` passes.
- [x] `flutter test` passes: 56 tests.
- [x] Widget test for AAC sentence interaction.
- [x] Widget test for emotion activity feedback.
- [x] Widget tests for routine completion persistence and caregiver observation logging.
- [x] Localization widget tests verifying Urdu RTL directionality and English LTR.
- [x] Unit/widget tests for the expression-practice pipeline: throttle, EMA, hold/star award, UI states, and star integration.
- [ ] Physical Android smoke test.
- [ ] Airplane-mode demo run.
- [ ] Rapid-tap speech test.

## P1 - Important After P0

### Backend and Caregiver Data

- [ ] Firebase project configuration (blocked on account/credentials; `AppConfig.firebaseConfigured` gate is ready).
- [ ] Firebase Authentication for parent/teacher accounts.
- [ ] Firestore child/profile repositories.
- [x] Firestore Security Rules and role isolation (`firestore.rules`: caregiver-list isolation, append-only progress/observations, deny-by-default; deployment awaits the Firebase project).
- [ ] Firebase Storage for custom card media, only if needed.
- [x] Progress repository and weekly aggregation (`WeeklyProgressAggregator`, tested).
- [x] Parent dashboard backed by recorded data: activity counts, real routine percentage, star total, seven-day chart buckets.
- [x] Manual caregiver observation logging with durable storage surfaced on the dashboard.
- [x] Offline queue and last-write-wins merge semantics (`OfflineSyncQueue`, tested); remote drain awaits Firebase.

### Expression Practice

- [ ] Camera permission flow (needs the camera plugin; permission-denied UI state is implemented).
- [ ] Camera lifecycle and disposal.
- [ ] ML Kit face detection adapter (blocked on physical-device verification by plan).
- [ ] On-device smile probability from ML Kit (the `ExpressionReading.smile` contract and full downstream pipeline exist; only the detector source is missing).
- [x] Optional eye-open/head-angle readings carried in `ExpressionReading` for future use.
- [x] Busy-flag frame throttling (`FrameThrottle`, tested).
- [x] EMA smoothing around alpha `0.3` (`SmileEmaSmoother`, tested).
- [x] Approximately one-second threshold and star award (`ExpressionSessionEngine`, tested incl. dip/lost-face reset, exact-once award, session completion).
- [x] Unsupported-device, denied-permission, loading, and error states in `ExpressionPracticeScreen` plus a simulated offline demo source so the flow runs today without hardware.
- [x] Privacy test confirming no frame persistence or upload: engine keeps aggregates only, no storage API is reachable from the pipeline, and the privacy note is surfaced in-app.

### Localization and Accessibility

- [x] Complete English/Urdu localization of all screens (ARB + generated classes).
- [x] Urdu RTL audit on every screen (Material locale-driven directionality; widget-tested RTL/LTR).
- [x] Minimum 64 dp child-facing touch targets (AAC speak button, emotion choice buttons, auth sign-in, expression practice actions).
- [x] WCAG AA contrast review of core color pairs in both sensory modes, verified programmatically (`theme_contrast_test.dart` enforces 4.5:1 text and 3:1 UI-component ratios); physical-device spot check still pending.
- [ ] Screen-reader semantics review with TalkBack/VoiceOver.
- [x] Sensory-mode audit hooks: reduced motion transitions, flat cards, softer TTS rate/volume (device listening pass still pending).

## P2 - Deferred Scope

- [ ] Social stories with authored content.
- [ ] Fixed-branch conversation practice.
- [ ] 2D role-play.
- [ ] Interest profile and authored learning path.
- [ ] Flexibility training.
- [ ] Custom AAC cards from gallery/camera.
- [ ] OS-level local notifications and scheduled reminders (in-app spoken warnings shipped first).
- [ ] Badges, streaks, and progress rings beyond stars.
- [ ] Speech-to-text evaluation, only if the P0/P1 schedule permits.

## Production and Release

- [ ] Android SDK configured.
- [ ] Debug APK builds successfully.
- [ ] Release signing configuration.
- [ ] Android release build.
- [ ] iOS best-effort build.
- [ ] Crash handling and logging.
- [ ] Security/privacy review.
- [ ] Unit, widget, and integration test coverage review.
- [ ] Two complete demo rehearsals on the actual device.
- [ ] Final technical documentation and demo script.

## Evidence and Detailed Status

- D3 implementation details: `docs/D3_IMPLEMENTATION_STATUS.md`
- D3 execution checklist: `docs/D3_EXECUTION_CHECKLIST.md`
- Architecture: `PROJECT-STRUCTURE.md`
- AI integration: `AI-INTEGRATION.md`
- Roadmap: `DEVELOPMENT-ROADMAP.md`
- TTS hardware probe: `tools/urdu_tts_probe/README.md`

## Next Actions

1. Install the Android SDK/toolchain and run `flutter build apk --debug`, then the AAC rapid-tap and airplane-mode checks on the demo device.
2. Run the Urdu TTS probe online and offline on physical hardware; record results here.
3. Create the Firebase project, inject credentials via `--dart-define` (see `.env.example`), then implement the Firestore adapter that drains `OfflineSyncQueue`.
4. Run TalkBack/VoiceOver and WCAG contrast passes once device access exists.
5. Only after the device gate passes, attempt ML Kit expression practice.
