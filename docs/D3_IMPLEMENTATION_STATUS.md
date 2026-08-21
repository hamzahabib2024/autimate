# D3 AI Track Implementation Status

Audited after commit `6e580c8` on branch `AI`. This status reflects code currently present, not planned interfaces.

## Build Status

- flutter analyze: PASS (no issues).
- flutter test: PASS (43 tests: domain logic, TTS contracts, app-shell navigation, AAC, emotion flows, progress persistence round-trips, offline sync queue, routine completion, weekly aggregation, settings persistence, and EN/UR localization incl. RTL).
- flutter run/build: `flutter build apk --debug` blocked because no Android SDK is configured in this environment.
- Android physical device status: NOT VERIFIED; the Urdu probe remains available under `tools/urdu_tts_probe`.

## TTS

- [x] TtsService: `QueuedTtsService` and `FlutterTtsPlatformClient` exist in `mobile/lib/core/services/tts_service.dart`.
- [x] English: locale ladder includes `en-US`, `en-GB`, and `en`.
- [x] Urdu: locale ladder includes `ur-PK`, `ur-IN`, and `ur`; device output is unverified.
- [ ] Offline verification: requires physical Android device and probe result.
- [x] Queue
- [x] Barge-in
- [x] Warm start: initialization is awaited before `runApp`.
- [x] Sensory mode
- [x] Error handling
- [ ] Latency measurement

## Sentence Realisation

- [x] Shared card structure: `CardGrammar` includes the documented metadata.
- [x] English realiser
- [x] Urdu realiser
- [x] Gender agreement
- [x] Article handling
- [x] POS handling
- [x] Empty strip
- [x] Tests

## Card Ranking

- [x] Usage tracking: AAC records card events for the current session.
- [x] Recency decay
- [x] Ranking
- [x] Top-eight selection
- [x] Tests

## Emotion Engine

- [x] Six emotions
- [x] Confusability matrix
- [x] Beginner
- [x] Intermediate
- [x] Advanced
- [x] Distractor generation
- [x] Scoring
- [x] Session summary
- [x] Tests

## Adaptive Controller

- [x] Three levels
- [x] Promotion
- [x] Demotion
- [x] Parent override
- [x] Parent lock
- [x] Between-session evaluation contract
- [x] Tests

## Expression Practice

- [ ] Camera
- [ ] ML Kit
- [ ] Smile probability
- [ ] Eye-open probability if required
- [ ] Frame throttling
- [ ] EMA smoothing
- [ ] One-second threshold
- [ ] Star award
- [x] Privacy contract: camera implementation is still absent; future adapter must remain local-only.
- [ ] Disposal
- [ ] Tests

## Integration

- [x] AAC integration: semantic cards, realiser, usage ranking, and TTS action are connected.
- [x] Emotion integration: screen uses the deterministic engine and produces a session result.
- [x] Adaptive integration: session engine consumes the controller with lock and override support.
- [ ] Firestore integration: mock backend contracts only; in-memory repository is active.
- [x] UI integration: shell, AAC, emotion, and dashboard progress wiring exist.
- [ ] Offline verification

## Remaining Work

1. Replace the in-memory progress repository with durable offline storage/Firebase adapters.
2. Verify TTS locale availability, Urdu output, offline speech, rapid taps, and latency on physical Android hardware.
3. Add Firebase/Firestore adapters after credentials and rules are available.
4. Add Riverpod providers at the integration boundary without rewriting tested domain logic.
5. Attempt ML Kit expression practice only after P0 is stable and Android tooling/device access exists.

## Blockers

- No Android SDK is configured in the current environment, so APK/device validation cannot run here.
- Urdu voice availability is unknown until the physical-device probe is run.
- Firebase credentials/configuration do not exist in the repository; Firestore remains mock-only.

## Recommended Execution Order

P0 sentence realiser -> card ranker -> emotion engine -> adaptive controller -> unit tests -> platform TTS -> AAC integration -> emotion integration -> physical-device/offline verification -> P1 ML Kit expression practice.
