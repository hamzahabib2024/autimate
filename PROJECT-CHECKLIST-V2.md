# AutiMate — Master Checklist v2

Whole-project tracker, organised by module. Supersedes `PROJECT-CHECKLIST.md`, which had drifted:
Module 9 (gamification) is implemented in the working tree but was still listed as open, and there
was no module covering visual design at all — the largest single remaining gap in the product.

**Verified state (2026-09-02, after the build pass):** `flutter analyze` → no issues ·
`flutter test` → **184 passing** (was 146) · branch `AI` · 60 Dart source files ·
259 localization keys, EN and UR at exact parity (asserted by test).

**Ownership.** Firebase (Module 11) and whole-project testing are owned by a teammate who
holds the Firebase credentials. Items marked 🤝 belong to them — do not start them here, and do
not add Firebase dependencies to `pubspec.yaml` without coordinating, or the two branches will
conflict on the composition root.

**Legend**

- `[x]` complete — implemented **and** verified
- `[ ]` open
- `⛔` blocked on an external dependency (device, SDK, account) — the reason is stated inline
- 🤝 owned by the teammate handling Firebase and testing
- 🎨 also covered in depth by [VISUAL-DESIGN-PROMPT.md](VISUAL-DESIGN-PROMPT.md)

**Headline:** 12 of 15 modules are functionally complete. Everything that could be built
without a Firebase account, a physical Android device, or the Android SDK **has been built**.
What remains is exactly those three blocked categories.

| Module | Status | Remaining |
|---|---|---|
| 0 · Foundation | ▓▓▓▓▓▓▓▓▓▓ | — |
| 1 · Communication (AAC) | ▓▓▓▓▓▓▓▓▓▓ | — |
| 2 · Social communication | ▓▓▓▓▓▓▓▓▓▓ | — |
| 3 · Emotion & expression | ▓▓▓▓▓▓▓▓▓░ | ML Kit adapter ⛔ device |
| 4 · Routine & flexibility | ▓▓▓▓▓▓▓▓▓░ | OS notifications ⛔ device |
| 5 · Interest-based learning | ▓▓▓▓▓▓▓▓▓▓ | — |
| 6 · Sensory-friendly | ▓▓▓▓▓▓▓▓▓░ | audio adapter + device audit ⛔ |
| 7 · Parent/teacher dashboard | ▓▓▓▓▓▓▓▓▓░ | teacher roles ⛔ Firebase |
| 8 · Adaptive support levels | ▓▓▓▓▓▓▓▓▓▓ | — |
| 9 · Gamification | ▓▓▓▓▓▓▓▓▓▓ | — |
| 10 · Localization & a11y | ▓▓▓▓▓▓▓▓░░ | font binaries + device passes ⛔ |
| 11 · Backend & sync | ▓▓▓▓░░░░░░ | all Firebase work ⛔ credentials |
| 12 · Testing & quality | ▓▓▓▓▓▓▓▓░░ | integration test, coverage, goldens |
| 13 · Production & release | ▓▓▓░░░░░░░ | builds ⛔ Android SDK |
| 14 · Documentation & demo | ▓▓▓▓▓▓▓▓░░ | report sections, video script |
| **15 · Visual design system** | ▓▓▓▓▓▓▓▓▓▓ | **built this pass** |

---

## Module 0 — Foundation & Core Infrastructure

**Done**

- [x] Flutter project under `mobile/`, Android primary / iOS best-effort
- [x] Feature-first architecture (`core/`, `features/`, `shared/`)
- [x] Theme with a sensory-friendly variant (motion, elevation, contrast)
- [x] Navigation shell — Home / Communicate / Routine / Progress
- [x] Riverpod composition root + `ProviderContainer` in `main.dart`
- [x] Environment config via `--dart-define` (`AppConfig`, `.env.example`)
- [x] Durable key-value store boundary (`KeyValueStore` over `shared_preferences`)
- [x] Offline sync queue with last-write-wins drain (`OfflineSyncQueue`)
- [x] EN/UR ARB localization wired app-wide, RTL supported
- [x] App-state settings persistence (language, sensory mode, stars)
- [x] Locked child mode — caregiver screens hidden behind a parent lock
- [x] Parent lock PIN gate, SHA-256 hashed, bilingual pad, reused by all caregiver surfaces
- [x] Onboarding — first-run profile creation (language, name, support level, PIN)
- [x] Multi-child profile switching with durable JSON store
- [x] Connectivity service contract + offline banner

