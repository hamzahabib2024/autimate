# AI Integration

## Boundary

AI work belongs under `mobile/lib/features/ai/`. The UI should depend on `AiEngine` or `ExpressionPracticeService`, never on a concrete model, camera plugin, or preprocessing implementation.

Existing contracts:

- `AiEngine.initialise()` loads a model and prepares runtime resources.
- `AiEngine.predict(Object input)` returns a `PredictionResult` with a label, confidence, and model version.
- `ExpressionPracticeService` exposes support detection, a stream of `ExpressionReading`, and stop/dispose behavior.
- `RuleBasedAiEngine` is the working `AiEngine`. It replaced a placeholder that returned `not_implemented` for every input.
- `MlKitExpressionService` is the real `ExpressionPracticeService`: camera frames -> on-device ML Kit face detection -> `ExpressionReading`.
- `SimulatedExpressionService` remains as the fallback so the flow is demonstrable with no camera and a camera failure never leaves the screen dead.
- `PlatformCameraPermissionService` gives the real OS answer, distinguishing denied from permanently denied.

The signal pipeline between `ExpressionReading` frames and the UI lives in `features/ai/domain/expression_practice_engine.dart`: `FrameThrottle` (busy-flag + minimum interval), `SmileEmaSmoother` (alpha 0.3), and `ExpressionSessionEngine` (one-second hold above threshold awards one star; three stars complete a session). It is pure Dart and fully tested.

There are no `TODO: AI IMPLEMENTATION` markers left; every method on both contracts is implemented.

## The expression pipeline (built)

`camera frame -> ML Kit face detection -> ExpressionReading -> FrameThrottle -> SmileEmaSmoother -> ExpressionSessionEngine -> UI`

`MlKitExpressionService` opens the front camera at `ResolutionPreset.low` — face detection needs no more, and a smaller frame means less conversion, less inference, and less heat on a device a child is holding. The detector enables classification only; landmarks, contours, and tracking stay off because this app has no use for them and they are not free.

**The privacy contract is enforced in code, not promised in prose.** A frame is converted, passed to the detector, and dropped. There is no code path in the adapter that writes, buffers, or transmits one; the only thing outliving a frame is a handful of doubles. Anyone editing that file should treat adding a debug frame dump as breaking the feature's entire basis.

The busy-flag throttle drops frames arriving while the previous one is still in the detector rather than queueing them, which keeps inference load flat on low-end hardware.

Remaining: verification on a physical Android device. The code is complete.

## Why the classifier is rules, not a model

`ExpressionClassifier` maps an `ExpressionReading` onto a coarse label with a plain-language reason. It is deliberately not a trained model:

- A neural classifier would need training data of autistic children's faces, would encode whatever bias that data carried, and would hand a caregiver a number with no account of itself. The scope rules out black boxes, and this is where that rule bites hardest.
- ML Kit supplies three usable signals — smile probability, per-eye openness, head roll — so a handful of coarse classes plus `unclear` is the honest ceiling. `unclear` is a real answer and often the correct one.
- Rules can be read, argued with, and corrected by the person relying on them.

**Every label names an appearance, never a feeling** — `smiling`, `wideEyed`, `eyesClosed`, not `happy` or `scared`. Autistic expression frequently does not map onto neurotypical readings, and the scope's own wording is "a practice signal, not a claim about a person's true emotional state". A test asserts no label contains an emotion word, so a future rename cannot quietly cross that line.

The rule order matters: unreadable conditions (tilted head, closed eyes) are ruled out *before* any expression is claimed, because those states make the smile probability unreliable.

## Deferred capabilities

The scope documents design, but do not ship yet: a trained multi-class emotion classifier and speech-to-text. Open-ended generative child chat is explicitly out of scope. Any future parent-facing summarization must use aggregated data, keep secrets server-side, and retain a deterministic offline fallback.

## AI-to-UI flow

`camera/audio/text input -> AI adapter -> domain result -> state/controller -> accessible widget`

The domain result must include confidence where applicable and enough metadata for the caregiver UI to explain what happened. The child UI should use friendly labels and never expose raw model errors.
