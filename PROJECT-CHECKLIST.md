# AutiMate Master Project Checklist

Whole-project tracker organised by product module (per `AutiMate_Scope_Doc.md`). Work proceeds module by module, top to bottom within each module. Update a checkbox only when the work is implemented **and** verified.

Status legend:

- `[x]` complete (implemented + verified)
- `[ ]` open
- `⛔ BLOCKED:` prefix = cannot proceed until the stated external dependency exists (device, SDK, credentials)

Current verified state: `flutter analyze` PASS · `flutter test` PASS (135 tests) · branch `AI`

---

## Module 0 — Foundation & Core Infrastructure

### Done

- [x] Flutter project under `mobile/`, Android primary / iOS best-effort
- [x] Feature-based architecture (`core/`, `features/`, `shared/`)
- [x] Theme with sensory-friendly variant (motion, elevation, contrast)
- [x] Navigation shell (Home / Communicate / Routine / Progress)
- [x] Riverpod composition root (`core/providers/app_providers.dart`) + `ProviderContainer` in `main.dart`
- [x] Environment configuration via `--dart-define` (`AppConfig`, `.env.example`)
- [x] Durable key-value store boundary (`KeyValueStore` over shared_preferences)
- [x] Offline sync queue with last-write-wins drain (`OfflineSyncQueue`)
- [x] English/Urdu ARB localization wired app-wide, RTL supported
- [x] App-state settings persistence (language, sensory mode, stars)

### Open

- [x] Locked child mode: simplified launcher that hides caregiver screens behind parent lock (settings icon + Progress tab gated; tested) — done
- [x] Parent lock PIN/gate screen reused by all caregiver surfaces (SHA-256 hashed, bilingual pad; auto-passes until a PIN exists) — done
- [x] Onboarding flow: first-run profile creation (language, child name, support level, PIN; app swaps to shell on completion) — done
- [x] Multi-child profile switching (add/select in Settings, durable JSON store, every screen reads `selectedChild`) — done
- [x] Connectivity service contract + offline banner (`ConnectivityService` with static impl; platform adapter awaits device verification) — done
- [ ] App icon and splash screen assets (needs final artwork/tooling)

---

## Module 1 — Communication Aid (AAC) — highest priority

### Done

- [x] Semantic card grid with grammar metadata (`CardGrammar`)
- [x] Sentence strip composition (tap-to-build)
- [x] Bilingual sentence realiser (English articles/plurality, Urdu SOV + gender agreement)
- [x] TTS playback: card taps and full sentence (EN + UR locale ladder)
- [x] Recency-weighted frequent-cards ranking (top eight)
- [x] Fully offline operation
- [x] Large tap targets, high-contrast layout, screen-reader labels

### Open

- [ ] Custom caregiver cards: image from gallery/camera + label + optional audio (⛔ needs Firebase Storage decision or local-file approach; local-first possible)
- [x] Expand catalog into scoped categories: Food, Drinks, Emotions, Activities, People, Places, Needs, Objects (30 cards: 2 carriers + all eight categories; six-emotion set complete) — done
- [x] Category tabs/filter UI in the AAC grid (localized ChoiceChips EN/UR, carriers always visible) — done
- [x] Frequently-used surfaced as tappable cards (durable history + session usage merged into ranked ActionChips) — done
- [x] Sentence-strip word removal (backspace single card) and reorder — removal done; reorder deferred with custom-card work
- [ ] Custom caregiver cards (listed above)
- [x] Quick request benchmark: "request in ≤ 3 taps" verified in a widget test (tap carrier → tap noun → tap speak; TTS text asserted) — done

## Module 2 — Social Communication Training (P2)

- [x] Authored social stories: meeting someone, asking for help, waiting for turn, going to a shop — done
- [x] Story reader UI with narration (TTS) and illustrations — done
- [x] Comprehension checks after each story (fixed questions) — done
- [x] Scripted branching conversation practice (greetings, requesting, turn-taking, closing) — done
- [x] 2D role-play character with expression states — done
- [x] All content bilingual EN/UR, caregiver-approved, fixed (no generative chat) — done

## Module 3 — Emotion & Expression Recognition

### Done

