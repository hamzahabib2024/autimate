# AutiMate — Project Completion Prompt

> **How to use:** paste everything below the divider into Claude Code as a single prompt, from the
> repository root. It covers *everything still unfinished* across all 15 modules, in dependency
> order, with acceptance criteria per item and explicit handling for the work that is genuinely
> blocked on hardware or accounts.
>
> The visual redesign is covered separately and in far more depth by
> [VISUAL-DESIGN-PROMPT.md](VISUAL-DESIGN-PROMPT.md) — run that one first, or run it as Phase 2
> below. Progress is tracked in [PROJECT-CHECKLIST-V2.md](PROJECT-CHECKLIST-V2.md).

---

You are completing **AutiMate**, an offline-first Flutter app for autistic children and their
caregivers, built as a final-year project. The app is already substantially working. Your job is to
finish it: close the remaining feature gaps, do the visual redesign, connect the backend, harden
the tests, and produce the release and documentation deliverables.

## Ground truth before you start

- Repository root contains the docs; the app lives in `mobile/`.
- **Current verified state:** `flutter analyze` → no issues; `flutter test` → **146 passing**; branch `AI`.
- Architecture: feature-first Flutter, `AppState extends ChangeNotifier` as the state hub,
  Riverpod `ProviderContainer` composition root, ARB localization (EN + UR, 268 keys, RTL),
  local `shared_preferences`-backed repositories behind interfaces, and an `OfflineSyncQueue` with
  last-write-wins semantics waiting for a Firestore adapter.
- Read `AutiMate_Scope_Doc.md` for objectives O1–O8 and the explicit out-of-scope list.
  **Do not build anything on the out-of-scope list** — no generative child chat, no clinical or
  diagnostic claims, no AR/VR, no messaging, no multi-tenant school management.

## Rules that apply to every task below

1. **Never let the test count drop.** Run `flutter analyze && flutter test` after each task. 146 is
   the floor and it should only go up. Do not weaken or delete a test to make a change fit.
2. **Never rename or remove a `ValueKey` that a test finds.** Carry keys onto replacement widgets.
3. **No hard-coded user-facing strings.** New copy goes into `app_en.arb` **and** `app_ur.arb`
   (real Urdu, not placeholders), then `flutter gen-l10n`.
4. **RTL-safe always:** `EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`.
5. **Offline-first.** Every child-facing feature must work fully with no network. Nothing fetched
   at runtime — fonts and media are bundled assets.
6. **Justify every new dependency** in `PROJECT-STRUCTURE.md` before adding it.
7. **Safety framing:** no clinical claims, no behavioural labelling, no competitive/ranked
   gamification, no flashing or strobing visuals, camera frames never persisted or uploaded.
8. **Commit per task**, with a message that states what became true. Update
   `PROJECT-CHECKLIST-V2.md` in the same commit that completes an item.

---

## Phase 1 — Close the unblocked feature gaps

### 1.1 Custom caregiver AAC cards *(Module 1 — the last open flagship item)*
Let a caregiver add their own card: image from gallery or camera, bilingual label, optional spoken
label, and a category so it inherits the word-class colour coding. **Go local-first** — store the
image in the app documents directory and persist the path; do not wait on a Firebase Storage
decision, and design the record so a future remote URL is a drop-in alternative.
*Acceptance:* a caregiver-created card appears in the grid, participates in the sentence strip and
frequent-cards ranking, survives restart, is deletable and editable, and works offline. Tests cover
create → appears in deck → speaks → persists → deletes.

### 1.2 Sentence-strip reorder *(Module 1)*
Drag-to-reorder the composed sentence, with the realiser re-running after the move. This was
deliberately deferred alongside custom cards.
*Acceptance:* reorder changes the realised EN and UR sentence correctly; a test asserts both.

### 1.3 Emotion artwork *(Module 3)*
Replace the stock Material icons for the six emotions. Build `EmotionFace` as a parameterised
`CustomPainter` — see §5.2 of the visual prompt. It also satisfies the Module 2 role-play
expression states, so build it once and use it in both places.
*Acceptance:* six visually distinct faces, tweenable, theme-aware, unit-tested per emotion.

### 1.4 Translation review pass *(Module 10)*
Audit all 268 ARB keys. Fix placeholder or machine-stiff Urdu, verify plural/placeholder forms
render correctly in both languages, and confirm no key exists in one file but not the other.
*Acceptance:* a test asserts EN and UR key sets are identical; the diff shows the corrections.

---

## Phase 2 — Visual and experience redesign *(Module 15 — the largest single gain)*

Execute **[VISUAL-DESIGN-PROMPT.md](VISUAL-DESIGN-PROMPT.md)** in full: the token system
(colour, typography, spacing, motion), bundled Lexend + Noto Nastaliq Urdu fonts, the shared
component library, the mascot and `EmotionFace`, the child-tier / caregiver-tier split, all twelve
screen passes, dark theme, and the app icon and splash.

Do not treat this as optional polish. The app currently looks like an admin console to a
five-year-old non-verbal user; for this product that is a functional defect, not a cosmetic one.

---

## Phase 3 — Backend and sync *(Module 11)*

