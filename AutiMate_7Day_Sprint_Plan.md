# AutiMate — 7-Day Build Sprint Plan

**Team size:** 4
**Build window:** 7 days
**Goal:** A stable, demonstrable vertical slice — not a feature-complete product
**Document version:** 1.0

---

## 1. Reality Check — Read This First

The full scope document describes seven modules across roughly sixteen weeks. In seven days with four people you have approximately **112 working hours of usable capacity** (4 people × 7 days × ~6 productive hours, minus setup friction, merge conflicts, and debugging).

That capacity buys you **four modules built properly**, not seven built partially.

The failure mode we are avoiding is *breadth without depth*: an app with seven half-implemented tabs, three of which crash during the demo. The strategy instead is a **vertical slice** — a smaller set of features that work end-to-end, offline, in both languages, with real data persistence. That demos far better and is far more defensible in a viva.

---

## 2. Sprint Scope — Locked

### BUILD (P0 — non-negotiable)

| # | Feature | Why it's P0 |
|---|---------|------------|
| 1 | Auth + parent account + child profile | Everything else needs a child ID |
| 2 | **AAC Communication Aid + TTS** | The flagship. Highest demo impact, lowest technical risk |
| 3 | Emotion identification activity | Second-strongest demo; produces progress data |
| 4 | Visual routine schedule | Shows the "daily life support" angle |
| 5 | Parent progress screen + one chart | Proves data actually persists and aggregates |
| 6 | Sensory-friendly mode toggle | Cheap to build, unique, strong talking point |
| 7 | EN/UR localisation + RTL | Cheap if done from hour one, expensive if retrofitted |
| 8 | Basic gamification (stars) | ~3 hours, big perceived polish gain |

### STRETCH (P1 — only if P0 is done by Day 5)

| # | Feature | Condition |
|---|---------|-----------|
| 9 | Expression practice via on-device face detection | Only if AI/ML track finishes P0 early |
| 10 | 3 static social stories | Content-heavy, code-light — good filler task |
| 11 | Routine reminder notifications | Local notifications only |

### CUT (explicitly not building this week)

Conversation practice · Role-play · Interest-based learning · Flexibility training · Adaptive support levels (ship a **manual** 3-level selector instead) · Teacher role · Observation logging · Speech-to-text · Offline sync engine · Web dashboard · Custom-trained ML models

> **Say this to your supervisor up front.** "We scoped a vertical slice for the build week; remaining modules are designed and documented but not implemented." That is a professional answer. "We ran out of time" is not.

---

## 3. The Four Technical Tracks

A pure layer-based split (one person does all UI, one does all Firebase) blocks people constantly — the UI dev waits for repositories, the Firebase dev has nothing to test against. So the split below is **layer-based for Days 1–2** (build foundations in parallel) then **feature-based for Days 3–7** (own features end-to-end).

---

### D1 — Frontend Core & Design System

**Owns:** Everything shared and visual.

