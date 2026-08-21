# AutiMate — D3 Track Plan: AI, Speech & Adaptive Logic

**Owner:** Muhammad Hamza Habib (Track D3)
**Team size:** 4 · **Role split:** D1 Frontend/Design System · D2 Firebase/Data · **D3 AI/Speech/Logic (me)** · D4 Integration/Dashboard/Release
**Context:** Alibaba Cloud AI Hackathon Pakistan 2026 — build phase 22–27 August 2026
**Document version:** 1.0 · **Written:** 20 August 2026
**Status:** Draft for team review — Section 13 needs answers before Day 0

---

## 0. The Refined Prompt

The original ask was: *"analyse the 3 documents, tell me my AI-side work, how to do it, what stack to use, and write it up."*

Refined into the question this document actually answers:

> Given the AutiMate scope document (16-week FYP plan), the 7-day sprint plan (4-person vertical slice), and the Alibaba Cloud AI Hackathon Pakistan 2026 schedule (build phase 22–27 August, regional round 28–30 August), define the **D3 / AI track** as an executable work order:
>
> 1. **What** — the exact deliverables I own, the boundary against D1/D2/D4, and what I explicitly do not own.
> 2. **How** — a day-by-day build order mapped onto the real hackathon calendar, the algorithms behind each deliverable, and the interface contracts my teammates code against (frozen end of Day 2).
> 3. **Stack** — the packages, APIs and services I will use, each with a one-line justification, plus the alternatives I am rejecting and why.
>
> Constraints to respect: offline-first, no open-ended generative AI facing children, no custom-trained ML model this week, on-device inference only for anything involving a child's camera, bilingual EN/UR with RTL, and an honest AI story that survives a judge asking *"where is the AI?"*

---

## 1. What the Three Documents Say Together

Read individually the three documents conflict. Read together they resolve cleanly.

| Document | What it is | How I treat it |
|---|---|---|
| `AutiMate_Scope_Doc.md` | The full 16-week FYP product vision, 8 modules | **The north star and the report.** Defines the feature set I design toward and document, not what I build this week |
| `AutiMate_7Day_Sprint_Plan.md` | A 4-person, 7-day vertical slice of that scope | **The build order.** This is what ships |
| `ABC_AIH_Training_and_Programme_Schedule.pdf` | Alibaba Cloud AI Hackathon Pakistan 2026 calendar | **The hard deadline.** It converts the sprint plan's abstract "Day 1–7" into real dates and adds a judging audience |

### 1.1 The real calendar

The sprint plan's day numbers map onto the hackathon schedule as follows. This mapping is the most important thing in this section — the sprint plan assumes 7 days, the hackathon gives 6.

| Sprint day | Real date | What happens | My gate |
|---|---|---|---|
| **Day 0** | Thu 21 Aug | Qoder access issued to participation email. Environment setup | **Urdu TTS voice verified on the physical demo device.** Non-negotiable |
| Day 1 | Fri 22 Aug | Build phase opens. Foundations, everyone parallel | TTS service speaks EN + UR on a real device |
| Day 2 | Sat 23 Aug | Shared layer complete. **Interfaces freeze** | Sentence realiser + emotion engine, unit tested, pure Dart |
| Day 3 | Sun 24 Aug | AAC — all hands on the flagship | Tap → phrase → speech, offline, both languages |
| Day 4 | Mon 25 Aug | Emotion activity + sensory mode | A 5-question session scores and writes progress |
| Day 5 | Tue 26 Aug | Routines + dashboard. **P0 feature-complete** | Routine narration; P1 expression practice starts only if free |
| Day 6 | Wed 27 Aug | Hardening. **Code freeze midday.** Build phase closes | Signed APK on demo device, two clean run-throughs |
| — | Thu 28 / Fri 29 / Sat 30 Aug | **Regional round, in person** (Karachi / Lahore / Islamabad) | Demo + Q&A |
| — | 31 Aug – 2 Sep | Judging and finalist selection | — |
| — | 10 Sep | National Grand Finale | — |

**Consequence:** there is no Day 7. The sprint plan's Day 7 (freeze, document, rehearse) collapses into the second half of Day 6 and the night before the regional round. Rehearsal happens on Day 6 evening, not on a spare day. Plan the last 24 hours accordingly.

### 1.2 What the hackathon context changes for me

The FYP framing says *"do not overstate the AI."* The hackathon framing says *"AI for Pakistan's Future"* and puts me in front of judges who will look for it. These are not in conflict, but they shift my emphasis:

- The AI must be **visible and live on stage**, not a claim in a report. A meter that fills as a child smiles beats a paragraph about a classifier.
- The AI must be **defensible under questioning**. Rule-based systems described honestly score better than neural claims that collapse under one question.
- Every AI feature must **degrade gracefully offline**, because the demo may run on venue wifi or none at all.

My track is where the judges' attention will land. I own the answer to *"where is the AI?"* (Section 11).

---

## 2. My Role: The D3 Boundary

### 2.1 I own

Everything that **thinks**, and everything that **makes sound**.

- Text-to-Speech service — bilingual, queued, interruptible, offline
- AAC sentence assembly — cards → grammatical phrase → speech, in two languages with different word order
- Card ranking — the "recently used / frequently used" personalisation
- Emotion activity engine — question generation, distractor selection, scoring, difficulty tiers
- Adaptive difficulty — the rule-based promotion/demotion state machine
- Routine step narration (Day 5)
- **P1:** on-device expression practice via ML Kit face detection

### 2.2 I do not own

Stating this explicitly prevents the most expensive failure mode in a 6-day sprint: two people editing the same file.