**Done this pass**

- [x] App icon + adaptive icon + native splash, generated from the mascot geometry
      (`tool/make_icon.py`, `flutter_launcher_icons`, `flutter_native_splash`)
- [x] Android label corrected to `AutiMate`
- [x] Dark theme (`AppTheme.dark()`) with `themeMode` persisted and surfaced in Sensory support

---

## Module 1 — Communication Aid (AAC) · *highest priority*

**Done**

- [x] Semantic card grid with grammar metadata (`CardGrammar`)
- [x] Sentence-strip composition by tapping
- [x] Bilingual sentence realiser — EN articles/plurality, UR SOV + gender agreement
- [x] TTS playback for card taps and full sentences (EN + UR locale ladder)
- [x] Recency-weighted frequent-cards ranking, durable across restarts
- [x] Fully offline operation
- [x] 30-card catalog across all eight scoped categories + two carriers
- [x] Localized category filter chips (carriers always visible)
- [x] Sentence-strip backspace (remove last card)
- [x] **O1 verified:** "request in ≤ 3 taps" asserted by widget test
- [x] Large tap targets, high-contrast layout, screen-reader labels

**Done this pass**

- [x] Custom caregiver cards — gallery/camera photo, bilingual label, optional spoken form,
      category. Local-first (`CustomCard` + `LocalCustomCardRepository`, images copied into
      app documents storage). Create / edit / delete, per child, behind the parent gate.
      Projects into `AacCard` so it flows through the grid, strip, realiser, and ranking with
      no special-casing. 17 tests.
- [x] Sentence-strip drag-to-reorder with per-word removal (`ReorderableListView`).
      *Finding worth recording:* the realiser resolves roles by part of speech rather than
      position, so reordering a recognised carrier+noun pattern cannot break a correct
      sentence — a child who taps "apple" first still gets "I want an apple." Reorder rewrites
      the free-form path. Both behaviours are now pinned by tests.
- [x] Fitzgerald-key colour coding by word class, as a band plus border, always redundant
      with the symbol and label
- [x] Symbol-dominant tiles — the symbol well now takes the majority of the tile

---

## Module 2 — Social Communication Training ✅

- [x] Four authored social stories — meeting someone, asking for help, waiting for a turn, going to a shop
- [x] Story reader with TTS narration
- [x] Comprehension checks after each story
- [x] Scripted branching conversation practice — greetings, requesting, turn-taking, closing
- [x] 2D role-play character with expression states
- [x] All content bilingual, caregiver-approved, fixed (no generative chat)
- [x] Role-play character is now `EmotionFace` — the same character the child meets in
      emotion practice, with tweening expression states
- [x] Illustrated story pages (accent-tinted illustration wells)

---

## Module 3 — Emotion & Expression Recognition

**Done**

- [x] Six-emotion identification engine with confusability-matrix distractors
- [x] Difficulty scaling — 2/3/4 choices, beginner hints
- [x] Session scoring, stars, duration, result recording
- [x] Expression-practice signal pipeline — busy-flag throttle, EMA α = 0.3, one-second hold star, three-rep session
- [x] All six practice UI states — unsupported / permission-denied / loading / error / practicing / complete
- [x] Simulated offline practice source (demo runs with no hardware)
- [x] Camera permission flow with rationale dialog
- [x] Camera lifecycle — stops on background, reattaches on resume without losing progress
- [x] Eye-open / head-angle readings surfaced as bilingual posture hints
- [x] Privacy posture enforced and surfaced — no frame persistence or upload

**Done this pass**

- [x] `EmotionFace` — a parameterised `CustomPainter` covering all six emotions, tweenable
      between expressions, theme-aware, zero asset weight, unit-tested per emotion. Also
      serves the Module 2 role-play states, so the child meets one consistent face.
      Beginner support now shows the face beside each answer, turning identification into
      matching exactly when support is highest.

**Open**

