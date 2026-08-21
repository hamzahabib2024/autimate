# Development Roadmap

## Phase 1: Foundation

Complete Firebase project setup, Riverpod adoption, authentication, parent and child profile CRUD, Firestore rules, offline persistence, ARB localization, and platform configuration. Keep mock adapters available for tests.

## Phase 2: P0 child experience

Finish AAC repositories and bilingual sentence realization, platform TTS with Urdu fallback, seeded emotion activities, progress writes, stars, and sensory-mode audits. Add loading, empty, error, retry, and offline states to each flow.

## Phase 3: Routines and learning

Add routine CRUD, local notifications, transition warnings, flexibility training, interest profiles, authored learning content, and rule-based support-level adaptation.

## Phase 4: Caregiver experience

Complete child management, activity history, weekly aggregation, charts, and human-authored observation logging. Enforce parent/teacher access in Firestore Security Rules.

## Phase 5: Advanced AI

Implement the on-device ML Kit expression-practice adapter if P0 is stable. Consider speech-to-text only after privacy, offline behavior, permission handling, and performance are proven.

## Phase 6: Hardening

Run unit/widget/integration tests, offline and RTL audits, accessibility review, performance measurement, security review, crash handling, Android release preparation, and documentation/demo rehearsal.

The 7-day sprint plan is the current delivery gate: cut P1 expression practice first when the vertical slice is behind schedule; do not cut AAC/TTS or offline core behavior.
