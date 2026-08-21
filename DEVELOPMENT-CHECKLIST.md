# AutiMate Development Checklist

This is the canonical progress tracker. Update the checkbox only when the work is implemented and verified. `P0` is demo-critical, `P1` is the next priority, and `P2` is deferred until the vertical slice is stable.

## Current Snapshot

- Branch: `AI`
- Latest implementation area: D3 speech, AAC logic, emotion engine, and adaptive controller
- Static analysis: PASS
- Automated tests: PASS, 19 tests
- Android APK/device verification: BLOCKED because no Android SDK/device is available in the current environment
- Urdu offline speech: UNKNOWN until `tools/urdu_tts_probe` runs on physical Android hardware
- Firebase: NOT CONNECTED; mock repositories are active

## P0 - Demo-Critical

### Foundation

- [x] Repository documentation audited. Evidence: project Markdown, DOCX/PDF documents, diagrams.
- [x] Flutter project created under `mobile/`.
- [x] Feature-based architecture created.
- [x] Theme and shared accessibility widgets created.
- [x] Navigation shell created.
- [x] Mock repository/service boundaries created.
- [ ] Riverpod providers adopted. Next: add providers at integration boundaries without rewriting domain logic.
- [ ] Environment configuration connected. File exists: `.env.example`.
- [ ] English/Urdu ARB localization created and hard-coded UI strings removed.

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
- [ ] Durable offline persistence and Firestore sync.
- [ ] Routine completion state and local reminders.
- [ ] Offline persistence for AAC, routines, and progress.

### Verification

- [x] `flutter analyze` passes.
- [x] `flutter test` passes: 19 tests.
- [x] Widget test for AAC sentence interaction.
- [x] Widget test for emotion activity feedback.
- [ ] Physical Android smoke test.
- [ ] Airplane-mode demo run.
- [ ] Rapid-tap speech test.

## P1 - Important After P0

### Backend and Caregiver Data

- [ ] Firebase project configuration.
- [ ] Firebase Authentication for parent/teacher accounts.
- [ ] Firestore child/profile repositories.
- [ ] Firestore Security Rules and role isolation.
- [ ] Firebase Storage for custom card media, only if needed.
- [ ] Progress repository and weekly aggregation.
- [ ] Parent dashboard backed by recorded data.
- [ ] Manual caregiver observation logging.
- [ ] Offline queue and last-write-wins sync.

### Expression Practice

- [ ] Camera permission flow.
- [ ] Camera lifecycle and disposal.
- [ ] ML Kit face detection adapter.
- [ ] On-device smile probability.
- [ ] Optional eye-open/head-angle readings.
- [ ] Busy-flag frame throttling.
- [ ] EMA smoothing around alpha `0.3`.
- [ ] Approximately one-second threshold and star award.
- [ ] Unsupported-device, denied-permission, loading, and error states.
- [ ] Privacy test confirming no frame persistence or upload.

### Localization and Accessibility

- [ ] Complete English/Urdu localization.
- [ ] Urdu RTL audit on every screen.
- [ ] Minimum 64 dp child-facing touch targets.
- [ ] WCAG AA contrast review.
- [ ] Screen-reader semantics review.
- [ ] Sensory-mode audit for motion, sound, contrast, and clutter.

## P2 - Deferred Scope

- [ ] Social stories with authored content.
- [ ] Fixed-branch conversation practice.
- [ ] 2D role-play.
- [ ] Interest profile and authored learning path.
- [ ] Flexibility training.
- [ ] Custom AAC cards from gallery/camera.
- [ ] Local notifications and transition warnings.
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

1. Run the Urdu TTS probe on the physical Android demo device, online and offline.
2. Configure Android SDK/device access and run the AAC flow with rapid taps.
3. Add widget tests for AAC and emotion screens.
4. Connect Riverpod providers and real persistence only after the device gate is known.
5. Attempt ML Kit expression practice only after P0 physical verification passes.