Everything here is behind an account you may not have. **If credentials are unavailable, do not
stall the project** — implement against the Firebase emulator suite, keep the local repositories as
the default runtime path, and mark the live-project items as awaiting credentials.

- **3.1** Create the Firebase project; register the Android and iOS apps; keep
  `google-services.json` and `GoogleService-Info.plist` out of version control and document the
  placement in `README.md`.
- **3.2** Firebase Authentication: email/password for parents, an invite path for teachers. The
  child uses a *profile*, never an account — this is a scope rule, hold it.
- **3.3** Firestore adapters implementing the existing repository interfaces and draining
  `OfflineSyncQueue` on reconnect, with last-write-wins merge. The `AppConfig.firebaseConfigured`
  gate must keep the app fully runnable with no credentials — verify by running with no defines.
- **3.4** Deploy the already-authored `firestore.rules` and write rules unit tests against the
  emulator: caregiver isolation, append-only progress records, deny-by-default.
- **3.5** Teacher/therapist role: read plus observation-logging access limited to assigned children
  (this is the last open Module 7 item and it depends on 3.2).
- **3.6** Decide on Crashlytics vs. local-only logging and write the decision down. Whatever you
  choose, no child-identifying data leaves the device.

*Acceptance:* the app behaves identically offline with and without Firebase configured; sync
reconciles a queued offline change on reconnect; rules tests pass against the emulator.

---

## Phase 4 — Device-gated work

These need a physical Android device (and macOS/Xcode for iOS). Prepare each so it becomes a
verification step, not an implementation step, the moment hardware is available.

- **4.1 ML Kit face-detection adapter** producing `ExpressionReading` from real camera frames,
  behind the existing `ExpressionPracticeService` interface. The whole pipeline —
  `FrameThrottle`, `SmileEmaSmoother`, `ExpressionSessionEngine`, and all six UI states — is
  already built and tested against `SimulatedExpressionService`. Write the adapter, keep frames in
  memory only, never persist or upload, and keep the simulated source as the fallback.
- **4.2 OS-level local notifications** for routine reminders via `flutter_local_notifications`,
  including permission handling and exact-alarm considerations on modern Android. In-app spoken
  warnings already work; this extends them beyond the foreground.
- **4.3 Ambient sound adapter** replacing the current silent no-op `AmbientSoundService`, with a
  hard volume ceiling and no autoplay.
- **4.4 Device verification passes:** TalkBack end-to-end; Urdu Nastaliq rendering; sensory-mode
  listening/volume comfort; brightness and clutter audit; airplane-mode run; rapid-tap speech
  stress; frame-pacing and TTS-latency profiling.

---

## Phase 5 — Testing and quality *(Module 12)*

- **5.1** Integration test of the full offline journey: build a sentence → speak it → complete an
  emotion session → see it reflected on the caregiver dashboard, with no network.
- **5.2** Coverage report (`flutter test --coverage`) plus a written gap review naming the
  untested paths and why they are or aren't worth closing.
- **5.3** Golden tests for the new design system — the AAC tile, the six emotion faces, the home
  tiles, and the progress ring, in light/dark × normal/sensory. This is what stops the redesign
  from silently regressing later.

---

## Phase 6 — Release *(Module 13)*

- **6.1** Configure the Android SDK toolchain; get a debug APK building.
- **6.2** App icon, adaptive icon, and splash (also covered by the visual prompt); fix the Android
  label from `"autimate"` to `"AutiMate"`.
- **6.3** Release signing with the keystore held outside version control and documented.
- **6.4** Android release build (AAB and APK). iOS best-effort if macOS is available.
- **6.5** Crash handling and logging wired per the Phase 3.6 decision.
- **6.6** Final security and privacy review: camera handling, data export, secrets scan, and a
  written confirmation that no child data leaves the device without explicit caregiver action.
- **6.7** Two full demo rehearsals on a real device.

---

## Phase 7 — Documentation and demo deliverables *(Module 14)*

- **7.1** A five-minute demo script mapped explicitly to objectives O1–O8, with the exact tap path
  for each — including the "request in ≤ 3 taps" moment (O1), which is the strongest single beat
  in the demo.
- **7.2** FYP report sections: methodology, architecture, testing evidence (test counts, contrast
  results, coverage), and an honest limitations section naming what is simulated versus real.
- **7.3** Short demo video script.
- **7.4** Final handover: dependency justification list, and `README.md` / `PROJECT-STRUCTURE.md` /
  `AI-INTEGRATION.md` brought current with the finished app.
- **7.5** Store listing assets (EN + UR screenshots and description) if distribution is intended.

---

## Suggested order

Phase 1 → Phase 2 → Phase 5.1 & 5.3 → Phase 3 (emulator path) → Phase 7.1 → Phase 4 and 6 as
hardware and credentials allow → Phase 7 remainder.

Rationale: Phases 1 and 2 are unblocked, high-visibility, and make every later demo and screenshot
better. Locking the design in with golden tests before the backend work protects it. The demo
script is written early because it tells you which rough edges actually matter.

## Reporting

After each phase, state plainly what was completed, what the test count is, and what remains —
including anything you could not do and why. Update `PROJECT-CHECKLIST-V2.md` as you go; a checkbox
is ticked only when the work is implemented **and** verified.
