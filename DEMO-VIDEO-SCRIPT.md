# Demo Video Script — 3 minutes

A tighter cut of [DEMO-SCRIPT.md](DEMO-SCRIPT.md), written for recording
rather than for a live walkthrough. Narration is in the left column, what to
show in the right. Timings are cumulative.

**Record with:** the device in airplane mode, sensory mode off, English,
a child profile named Ayaan with a few sessions already logged so the
dashboard is not empty.

**Screen recording tips:** slow every tap down — the app is deliberately
calm and fast tapping fights that. Leave a beat of silence after each spoken
sentence rather than cutting tight.

---

## 0:00 – 0:20 · Open

> "AutiMate is an offline-first Flutter app for autistic children and their
> caregivers. It supports communication, emotion learning, predictable
> routines, and sensory regulation. It is not a diagnostic tool and makes no
> clinical claims."

**Show:** app icon on the home screen → launch → splash → the child home.
Point out the airplane-mode indicator in the status bar and leave it visible
for the whole recording.

---

## 0:20 – 1:00 · The communication board *(the strongest 40 seconds)*

> "This is the flagship. The primary user is a non-verbal or minimally
> verbal child, so the picture is the content and the words are only a
> caption."

**Show:** Communicate tab. Hold still for two seconds on the grid.

> "The coloured band on each card is the Fitzgerald key — a standard AAC
> convention. Rose is a carrier phrase, orange a noun, green a verb. A child
> learns sentence structure from the colour before they can read a word."

**Show:** slow pan across the grid.

> "Three taps to a spoken request."

**Show:** tap **I want** → tap **Apple** → tap **Speak**. Let the audio play
fully. Do not talk over it.

> "That is the project's first objective, and a widget test asserts it, so
> it cannot silently regress."

**Show:** switch language to Urdu, tap the same two cards, tap Speak.

> "The Urdu is not a word-by-word translation — the realiser produces
> subject-object-verb order with gender agreement."

---

## 1:00 – 1:25 · Emotion practice

> "Six emotions. The faces are drawn in code as a parameterised painter, so
> they tween between expressions and every one is unit-tested. The same face
> is the role-play character in the social stories, so the child meets one
> consistent character throughout."

**Show:** Emotion practice. Answer one correctly — let the gentle
confirmation appear next to the face. Then answer one **incorrectly**.

> "No red X, no buzzer, no penalty. Errorless framing everywhere a child can
> reach."

**Show:** finish the session, star award.

---

## 1:25 – 1:45 · Routine

> "The ring answers the one question a child asks about their day: how much
> is left."

**Show:** Routine tab. Tick a step slowly.

> "Completion changes the fill, the icon, and the border together — never
> colour alone, so it works for a colour-blind child too."

---

## 1:45 – 2:20 · Sensory mode *(the most visually convincing moment)*

> "Now watch the entire app change at once."

**Show:** Sensory support → toggle **Sensory mode**. Hold on the screen for
three full seconds so the change registers on camera. Then navigate back to
the AAC board so the difference is visible on a busy screen.

> "Every accent desaturates by forty percent. Every shadow becomes a
> hairline. Motion stops. Speech slows and quietens. This is measurable, not
> cosmetic — tests assert each of those. The app also honours the device's
> own 'remove animations' setting, so a child whose phone is already
> configured for reduced motion gets it without anyone finding this toggle."

**Show:** the calming screen → turn on gentle sound → let it play for five
seconds → show the volume slider.

> "The app keeps a quiet upper limit even at maximum, and sensory mode
> lowers that limit again."

---

## 2:20 – 2:45 · Caregiver dashboard

> "Behind the parent lock, the interface changes character — denser,
> smaller, real data."

**Show:** parent gate → PIN → dashboard. Pan over the stat tiles, weekly
bars, and the accuracy trend.

> "All of this is from recorded sessions. No dummy data anywhere, and no
> automatic behavioural labelling — observations are free text a human
> wrote."

---

## 2:45 – 3:00 · Close

> "Everything you have seen ran with no network. Two hundred and forty-five
> tests pass, static analysis is clean, and the Firebase backend is built
> and waiting on credentials. Thank you."

**Show:** airplane-mode indicator one last time, then the home screen.

---

## Shot list

| # | Shot | Duration |
|---|---|---|
| 1 | Icon → launch → home | 20s |
| 2 | AAC grid pan, three-tap request, Urdu repeat | 40s |
| 3 | Emotion: correct, incorrect, session end | 25s |
| 4 | Routine ring + step tick | 20s |
| 5 | Sensory toggle, before/after on AAC, ambient sound | 35s |
| 6 | Dashboard | 25s |
| 7 | Close on airplane mode | 15s |

## Do not show

- Any real child's name, photo, or data. Use the demo profile.
- The custom-card camera flow with a real person in frame.
- Firebase credentials, console, or the `--dart-define` command line.
- Any screen with a `TODO` or debug banner visible.
