# AutiMate — Five-Minute Demo Script

Every beat maps to a scope objective (O1–O8) and gives the exact tap path.
Total: about 5 minutes at a calm pace. Run it on a physical Android device
if one is available; the app is fully functional offline either way.

**Before you start:** put the device in airplane mode. The offline banner
appearing is part of the demo, not a failure — it proves O7.

---

## 0 · Opening (20s)

> "AutiMate is an offline-first support tool for autistic children and their
> caregivers. It is not a diagnostic or screening application, and it makes
> no clinical claims. Everything you are about to see runs with no network."

Show airplane mode is on. Launch the app.

**Point out:** the splash and icon are the same character the child meets
inside; the launch never flashes white.

---

## 1 · Onboarding — O8 (30s)

*First run only. If the app is already onboarded, skip to §2 and mention it.*

| Step | Tap |
|---|---|
| Choose language | `App language` → **اردو** |
| Show it | Entire UI flips to Urdu, right-to-left, instantly |
| Switch back | `App language` → **English** |
| Fill | Child's name → `Ayaan`; support level → **Beginner**; PIN → `1234` |
| Start | **Get started** |

> "Full English and Urdu localisation with RTL. There are no hard-coded
> strings anywhere in the app — a test asserts both files declare identical
> keys."

**Objective proved: O8.**

---

## 2 · The communication board — O1 *(the strongest beat — do not rush it)*

Tap **Communicate** in the bottom bar.

> "This is the flagship feature. The primary user is a non-verbal or
> minimally verbal child, so the picture is the content and the word is only
> a caption."

**Point out before tapping anything:**
- The coloured band on each card is the **Fitzgerald key** — an established
  AAC convention. Rose is a carrier phrase, orange a noun, green a verb,
  blue a descriptor, amber a person. The child learns sentence structure
  from the colour before they can read.
- Colour is never the only channel: every card also carries its own symbol
  and both labels.

**Now the three taps:**

| Tap | What happens |
|---|---|
| 1. **I want** | Spoken aloud; appears in the sentence strip |
| 2. **Apple** | Spoken aloud; strip now reads *I want an apple.* |
| 3. **Speak** (the big teal button) | Full sentence spoken |

> "Three taps from intent to speech. That is objective O1, and it is asserted
> by a widget test so it cannot silently regress."

**Then show two more things:**
- **Reorder** — drag a word in the strip. Note that a recognised pattern
  stays correct in any order, because the realiser resolves roles by part of
  speech: a child who taps "apple" first still gets a well-formed sentence.
- **Urdu** — switch language and speak again. The realiser produces Urdu
  SOV word order with gender agreement, not a word-by-word translation.

**Objective proved: O1.**

---

## 3 · Custom cards — O1 (30s)

Tap the **add-photo icon** in the Communicate app bar → parent gate → PIN.

> "A caregiver adds the child's own vocabulary: a photo of their actual cup,
> their own sibling. Local-first — the image is copied into app storage, so
> it works with no network and no cloud account."

Create one card (or show one already made), then return to the board and
show it sitting in the grid, colour-coded like every built-in card.

---

## 4 · Emotion practice — O2 (45s)

Home → **Emotion practice**.

> "Six target emotions. The faces are drawn in code as a parameterised
> painter, which means they can tween between expressions and every one is
> unit-tested. The same face is the role-play character in the social
> stories module, so the child meets one consistent character."

- Answer one question correctly → gentle confirmation appears **next to the
  face**, where the child is already looking.
- Answer one incorrectly → *"Let us try the next one."*

> "There is no red X, no buzzer, no penalty. Errorless framing throughout."

Finish the session → star awarded, session recorded.

**Objective proved: O2.**

---

## 5 · Routine — O3 (30s)

Bottom bar → **Routine**.

> "The ring answers the one question a child asks about their day: how much
> is left."

- Tick a step → it turns green **and** gains a check icon **and** a heavier
  border. Three channels, not one.
- Point out the countdown banner and the flexibility-training badge if
  present.

**Objective proved: O3.**

---

## 6 · Sensory mode — O5 *(the most visually convincing beat)*

Home → **Sensory support** → toggle **Sensory mode**.

> "Watch the whole app change at once."

**Say what to look for:**
- Every accent desaturates by 40%.
- Every shadow disappears, replaced by a hairline outline.
- The ground softens.
- Motion stops — transitions become plain fades.
- Speech slows and quietens.

> "This is measurable, not cosmetic — tests assert the saturation drop, the
> elevation flattening, and the motion collapse. The app also honours the
> device's own 'remove animations' accessibility setting, so a child whose
> phone is already configured for reduced motion gets it without anyone
> finding this toggle."

Also show **Screen brightness → Dark**. Note it sits with the comfort
controls, not in a style menu, because a bright screen in a dim room is a
sensory complaint.

**Objective proved: O5.**

---

## 7 · Learning path — O4 (20s)

Home → **Learning path**.

> "The path is generated from the child's declared interests through a
> deterministic mapping table — no black-box recommender. Every activity
> card states why it is there: 'Ayaan likes cars.' A caregiver can always
> explain the recommendation."

**Objective proved: O4.**

---

## 8 · Caregiver dashboard — O6 (40s)

Bottom bar → **Progress** → parent gate → PIN.

> "Notice the interface just changed character: denser, smaller type, real
> data. That is deliberate — a caregiver can tell at a glance which mode the
> device is in."

- Point at the three stat tiles, the weekly bar chart, and the emotion
  accuracy trend — **all from recorded sessions, none of it dummy data**.
- Log an observation with a tag.
- Read the disclaimer aloud.

> "Free-text observation only. There is no automatic behavioural labelling
> and no fabricated precision anywhere in this screen."

**Objective proved: O6.**

---

## 9 · Offline — O7 (15s)

Point at the offline banner that has been visible the entire demo.

> "Airplane mode has been on since before launch. Every feature you have
> seen — speech, sessions, routines, the dashboard — ran entirely on device.
> Nothing was fetched, and no child data left the phone."

**Objective proved: O7.**

---

## 10 · Close (20s)

> "Nine of fifteen modules are functionally complete, 184 tests pass, static
> analysis is clean. What remains is honest to state: the Firebase backend
> is behind account credentials, the ML Kit camera adapter and OS
> notifications need a physical device to verify, and release builds need
> the Android SDK. Every one of those sits behind a contract that already
> exists and is already tested against a simulated implementation."

---

## Objective coverage checklist

| # | Objective | Demo section |
|---|---|---|
| O1 | Communication aid, request in ≤ 3 taps | §2, §3 |
| O2 | Emotion recognition activities | §4 |
| O3 | Routines and transitions | §5 |
| O4 | Interest-based learning path | §7 |
| O5 | Sensory mode alters motion, sound, contrast | §6 |
| O6 | Explainable caregiver progress | §8 |
| O7 | Core features work offline | §9 (and all of it) |
| O8 | English/Urdu with RTL | §1, §2 |

## If something goes wrong

- **No speech:** the device TTS may lack an Urdu voice. Say so plainly and
  switch to English — `tools/urdu_tts_probe` exists precisely to check this
  ahead of time.
- **No camera:** expression practice falls back to a simulated source and
  the flow still demonstrates end to end. Say that it is simulated.
- **Fonts look generic:** the design fonts are bundled assets that may not
  be installed in this checkout; see `mobile/assets/fonts/README.md`.