| Not mine | Whose | Why the line is there |
|---|---|---|
| Any widget, screen, or theme | D1 | I deliver logic and services; D1 renders them |
| Firestore reads/writes, models, security rules | D2 | I consume repository interfaces, I never touch Firestore directly |
| Wiring my services into screens | D4 | D4 integrates; I provide testable units |
| ARB files and localisation strings | D1 | I emit **localisation keys and structured data**, never user-facing English |
| The chart, the dashboard, progress aggregation | D4 | I produce the per-session result object D4 aggregates |

**The one rule that protects this:** my code lives under `lib/core/services/` and `lib/features/*/logic/` and depends only on Dart, my own packages, and D2's repository *interfaces*. It imports nothing from `presentation/`. If my code needs a widget, the design is wrong.

### 2.3 Why this split suits my track

My track carries the highest **risk concentration on Day 0–1** (does an Urdu voice exist on the device?) and the highest **testability** (all of it is pure Dart except TTS and the camera). That means:

- I can be productive before D1 and D2 have delivered anything, because my logic needs no UI and no database.
- My work is the easiest to unit test, so I carry the team's test-coverage claim.
- If I finish P0 early I unlock the single strongest demo moment (expression practice). If I run late, everything I own has a documented rule-based fallback.

---

## 3. My Deliverables

Seven deliverables, each with an acceptance test. A deliverable is not done because the code exists; it is done when the acceptance line is true **on the physical demo device**.

| # | Deliverable | Priority | Est. | Acceptance |
|---|---|---|---|---|
| **A1** | `TtsService` — bilingual, queued, warm-started | P0 | 6h | Speaks an English and an Urdu string in airplane mode; first utterance starts < 500 ms after tap |
| **A2** | `SentenceRealiser` — EN (SVO) + UR (SOV) surface realisation | P0 | 6h | `[I want][apple]` → *"I want an apple."* / *"میں سیب چاہتا ہوں"*, with correct verb gender agreement |
| **A3** | `CardRanker` — recency-weighted frequency personalisation | P0 | 2h | After a child uses "water" five times it appears in the top row with no manual configuration |
| **A4** | `EmotionActivityEngine` — question generation, distractors, scoring | P0 | 6h | A 5-question session returns a `SessionResult` D4 can persist; distractors get harder as level rises |
| **A5** | `AdaptiveLevelController` — rule-based promotion/demotion | P0 | 3h | 3 consecutive correct → level up; 2 consecutive wrong → level down + hints on; parent lock overrides both |
| **A6** | Routine step narration | P0 | 2h | Tapping a routine step speaks its label in the active language |
| **A7** | `ExpressionPracticeService` — ML Kit face detection | **P1** | 8h | "Make a happy face" — a live meter fills as `smilingProbability` rises, entirely on-device, no frame stored |

**Total P0 ≈ 25 hours.** Across Days 1–5 at ~6 productive hours/day that is 30 hours of capacity, leaving ~5 hours of slack — which will be consumed by integration support for D4. That is the honest budget: **P1 (A7) only happens if A1–A6 land on schedule.**

---

## 4. Interface Contracts — Frozen End of Day 2

These are the signatures D1, D2 and D4 code against. Publishing them on Day 1 and freezing them on Day 2 is the highest-leverage thing I do all week: it lets three other people write code against my track before my track exists.

I will post these in the team channel on **Day 1 evening** marked provisional, and re-post on **Day 2 evening** marked frozen. After that a signature change costs the whole team an hour and needs everyone's agreement.

### 4.1 Speech

```dart
enum AppLanguage { en, ur }
enum TtsState { idle, speaking, unavailable }

/// Result of asking the platform whether it can speak a language.
class VoiceAvailability {
  final AppLanguage language;
  final bool available;
  final String? resolvedLocale;    // e.g. 'ur-PK', 'ur-IN', null if unavailable
  final bool usingRecordedFallback;
  const VoiceAvailability({...});
}

abstract class TtsService {
  /// Call once during app start. Resolves voices and warms the engine so the
  /// first real utterance is not slowed by engine initialisation.
  Future<void> initialise();

  /// Availability per language — for the settings screen and for my fallback.
  Future<List<VoiceAvailability>> availability();

  /// Speak now, cancelling anything currently speaking (barge-in).
  /// Never throws — failures surface through [state].
  Future<void> speak(String text, AppLanguage language);

  /// Queue behind whatever is speaking. Used for routine step sequences.
  Future<void> enqueue(String text, AppLanguage language);

  Future<void> stop();

  /// D1 binds a speaker icon to this.
  Stream<TtsState> get state;
}
```

**Contract notes for the team**
- `speak()` never throws. If no voice exists it emits `TtsState.unavailable` and returns. D1 shows a muted-speaker state; nothing crashes mid-demo.
- `initialise()` must be awaited in `main()` before the first frame, or the first tap will feel slow.
- I own the fallback chain. Callers never need to know whether audio came from the platform engine or a recorded asset.

### 4.2 AAC sentence assembly

```dart
enum PartOfSpeech { carrier, pronoun, verb, noun, adjective, quantifier }
enum UrduGender { masculine, feminine }

/// The grammar-relevant subset of a card. D2 owns the full Firestore model
/// and maps into this; my logic never sees a Firestore document.
class CardGrammar {
  final String id;
  final String labelEn;
  final String labelUr;
  final PartOfSpeech pos;
  final bool isCountable;           // drives a / an / some in English
  final bool startsWithVowelSound;  // 'apple' true, 'university' false
  final UrduGender urduGender;      // drives Urdu adjective/verb agreement
}

/// Grammatical facts about the child, from their profile.
class SpeakerProfile {
  final UrduGender gender;  // Urdu verbs agree with the speaker: چاہتا / چاہتی
}

class RealisedSentence {
  final String text;        // the string to speak and to show on the strip
  final AppLanguage language;
}

abstract class SentenceRealiser {
  RealisedSentence realise(List<CardGrammar> strip, SpeakerProfile speaker);
}
```

