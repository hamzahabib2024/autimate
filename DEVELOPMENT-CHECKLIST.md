# Development Checklist

## Phase 1 - Foundation

- [x] Repository documentation audited
- [x] Flutter project configured under `mobile/`
- [x] Feature-based folder architecture created
- [x] Mock repositories and service boundaries created
- [x] Theme and accessible shared widgets configured
- [x] Navigation shell configured
- [ ] Riverpod providers adopted
- [ ] Firebase Auth, Firestore, and Storage configured
- [ ] Environment configuration connected
- [ ] English/Urdu ARB localization completed
- [ ] Firestore Security Rules deployed

## Phase 2 - Child Experience

- [x] AAC screen and sentence-strip dummy flow
- [x] Emotion activity dummy flow
- [x] Routine schedule dummy flow
- [x] Sensory mode setting
- [x] Progress dashboard placeholder
- [ ] Bilingual platform TTS with Urdu fallback
- [ ] Offline AAC, routines, and progress persistence
- [ ] Stars, badges, and session summary
- [ ] Social stories

## Phase 3 - Routines and Learning

- [ ] Routine builder and CRUD
- [ ] Local reminders and transition warnings
- [ ] Flexibility training
- [ ] Interest profile and authored learning path
- [ ] Adaptive support controller and tests

## Phase 4 - Caregiver and Backend

- [ ] Parent registration and sign-in API
- [ ] Child profile CRUD
- [ ] Repository implementations and data models
- [ ] Parent/teacher role boundaries
- [ ] Progress aggregation and weekly chart
- [ ] Manual observation logging
- [ ] Offline sync and last-write-wins behavior

## Phase 5 - AI

- [x] Replaceable AI engine contract
- [x] Expression practice contract and placeholder
- [ ] Camera permission flow
- [ ] On-device ML Kit face pipeline
- [ ] Frame throttling and result smoothing
- [ ] Confidence and unsupported-device states
- [ ] AI unit/integration tests
- [ ] Speech-to-text evaluation, only if schedule permits

## Phase 6 - Quality and Production

- [x] `flutter analyze` clean for the current skeleton
- [ ] Unit tests for sentence building, ranking, scoring, and adaptation
- [ ] Widget tests for AAC, routine, and emotion flows
- [ ] Auth/profile integration test
- [ ] Accessibility and 64 dp touch-target audit
- [ ] Urdu RTL audit on device
- [ ] Offline and airplane-mode verification
- [ ] Permission, privacy, and security review
- [ ] Crash reporting and release logging
- [ ] Android signed build; iOS best-effort build
- [ ] Final demo and technical documentation