**Responsibilities**
- Flutter project scaffolding, feature folder structure
- Theme system — including the **sensory-friendly theme variant** (reduced motion, muted palette, softened contrast, no shadows)
- Reusable child-facing widget library: `BigTappableCard`, `ChildAppBar`, `StarReward`, `ActivityScaffold`, `LoadingState`, `ErrorState`, `EmptyState`
- Navigation and routing, including child-mode lock (child can't reach parent screens)
- Localisation infrastructure: ARB files, EN + UR, RTL verification
- Onboarding and profile setup screens
- Owns the **sensory mode** feature end-to-end from Day 4

**Deliverable by end of Day 2:** Any teammate can import a child-friendly button, a loading state, and a localised string, and the app switches to Urdu RTL correctly.

**Skills:** Flutter widgets, theming, responsive layout, `flutter_localizations`, accessibility.

---

### D2 — Firebase, Data & Architecture

**Owns:** Everything that persists.

**Responsibilities**
- Firebase project setup, Android config, `firebase_options.dart`
- Firebase Authentication (email/password, parent accounts only)
- Firestore schema design and implementation
- Firestore **Security Rules** — a real deliverable, not an afterthought
- Repository layer for every collection (auth, child, cards, progress, routines)
- Riverpod provider architecture and conventions the team follows
- Firestore offline persistence configuration
- Seed script for default AAC cards, emotion images, sample routine

**Collections this week (only these):**
```
users/{uid}                    -> role, email, childIds[]
children/{childId}             -> name, age, prefs, supportLevel, ownerUid
communication_cards/{cardId}   -> label_en, label_ur, imageUrl, category
progress/{progressId}          -> childId, activityType, score, total, timestamp
routines/{routineId}           -> childId, steps[], dayOfWeek
```

**Deliverable by end of Day 2:** Auth works, a child profile can be created and read, repositories return real types, and the team can call `ref.watch(childProvider)` and get data.

**Skills:** Firebase, Firestore modelling, security rules, Riverpod, repository pattern.

---

### D3 — AI/ML, Speech & Adaptive Logic

**Owns:** Everything intelligent, and everything that makes noise.

**Responsibilities**
- **Text-to-Speech service** — EN + UR, device voice selection, queueing, interruption handling. *This is the single most demo-critical service in the app.* Build it Day 1.
- Sentence assembly logic for AAC (cards -> grammatical phrase -> speech)
- Emotion activity engine: question generation, distractor selection, scoring, difficulty tiers
- Simple rule-based difficulty logic (choice count and hint visibility by level)
- **P1:** On-device expression practice using ML Kit face detection

**Critical technical recommendation — see Section 6.** Do **not** train or source a custom TFLite emotion model this week.

**Deliverable by end of Day 2:** A working TTS service that speaks an English and an Urdu string on a real device, plus emotion activity logic with passing unit tests (pure Dart, no UI needed).

**Skills:** `flutter_tts`, ML Kit / camera plugins, algorithm design, unit testing.

---

### D4 — Features, Dashboard & Integration

**Owns:** Assembly, caregiver-facing screens, and quality.

**Responsibilities**
- Parent dashboard: child list, progress screen, one weekly bar chart
- Progress aggregation logic (query -> chart-ready data)
- Routine builder (parent side) and visual schedule (child side)
- Gamification: star awards, session summary screen
- Integration duty — wires D1's widgets, D2's repositories, and D3's services into working screens
- **Release manager:** owns the build, resolves merge conflicts, keeps `main` demo-ready
- Demo script and screenshots

**Deliverable by end of Day 2:** App shell running with all four tabs navigable, placeholder content, and a green `flutter analyze`.

**Skills:** Flutter, `fl_chart`, data aggregation, git, debugging.

---

## 4. Day-by-Day Plan

### Day 1 — Foundations (everyone parallel, nobody blocked)

| Who | Task |
|-----|------|
| D1 | Project scaffold, folder structure, theme + sensory variant, localisation setup |
| D2 | Firebase project, auth flow, Firestore rules v1, child profile model + repository |
| D3 | TTS service working on a physical device in EN and UR — **verify an Urdu voice exists** |
| D4 | App shell, routing skeleton, git workflow, branch protection, analyze check |

**Gate:** App launches. A user can register. A string speaks aloud in Urdu.

---

### Day 2 — Contracts and shared layer

| Who | Task |
|-----|------|
| D1 | Reusable widget library complete; onboarding + child profile screens |
| D2 | All repositories implemented; seed data uploaded; offline persistence on |
| D3 | AAC sentence logic + emotion activity engine, unit tested |
| D4 | Screens wired to providers with real data flowing; dashboard shell |

**Gate:** No one is blocked on anyone. **Interfaces freeze here** — changing a repository signature on Day 5 costs the whole team an hour.

---

### Day 3 — AAC (all hands on the flagship)

| Who | Task |
|-----|------|
| D1 | AAC grid UI, category tabs, sentence strip, huge tap targets |
| D2 | Card data loading, offline caching, custom card creation (parent) |
| D3 | Card tap -> phrase -> speech pipeline; recently-used ranking |
| D4 | Integration, star rewards on use, on-device testing |

**Gate:** A child taps an apple card and the phone says *"I want an apple."* Works in airplane mode. Works in Urdu.

> This is your demo's opening scene. It must be flawless before anything else gets attention.

---

### Day 4 — Emotion activity + Sensory mode

| Who | Task |
|-----|------|
| D1 | Sensory mode end-to-end; emotion activity screens |
| D2 | Progress writes to Firestore; verify offline queue and sync |
| D3 | Activity flow: question -> choices -> feedback -> score; difficulty tiers |
| D4 | Session summary, star awards, progress aggregation |

**Gate:** A child completes 5 emotion questions, sees stars, and the result appears in Firestore.

---

### Day 5 — Routines + Dashboard

| Who | Task |
|-----|------|
| D1 | Visual schedule child UI (icon + label + time), completion animation |
| D2 | Routine CRUD, routine access rules, final security rules pass |
| D3 | Routine step narration via TTS; **start P1 expression practice if free** |
| D4 | Parent routine builder, progress chart, dashboard polish |

**Gate:** P0 feature-complete. Everything after this is polish and hardening.

---

### Day 6 — Hardening (no new features)

Everyone: bug fixing, error/loading states, Urdu + RTL audit on every screen, sensory mode audit, offline testing, `flutter analyze` clean, unit tests for D3's logic and D4's aggregation.

D3 only: finish expression practice **if and only if** it is already working. If it is not working by noon on Day 6, cut it and say so.

**Gate:** Signed APK installed on the demo device. Full run-through completed twice with no crash.

---

### Day 7 — Freeze, document, rehearse

- **Code freeze at midday.** Only crash fixes after that.
- Screenshots, demo script, README, architecture diagram
- Rehearse the demo three times on the actual demo device
- Prepare answers for: *"Why isn't module X built?"* and *"Where is the AI?"*

---

## 5. Dependency Map — Who Blocks Whom

```
Day 1-2   D1 (widgets) ---+
          D2 (repos)   ---+---> D4 (integration)
          D3 (services)---+

Day 3-7   D1 -> owns the UI of the feature in play
          D2 -> owns its data
          D3 -> owns its logic
          D4 -> assembles and guards the build
```

**Three rules that prevent the week collapsing:**

1. **Interfaces freeze end of Day 2.** Signatures agreed, then untouchable.
2. **Nobody edits another person's files without telling them.** Merge conflicts are the top killer of short sprints.
3. **`main` must always run.** D4 has veto power on merges.

---

## 6. Key Technical Recommendation — Change the AI/ML Approach

**Do not train or source a custom TFLite emotion-classification model this week.**

Model sourcing, quantisation, input preprocessing, and camera-frame plumbing is realistically 3–4 days of D3's time with a genuine chance of ending Day 6 with nothing working. That risk is unacceptable in a 7-day sprint.

**Use Google ML Kit Face Detection instead** (`google_mlkit_face_detection`).

| | Custom TFLite model | ML Kit face detection |
|---|---|---|
| Setup time | 3–4 days, uncertain | ~4 hours |
| Runs on-device | Yes | Yes |
| Privacy | Frames stay local | Frames stay local |
| Latency | Variable | ~30–60 ms per frame |
| Output | 6-class emotion (if it works) | Smile probability, eye-open probability, head angle |
| Risk | High | Low |

ML Kit gives you `smilingProbability` and `leftEyeOpenProbability` directly. That is enough for a genuinely strong **"Can you make a happy face?"** activity with a live progress meter that fills as the child smiles — which demos *better* than a 6-class classifier, because the evaluator can watch it respond in real time.

It is still real on-device machine learning, still privacy-preserving, still zero network calls. You lose nothing academically and you gain three days.

**How to describe this honestly in the report:** "Expression practice uses on-device ML Kit face detection to derive expression signals locally; a fine-tuned multi-class emotion classifier is documented as future work."

---

## 7. Where the "AI" Is — For Your Viva

You will be asked this. Prepare the answer now:

| Claim | What actually ships |
|-------|--------------------|
| On-device ML | ML Kit face detection for expression practice (P1) |
| Speech synthesis | Platform TTS, bilingual, offline |
| Rule-based adaptation | Difficulty tiers driven by performance — deliberately explainable |
| Deferred | Custom emotion classifier, STT, conversation practice — designed, documented, not built |

**Do not overstate.** A team that says "we chose a rule-based adaptive system because it is explainable to parents, and used on-device ML only where it added real value" sounds considerably more mature than one claiming AI it cannot demonstrate. Restraint is defensible; overreach is not.

---

## 8. Packages — Approved List Only

Anything outside this list requires team agreement, because every unfamiliar package is a potential half-day of debugging you do not have.

```yaml
flutter_riverpod              # state management
firebase_core
firebase_auth
cloud_firestore
firebase_storage              # only if custom card images ship
flutter_tts                   # bilingual speech output
flutter_localizations         # SDK
intl
fl_chart                      # one chart on the dashboard
google_mlkit_face_detection   # P1 only
camera                        # P1 only
```

No code generation. **`build_runner` is a trap in a one-week sprint** — a single generation failure can cost half a day. Write your models by hand.

---

## 9. Definition of Done — Sprint Edition

Trimmed from the full scope document to what is achievable in a week:

1. Runs without crashing on the demo device
2. Strings localised EN + UR; screen verified in RTL
3. Loading and error states present
4. Respects sensory mode
5. `flutter analyze` clean
6. AAC and routines verified in airplane mode
7. Merged to `main` and confirmed still building

---

## 10. Contingency

If Day 4 ends behind schedule, cut in this order:

1. Expression practice (P1) — cut first, no hesitation
2. Routine reminders / notifications
3. Custom card creation (ship with seeded cards only)
4. Urdu on **parent** screens (keep Urdu on all **child** screens — that's the accessibility claim)
5. The dashboard chart (replace with a simple stats list)

**Never cut:** AAC + TTS, or offline capability. Those two are the project's identity.

---

## 11. Open Questions — Confirm Before Day 1

1. Does everyone have a physical Android device? Urdu TTS voice availability **must** be verified on Day 1 — emulators are unreliable for this.
2. Is one week the total build time, or does report/documentation sit outside it?
3. Who is D4 (release manager)? It should be whoever is strongest with git.
4. Are the 7 days consecutive full days, or spread across a longer calendar period?
5. Do you have image assets for AAC cards and emotion faces, or does someone need to source openly licensed ones on Day 0?

---

*End of sprint plan. Scope changes require whole-team agreement — mid-sprint additions in a 7-day window come directly out of hardening time.*