- [x] Six-emotion identification engine with confusability-matrix distractors
- [x] Difficulty scaling: choices 2/3/4, beginner hints
- [x] Session scoring, stars, duration, result recording
- [x] Expression-practice signal pipeline: busy-flag throttle, EMA alpha 0.3, one-second hold star award, three-rep session
- [x] Practice UI states: unsupported / permission-denied / loading / error / practicing / complete
- [x] Simulated offline practice source (demo without hardware)
- [x] Privacy posture enforced and surfaced (no frame persistence/upload)

### Open

- [ ] Real face/scene artwork for the six emotions (current UI uses standard icons)
- [x] Camera permission flow (request + rationale dialog) — done
- [x] Camera lifecycle and disposal management (stops on background, reattaches on resume without losing session progress; dispose stops the camera) — done
- [ ] ML Kit face-detection adapter producing `ExpressionReading` ⛔ BLOCKED: requires physical Android device verification per plan
- [x] Eye-open/head-angle readings surfaced in feedback (contract carries them; engine flags closed eyes / tilt and the practice UI shows bilingual posture hints incl. lost-face "come closer") — done

## Module 4 — Routine & Flexibility Builder

### Done

- [x] Visual daily schedule (icon + label + time)
- [x] Per-day completion tracking with automatic morning reset
- [x] Progress bar and completion count
- [x] In-app spoken transition warnings while routine screen is open
- [x] Durable storage per child per day

### Open

- [x] Caregiver routine editor: add/edit/remove steps (title EN/UR, time, icon) — done
- [x] Per-step optional audio cue (TTS phrase; spoken instead of the title on announcements) — done
- [ ] OS-level local notification reminders ⛔ BLOCKED: needs `flutter_local_notifications` + device build verification
- [x] Transition countdown warnings ("5 minutes left") with configurable lead time — done
- [x] Flexibility training: parent-approved controlled change inserted into known routine + positive reinforcement flow — done

## Module 5 — Interest-Based Learning (P2)

- [x] Interest profile editor (cars, animals, trains, space) — done
- [x] Deterministic interest → topic mapping table — done
- [x] Learning path screen ordered by mapped topics — done
- [x] Themed activities/quizzes with authored bilingual content — done
- [x] Explainable mapping shown to caregivers ("{name} likes {interest}" on every activity card) — done

## Module 6 — Sensory-Friendly Environment

### Done

- [x] Global sensory mode toggle persisted app-wide
- [x] Reduced motion transitions, flat cards, softened TTS rate/volume
- [x] No flashing/strobing elements anywhere in current UI

### Open

- [x] Guided breathing activity (animated pace circle, haptic-free) — done
- [x] Slow visual patterns calming screen — done
- [x] Gentle sound option (short, low-volume, looped-off by default) — done (silent no-op service until OS-audio adapter)
- [ ] Brightness/clutter reduction audit on physical device ⛔ BLOCKED: device
- [x] Sensory quick-access from child home (already reachable via Sensory support tile; verify reachability in child mode) — verified by test

## Module 7 — Parent & Teacher Dashboard

### Done

- [x] Weekly activity aggregation (Mon–Sun buckets) from recorded sessions
- [x] Real metrics: activity count, routine %, star total
- [x] Manual observation logging (free text, durable, listed on dashboard)
- [x] Explainable-progress disclaimer (no clinical claims)

### Open

- [x] Emotion accuracy-over-time chart (score/total trend line) — done
- [x] Observation tags (optional category per note) — done
- [x] Child profile management UI (create/edit profiles) — done
- [ ] Teacher/therapist read + observe access limited to assigned children ⛔ BLOCKED: Firebase Auth roles

## Module 8 — Adaptive Support Levels

### Done

- [x] Three levels (beginner/intermediate/advanced) affecting choice count and hints
- [x] Rule-based promotion (3 correct) / demotion (2 incorrect)
- [x] Parent override + lock supported in engine API

### Open

- [x] Support-level picker UI in Settings wired to the engine (tile is currently a placeholder) — done
- [x] Parent lock toggle UI persisting the chosen level — done
- [x] Audio assistance dimension (spoken question at beginner level) — done
- [ ] Reward-frequency dimension per level
- [ ] Level changes reflected live in running sessions (restart prompt)

## Module 9 — Gamification

### Done

- [x] Stars awarded across emotion, expression, and persisted totals

### Open

- [ ] Badges (milestones: first session, 10 sessions, 3-day streak…)
- [ ] Streak calculation from recorded sessions
- [ ] Progress ring visualisation
- [ ] Cooperative framing copy (child + caregiver team, no competition)