**Contract notes**
- D2 must include `pos`, `isCountable`, `startsWithVowelSound` and `urduGender` on every seeded card. **This is the one thing I need from D2 on Day 1.** If the seed data lacks these fields, A2 degrades to naive word-joining. It is four extra fields, seeded once.
- The realiser is pure and synchronous — no I/O, no futures, fully unit testable.

### 4.3 Card ranking

```dart
class CardUsageEvent {
  final String cardId;
  final DateTime usedAt;
}

abstract class CardRanker {
  /// Top-N card ids for the "Frequently used" row, most-relevant first.
  List<String> rank(List<CardUsageEvent> history, {int limit = 8});
}
```

### 4.4 Emotion activity

```dart
enum EmotionLabel { happy, sad, angry, surprised, scared, neutral }
enum SupportLevel { beginner, intermediate, advanced }

class EmotionQuestion {
  final String assetKey;             // which face image — D1 resolves to an asset
  final EmotionLabel answer;
  final List<EmotionLabel> choices;  // shuffled, includes the answer
  final bool hintVisible;
  final int index;                   // 1-based, for "Question 3 of 5"
  final int total;
}

class AnswerOutcome {
  final bool correct;
  final EmotionLabel picked;
  final EmotionLabel answer;
  final bool showHintNext;
}

/// Handed to D4 to persist and to the summary screen to render.
class SessionResult {
  final String childId;
  final String activityType;    // 'emotion_identification'
  final int score;
  final int total;
  final SupportLevel levelPlayed;
  final SupportLevel levelAfter; // may differ — the adaptive rule stepped it
  final Duration duration;
  final DateTime completedAt;
  final int starsAwarded;        // 0–3
}

abstract class EmotionActivityEngine {
  EmotionQuestion start({required SupportLevel level, int questionCount = 5});
  AnswerOutcome submit(EmotionLabel picked);
  EmotionQuestion? next();      // null when the session is over
  SessionResult finish();
}
```

**Contract notes**
- The engine returns `assetKey` and `EmotionLabel` enums — **never display text**. D1 maps enum → localised label; I stay out of the ARB files entirely. This is what keeps Urdu working without me touching it.
- `SessionResult` is the exact shape D2 writes to `progress/{progressId}` and D4 aggregates for the chart. **Agree this shape with both of them on Day 1** — it crosses three tracks.

### 4.5 Adaptive level

```dart
abstract class AdaptiveLevelController {
  SupportLevel evaluate({
    required SupportLevel current,
    required List<bool> recentOutcomes,  // most recent last
    required bool parentLocked,
  });
}
```

### 4.6 Expression practice (P1)

```dart
class ExpressionReading {
  final double smile;           // 0.0–1.0
  final double leftEyeOpen;
  final double rightEyeOpen;
  final double headTiltDegrees;
  final bool faceDetected;
}

abstract class ExpressionPracticeService {
  Future<bool> isSupported();

  /// Emits ~10–15 readings/second while the camera streams.
  /// Frames are processed in memory and discarded — never written, never uploaded.
  Stream<ExpressionReading> start();

  Future<void> stop();
}
```

---

## 5. How I Build It — Day by Day

### Day 0 — Thursday 21 August: the risk-retirement day

Qoder access arrives today against the participation email. Nothing in the sprint plan officially starts, but **the single largest risk in my track is retired today, not on Day 1.**

| Task | Time | Why now |
|---|---|---|
| Claim Qoder access; do **not** have registered a Qoder account with the participation email beforehand | 30 m | Per the programme document §5, a pre-existing account blocks the issued access |
| Flutter + Android SDK working, physical Android device in developer mode | 1 h | Emulator TTS is unreliable; everything I own must be verified on hardware |
| **Urdu TTS probe** — a 20-line throwaway Flutter app that calls `getLanguages` and tries to speak an Urdu string | **2 h** | This determines whether A1 is a 6-hour task or a 12-hour task. Find out today |
| Post the probe result to the team | 15 m | If Urdu TTS is missing, D1's Urdu plan and D4's demo script both change |

**The probe, concretely:**

```dart
final tts = FlutterTts();
print(await tts.getLanguages);                  // dump every locale the device has
print(await tts.isLanguageAvailable('ur-PK'));  // Pakistan Urdu
print(await tts.isLanguageAvailable('ur-IN'));  // India Urdu — often present when ur-PK is not
print(await tts.isLanguageAvailable('ur'));     // generic
await tts.setLanguage('ur-PK');
await tts.speak('السلام علیکم، میں سیب چاہتا ہوں');
```

**Three outcomes, three plans:**

1. **An Urdu voice speaks.** A1 is a 6-hour task. Proceed as planned. Record which locale string worked and pin it.
2. **No Urdu voice, but Google Speech Services can install one** (Android Settings → System → Languages & input → Text-to-speech output → Install voice data). Install it on the demo device, note it in the setup README, and **buy a second device that also has it** so the demo is not hostage to one phone.
3. **No Urdu voice available at all.** Fall back to pre-recorded Urdu audio for a fixed set of ~30 core AAC phrases and the six emotion labels. This adds one package (`audioplayers`, see §7.2) and roughly 4 hours of recording and wiring. **This decision must be made on Day 0** — discovering it on Day 5 would be fatal.

