# Urdu TTS probe

One question, answered on hardware, before the build starts:

> **Does this phone have a usable Urdu voice?**

Everything in the AutiMate AI track depends on the answer. If it is yes, the TTS
service is a six-hour task. If it is no, the Urdu speech path becomes recorded
native audio and that decision has to be made on Day 0 — not on Day 5.

---

## Run it

```bash
cd tools/urdu_tts_probe
flutter create .          # generates android/ ios/ for this pubspec, once
flutter pub get
flutter run               # with a PHYSICAL Android device connected
```

Emulators report voices they cannot actually produce. Use a real phone.

## What to do

1. Let the probe run on launch. It prints the installed engines, every locale the
   current engine reports, direct `isLanguageAvailable` answers for `ur-PK`,
   `ur-IN` and `ur`, and any voice that looks Urdu.
2. Press **Speak ur-PK**, then **ur-IN**, then **ur**. *Listen.* A query
   answering `true` is encouraging; hearing the sentence is the only proof.
3. Turn **airplane mode on** and repeat step 2. Some Google voices are
   network-backed — if Urdu only speaks while online, it does not satisfy the
   offline requirement and counts as a miss.
4. Press refresh (top right) after installing any voice data, so the engine is
   re-queried.

The Urdu test sentence is `السلام علیکم، میں سیب چاہتا ہوں`
("Peace be upon you, I want an apple").

## Reading the result

| What you observe | Outcome | What it means |
|---|---|---|
| Urdu speaks clearly, online and offline | **A** | Pin the locale string that worked. TTS stays a ~6 hour task. |
| Nothing until you install voice data, then it works | **B** | Install it, write the steps into the setup README, prepare a second phone identically. |
| Urdu only speaks while online | **B/C** | The voice is network-backed. Treat as a miss for the offline claim; look for a downloadable voice, else go to C. |
| No Urdu locale, no sound, or unintelligible output | **C** | Switch to recorded native audio for ~30 core phrases and add `audioplayers`. About four hours. |

## Before you conclude "no Urdu"

1. Settings → Text-to-speech output → check which **engine** is selected.
2. Install / update **Speech Recognition & Synthesis** (`com.google.android.tts`)
   from the Play Store — some OEM builds ship an old engine with fewer languages.
3. Gear icon → **Install voice data** → look for Urdu → download → run the probe
   again.
4. Try a second engine (Samsung TTS, eSpeak NG) and a second phone.

## Report it to the team

```
Device:            <brand / model>
Android version:   <version>
TTS engine:        <package + version>
Urdu locales:      <what getLanguages reported>
ur-PK / ur-IN / ur availability: <true/false each>
Spoke Urdu online:  <yes/no>
Spoke Urdu offline: <yes/no>
Outcome:           A / B / C
Action:            <what changes for D1, D3 and the demo script>
```

Post it the same day. If the answer is C, D1's Urdu plan and D4's demo script both change.
