# Security & Privacy Review

**Scope:** AutiMate mobile app, reviewed at 245 passing tests.
**Subject population:** autistic children, most under 12. Data about a
minor, held by a caregiver. That is the standard everything below is
measured against.

This is a self-review by the development team, not an external audit.

---

## 1. What data exists

| Data | Where it lives | Leaves the device? |
|---|---|---|
| Child's first name, support level | `shared_preferences`, and Firestore if configured | Only with credentials configured |
| Session history (scores, duration, stars) | Local store / Firestore | Only if configured |
| AAC card-usage events | Local store / Firestore | Only if configured |
| Caregiver observations (free text) | Local store / Firestore | Only if configured |
| Routine definitions and completion | Local store / Firestore | Only if configured |
| Caregiver PIN | SHA-256 hash in `shared_preferences` | **Never** |
| Custom-card photos | App documents directory | **Never** |
| Camera frames (expression practice) | Memory only | **Never** |
| Caregiver email + password | Firebase Auth | Only if configured |

**No child account exists.** A child is a profile owned by a caregiver, by
design and enforced in `FirebaseAuthRepository`.

**Default state: nothing leaves the device.** With no `--dart-define`
credentials the app never constructs a backend adapter. Asserted by
`offline_journey_test.dart`.

---

## 2. Camera

The scope permits on-device expression practice and forbids anything else.

- Frames are processed in memory and discarded. No file write, no upload,
  no buffer retained beyond the frame.
- `AI-INTEGRATION.md` states this as a contract for the ML Kit adapter that
  is still to be written; `SimulatedExpressionService` honours it today.
- Permission is requested with a rationale dialog before the OS prompt.
- The camera stops on background and reattaches on resume.
- Output is framed as a *practice signal* (smile probability), never as a
  claim about the child's real emotional state.

**Residual risk:** the ML Kit adapter does not exist yet. Whoever writes it
must not add frame persistence for debugging. Flagged in the file's doc
comment.

---

## 3. Secrets

- **No credentials in the repository.** Firebase configuration arrives via
  `--dart-define` at build time. This is why the dart-define route was
  chosen over a committed `google-services.json`: secrets stay out by
  construction, not by remembering to gitignore.
- `.env.example` contains names with empty values only.
- Scan performed: no API keys, tokens, or passwords in tracked files.
- The caregiver PIN is SHA-256 hashed (`crypto`), never stored in plaintext.

**Residual risk:** SHA-256 without a salt or work factor is weak against a
targeted offline attack. Judged acceptable here — the PIN gates a *local UI
surface* on a device the caregiver already controls, and is not a
credential for anything remote. If it ever guards remote access, it needs
replacing with a proper KDF.

---

## 4. Data isolation

`firestore.rules` enforces, server-side:

- Only authenticated users touch anything; deny-by-default on all other paths.
- A child is readable only by UIDs listed in its `caregiverIds` array.
- A caregiver cannot write themselves out of, or a stranger into, a child
  they can see (`keepsSelfAsCaregiver`).
- Sessions, card usage, and observations are **append-only**: deletes are
  refused, and the narrow update permission cannot move a record to a
  different child.
- A therapist assigned to one child sees that child only.

**Residual risk — the most significant open item in this document.**
`fake_cloud_firestore` does not evaluate rules, so the 28 adapter tests
prove the *client* uses the right paths and prove nothing about the rules
themselves. **The rules have never been executed.** Rules unit tests against
the Firebase emulator must be written before any real child's data goes in.

---

## 5. Clinical and ethical posture

- No diagnosis, screening, or severity classification anywhere.
- No automatic behavioural labelling. Observations are free text a human
  wrote; the optional tag is a filter, not an assessment.
- The dashboard carries an explainable-progress disclaimer and reports only
  counts and percentages actually recorded — no fabricated precision.
- The interest→topic mapping is a deterministic table, shown to the
  caregiver as "{name} likes {interest}". No black-box recommender.
- Gamification is cooperative. No leaderboard, no ranking, no comparison
  between children.
- Conversation practice is fixed and authored. **No generative model is
  reachable by a child.**

---

## 6. Sensory safety

Treated as a safety property, not a preference.

- Nothing flashes, strobes, or changes luminance above 3 Hz.
- Ambient audio is bounded by `AmbientVolumePolicy` — the caregiver's
  preference is a fraction of a ceiling, so the loudest possible output is
  capped by construction. Sensory mode lowers the ceiling further, including
  on already-playing audio. Asserted at every preference value.
- Audio never autoplays; every start, stop, and track change is faded.
- The loops are generated with no transients and energy below ~1 kHz.
- Reduced motion honours the OS `disableAnimations` setting, so a device
  already configured for it needs no caregiver action.
- Errorless framing: no red X, buzzer, shake, or penalty anywhere a child
  can reach.

---

## 7. Third-party dependencies

Nine runtime packages, each justified in `PROJECT-STRUCTURE.md`. Reviewed
for data egress:

| Package | Sends data off-device? |
|---|---|
| `flutter_riverpod`, `crypto`, `shared_preferences`, `path_provider` | No |
| `flutter_tts` | No (platform TTS; on-device voices) |
| `audioplayers` | No (bundled assets) |
| `image_picker` | No (returns a local path) |
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Yes — only when credentials are configured |

No analytics SDK. No advertising SDK. No crash reporter currently wired.

**Open decision:** Crashlytics vs. local-only logging. Recommendation:
**local-only.** A crash reporter on a child-focused app can capture screen
content and identifiers, and the value here does not justify that.

---

## 8. Findings summary

| # | Finding | Severity | Status |
|---|---|---|---|
| 1 | Firestore rules have never been executed against the emulator | **High** | Open — blocks any real data |
| 2 | ML Kit adapter unwritten; frame-handling contract unenforced in code | Medium | Open — device-blocked |
| 3 | PIN hashed without salt or work factor | Low | Accepted, with the reasoning above |
| 4 | No crash/error reporting decision recorded | Low | Recommendation made, awaiting sign-off |
| 5 | Custom-card photos unencrypted in app storage | Low | Accepted — app-private storage; encryption adds key management for little gain against the realistic threat |
| 6 | No data-export or delete-my-data flow | Medium | Open — worth adding before any distribution |

**Nothing found that would prevent a supervised demo.** Findings 1 and 6
must be closed before the app holds a real child's data outside the team.