> Under outcome 3, the honest framing is: *"Urdu speech uses recorded native-speaker audio for the core vocabulary, with platform TTS where a device voice is available."* Recorded native audio is arguably **better** for a child-facing accessibility app than a synthetic voice. It is not a downgrade to apologise for.

### Day 1 — Friday 22 August: TTS

**Goal:** the app speaks, in both languages, on hardware, offline.

1. **Skeleton and dependency setup** (30 m) — add `flutter_tts` only. Nothing else yet.
2. **Implement `TtsService`** (3 h)
   - Locale resolution with a fallback ladder: `ur-PK` → `ur-IN` → `ur` → recorded fallback → `unavailable`. Resolve once during `initialise()` and cache it; do not probe on every utterance.
   - `awaitSpeakCompletion(true)` so `speak()` genuinely awaits, which is what makes queueing possible.
   - A serial queue (a `Queue<_Utterance>` drained by a single loop) so five fast card taps produce five clean utterances rather than garbled overlap.
   - `speak()` = clear queue + stop + enqueue (barge-in). `enqueue()` = append.
   - Child-appropriate prosody: `setSpeechRate` around 0.45–0.5 on Android (the platform default is too fast for a child), `setPitch(1.0)`, `setVolume` capped so sensory mode can lower it further.
3. **Warm start** (45 m) — the first `speak()` on Android pays engine-initialisation cost that can exceed the 500 ms NFR. In `initialise()`, set the language and speak a single space at volume 0. Measure the first-tap latency with a `Stopwatch` and record the number; it is a real NFR I can quote to a judge.
4. **Sensory-mode hook** (30 m) — expose a volume ceiling and a slower rate that D1's sensory provider can drive. My service reads a settings object; it does not read the theme.
5. **Publish the provisional interfaces** from §4 (30 m).
6. **Device verification and hand-off note** (45 m).

**Day 1 gate:** on the physical device, in airplane mode, the app speaks *"I want an apple"* and *"میں سیب چاہتا ہوں"*.

### Day 2 — Saturday 23 August: logic day (pure Dart, no UI, no Firebase)

This is the day my track pulls ahead, because none of it depends on anyone else.

1. **`SentenceRealiser`** (4 h) — English and Urdu, per §6.1. Write the tests first; the rules are crisp enough that TDD is genuinely faster here.
2. **`EmotionActivityEngine`** (3 h) — question generation, the confusability-driven distractor picker (§6.3), scoring, star awards.
3. **`AdaptiveLevelController`** (1 h) — the state machine in §6.4.
4. **`CardRanker`** (1 h) — §6.2.
5. **Freeze and re-publish the interfaces** (30 m).

**Day 2 gate:** `flutter test` green with roughly 25–30 unit tests, zero UI code written, zero Firebase dependency. **Interfaces frozen.**

> Everything above is pure Dart. If Firebase is broken, or D1's theme is half-finished, or the device is in someone else's bag, none of it blocks me. That is why logic day is Day 2.

### Day 3 — Sunday 24 August: AAC — all hands on the flagship

D1 builds the grid, D2 loads the cards, D4 integrates. **I build the pipeline in the middle.**

1. **Card tap → strip → phrase → speech** (2 h) — the controller that holds the sentence strip, calls the realiser on every change, and speaks on the Speak button.
2. **Speak-on-tap vs speak-on-strip** (1 h) — each individual card also speaks its own label on tap (immediate auditory feedback is an AAC design norm), while the strip speaks the assembled sentence. Two different call sites, one service, barge-in handles the collision.
3. **Wire `CardRanker`** (1 h) — usage events recorded through D2's repository, ranking applied to the "Frequently used" row.
4. **Language switching mid-session** (1 h) — the strip is a list of card ids, not text; switching language re-realises the same strip through the other realiser. **This is a very strong 10-second demo moment: same taps, one toggle, correct Urdu word order.** Rehearse it.
5. **Offline verification in airplane mode** (1 h).

**Day 3 gate:** child taps `[I want]` `[apple]` → phone says *"I want an apple."* Toggle to Urdu → *"میں سیب چاہتا ہوں"*. Airplane mode on throughout.

### Day 4 — Monday 25 August: emotion activity

1. **Wire the engine into D1's screens** (2 h) — I supply a Riverpod controller exposing `EmotionQuestion`; D1 renders it. I do not build the screen.
2. **Feedback loop** (1 h) — correct/incorrect audio and spoken reinforcement through `TtsService`, respecting sensory mode (no sudden loud sounds — this is an explicit scope commitment, not a nicety).
3. **Difficulty tiers live** (1 h) — 2/3/4 choices, hint visibility, distractor difficulty all driven by `SupportLevel`.
4. **`SessionResult` handed to D4** (1 h) — verify it lands in Firestore and survives an offline→online round trip.
5. **Adaptive controller wired** (1 h) — level steps between sessions and the change is visible on the summary screen.

**Day 4 gate:** a child completes 5 questions, sees stars, the result appears in Firestore, and the level visibly adapts.

### Day 5 — Tuesday 26 August: narration, then P1

1. **Routine step narration** (2 h) — tap a step, hear it; "next step" narration queued via `enqueue()`.
2. **Decision point, 14:00 sharp.** If A1–A6 are all green and D4 is not blocked on me, start A7. Otherwise do not start it — spend the time on hardening and support instead.
3. **A7 expression practice** (remaining hours) — per §6.5.