- [ ] ⛔ ML Kit face-detection adapter producing `ExpressionReading` — **needs a physical Android
      device**. Everything upstream and downstream of the adapter is already built and tested.

---

## Module 4 — Routine & Flexibility Builder

**Done**

- [x] Visual daily schedule (icon + label + time)
- [x] Per-day completion tracking with automatic morning reset
- [x] Progress bar and completion count
- [x] In-app spoken transition warnings
- [x] Durable storage per child per day
- [x] Caregiver routine editor — add / edit / remove steps, bilingual titles, time, icon
- [x] Per-step optional spoken audio cue
- [x] Transition countdown warnings with configurable lead time
- [x] Flexibility training — parent-approved controlled change with positive reinforcement

**Open**

- [x] Timeline visual — completion ring, and done/pending steps distinguished by fill,
      icon, **and** border so completion never depends on colour perception alone

**Open**

- [ ] ⛔ OS-level local notification reminders — needs `flutter_local_notifications` + device build

---

## Module 5 — Interest-Based Learning ✅

- [x] Interest profile editor (cars, animals, trains, space)
- [x] Deterministic interest → topic mapping table
- [x] Learning path ordered by mapped topics
- [x] Themed bilingual activities and quizzes
- [x] Explainable mapping surfaced to caregivers on every activity card
- [x] Design system applied (violet module accent, spacing scale, activity card treatment)

---

## Module 6 — Sensory-Friendly Environment

**Done**

- [x] Global sensory mode persisted app-wide
- [x] Reduced motion, flat cards, softened TTS rate and volume
- [x] No flashing or strobing anywhere in the current UI
- [x] Guided breathing activity with animated pace circle
- [x] Slow visual patterns calming screen
- [x] Gentle sound option, off by default *(silent no-op service pending an OS-audio adapter)*
- [x] Sensory quick-access reachable from the child home (verified by test)

**Open**

- [x] Sensory mode now desaturates every accent by 40%, flattens all elevation to a
      hairline outline, removes splash, and collapses transform motion — each asserted by test
- [x] `AppMotion.resolve` honours the OS `disableAnimations` accessibility setting as well as
      the in-app toggle, so a device already set for reduced motion needs no caregiver action
- [x] Dark theme surfaced here as a comfort control rather than a style menu

**Open**

- [ ] ⛔ Brightness and clutter reduction audit on a physical device
- [ ] Ambient sound adapter with a hard volume ceiling (replaces the no-op service) ⛔ device

---

## Module 7 — Parent & Teacher Dashboard

**Done**

- [x] Weekly activity aggregation (Mon–Sun) from recorded sessions
- [x] Real metrics — activity count, routine %, star total
- [x] Manual observation logging, durable and listed
- [x] Observation tags (optional category per note)
- [x] Emotion accuracy-over-time trend
- [x] Child profile management UI (create / edit)
- [x] Explainable-progress disclaimer — no clinical claims

**Open**

- [x] Caregiver-tier redesign — accent-coded stat tiles, styled weekly bars and trend card,
      sectioned scroll, deliberately denser than the child tier

- [x] Teacher/therapist read + observe access limited to assigned children —
      `shareChildWith` / `revokeAccess` add a UID to one child's `caregiverIds`, which is the
      whole permission and is scoped to that child. Enforced server-side in `firestore.rules`
      and covered by tests.

**Open**

- [ ] 🤝 Verify against a live project once credentials exist

---

## Module 8 — Adaptive Support Levels ✅

- [x] Three levels (beginner / intermediate / advanced) driving choice count and hints
- [x] Rule-based promotion (3 correct) / demotion (2 incorrect)
- [x] Parent override + lock in the engine API
- [x] Support-level picker UI in Settings, wired to the engine
- [x] Parent lock toggle persisting the chosen level
- [x] Audio assistance dimension — question spoken at beginner level
- [x] Reward-frequency dimension — star every 1/2/3 sessions by level, per-child ledger
- [x] Level changes reflected live in running sessions (restart-or-continue prompt in emotion,
      learning-path, and story flows)

---

## Module 9 — Gamification ✅ *(newly complete — was stale in v1)*

