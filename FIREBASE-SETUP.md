# Firebase Setup — credentials only

Everything on the app side is built and tested. This document is the whole
of what remains, and it is deliberately short: **create a project, paste six
values, deploy the rules.** No Dart code needs writing, no files need
generating, and nothing needs committing.

If you are the person holding the credentials, this is your page.

---

## What is already done

| Piece | Where | State |
|---|---|---|
| Firebase initialisation | `core/data/firebase/firebase_bootstrap.dart` | Built. Reads credentials from `--dart-define`, never throws. |
| Caregiver auth | `features/authentication/data/firebase_auth_repository.dart` | Built. Email/password, auto-registers a new caregiver on first sign-in. |
| Progress store | `core/data/firebase/firestore_progress_repository.dart` | Built. Sessions, card usage, observations. Append-only. |
| Child profiles | `core/data/firebase/firestore_child_repository.dart` | Built, including teacher/therapist assignment. |
| Offline sync | `core/data/firebase/firestore_sync_backend.dart` | Built. Drains `OfflineSyncQueue` on reconnect, idempotent on replay. |
| Document layout | `core/data/firebase/firestore_paths.dart` | Built. Mirrors the rules exactly. |
| Security rules | `firestore.rules` | Authored. Ready to deploy. |
| Tests | `test/firebase_backend_test.dart` | 28 tests, in-memory Firestore, no live project needed. |

The app currently runs **fully offline against local repositories**. It
keeps doing that if you never touch any of this — which is the point of the
gate described below.

---

## Step 1 — Create the project

1. <https://console.firebase.google.com> → **Add project** → name it `autimate`.
2. Google Analytics is not needed; turn it off.
3. **Build → Authentication → Get started → Email/Password → Enable.**
4. **Build → Firestore Database → Create database.** Start in **production
   mode** (the rules in this repo are what will govern it) and pick a region
   close to your users.

## Step 2 — Register the Android app

**Project settings → Your apps → Add app → Android.**

- Android package name: `com.example.autimate`
  (confirm against `mobile/android/app/build.gradle.kts` → `applicationId`).
- Nickname and SHA-1 can be skipped for now. SHA-1 is only needed for Google
  Sign-In, which this project does not use.

You will be offered `google-services.json`. **You do not need it.** See the
note at the bottom if you would rather use it anyway.

## Step 3 — Copy the six values

From **Project settings → General → Your apps → SDK setup and configuration**:

| Firebase console field | Goes to |
|---|---|
| `apiKey` | `AUTIMATE_FIREBASE_API_KEY` |
| `appId` | `AUTIMATE_FIREBASE_APP_ID` |
| `projectId` | `AUTIMATE_FIREBASE_PROJECT_ID` |
| `messagingSenderId` | `AUTIMATE_FIREBASE_MESSAGING_SENDER_ID` |
| `storageBucket` | `AUTIMATE_FIREBASE_STORAGE_BUCKET` |
| — | `AUTIMATE_ENVIRONMENT` → set to `production` |

## Step 4 — Run it

```powershell
cd mobile
flutter run `
  --dart-define=AUTIMATE_ENVIRONMENT=production `
  --dart-define=AUTIMATE_FIREBASE_API_KEY=... `
  --dart-define=AUTIMATE_FIREBASE_APP_ID=... `
  --dart-define=AUTIMATE_FIREBASE_PROJECT_ID=... `
  --dart-define=AUTIMATE_FIREBASE_MESSAGING_SENDER_ID=... `
  --dart-define=AUTIMATE_FIREBASE_STORAGE_BUCKET=...
```

That is the entire integration. The app detects the credentials, brings
Firebase up, and swaps the repositories over.

**Do not paste these into a file that gets committed.** Keep them in a local
script that git ignores, or in your CI's secret store. `.env.example` at the
repository root lists the names with empty values as a reference.

## Step 5 — Deploy the rules

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules --project <your-project-id>
```

The rules live in `firestore.rules` and are already written against the
document layout the app uses. **Read them before deploying** — they are the
only thing standing between one family's data and another's.

---

## How the gate works

`AppConfig.firebaseConfigured` is true only when the API key, app id, and
project id are all non-empty. Two consequences worth understanding:

- **With no credentials, nothing Firebase-related is ever constructed.**
  The app uses local repositories and works completely offline. This is not
  a degraded mode; it is the demo mode, and objective O7 depends on it.
- **Credentials being present and Firebase being usable are different
  facts.** `FirebaseBootstrap.ensureInitialised` returns false if init fails
  for any reason, and the app falls back to local repositories rather than
  crashing. A misconfigured backend must never cost a child the app
  mid-sentence.

You can force local-only even with credentials present by passing
`--dart-define=AUTIMATE_ENVIRONMENT=mock`. Useful for a demo on a flaky
network.

---

## The data model, briefly

```
children/{childId}
  ├── caregiverIds: [uid, ...]      ← access is membership of this array
  ├── name, supportLevel
  ├── sessions/{id}                 ← append-only
  ├── cardUsage/{id}                ← append-only
  ├── observations/{id}             ← append-only
  ├── routineSteps/{id}             ← mutable
  └── routineDays/{yyyy-MM-dd}      ← mutable
```

**A child is shared, not owned.** The obvious alternative — nesting
everything under `caregivers/{uid}` — is simpler but makes the scope's
teacher/therapist requirement impossible. Here a therapist is added to one
child's `caregiverIds` and sees that child and nothing else:

```dart
await childRepository.shareChildWith(childId, therapistUid);
await childRepository.revokeAccess(childId, therapistUid);
```

Sessions, card usage, and observations are **append-only in the rules**, not
merely by convention. Updates are permitted narrowly so the offline queue can
replay a write under its own deterministic id after a crash, and a replay
cannot move a record to a different child. Deletes are refused outright.

---

## Optional: emulator instead of a live project

You can exercise everything without creating a project at all:

```bash
firebase emulators:start --only auth,firestore
```

Then point the app at it by adding to `main.dart`, before `runApp`:

```dart
await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
```

Worth doing to test the rules themselves, which the in-memory tests
deliberately cannot cover — `fake_cloud_firestore` does not evaluate
security rules, so **the 28 passing adapter tests prove the Dart side is
correct and say nothing about whether the rules are.** Rules unit tests
against the emulator are the remaining gap, and they are the thing most
worth writing next.

---

## Optional: `google-services.json` instead of dart-defines

The dart-define route is the default because it keeps secrets out of the
repository by construction rather than by remembering to gitignore a file.

If you prefer the file:

1. Put `google-services.json` in `mobile/android/app/`.
2. Add the Google Services Gradle plugin to
   `mobile/android/settings.gradle.kts` and `mobile/android/app/build.gradle.kts`.
3. Add both paths to `.gitignore` — **the file contains project identifiers
   and must not be committed.**

Note the trade-off: with the plugin applied, a build **fails** if the file is
missing, so every other developer on the project then needs a copy before
they can build at all. The dart-define route has no such coupling, which is
why it is the default here.

---

## If something does not work

| Symptom | Cause |
|---|---|
| App runs but nothing syncs | Credentials not detected. Check all three of api key, app id, project id are non-empty — the gate needs all three. |
| `PERMISSION_DENIED` in logs | Rules not deployed, or the caregiver is not in the child's `caregiverIds`. |
| Sign-in always fails | Email/Password provider not enabled in the console. |
| Data written but dashboard empty | Signed out. Repositories no-op rather than throw when there is no uid; check `FirebaseAuth.instance.currentUser`. |
| Queued writes never drain | Expected while signed out — writes are kept, not dropped. They flush on the next reconnect after sign-in. |
