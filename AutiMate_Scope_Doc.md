# AutiMate — Project Scope Document

**Project Type:** Final Year Project (FYP)
**Product:** AI-assisted mobile application supporting autistic children
**Primary Platform:** Flutter (Android primary, iOS secondary)
**Document Version:** 1.0 — Draft for team review
**Status:** Awaiting sign-off

---

## 1. Executive Summary

AutiMate is a child-friendly mobile application that supports autistic children in communication, emotion recognition, daily routines, learning, and sensory regulation. It also gives parents, teachers, and therapists lightweight tools to configure activities and observe progress.

AutiMate is a **support and training tool**. It is explicitly **not** a diagnostic, screening, or treatment application, and it makes no clinical claims.

---

## 2. Problem Statement

Autistic children often face challenges in:

- Expressing needs verbally
- Interpreting facial expressions and emotional cues
- Coping with unexpected changes in routine
- Engaging with generic learning material not aligned to their interests
- Managing sensory overload from typical app interfaces

Existing tools tend to be either expensive, English-only, internet-dependent, or designed for clinicians rather than for the child and their caregivers. AutiMate addresses this gap with an offline-capable, bilingual (English/Urdu), sensory-friendly application that uses on-device AI where it genuinely adds value.

---

## 3. Project Objectives

| # | Objective | Success Indicator |
|---|-----------|-------------------|
| O1 | Give non-verbal / minimally verbal children a working communication aid | Child can build and speak a request in ≤ 3 taps |
| O2 | Teach emotion recognition through structured, repeatable activities | Measurable accuracy improvement across sessions |
| O3 | Make daily routines predictable and transitions less stressful | Routine completion tracked and visualised |
| O4 | Personalise learning around the child's declared interests | Learning path generated from interest profile |
| O5 | Reduce sensory overload through configurable UI | Sensory mode measurably alters motion, sound, contrast |
| O6 | Give caregivers explainable progress insight | Weekly report with no fabricated precision |
| O7 | Work without internet for core child-facing features | Core modules function fully offline |
| O8 | Support English and Urdu including RTL layout | Full UI localised, no hard-coded strings |

---

## 4. Stakeholders and User Roles

| Role | Description | Access |
|------|-------------|--------|
| **Child** | Primary user. Uses communication, emotion, routine, learning and sensory features. | Simplified, locked child mode |
| **Parent** | Creates the child profile, configures routines and preferences, logs observations, views reports. | Full profile control |
| **Teacher / Therapist** | Reviews progress for assigned children, logs observations, supports activities. | Read + observation logging on assigned children only |
| **Supervisor / Evaluator** | FYP assessor. Not an app role — consumes the demo and documentation. | N/A |

> **Note:** Role-based logic will be implemented only to the depth each feature actually requires. No speculative permission framework will be built up front.

---

## 5. Scope — In Scope

### 5.1 Module 1 — Communication Aid (AAC) — *Highest Priority*

The flagship feature and the strongest demo asset.

- Picture/symbol-based communication grid
- Categories: Food, Drinks, Emotions, Activities, People, Places, Needs, Objects
- Sentence strip — child taps cards to compose a phrase
- Text-to-Speech playback in English and Urdu
- Frequently-used and recently-used cards surfaced automatically
- Parent-added custom cards (image from gallery/camera + label + audio)
- Full offline operation
- Very large tap targets, minimal text, high contrast

### 5.2 Module 2 — Social Communication Training

- **Social Stories** — short illustrated scenarios (meeting someone, asking for help, waiting for a turn, going to a shop) with narration and simple comprehension checks
- **Conversation Practice** — guided, *constrained* dialogue with fixed branching (greetings, requesting, turn-taking, closing a conversation)
- **Role-play** — simple 2D character with expression states and visual cues

> Conversation practice will be scripted/branching, **not** open-ended generative chat, for child-safety reasons.

### 5.3 Module 3 — Emotion & Expression Recognition

- Emotion identification activities (faces, emojis, illustrated scenes)
- Six target emotions: Happy, Sad, Angry, Surprised, Scared, Neutral
- Difficulty scaling — number of choices, hint availability
- **Expression practice** using on-device camera inference (TFLite / MediaPipe), processed locally, no frames uploaded or stored
- Framed throughout as an educational aid, never as an accurate reading of real emotional state

### 5.4 Module 4 — Routine & Flexibility Builder

- Visual daily schedule (icon + label + time + optional audio)
- Routine step completion tracking
- Local notification reminders
- Transition warnings ("Play time ends in 5 minutes")
- **Flexibility training** — controlled, parent-approved insertion of a small change into a known routine, with positive reinforcement