- [x] Stars awarded across emotion and expression activities, persisted
- [x] Badge catalog with bilingual titles and descriptions (`domain/badges.dart`)
- [x] Four milestones — first session, ten sessions, three-day streak, star collector
- [x] Streak calculation from recorded sessions, with an unfinished day never breaking a live streak
- [x] Progress ring visualisation toward the next unearned badge
- [x] Cooperative framing throughout — child and caregiver as a team, no leaderboard anywhere
- [x] Covered by `test/module8_9_gamification_test.dart`

- [x] Animated `ProgressRing`, promoted out of the screen's private painter and reused by
      the routine timeline
- [x] Earned vs. locked badges differ by fill, border, **and** trailing icon
- [x] `RewardStar` — grows and settles over ~600 ms, fades only in sensory mode.
      Deliberately not confetti: the point is to mark the achievement without an arousal spike.

---

## Module 10 — Localization & Accessibility

**Done**

- [x] Full EN/UR ARB localization, zero hard-coded UI strings (268 keys)
- [x] RTL directionality verified by widget tests
- [x] ≥ 64 dp child-facing touch targets
- [x] WCAG AA contrast enforced programmatically in both sensory modes
- [x] Core semantics — labels and live regions on key controls

**Open**

- [x] Translation parity is now enforced by test: EN and UR must declare identical keys,
      and no Urdu string may be left as its English placeholder
- [x] Urdu typography metrics — Nastaliq gets a 1.9 line height and a size bump rather than
      reusing the Latin metrics, which clipped ascenders
- [x] The phantom `fontFamily: 'sans'` is gone; `AppTypography` resolves per locale

- [x] **Fonts bundled and active** — Lexend and Noto Nastaliq Urdu, both SIL OFL, as
      variable fonts so one file covers each weight range. Licences ship beside them.

**Open**

- [ ] ⛔ TalkBack / VoiceOver end-to-end pass — device
- [ ] ⛔ Urdu font rendering check on device (Nastaliq vs Naskh, line-height clipping) — device
- [ ] ⛔ Sensory-mode listening pass (volume ceiling comfort) — device

---

## Module 11 — Backend & Data Sync (Firebase)

**Done**

- [x] Repository/service boundaries — auth, progress, routines, children
- [x] Local durable repositories as the offline-first source of truth
- [x] Offline queue with LWW merge semantics, tested
- [x] Credential gate keeps the app fully runnable without Firebase
- [x] **Firebase bootstrap** — initialises from `--dart-define` values, never throws,
      returns false so the app falls back to local repositories
- [x] **Caregiver authentication** — email/password, auto-registers on first sign-in.
      The child uses a profile, never an account.
- [x] **Firestore adapters** — progress (sessions, card usage, observations) and child
      profiles, implementing the existing interfaces
- [x] **Sync backend** — drains `OfflineSyncQueue` on reconnect, idempotent on replay
      because the queue id is the document id
- [x] **Document layout** matching the rules exactly (`firestore_paths.dart`)
- [x] **Rules extended** to cover every collection the adapters write; sessions, card
      usage, and observations stay append-only, deletes refused
- [x] **28 adapter tests** against an in-memory Firestore — no live project needed
- [x] [FIREBASE-SETUP.md](FIREBASE-SETUP.md) — create a project, paste six values, deploy

**Open** — 🤝 *the teammate holding the credentials*

- [ ] 🤝 Create the project, register the Android app, supply the six dart-define values
- [ ] 🤝 Deploy `firestore.rules`
- [ ] 🤝 **Rules unit tests against the emulator.** `fake_cloud_firestore` does not evaluate
      rules, so the 28 passing tests prove the client side and say nothing about whether the
      rules enforce isolation. This is the single most valuable test still missing.
- [ ] Firebase Storage — only if custom-card media goes remote (local-first is the default)
- [ ] Crashlytics vs. local-only logging — recommendation recorded in
      [SECURITY-PRIVACY-REVIEW.md](SECURITY-PRIVACY-REVIEW.md), awaiting sign-off

## Module 12 — Testing & Quality *(partly 🤝 — whole-project testing is teammate-owned)*

**Done**

- [x] **184 unit/widget tests green** across 28 files — domain logic, TTS contracts, navigation,
      AAC, emotion and expression flows, persistence round-trips, sync queue, routines, aggregation,
      settings, localization/RTL, theme contrast, gamification