**Day 5 gate:** P0 complete for my track. Everything after this is polish.

### Day 6 — Wednesday 27 August: hardening and freeze

- **Morning:** finish A7 **only if it already runs**. Per the sprint plan, if it is not working by noon, cut it and say so. Cutting a P1 cleanly is a good decision; demoing a crash is not.
- **Midday: code freeze.** Only crash fixes afterwards.
- **Afternoon:** the audit list below, then the demo rehearsal.

**My Day 6 audit checklist**

- [ ] Every `speak()` call site handles `TtsState.unavailable` without a crash
- [ ] TTS stops when a screen is disposed (a voice speaking over the next screen is the classic demo embarrassment)
- [ ] Rapid-tap stress test — 20 taps in 5 seconds produces clean audio, no overlap, no crash
- [ ] Airplane-mode run through AAC, emotion activity and routines
- [ ] Sensory mode verified: volume ceiling applied, rate slowed, no sudden loud audio anywhere
- [ ] Urdu realiser checked against the full seeded card set, not just the demo phrases
- [ ] `flutter analyze` clean; `flutter test` green
- [ ] Camera permission denial handled gracefully (if A7 shipped)
- [ ] First-utterance latency re-measured on the demo device and written down

---

## 6. The Algorithms

This section is what makes the track defensible in Q&A. Each subsection is a design I can explain on a whiteboard.

### 6.1 Bilingual sentence realisation

This is the most technically interesting thing in my track and the part judges are most likely to probe.

**The problem.** English is SVO: *I want an apple.* Urdu is SOV: *میں سیب چاہتا ہوں* — literally *I apple want-am*. A word-by-word translation of the English strip produces broken Urdu. So the sentence strip cannot be a string; it must be a **structure** that each language renders independently.

**The design.** The strip is a `List<CardGrammar>`. Two realisers consume it:

**English realiser**
1. Order: carrier/pronoun → verb → quantifier/adjective → noun (already the tap order, so mostly identity).
2. Article selection: countable + singular → `an` before a vowel sound, else `a`; uncountable → `some` or bare.
3. Capitalise the first word, append a full stop.
4. `[I want][apple]` → *"I want an apple."*

**Urdu realiser**
1. Reorder to SOV: subject → object → verb.
2. Verb agreement with the **speaker's gender** from `SpeakerProfile`: چاہتا ہوں (masculine) vs چاہتی ہوں (feminine).
3. No articles — Urdu has none, so the English article logic is simply skipped rather than translated.
4. `[I want][apple]` → *میں سیب چاہتا ہوں*

**Why this is worth saying out loud in the demo.** Most bilingual apps translate strings. This one **generates** a sentence per language from a shared semantic structure, which is why the Urdu is grammatical rather than word-salad — and why a girl's app says چاہتی and a boy's says چاہتا. That is a two-hour implementation detail that reads as real linguistic engineering, because it is.

**Honest framing:** this is rule-based natural language generation — specifically surface realisation. It is not machine learning and I will not call it machine learning. It is the correct tool: deterministic, offline, explainable, and it cannot produce an unsafe utterance, which matters when the user is a child.

**Test cases to write on Day 2**

| Strip | English | Urdu |
|---|---|---|
| `[I want][apple]` | I want an apple. | میں سیب چاہتا ہوں |
| `[I want][water]` (uncountable) | I want some water. | میں پانی چاہتا ہوں |
| `[I want][book]` | I want a book. | میں کتاب چاہتی ہوں (feminine speaker) |
| `[I feel][happy]` | I feel happy. | میں خوش ہوں |
| `[apple]` (bare noun) | Apple. | سیب |
| `[]` (empty strip) | *(no speech, no crash)* | *(no speech, no crash)* |

The empty-strip and single-card cases are the ones that crash live demos. Test them first.

### 6.2 Card ranking — recency-weighted frequency

**Naive approach:** sort by raw usage count. Problem — a card used 40 times last month outranks the card the child needs today.

**My approach:** exponential recency decay.

```
score(card) = Σ over uses  exp(-λ · ageInDays)
λ = ln(2) / 7        // a use is worth half as much after 7 days
```

Sum the decayed weight of every use of a card; sort descending; take the top 8.

**Properties worth stating:** it is a single line of arithmetic, it needs no training data, it runs offline in microseconds, it self-corrects when a child's needs change, and I can explain exactly why any given card is in the top row. Compared with a collaborative-filtering recommender it is not just cheaper — it is *more appropriate*, because a caregiver can predict and trust its behaviour.

**Demo line:** *"The grid learns the child's vocabulary. Use 'water' a few times and it moves to the front — with a half-life, so last month's habits don't crowd out today's needs."*

### 6.3 Distractor selection and the confusability matrix

Random wrong answers make a bad teaching activity: *happy* against *sad* is trivial at every level, so the child stops learning.

**My approach:** a confusability matrix over the six emotions — a hand-authored 6×6 table of how easily each pair is mistaken for the other, grounded in the visual features that distinguish them (mouth curvature, eyebrow angle, eye aperture).

| | happy | sad | angry | surprised | scared | neutral |
|---|---|---|---|---|---|---|
| **happy** | — | 0.1 | 0.1 | 0.3 | 0.1 | 0.4 |
| **sad** | 0.1 | — | 0.5 | 0.1 | 0.6 | 0.4 |
| **angry** | 0.1 | 0.5 | — | 0.2 | 0.5 | 0.3 |
| **surprised** | 0.3 | 0.1 | 0.2 | — | 0.7 | 0.2 |
| **scared** | 0.1 | 0.6 | 0.5 | 0.7 | — | 0.2 |
| **neutral** | 0.4 | 0.4 | 0.3 | 0.2 | 0.2 | — |