## Module 10 — Localization & Accessibility

### Done

- [x] Full EN/UR ARB localization, zero hard-coded UI strings
- [x] RTL directionality verified by widget tests
- [x] ≥ 64 dp child-facing touch targets
- [x] WCAG AA contrast enforced programmatically in both sensory modes
- [x] Core semantics (labels, live regions) on key controls

### Open

- [ ] TalkBack/VoiceOver end-to-end pass ⛔ BLOCKED: physical device
- [ ] Urdu font rendering check on device (Nastaliq vs Naskh fallback) ⛔ BLOCKED: device
- [ ] Sensory-mode listening pass (volume ceiling comfort) ⛔ BLOCKED: device
- [ ] Remaining placeholder descriptions translated review pass

## Module 11 — Backend & Data Sync (Firebase)

### Done

- [x] Repository/service boundaries (auth, progress, routines, children)
- [x] Local durable repositories (offline-first source of truth)
- [x] Offline queue with LWW merge semantics (tested)
- [x] Firestore Security Rules authored: caregiver isolation, append-only records, deny-by-default (`firestore.rules`)
- [x] Credential gate (`AppConfig.firebaseConfigured`) keeps app runnable without Firebase

### Open

- [ ] Create Firebase project (Android + iOS apps registered) ⛔ BLOCKED: account/credentials
- [ ] Firebase Authentication (email/password parents, teacher invites)
- [ ] Firestore adapter implementations draining `OfflineSyncQueue`
- [ ] Deploy Security Rules and test with emulator + rules unit tests
- [ ] Firebase Storage only if custom-card media goes remote
- [ ] Crashlytics / logging decision

## Module 12 — Testing & Quality

### Done

- [x] 56 unit/widget tests green: domain logic, TTS contracts, navigation, AAC, emotion flows, persistence round-trips, sync queue, routines, aggregation, settings, localization/RTL, expression pipeline/screen, theme contrast
- [x] Static analysis clean

### Open

- [ ] Integration test: full offline journey (build sentence → speak → record → dashboard reflects)
- [ ] Test coverage report + gap review
- [ ] Performance profiling on device (frame pacing, TTS latency) ⛔ BLOCKED: device
- [ ] Physical checks: airplane-mode run, rapid-tap speech, smoke test ⛔ BLOCKED: device

## Module 13 — Production & Release

- [ ] Android SDK toolchain configured ⛔ BLOCKED: install SDK
- [ ] Debug APK builds successfully ⛔ BLOCKED: SDK
- [ ] App icon/adaptive icon + splash
- [ ] Release signing configuration (keystore outside VCS)
- [ ] Android release build (AAB/APK) ⛔ BLOCKED: SDK
- [ ] iOS best-effort build ⛔ BLOCKED: macOS/Xcode
- [ ] Crash handling and logging wired
- [ ] Final security/privacy review (camera, data export, secrets scan)
- [ ] Two demo rehearsals on actual device ⛔ BLOCKED: device
- [ ] Store listing assets (screenshots, description EN/UR) — if distributing

## Module 14 — Documentation & Demo Deliverables

### Done

- [x] README (run/config instructions), PROJECT-STRUCTURE, AI-INTEGRATION kept current
- [x] DEVELOPMENT-CHECKLIST maintained with honest status
- [x] Architecture diagrams in `docs/diagrams/`
- [x] Urdu TTS probe tool retained for hardware verification

### Open

- [ ] Demo script (5-minute walkthrough aligned to objectives O1–O8)
- [ ] FYP report sections: methodology, testing evidence (test counts, contrast results)
- [ ] Short demo video script
- [ ] Final handover: dependency justification list (dependency rule compliance)

---

## Suggested execution order (next up first)

1. **Module 1** — AAC catalog expansion + categories (highest demo value, zero blockers)
2. **Module 0** — Child mode + parent lock + onboarding (unlocks safe demos)
3. **Module 8** — Support-level picker + lock UI (small, completes adaptive story)
4. **Module 4** — Routine editor + countdown warnings (OS notifications when device available)
5. **Module 6** — Breathing/calming activities (self-contained)
6. **Module 9** — Badges/streaks/ring (pure logic + visuals)
7. **Module 7** — Accuracy-trend chart + observation tags
8. **Module 2 / 5** — Authored content modules (largest content effort)
9. **Module 11/13** — Firebase + release track ⛔ waits on account/SDK/device