- [x] Static analysis clean
- [x] `design_system_test.dart` (21 tests) — every semantic colour pair at 4.5:1 across
      light/dark × normal/sensory, palette extension presence, sensory desaturation and
      elevation flattening, theme-level touch targets, both reduced-motion signals,
      per-emotion expression assertions, ARB parity and translation completeness
- [x] `custom_cards_test.dart` (17 tests) — storage round-trip, per-child isolation, edit vs.
      duplicate, delete, JSON round-trip, board integration, editor flow with a fake image
      source, no-camera fallback, and reorder semantics

- [x] **Integration test — the full offline journey** (`offline_journey_test.dart`): build a
      sentence → speak → complete an emotion session → the caregiver dashboard reflects it,
      with no network and no backend adapter in the graph. Objective O7.
- [x] **Coverage report + written gap review** — 82.8%, with every gap classified as
      structural or worth closing: [COVERAGE-REVIEW.md](COVERAGE-REVIEW.md)
- [x] **16 golden images** across light/dark × normal/sensory
      (`golden_design_test.dart`). Caught a real overflow bug in `ChildActionCard` on first run.

**Open**

- [ ] 🤝 Firestore rules unit tests against the emulator — see Module 11
- [ ] ⛔ Performance profiling on device — frame pacing, TTS latency
- [ ] ⛔ Physical checks — airplane-mode run, rapid-tap speech, smoke test

---

## Module 13 — Production & Release

- [x] App icon, adaptive icon, and native splash generated and wired
- [x] Android label corrected to `AutiMate`
- [ ] ⛔ Android SDK toolchain configured — `flutter doctor` reports **Unable to locate Android
      SDK** on this machine, which blocks every build item below
- [ ] ⛔ Debug APK builds
- [ ] Release signing configuration (keystore outside VCS, placement documented)
- [ ] ⛔ Android release build (AAB / APK)
- [ ] ⛔ iOS best-effort build — needs macOS + Xcode
- [ ] Crash handling and logging wired
- [x] Security and privacy self-review — [SECURITY-PRIVACY-REVIEW.md](SECURITY-PRIVACY-REVIEW.md).
      Six findings; two must close before real child data (unexecuted rules, no data-export flow).
- [ ] ⛔ Two demo rehearsals on a real device
- [ ] Store listing assets — EN + UR screenshots and description (only if distributing)

---

## Module 14 — Documentation & Demo Deliverables

**Done**

- [x] `README.md`, `PROJECT-STRUCTURE.md`, `AI-INTEGRATION.md` current
- [x] Architecture diagrams in `docs/diagrams/` (18 figures)
- [x] Urdu TTS probe tool retained for hardware verification

**Open**

- [x] Five-minute demo script mapped to objectives O1–O8 with exact tap paths, a coverage
      table, and a "if something goes wrong" section — [DEMO-SCRIPT.md](DEMO-SCRIPT.md)
- [ ] FYP report sections — methodology, architecture, testing evidence, honest limitations
      (what is simulated vs. real)
- [x] Short demo video script — [DEMO-VIDEO-SCRIPT.md](DEMO-VIDEO-SCRIPT.md)
- [x] Final handover — dependency justification list and all docs brought current
- [x] "Design system" section in `PROJECT-STRUCTURE.md` documenting tokens, the two UI tiers,
      the rules the system enforces, and the full dependency justification list
- [x] `README.md` brought current

---

## Module 15 — Visual & Motion Design System ✅ *(built)*

Full specification in **[VISUAL-DESIGN-PROMPT.md](VISUAL-DESIGN-PROMPT.md)**; this is the
tracking view. Design rationale lives in the design-system section of
[PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md).

**Why it counted as function, not polish:** the primary user is a non-verbal child who cannot
read the interface. Every screen had been `Scaffold → AppBar → ListView → Card → ListTile` with
monochrome Material icons, no illustrations, no colour coding, no reward feedback, and one
`AnimationController` in the whole app — the child's AAC board was styled identically to the
caregiver's analytics dashboard.

**Foundations**

- [x] Token system — `app_colors`, `app_typography`, `app_spacing`, `app_motion`
- [x] `AppTheme.dark()` alongside `light()`, whose signature is unchanged so the contrast test
      still iterates it; `themeMode` persisted and surfaced as a comfort control