Selection rule by level:

- **Beginner** — 2 choices, distractor drawn from the *lowest* confusability band (happy vs sad). Success is the goal.
- **Intermediate** — 3 choices, mid band.
- **Advanced** — 4 choices, drawn from the *highest* band (scared vs surprised, sad vs scared). Genuine discrimination is the goal.

**Why this matters academically.** It turns a quiz into a graded discrimination task with a defensible pedagogical basis. When a judge asks *"how does difficulty actually increase?"*, "more options appear" is a weak answer; "the wrong answers become visually harder to distinguish, along a matrix I can show you" is a strong one.

### 6.4 Adaptive difficulty state machine

```
promote  : 3 consecutive correct    → step up   (advanced is the ceiling)
demote   : 2 consecutive incorrect  → step down + hints on (beginner is the floor)
otherwise: hold
parentLocked == true → always hold, whatever the outcomes
```

Deliberate design choices, each with a reason a judge may ask for:

- **Promotion is slower than demotion** (3 up, 2 down). Frustration costs an autistic child more than boredom does; the system errs toward success.
- **Evaluated between sessions, not mid-session.** Difficulty shifting under a child mid-activity is disorienting — predictability is a core requirement of this product.
- **Parent lock is absolute.** The caregiver knows the child; the rule does not.
- **Pure function.** `evaluate()` takes state in and returns state out — no hidden fields, trivially unit tested, and I can enumerate every possible transition on a whiteboard.

**Framing:** *"We chose a rule-based adaptive system deliberately. A parent can understand exactly why the level changed. A learned policy would need training data we do not ethically have, and would be unexplainable to the person who most needs to trust it."* That answer is stronger than any model I could train this week.

### 6.5 Expression practice pipeline (P1)

Following the sprint plan's Section 6 recommendation: **ML Kit face detection, not a custom TFLite classifier.** Model sourcing, quantisation and preprocessing is 3–4 uncertain days; ML Kit is roughly 4 hours and ships.

**Pipeline**

```
CameraController (front, medium resolution, nv21 on Android)
   → startImageStream
   → throttle to ~10 fps          // ML Kit is fast; the UI does not need 30
   → CameraImage → InputImage     // the fiddly part; see below
   → FaceDetector(enableClassification: true, performanceMode: fast)
   → Face.smilingProbability, leftEyeOpenProbability, headEulerAngleZ
   → exponential moving average (α ≈ 0.3)   // stops the meter jittering
   → ExpressionReading stream → D1's meter widget
```

**Implementation notes that save hours**

- Construct the `CameraController` with `imageFormatGroup: ImageFormatGroup.nv21` on Android and `bgra8888` on iOS. Guessing the format is the single biggest time sink in this integration.
- `FaceDetectorOptions(enableClassification: true)` is required — without it `smilingProbability` is null. Leave contours and landmarks **off**; they cost latency and I do not use them.
- **Throttle with a busy flag**, not a timer: drop incoming frames while a detection is in flight, or the queue backs up and latency climbs steadily until the app stalls.
- Smooth with an EMA before it reaches the UI. Raw per-frame probability jitters and the meter looks broken even when it is working.
- Dispose the detector and stop the stream in `dispose()`. A live camera stream behind a navigation push is a battery drain and an obvious bug in Q&A.

**Privacy — say this on stage, unprompted.** Frames exist in memory for one detection pass and are discarded. Nothing is written to disk, nothing is uploaded, the feature works in airplane mode. This is the concrete proof of the project's privacy commitment, not just a bullet in a document.

**The activity itself:** *"Can you make a happy face?"* A meter fills as `smilingProbability` rises; crossing 0.7 for one continuous second awards a star. Live, responsive, on-device, and visible from across a room. This is the best 20 seconds of the demo — which is exactly why it must not be started before the P0 list is green.

---

## 7. My Technology Stack

### 7.1 Packages I own