### 5.5 Module 5 — Interest-Based Learning

- Child interest profile (cars, animals, trains, space, etc.)
- Interest → topic mapping producing a simple learning path
- Interest-themed activities and quizzes
- Deterministic, explainable mapping (no black-box recommender)

### 5.6 Module 6 — Sensory-Friendly Environment

- Global sensory mode: reduced motion, muted palette, lower brightness, reduced clutter, volume ceiling
- Calming activities: guided breathing, slow visual patterns, gentle sound
- No flashing, strobing, or sudden loud audio anywhere in the app

### 5.7 Module 7 — Parent & Teacher Dashboard

- Child profile management
- Activity history and completion records
- Emotion activity accuracy over time
- Routine adherence
- Manual observation logging (free text + optional tag; **no automatic behavioural labelling**)
- Simple weekly charts and summaries

### 5.8 Module 8 — Adaptive Support Levels

- Three configurable levels: Beginner / Intermediate / Advanced
- Adjusts: choice count, hint visibility, audio assistance, activity complexity, reward frequency
- Simple rule-based promotion/demotion (e.g. N consecutive correct → step up; M consecutive incorrect → step down + hints)
- Parent can override and lock the level

### 5.9 Cross-Cutting

- Firebase Authentication (parent/teacher accounts; child uses a profile, not an account)
- Cloud Firestore for structured data, Firebase Storage for media
- Offline-first for child-facing features with sync on reconnect
- Gamification: stars, badges, streaks, progress rings — cooperative, not competitive
- Full English/Urdu localisation with RTL support
- Firestore Security Rules enforcing data isolation

---

## 6. Scope — Out of Scope

Explicitly excluded from this FYP. Listed so nobody assumes otherwise mid-project.

| Excluded | Reason |
|----------|--------|
| Clinical diagnosis, screening, or DSM-5 severity classification | Outside project remit; ethically and legally inappropriate |
| AR / VR experiences | High cost, low marginal value for this scope |
| Open-ended generative AI chat for children | Safety risk; cannot be adequately guardrailed at FYP scale |
| Multi-tenant school / institution management | Enterprise complexity, not FYP value |
| Video calling or messaging between users | Out of scope, significant safety surface |
| Payment, subscription, or monetisation | Not applicable |
| Web dashboard | **Optional stretch only.** Not counted in core deliverables (see Assumption A4) |
| Complex bidirectional sync engine with conflict resolution | Last-write-wins is sufficient |
| Languages beyond English and Urdu | Architecture will allow it; content will not be produced |
| Wearable / IoT sensor integration | Out of scope |
| Voice-based emotion recognition | Deferred — only if Phase 5 finishes early |

---

## 7. Technology Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| App framework | Flutter (Dart) | Single codebase, Android + iOS |
| State management | Riverpod | Compile-safe, testable, team standard |
| Auth | Firebase Authentication | Managed, secure, no custom auth code |
| Database | Cloud Firestore | Offline persistence built in — directly serves our offline-first goal |
| Media storage | Firebase Storage | Custom card images and audio |
| Notifications | Local notifications (primary); FCM only if remote push is genuinely needed | Routine reminders are device-local; no server needed |
| Local cache | Firestore offline persistence + a lightweight local store for app settings | Avoid duplicating the source of truth |
| Speech output | Platform TTS | Native, offline-capable, zero cost |
| Speech input | Platform STT | Phase 5 only |
| On-device ML | TensorFlow Lite / MediaPipe | Facial expression practice, runs locally |
| Design | Figma | UI/UX planning before implementation |

**Dependency rule:** every package added requires a one-line written justification in the PR. If Flutter, Firebase, or an existing dependency already does the job, no new package.

---

## 8. Architecture

Feature-based Flutter architecture.

```
lib/
├── core/
│   ├── constants/       app-wide constants
│   ├── theme/           theming incl. sensory-friendly variants
│   ├── localization/    ARB files, EN/UR, RTL handling
│   ├── routing/         navigation, child-mode guard
│   ├── services/        TTS, notifications, connectivity, ML
│   ├── utils/           shared helpers
│   └── widgets/         reusable child-friendly components
│
├── features/
│   ├── authentication/
│   ├── onboarding/
│   ├── communication/       (AAC)
│   ├── social_communication/
│   ├── emotion_recognition/
│   ├── routines/
│   ├── interest_learning/
│   ├── sensory_support/
│   ├── gamification/
│   ├── progress/
│   ├── parent_dashboard/
│   └── settings/
│
└── main.dart
```