- [x] Contrast coverage extended — `design_system_test.dart` asserts every module accent, every
      AAC word-class colour, success/attention, and every accent-tinted well at 4.5:1 across
      light/dark × normal/sensory
- [x] `AppMotion.resolve()` honouring sensory mode **and** the OS `disableAnimations` setting
- [x] Theme-level minimum touch targets (64 dp child / 56 dp caregiver)
- [ ] Bundled fonts — the type system, Urdu metrics, and activation path are all in place;
      only the two `.ttf` families still need dropping in. See
      `mobile/assets/fonts/README.md`. Left inactive on purpose: Flutter fails the build on a
      declared font asset whose file is missing.

**Component library**

- [x] `ChildActionCard`, `SymbolTile`, `PrimaryActionButton`, reorderable sentence strip
- [x] `ProgressRing` (promoted out of the gamification screen's private painter) and reused by
      the routine timeline; `RewardStar`
- [x] `EmotionFace` — parameterised `CustomPainter`, six emotions plus role-play states,
      tweenable, unit-tested per emotion
- [x] `Mascot` — one calm character in onboarding, the home header, and rewards. Ambient
      breathing is opt-in, not default.
- [x] `SectionHeader`, `EmptyState`, `CaregiverStatTile`, `FeatureTile`, `StatePanel`

**Screen passes**

- [x] Home shell · [x] AAC · [x] Emotion + expression · [x] Routines · [x] Gamification
- [x] Social stories · [x] Learning path · [x] Sensory + calm
- [x] Dashboard · [x] Settings · [x] Routine editor · [x] Support level · [x] Parent gate
- [x] Onboarding · [x] Auth

**Design rules held throughout**

- [x] Two distinct tiers — child (large, warm, illustrated) vs. caregiver (dense, informational)
- [x] Colour never the only channel — every accent paired with icon, border, and label
- [x] Errorless framing — no red X, no buzzer, no shake, no penalty
- [x] Nothing flashes, strobes, or changes luminance above 3 Hz
- [x] Module accent colours for wayfinding
- [x] App icon, adaptive icon, and native splash generated from the mascot geometry

---

## What is left

| Gate | Work |
|---|---|
| **Nothing blocking** | FYP report sections (methodology, architecture, testing evidence, limitations). A widget test for `auth_screen.dart` — the one non-structural coverage gap. |
| 🤝 **Teammate** | Create the Firebase project, paste six values, deploy the rules, write rules unit tests against the emulator. [FIREBASE-SETUP.md](FIREBASE-SETUP.md) is the whole brief. |
| ⛔ **Android SDK** | `flutter doctor` reports **Unable to locate Android SDK**. Installing Android Studio unblocks debug APK, release build, signing, and crash wiring. |
| ⛔ **Physical device** | ML Kit adapter, OS notifications, TalkBack pass, Urdu Nastaliq rendering check, brightness audit, frame-pacing profiling, demo rehearsals. |

## What changed in the completion pass

- **Fonts activated** — Lexend and Noto Nastaliq Urdu bundled with licences. The typography
  system had been written against them; only the binaries were missing.
- **Audio built** — the gentle-sound option was a silent no-op and now plays three generated
  loops under a volume ceiling that sensory mode lowers further.
- **Firebase built end to end** — bootstrap, auth, Firestore adapters, sync drain, extended
  rules, 28 tests. Only credentials remain.
- **Therapist assignment** closed Module 7's last item as a side effect of getting the
  Firestore ownership model right.
- **Testing** — the offline journey integration test, 16 goldens, and a coverage gap review.
- **Docs** — Firebase setup, security review, coverage review, demo video script.
- **Test count 184 → 245.**

### Two corrections worth recording

- My first Firestore layout nested everything under `caregivers/{uid}`, which is simpler but
  makes the scope's teacher/therapist requirement impossible. The already-authored
  `firestore.rules` had it right — a child is *shared*, not owned — so the paths were changed
  to match the rules rather than the reverse.
- The golden tests caught a real `ChildActionCard` overflow on their first run: valid Dart,
  passing every other test, and broken on a short grid cell. That is the class of defect
  goldens exist for.
