<div align="center">

# AutiMate

**An offline-first, bilingual communication and learning companion for autistic children.**

A complete, runnable Flutter app — not a prototype.

[![Flutter](https://img.shields.io/badge/Flutter-3.35.7-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Tests](https://img.shields.io/badge/tests-504%20passing-2ea44f)](#evidence)
[![Coverage](https://img.shields.io/badge/coverage-78.5%25-2ea44f)](#evidence)
[![Analyzer](https://img.shields.io/badge/analyze-0%20issues-2ea44f)](#evidence)
[![Languages](https://img.shields.io/badge/English%20%7C%20Urdu-6f42c1)](#why-it-stands-out)
[![Offline](https://img.shields.io/badge/works-fully%20offline-orange)](#why-it-stands-out)

</div>

---

## The problem

A child who cannot speak still has everything to say. Dedicated AAC devices cost more than a month of household income, and the good software is subscription-priced, English-only, and assumes a stable connection.

So Urdu-speaking children get an English board, families on prepaid data get nothing on a load-shedding evening, and caregivers get scores from a black box they cannot interrogate.

AutiMate closes all three gaps, and every child-facing feature runs on a phone in aeroplane mode.

> Not a diagnostic, screening, or treatment application. It makes no clinical claims.

## What it does

| Feature | |
|---|---|
| **AAC board** | 31 core cards, 8 categories, Fitzgerald colour coding, drag-to-reorder strip, grammatical sentence realisation in both languages before it speaks |
| **Custom cards** | Caregiver adds the child's own people and places by photo, and can record their own voice for the card |
| **Emotion practice** | Six emotions drawn in code as a parameterised face painter, adaptive difficulty, five-point intensity scale |
| **Expression practice** | Child mirrors a face; on-device ML Kit reads the frame and discards it |
| **Routines** | Visual timeline, countdown, spoken transition warnings, waiting board, flexibility training |
| **Social stories** | Authored bilingual branching scripts. Unexpected replies stay put — there is no failure state |
| **Learning** | Deterministic interest-to-topic mapping: a child fascinated by trains counts with trains |
| **Sensory support** | Sensory mode, dark theme, guided breathing, three calming ambient loops under a volume ceiling |
| **Gamification** | Stars, badges, streaks, progress ring — cooperative. No leaderboard anywhere, by policy |
| **Caregiver dashboard** | PIN-gated weekly aggregation, emotion trend, observation log, printable PDF board, backup and restore |

## Why it stands out

- **Offline is a guarantee, not a fallback.** Firebase sits *on top of* local repositories, never underneath them. Init failure is explicitly non-fatal — a misconfigured backend can never cost a child the app. Offline writes queue durably and drain idempotently on reconnect.
- **Bilingual by construction.** ~410 strings in English and Urdu, full RTL, Noto Nastaliq bundled as a variable font with its own line-height ramp. The realiser handles English articles *and* Urdu gender agreement — not a word-swap.
- **Explainable by design.** Every adaptive behaviour is a transparent rule a caregiver can be shown, behind an interface a trained model could implement tomorrow. No weights nobody on the team can inspect.
- **Accessibility enforced by tests.** WCAG 2.1 contrast is a unit test asserting 4.5:1 — including after sensory mode strips 40% of saturation. Nothing flashes above 3 Hz. Motion honours the OS "remove animations" setting. 16 goldens lock the rendered output.
- **Privacy is structural.** Camera frames never leave the device. Photos stay app-private. The home-screen widget carries labels only. Emotion intensity is deliberately never aggregated — that artefact turns an aid into a surveillance record.

## Run it

```powershell
cd mobile
flutter pub get
flutter run
```

No credentials, no account, no backend. That is the whole setup, and it is also the demo mode. Android is primary; iOS is best-effort.

```powershell
flutter analyze   # No issues found!
flutter test      # All tests passed! (504)
```

Cloud sync is optional and already coded — see [FIREBASE-SETUP.md](FIREBASE-SETUP.md).

## Evidence

Measured on this commit, not estimated.

| | |
|---|---|
| Tests | **504 passing**, 0 failing, 41 files |
| Line coverage | **78.5%** — 6,819 / 8,682 lines |
| Static analysis | **0 issues** |
| Source | 101 files, ~25,800 lines of Dart |
| Localisation | ~410 strings × 2 languages, full RTL |

Covering domain logic, widget behaviour, complete offline journeys, contrast maths, overflow audits, lifecycle disposal, and the Firebase adapters against an in-memory Firestore.

## Known gaps

Three things are written but have never executed, and we do not claim them as working: the **Firestore security rules** (the adapter tests use an in-memory Firestore that does not enforce them), the **ML Kit camera adapter** (never run against a real camera), and the **native side of the home-screen widget** (never compiled). Each needs a physical device or the full Android SDK.

Urdu TTS quality also varies by device — which is exactly why caregiver voice recording exists.

## Architecture

Feature-first Flutter, strictly layered. One rule keeps it honest: **logic never imports presentation, and never imports Firestore.** Every platform capability sits behind a domain interface with a test double, which is why 78.5% coverage is reachable with no device attached.

```
mobile/lib/
├── core/          config · data (stores, sync queue, Firebase, backup) · services · theme
├── features/      14 features, each domain / data / presentation
├── shared/        the component library
└── l10n/          app_en.arb · app_ur.arb
```

Riverpod for state, `flutter_tts` behind a queued locale-aware service, ML Kit on-device, Firebase optional. Every dependency in [mobile/pubspec.yaml](mobile/pubspec.yaml) carries a written justification. All 18 design figures are in [docs/diagrams/](docs/diagrams/).

## Team

**Muhammad Hamza Habib** and **Mohsin Behzad** — 111 commits at [hamzahabib2024/autimate](https://github.com/hamzahabib2024/autimate).

Fonts: Lexend and Noto Nastaliq Urdu, SIL OFL 1.1, licences bundled in [mobile/assets/fonts/](mobile/assets/fonts/).