Each feature contains only the layers it needs — typically `models/`, `data/` (repository), `providers/`, `presentation/`, `widgets/`. Trivial features do not get ceremonial layers they don't use.

---

## 9. Conceptual Data Model

Collections are created **only when the feature that needs them is implemented.**

| Collection | Purpose | Created in |
|-----------|---------|-----------|
| `users` | Parent/teacher accounts, role, linked children | Phase 1 |
| `children` | Child profile, age, interests, preferences, support level | Phase 1 |
| `communication_cards` | Default + custom AAC cards | Phase 2 |
| `social_stories` | Story content and steps | Phase 2 |
| `activities` | Activity definitions (emotion, learning) | Phase 2 |
| `progress` | Per-child activity results and scores | Phase 2 |
| `routines` | Routine templates and daily steps | Phase 3 |
| `learning_content` | Interest-mapped learning items | Phase 3 |
| `observations` | Manual caregiver observation logs | Phase 4 |

**Data ownership rules enforced in Firestore Security Rules:**

- A parent reads/writes only their own children's data
- A teacher reads only explicitly assigned children, and writes only observations
- No user can read another user's records
- Client-side checks are UX only — the rules are the actual boundary

---

## 10. Non-Functional Requirements

| Area | Requirement |
|------|-------------|
| **Performance** | Screen transitions under 300 ms; TTS playback starts under 500 ms from tap |
| **Latency** | On-device inference preferred; no per-frame network calls; assets preloaded |
| **Offline** | AAC, routines, downloaded stories, and basic progress recording all work offline |
| **Accessibility** | Minimum 64 dp tap targets in child screens; WCAG AA contrast; audio labels |
| **Privacy** | Minimum data collection; camera frames processed on-device and discarded; no raw audio/video stored; no third-party analytics on child data |
| **Security** | No hard-coded secrets; Firestore rules enforced server-side; auth required for all writes |
| **Reliability** | Every network/AI operation has explicit loading, success, empty, error, and retry states |
| **Error UX** | Child screens show friendly, non-technical messages; technical detail only in caregiver screens/logs |
| **Localisation** | Zero hard-coded user-facing strings; RTL verified for Urdu |

---

## 11. Delivery Phases

> Timeline assumes a ~16-week semester (Assumption A2). Adjust week ranges to your actual calendar.

### Phase 1 — Foundation (Weeks 1–3)
Flutter project setup, Firebase integration, authentication, user and child profile CRUD, routing, theming, localisation scaffolding.
**Exit criteria:** A parent can register, log in, create a child profile, and switch the app language.

### Phase 2 — Core Child Experience (Weeks 4–7)
AAC communication aid, TTS, social stories, emotion identification activities, basic gamification.
**Exit criteria:** A child can compose and speak a sentence, complete a social story, and complete an emotion activity that records a result.

### Phase 3 — Routines & Learning (Weeks 8–10)
Visual schedule, reminders, routine tracking, transition warnings, flexibility training, interest profile and interest-based learning, rule-based adaptive difficulty.
**Exit criteria:** A parent can configure a routine that produces reminders and completion records; difficulty adapts to performance.

### Phase 4 — Parent & Teacher Dashboard (Weeks 11–12)
Progress views, activity history, observation logging, weekly charts.
**Exit criteria:** A caregiver can view a week of activity with charts and add an observation.

### Phase 5 — Advanced AI (Weeks 13–14)
On-device facial expression recognition, speech-to-text, guided conversation practice, refined adaptive logic.
**Exit criteria:** Expression practice runs locally on-device with acceptable latency.

### Phase 6 — Hardening & Documentation (Weeks 15–16)
Testing, bug fixing, performance tuning, sensory mode audit, Urdu/RTL audit, final report, demo preparation.

**Contingency:** If the schedule slips, Phase 5 is reduced (expression recognition only, drop STT) and Phase 6 is protected. Phases 1–4 constitute the defensible minimum project.

---

## 12. Deliverables

1. Flutter source code (Android + iOS build capable), version controlled
2. Signed Android APK for demonstration
3. Firebase project with deployed Firestore Security Rules
4. Figma UI/UX designs
5. Test suite (unit + widget; integration tests for key flows)
6. Technical documentation: architecture, data model, setup guide
7. FYP report and presentation deck
8. Live demonstration script

---

## 13. Testing Strategy

