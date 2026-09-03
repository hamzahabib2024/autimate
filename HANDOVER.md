# AutiMate — Handover

Everything the next person needs, in one page. Read this first.

**State at handover (2026-09-03):** `flutter analyze` clean ·
**405 tests passing** · 78.6% line coverage · branch `AI`, pushed.

---

## 1. Run it in five minutes

```powershell
cd mobile
flutter pub get
flutter analyze          # expect: No issues found!
flutter test             # expect: All tests passed! (405)
flutter run              # needs the Android SDK — see §5
```

With no arguments the app runs **fully offline** against local storage. That
is not a degraded mode; it is the demo mode, and objective O7 depends on it.

---

## 2. What is done

Fourteen of fifteen modules are functionally complete. Full detail in
[PROJECT-CHECKLIST-V2.md](PROJECT-CHECKLIST-V2.md).

| Area | State |
|---|---|
| Communication (AAC) | Board, bilingual realiser, TTS, Fitzgerald colour coding, reorder, custom cards with photos and recorded voice, word prediction, phrase bank, grid shapes, printable PDF, Transition to Literacy |
| Emotion & expression | Six-emotion engine, code-drawn faces, adaptive levels, 1–5 intensity scale, ML Kit camera pipeline |
| Routines | Timeline, editor, spoken warnings, countdowns, flexibility training, waiting board with visual timer |
| Sensory | Sensory mode, dark theme, three breathing patterns, calming visuals, ambient audio with a volume ceiling |
| Caregiver | Dashboard, emotion trend, observations, achievements timeline, profiles, parent lock, backup and transfer |
| Design system | Colour, type, spacing, motion, depth tokens; child/caregiver tiers; intro animation; app icon and splash |
| Backend | Firebase auth, Firestore adapters, offline sync drain — **credentials only**, see [FIREBASE-SETUP.md](FIREBASE-SETUP.md) |

---

## 3. What is NOT done — read this carefully

Three things are **written but have never run**. Do not report them as
working, and do not let them into a demo without checking first.

| Item | Status | What it needs |
|---|---|---|
| **Firestore security rules** | Never executed. `fake_cloud_firestore` does not evaluate rules, so the 28 passing adapter tests prove the *client* is correct and say nothing about whether the rules enforce isolation. | Emulator rules tests, before any real child's data goes in. |
| **ML Kit camera adapter** | Complete, never run against a camera. Frame-format handling only reveals itself on hardware. | A physical Android device. |
| **Home-screen widget (native)** | Kotlin provider, layout, drawables and manifest receiver written; never compiled. The Dart side is complete and tested. | Android SDK, then a device. |

Genuinely open, nothing blocking:

- **FYP report sections** — methodology, architecture, testing evidence, limitations.
- `auth_screen.dart` widget test — the one non-structural coverage gap.
- Device passes: TalkBack, Urdu Nastaliq rendering, brightness audit, frame pacing.
- Release track: signing config, AAB/APK, store assets.

---

## 4. The rules this codebase holds

Break these and the app stops being suitable for its users. They are enforced
by tests, not just convention.

1. **Nothing flashes, strobes, or changes luminance above 3 Hz.** Ever.
2. **Colour is never the only channel.** Every accent pairs with an icon,
   border, or label.
3. **Sensory mode is measurable** — 40% desaturation, zero elevation, no
   splash, motion collapsed. Asserted in `design_system_test.dart`.
4. **Reduced motion honours the OS**, not just the in-app toggle.
5. **No clinical claims, no behavioural labelling, no generative child chat.**
6. **Errorless framing** — no red X, buzzer, shake, or penalty anywhere a
   child can reach.
7. **The expression classifier reports appearance, never feeling.** A test
   asserts no label contains an emotion word.
8. **Offline-first.** Every child-facing feature works with no network.
9. **Zero hard-coded user-facing strings.** EN/UR parity is asserted.
10. **No Claude/AI co-author trailers in commits.**

---

## 5. Environment

`flutter doctor` on the original machine reported **Unable to locate Android
SDK**, which is why nothing has been built or run on a device. Install
Android Studio and the whole release track unblocks at once.

Fonts (Lexend, Noto Nastaliq Urdu) and audio loops are committed. The app
icon and ambient audio can be regenerated:

```powershell
python tool/make_icon.py && dart run flutter_launcher_icons
dart run flutter_native_splash:create
python tool/make_ambient_audio.py
```

Golden images are committed. Regenerate **deliberately** and read the diff:

```powershell
flutter test --update-goldens test/golden_design_test.dart
```

---

## 6. Where things live

```
mobile/lib/core/theme/       design tokens — colour, type, spacing, motion, depth
mobile/lib/core/data/        local stores, offline queue, Firebase adapters, backup
mobile/lib/features/<name>/  domain / data / presentation per feature
mobile/lib/shared/widgets/   the component library
mobile/test/                 405 tests, 16 committed goldens
```

Full map and the design-system rationale: [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md).

---

## 7. Documents

| File | What it is for |
|---|---|
| [PROJECT-CHECKLIST-V2.md](PROJECT-CHECKLIST-V2.md) | Module-by-module status and blockers |
| [FIREBASE-SETUP.md](FIREBASE-SETUP.md) | Create a project, paste six values, deploy rules |
| [PROJECT-STRUCTURE.md](PROJECT-STRUCTURE.md) | Architecture, design system, dependency justifications |
| [FEATURE-OPPORTUNITIES.md](FEATURE-OPPORTUNITIES.md) | Researched roadmap with pros and cons |
| [SECURITY-PRIVACY-REVIEW.md](SECURITY-PRIVACY-REVIEW.md) | Six findings; two must close before real data |
| [COVERAGE-REVIEW.md](COVERAGE-REVIEW.md) | What is tested, what is not, and why |
| [DEMO-SCRIPT.md](DEMO-SCRIPT.md) | Five-minute walkthrough against O1–O8 |
| [DEMO-VIDEO-SCRIPT.md](DEMO-VIDEO-SCRIPT.md) | Three-minute recorded cut |
| [AI-INTEGRATION.md](AI-INTEGRATION.md) | The expression pipeline and why the classifier is rules |

---

## 8. If you change one thing, know this

- **The AAC category filter re-flows the grid.** That works against motor
  planning, which every premium AAC app is built around. Making the filter
  *dim* non-matching cards instead of re-flowing them is the single highest-
  value change left in the app. `GridShape` is the groundwork.
- **Adding a language is content work, not re-architecture.** Punjabi and
  Sindhi are a documented, unaddressed research gap in Pakistan. See
  §1.3 of [FEATURE-OPPORTUNITIES.md](FEATURE-OPPORTUNITIES.md).
- **The AAC vocabulary is 30 cards.** A speech and language therapist will
  notice that before anything else.
