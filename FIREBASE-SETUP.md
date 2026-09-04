# Firebase Setup

**Status: credentials are in place.** Project `auth-eb2cf` has been
configured with the FlutterFire CLI, which generated
`mobile/lib/firebase_options.dart`, `mobile/android/app/google-services.json`
and `mobile/ios/Runner/GoogleService-Info.plist`. The app reads those
automatically — there is nothing left to paste.

**Two things still have to happen in the Firebase console, and until they do
the app will run but not sync:**

1. **Deploy the security rules** (Step 5). Until then every read and write
   is refused, and an undeployed default may leave the database open.
2. **Enable the Email/Password sign-in provider.** Without it every
   caregiver sign-in fails.

Both are console actions, not code. The rest of this page is reference.

---

## What is already done

| Piece | Where | State |
|---|---|---|
| Firebase initialisation | `core/data/firebase/firebase_bootstrap.dart` | Built. Prefers the generated `firebase_options.dart`, falls back to `--dart-define`. Never throws. |
| Caregiver auth | `features/authentication/data/firebase_auth_repository.dart` | Built. Email/password, auto-registers a new caregiver on first sign-in, and handles email-enumeration protection. |
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

Because this project was configured with the FlutterFire CLI, the plain
command is now enough — the generated `firebase_options.dart` is read
automatically:

```powershell
cd mobile
flutter run
```

The dart-define route below still works and remains the way to point a build
at a *different* project without regenerating anything. Values passed this
way are only used when no generated file is present.

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

Run from the **repository root**, where `firebase.json` and `.firebaserc`
point at `firestore.rules` and project `auth-eb2cf`:

```bash
npm install -g firebase-tools
firebase login
firebase deploy --only firestore:rules
```

Note `mobile/firebase.json` is a different file, written by the FlutterFire
CLI to record app ids. It has no rules section and cannot deploy them, which
is why the root config exists.

The rules live in `firestore.rules` and are already written against the
document layout the app uses. **Read them before deploying** — they are the
only thing standing between one family's data and another's.

---

## How the gate works

Firebase comes up when **either** route supplies options: the generated
`firebase_options.dart` (this project's route, and it wins when present) or
all three of API key, app id and project id as dart-defines.

Supporting only the second route was a real defect, fixed in
`firebase_bootstrap.dart`: a project could add every file the CLI produces
and still find Firebase silently switched off, with no error explaining why.

Three consequences worth understanding:

- **With no credentials, nothing Firebase-related is ever constructed.**
  The app uses local repositories and works completely offline. This is not
  a degraded mode; it is the demo mode, and objective O7 depends on it.
- **Credentials being present and Firebase being usable are different
  facts.** `FirebaseBootstrap.ensureInitialised` returns false if init fails
  for any reason, and the app falls back to local repositories rather than
  crashing. A misconfigured backend must never cost a child the app
  mid-sentence.

- **A platform with no generated entry falls back rather than crashing.**
  The CLI configured Android, iOS and Windows. On web, macOS or Linux
  `DefaultFirebaseOptions.currentPlatform` throws, so `main.dart` catches it
  and runs local-only. A desktop run is a demo, not a failure.

You can force local-only even with credentials present by passing
`--dart-define=AUTIMATE_ENVIRONMENT=mock`. Useful for a demo on a flaky
network.

### Sign-in is now required when Firebase is up

With a backend attached, the caregiver's uid is the ownership key every
Firestore rule checks, so the app shows the sign-in screen until they
authenticate. With no backend it does not, and the app opens straight into
the child experience — objective O7 depends on that staying true.

Firebase persists the session across launches, so a returning caregiver is
not asked again.

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

## On the committed config files — the route this project took

`google-services.json`, `GoogleService-Info.plist` and `firebase_options.dart`
are committed. That is a deliberate, defensible choice and worth stating
plainly rather than leaving as a worry:

- **They are not secrets.** They hold client identifiers — an API key that
  identifies the project to Google, an app id, a sender id. Google documents
  them as safe to include in client code, which is unavoidable anyway since
  they ship inside every APK. There is no service-account key or private key
  in any of them.
- **What actually protects the data is the security rules**, which is why
  deploying them is step one at the top of this page and not an afterthought.
  An unauthenticated request with a valid API key still gets nothing.
- **The trade-off accepted:** with the Google Services Gradle plugin applied,
  an Android build *fails* if `google-services.json` is missing. Committing it
  is what keeps every other developer able to build. The dart-define route
  has no such coupling, which is why it remains supported above.

What must **never** be committed is a service-account JSON (it contains
`private_key` and grants admin access, bypassing all rules). None is present,
and `.gitignore` excludes `*serviceAccount*.json` and `*-adminsdk-*.json`.

---

## If something does not work

| Symptom | Cause |
|---|---|
| App runs but nothing syncs | Firebase did not come up. Confirm `firebase_options.dart` exists and the platform has an entry, or that all three dart-defines are non-empty. |
| Sign-in screen never appears | Expected with no backend. It appears only when Firebase is up and no caregiver is signed in. |
| First-ever caregiver cannot sign in | Email/Password provider not enabled in the console. |
| `PERMISSION_DENIED` in logs | Rules not deployed, or the caregiver is not in the child's `caregiverIds`. |
| Sign-in always fails | Email/Password provider not enabled in the console. |
| Data written but dashboard empty | Signed out. Repositories no-op rather than throw when there is no uid; check `FirebaseAuth.instance.currentUser`. |
| Queued writes never drain | Expected while signed out — writes are kept, not dropped. They flush on the next reconnect after sign-in. |