| Type | Coverage Focus |
|------|----------------|
| **Unit** | Adaptive difficulty logic, progress calculations, routine scheduling, AAC sentence building, interest→topic mapping |
| **Widget** | Reusable child-facing components, AAC grid, routine card, emotion activity screen |
| **Integration** | Auth → profile creation flow; complete-an-activity → progress-recorded flow |
| **Manual** | Sensory mode audit, Urdu/RTL layout audit, offline behaviour, on-device ML latency |

Every merged change must pass `flutter analyze` with no errors.

---

## 14. Risks and Mitigation

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|-----------|
| On-device emotion model underperforms or is too slow | Medium | Medium | Phase 5 is intentionally late; recognition activities work fully without the camera feature |
| Urdu TTS quality varies by device | Medium | High | Test on target devices early; fall back to pre-recorded audio for core AAC phrases |
| Scope creep across seven modules | High | High | Phase gates with explicit exit criteria; out-of-scope list is binding |
| Offline sync conflicts | Low | Medium | Last-write-wins; no complex CRDT/merge logic |
| Firestore free-tier read limits during testing | Low | Medium | Rely on offline persistence; avoid real-time listeners where a one-time fetch suffices |
| No access to real autistic children for testing | Medium | High | Validate design against published accessibility guidance; seek feedback from a special-education teacher if possible |
| Team member unavailability | Medium | Medium | Feature-based structure limits coupling; document as you go |

---

## 15. Ethical and Privacy Commitments

These are non-negotiable and must appear in the final report.

- AutiMate makes **no** diagnostic, clinical, or therapeutic claims anywhere in the UI, marketing, or documentation
- Emotion recognition output is labelled as a learning aid, never as fact about a person's feelings
- Camera frames are processed on-device and immediately discarded — never uploaded, never stored
- Only data strictly necessary for a feature is collected
- No behavioural auto-labelling; caregiver observations are free-text and human-authored
- No advertising, no third-party analytics on child data
- A visible privacy statement is shown during onboarding

---

## 16. Assumptions Requiring Confirmation

These are **assumptions, not decisions.** Please confirm or correct before the team starts.

| ID | Assumption |
|----|-----------|
| A1 | Team size and role split are not yet defined — Section 17 is a proposal, not a fact |
| A2 | Timeline is approximately 16 weeks; adjust phase weeks to your real academic calendar |
| A3 | Android is the primary build and demo target; iOS is best-effort |
| A4 | The web dashboard is **out of core scope** and will only be attempted if Phases 1–5 complete early |
| A5 | Child accounts do not exist — the child uses a profile inside the parent's authenticated session |
| A6 | Social story and learning content will be authored by the team (a small fixed set), not sourced from a licensed library |
| A7 | Card imagery will use openly licensed icon sets; no proprietary AAC symbol libraries (e.g. PCS, Widgit) will be used |
| A8 | No real clinical/user trial with autistic children is planned; evaluation is heuristic and supervisor-guided |
| A9 | Firebase free (Spark) tier is sufficient for development and demonstration |

---

## 17. Proposed Work Allocation *(adjust to actual team)*

| Track | Responsibility |
|-------|----------------|
| **Track A — Foundation & Data** | Firebase setup, auth, profiles, Firestore rules, repositories, offline strategy |
| **Track B — Child Experience** | AAC, social stories, emotion activities, sensory mode, gamification, child-facing widgets |
| **Track C — Routines & Learning** | Visual schedule, reminders, flexibility training, interest learning, adaptive difficulty |
| **Track D — Caregiver & Quality** | Dashboard, progress charts, observations, localisation, testing, documentation |

Shared responsibilities: Figma design, code review, report writing.

---

## 18. Definition of Done (per feature)

A feature is complete only when **all** of the following are true:

1. Implemented following the existing feature-based architecture
2. All user-facing strings localised (EN + UR), RTL verified
3. Loading / success / empty / error / retry states handled
4. Child-facing errors are friendly and non-technical
5. Respects sensory-friendly mode
6. Unit and/or widget tests written and passing
7. `flutter analyze` clean
8. Works offline where the offline requirement applies
9. Firestore rules updated if new data is touched
10. Reviewed by at least one other team member

---

## 19. Sign-Off

| Name | Role | Date | Approved |
|------|------|------|----------|
| | Project Lead | | ☐ |
| | Team Member | | ☐ |
| | Team Member | | ☐ |
| | Supervisor | | ☐ |

---

*End of document — v1.0. Any change to Section 5 (In Scope) or Section 6 (Out of Scope) requires team agreement and a version bump.*
