# Test Coverage & Gap Review

**Measured:** `flutter test --coverage` · **405 tests passing** ·
`flutter analyze` clean · **78.6% line coverage (6,777 / 8,625)**

The percentage moved down from 82.8% as the feature surface roughly
half-again grew; the absolute covered lines rose from 4,889 to 6,777. The
remaining gaps are the same two categories as before — platform adapters
that need a device, and the composition root.

Regenerate with:

```powershell
cd mobile
flutter test --coverage
python ../tools/coverage_report.py   # or read coverage/lcov.info directly
```

This document is the honest part: what is covered, what is not, and which
gaps are worth closing versus which are structural.

---

## Coverage by area

| Area | Covered | % | Note |
|---|---|---|---|
| features/progress | 16 / 16 | 100.0% | |
| features/gamification | 162 / 163 | 99.4% | |
| features/onboarding | 80 / 83 | 96.4% | |
| shared/widgets | 471 / 492 | 95.7% | design-system components |
| features/settings | 236 / 248 | 95.2% | |
| features/parent_dashboard | 273 / 289 | 94.5% | |
| features/learning | 262 / 280 | 93.6% | |
| features/routines | 538 / 581 | 92.6% | |
| features/home | 118 / 131 | 90.1% | |
| features/emotion_recognition | 410 / 461 | 88.9% | |
| core/theme | 224 / 252 | 88.9% | |
| core/data | 296 / 339 | 87.3% | |
| features/social_communication | 283 / 325 | 87.1% | |
| features/communication | 562 / 647 | 86.9% | the flagship AAC board |
| core/services | 321 / 383 | 83.8% | |
| features/ai | 67 / 88 | 76.1% | |
| features/sensory_support | 259 / 348 | 74.4% | audio adapter drags this down |
| core/config | 5 / 7 | 71.4% | |
| **core/providers** | **0 / 60** | **0.0%** | composition root |
| **features/authentication** | **0 / 72** | **0.0%** | sign-in screen + Firebase auth |

---

## The gaps, and whether they matter

### Structural — cannot be unit-tested, and should not be

These are platform adapters. Every one sits behind an interface that *is*
tested through a fake, which is the whole reason the boundaries exist.
Covering them needs a device, not a better test.

| File | Lines | Why uncovered | Covered instead by |
|---|---|---|---|
| `sensory_support/data/platform_ambient_sound_service.dart` | 81 | Needs real audio output | `SilentAmbientSoundService` + `_FakeAmbient`, 12 tests |
| `authentication/data/firebase_auth_repository.dart` | 24 | Needs live Firebase Auth | `MockAuthRepository`; gate logic tested |
| `core/data/firebase/firebase_bootstrap.dart` | 16 | Calls `Firebase.initializeApp` | `AppConfig` gate tested directly |
| `communication/data/image_source_service.dart` | 20 | Needs gallery/camera | `_FakeImageSource`, 4 tests |
| `ai/data/simulated_expression_service.dart` | 17 | Demo-only stand-in | pipeline tested via `ExpressionSessionEngine` |
| `core/providers/app_providers.dart` | 60 | Wiring, not logic | every provided object tested individually |

**Verdict: leave them.** Chasing these numbers would mean mocking the
platform, which tests the mock rather than the app. The device-verification
items in Module 13 are the real coverage for this code.

### Worth closing

| Gap | Lines | Why it matters |
|---|---|---|
| `authentication/presentation/auth_screen.dart` | 48 | A **real** gap. It is a plain form with no device dependency, and it is the first screen a caregiver meets. It should have a widget test covering empty input, a failed sign-in, and a successful one. |
| `core/services/tts_service.dart` | 30 uncovered | The locale ladder is tested; the error paths are not. Worth a test for "no Urdu voice installed", which is a likely real-world condition. |
| `main.dart` | 23 uncovered | Bootstrap ordering — Firebase init, sync drain wiring. Awkward to test directly; an integration test on device covers it better. |

### Not a gap

- `l10n/generated/*` (6.8%) — generated code. Every string is asserted for
  key parity and translation completeness in `design_system_test.dart`,
  which is the meaningful check.
- `core/theme/app_spacing.dart` (20%) — a file of constants. The tokens that
  carry behaviour (`AppElevation.resolve`, touch targets) are tested.
- `backend_contracts.dart` (0/3) — an interface declaration.

---

## What the tests actually assert

Coverage percentage is a weak measure on its own, so for the record, the
suite covers by *behaviour*:

- **Objective O1** — a request in three taps, asserted end to end.
- **Objective O7** — the full offline journey: build a sentence → speak →
  record a session → the caregiver dashboard reflects it, with no network
  and no backend adapter in the graph (`offline_journey_test.dart`).
- **Objective O8** — EN/UR key parity, no untranslated placeholders, RTL
  directionality.
- **Accessibility** — every semantic colour pair at 4.5:1 across
  light/dark × normal/sensory; theme-level minimum touch targets.
- **Sensory mode** — measurable desaturation, elevation flattening, motion
  collapse, and the OS `disableAnimations` signal.
- **Safety** — volume ceiling bounded at every preference; append-only
  progress; caregiver isolation and per-child therapist assignment.
- **Design system** — 16 pixel goldens across light/dark and normal/sensory.

## Known limitation, stated plainly

`fake_cloud_firestore` **does not evaluate security rules**. The 28 passing
Firebase adapter tests prove the Dart side reads and writes the right paths;
they say nothing about whether `firestore.rules` actually enforces
isolation. Rules unit tests against the Firebase emulator are the single
most valuable test still missing from this project. See `FIREBASE-SETUP.md`.