| Package | Purpose | Justification (the sprint plan's dependency rule) |
|---|---|---|
| `flutter_tts` | Bilingual speech output | The only maintained Flutter package wrapping platform TTS on both Android and iOS. Uses the on-device engine, so it is offline and free |
| `google_mlkit_face_detection` | **P1** expression practice | On-device, no network, ~30–60 ms per frame, ships a working model. The alternative is 3–4 uncertain days |
| `camera` | **P1** frame source for the above | The official Flutter camera plugin; `startImageStream` is required for live inference |
| `flutter_riverpod` | Exposing my services to the UI | Team standard, set by D2. I add no state-management opinion of my own |
| `flutter_test` | Unit tests for all pure logic | SDK |

**Nothing else.** Everything in §6 is plain Dart: no ML runtime, no NLP library, no code generation. `build_runner` is explicitly excluded — per the sprint plan it is a trap in a one-week sprint, and my hand-written model classes are small enough that generation buys nothing.

### 7.2 Conditional package — decided on Day 0

| Package | Condition | Justification |
|---|---|---|
| `audioplayers` | **Only** if the Day 0 probe finds no usable Urdu voice | Plays pre-recorded Urdu audio assets for core phrases. `flutter_tts` cannot play audio files, so a player is genuinely required, not merely convenient |

### 7.3 Platform APIs beneath the packages

| Layer | Android | iOS |
|---|---|---|
| Speech synthesis | Android `TextToSpeech` (Google Speech Services) | `AVSpeechSynthesizer` |
| Urdu voice | Google Speech Services voice data, may need manual install | System Urdu voice, availability varies |
| Face detection | ML Kit on-device face model, bundled into the APK | Same, via the ML Kit iOS SDK |
| Camera | CameraX / camera2 via the `camera` plugin | AVFoundation |

**Android is the primary target** (Assumption A3 in the scope document, and the demo device is Android). iOS is best-effort and will not be demoed.

### 7.4 Development tooling

| Tool | Use |
|---|---|
| **Qoder** (issued 21 August) | The hackathon's AI IDE — I will use it for the mechanical parts of my track: test scaffolding, boilerplate model classes, ML Kit plumbing. Judges are likely to ask how it was used, so keep concrete examples |
| Flutter DevTools | Latency measurement for the < 500 ms TTS NFR and per-frame ML Kit timing |
| A physical Android device | Non-negotiable. Emulator TTS and emulator camera are both unreliable |
| `flutter test` | The full §6 logic suite |

### 7.5 Alternatives I am rejecting, and why

Have these answers ready — each is a plausible judge question.

| Rejected | Why |
|---|---|
| Custom-trained TFLite emotion classifier | 3–4 days of uncertain work with a real chance of ending Day 6 with nothing. ML Kit delivers a live, on-device, better-demoing feature in ~4 hours. Documented as future work, honestly |
| Cloud speech synthesis (any provider) | Breaks the offline requirement, adds latency and cost, and sends child utterances to a server. Platform TTS is free, instant and local |
| Open-ended LLM chat for the child | Explicitly out of scope in the scope document, on safety grounds. Cannot be adequately guardrailed at this scale, and I will not pretend otherwise |
| A learned adaptive-difficulty policy | No ethically obtainable training data; unexplainable to the parent who must trust it. Rule-based is the correct engineering choice, not a compromise |
| Speech-to-text | Cut from the sprint scope. Phase 5 of the full plan, documented as designed-not-built |
| A translation API for Urdu | Would produce word-order errors exactly where they matter. Language-specific realisation from a shared structure is both cheaper and better |

---

## 8. Optional: the Alibaba Cloud Angle

This is a hackathon run by Alibaba Cloud. Using an Alibaba Cloud AI service is not required by anything I have read, but it is worth a deliberate decision rather than an accidental omission. **Flagging it for the team; not building it unilaterally.**

**The only safe place for a generative model in this product is the parent-facing weekly summary.** Not the child's screen — that is out of scope on safety grounds and I am not reopening it.

**The idea:** on the parent dashboard, a "Weekly summary" that turns aggregated numbers into two or three plain sentences in English or Urdu — *"Ali completed 12 activities this week, up from 8. He is most accurate with 'happy' and 'sad', and finds 'scared' hardest. His morning routine was completed on 5 of 7 days."*

| | Detail |
|---|---|
| Service | Alibaba Cloud Model Studio (DashScope), Qwen family, OpenAI-compatible endpoint |
| Input | **Aggregated counts only** — no child name, no free text, no observations, no media |
| Output | 2–3 sentences, parent-facing, in the parent's chosen language |
| Offline | Falls back to a deterministic template summary. The feature never blocks the dashboard |
| Cost | ~2 hours if the key handling is solved; the generation itself is one HTTP call |

**The blocker to solve first.** The scope document forbids hard-coded secrets, and an API key shipped inside an APK is extractable. The clean fix is a Firebase Cloud Function proxy — but Assumption A9 puts the project on the Firebase Spark tier, and Spark blocks outbound network calls to non-Google services from Cloud Functions. So the honest options are:

1. **Upgrade to Blaze** (pay-as-you-go; free quota comfortably covers a demo) and proxy through a Cloud Function. ~1 hour. Correct and safe.
2. **Skip it.** The template summary is genuinely good and costs nothing.
3. ~~Ship the key in the app~~ — no. It contradicts a stated security commitment, and a judge who asks where the key lives gets an answer that undoes the privacy story I am otherwise telling well.

**My recommendation:** decide this on **Day 5, not before.** If P0 is green and A7 is done or cut, option 1 is a strong two-hour addition that lands squarely in the hackathon's theme. If P0 is anything short of green, option 2 and no regrets. It must never be on the critical path.

---

## 9. My Testing Plan

I carry the team's test-coverage claim, because my track is the testable one.

| Suite | Cases | Priority |
|---|---|---|
| `sentence_realiser_test.dart` | ~12 — a/an/some selection, SOV reordering, gender agreement, empty strip, single card, unknown POS | **Highest** — pure logic, highest bug density, most demo-visible |
| `emotion_engine_test.dart` | ~8 — no repeated questions in a session, answer always present in choices, choice count matches level, distractor band matches level, scoring, star thresholds | High |
| `adaptive_level_test.dart` | ~6 — promote at 3, demote at 2, floor at beginner, ceiling at advanced, parent lock overrides both, empty history holds | High |
| `card_ranker_test.dart` | ~4 — recency beats raw count, empty history returns empty, limit respected, tie-break is stable | Medium |
| `tts_service_test.dart` | ~3 with a fake platform channel — barge-in clears the queue, `enqueue` preserves order, unavailable language emits `unavailable` without throwing | Medium |

**Target: 30+ passing unit tests by end of Day 2**, all pure Dart, no device or Firebase needed. This is also what lets me refactor safely on Days 3–5 while three other people are calling my code.

Manual verification, on the physical device, every day: airplane mode, Urdu output, rapid-tap stress, and first-utterance latency.

---

## 10. Risks I Own

| Risk | Likelihood | Impact | Mitigation | Trigger to act |
|---|---|---|---|---|
| No Urdu TTS voice on the demo device | **High** | **High** | Recorded-audio fallback for ~30 core phrases | Day 0 probe result |
| TTS first-utterance latency breaches 500 ms | Medium | Medium | Warm start during `initialise()` | Day 1 measurement |
| Overlapping speech on rapid taps | High | Medium | Serial queue + barge-in from the start | Built in on Day 1 |
| Urdu realiser produces wrong word order for an unseen card | Medium | Medium | Test against the **entire** seeded card set on Day 6, not just demo phrases | Day 6 audit |
| D2's seed data lacks the four grammar fields | Medium | **High** | Ask on Day 1, in writing, with the exact field list | Day 1 morning |
| ML Kit camera integration overruns | Medium | Low | Hard cut at noon on Day 6; P0 does not depend on it | Day 6 noon |
| Camera permission denied during the demo | Low | **High** | Grant it before the demo; handle denial with a friendly fallback screen | Day 6 audit |
| I become the bottleneck for D4's integration | Medium | Medium | Interfaces published Day 1, frozen Day 2, so D4 can code against them before I finish | Ongoing |

**My personal contingency order** (mirrors the sprint plan's §10): cut A7 first, then Urdu narration on routine steps, then the confusability matrix (fall back to random distractors). **Never cut:** TTS or the sentence realiser. Those two *are* the AAC feature, and AAC is the project's identity.

---

## 11. "Where Is the AI?" — My Answer

I will be asked this. Prepared, honest, and in this order:

**1. On-device machine learning — expression practice.**
"Google ML Kit's face detection model runs entirely on the device. It gives us a smile probability we turn into a live practice activity. No frame ever leaves the phone, nothing is stored, and it works in airplane mode — which is exactly why we chose on-device inference for anything involving a child's camera."

**2. Bilingual natural language generation — the AAC sentence engine.**
"The sentence strip isn't text, it's a structure. Each language has its own realiser: English SVO with article selection, Urdu SOV with speaker-gender verb agreement. That's why the Urdu is grammatical and not a word-for-word translation — and why the app says چاہتی for a girl and چاہتا for a boy."

**3. Personalisation — the card ranker.**
"Recency-weighted frequency with a seven-day half-life. The grid adapts to the child's actual vocabulary, and I can tell you exactly why any card is where it is."

**4. Adaptive difficulty — deliberately rule-based.**
"We chose rules over a learned policy on purpose. There is no ethically obtainable training dataset of autistic children's activity performance, and a parent needs to understand why the level changed. Explainability isn't a limitation here, it's the requirement."

**5. What we deliberately did not build.**
"Open-ended generative chat for children — out of scope on safety grounds, and we won't ship a guardrail we can't verify. A custom-trained emotion classifier — documented as future work; we chose a working on-device feature over an uncertain one. Speech-to-text — designed, not built."

> **Rule for the room:** never claim a model I cannot demonstrate. A team that says *"we used ML only where it earned its place, and here it is running live in airplane mode"* is more credible than one claiming a classifier it cannot show. Restraint is defensible; overreach is not.

---

## 12. My Definition of Done

Adapted from the scope document §18, trimmed to what applies to a services-and-logic track:

1. Public API matches the frozen interface in §4
2. Zero user-facing English strings in my code — enums and localisation keys only
3. Never throws across the public API; failures surface as states
4. Respects sensory mode (volume ceiling, rate, no sudden loud audio)
5. Works in airplane mode
6. Unit tested, `flutter test` green
7. `flutter analyze` clean
8. Verified on the physical demo device, not the emulator
9. Reviewed by at least one teammate — D4 for anything they integrate

### Daily standing checklist

- [ ] Did I break a frozen interface? (If yes: tell everyone immediately, before merging)
- [ ] Did I test on the physical device today?
- [ ] Did I test in airplane mode today?
- [ ] Are my tests still green?
- [ ] Is anyone blocked on me right now?

---

## 13. Open Questions — Answer Before Day 0

Mine, on top of the sprint plan's §11. Each one changes what I build.

1. **Which device is the demo device, and does it have an Urdu voice?** Probe it on 21 August. Everything about A1 depends on the answer. *(Highest priority.)*
2. **Is there a second device with the same voice available?** One phone is a single point of failure for an in-person demo.
3. **D2: will the seeded cards carry `pos`, `isCountable`, `startsWithVowelSound` and `urduGender`?** Without these, the Urdu realiser degrades to word-joining and the best line in my demo disappears.
4. **Does the child profile carry gender?** Urdu verb agreement requires it. If not, I default to masculine and note the limitation — but asking costs nothing and the feature is much stronger with it.
5. **Who writes the six emotion face assets, and are they photographs or illustrations?** Illustrations are safer (no likeness or consent issues) and match the sensory-friendly design. Needed by Day 3, not Day 4.
6. **D4: is `SessionResult` (§4.4) the shape you want for the chart?** Confirm on Day 1 — this object crosses three tracks and changing it on Day 4 is expensive.
7. **Team: do we pursue the Alibaba Cloud summary (§8)?** Decide on Day 5, and only if P0 is green. It requires a Firebase Blaze upgrade to do safely.
8. **Are we recording native Urdu audio as insurance regardless of the probe result?** Even if a device voice exists, recorded audio for the top 10 phrases is cheap demo insurance against a phone that decides to update itself overnight.

---

*End of D3 track plan v1.0. Interfaces in §4 freeze at the end of Day 2 (23 August). Any change after that requires whole-team agreement.*
