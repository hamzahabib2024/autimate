# AI Integration

## Boundary

AI work belongs under `mobile/lib/features/ai/`. The UI should depend on `AiEngine` or `ExpressionPracticeService`, never on a concrete model, camera plugin, or preprocessing implementation.

Existing contracts:

- `AiEngine.initialise()` loads a model and prepares runtime resources.
- `AiEngine.predict(Object input)` returns a `PredictionResult` with a label, confidence, and model version.
- `ExpressionPracticeService` exposes support detection, a stream of `ExpressionReading`, and stop/dispose behavior.
- `MockAiEngine` and `SimulatedExpressionService` keep the app runnable while the camera adapter is absent; the simulated source emits a deterministic smile ramp so the practice flow is demonstrable offline.

The signal pipeline between `ExpressionReading` frames and the UI lives in `features/ai/domain/expression_practice_engine.dart`: `FrameThrottle` (busy-flag + minimum interval), `SmileEmaSmoother` (alpha 0.3), and `ExpressionSessionEngine` (one-second hold above threshold awards one star; three stars complete a session). It is pure Dart and fully tested.

Every unfinished method is marked `TODO: AI IMPLEMENTATION`.

## Planned P1 expression pipeline

Camera input should be throttled and processed locally through ML Kit face detection. The output is a practice signal such as smile probability, not a claim about a person's true emotional state. Frames must remain in memory only; they must never be uploaded or stored. The processing engine, UI states (unsupported, permission denied, loading, error, practicing, complete), and star integration are implemented; the remaining work is the ML Kit camera adapter in `features/ai/data/` that produces `ExpressionReading` from real frames, gated on physical-device verification.

## Deferred capabilities

The scope documents design, but do not ship yet: a multi-class emotion classifier, speech-to-text, and guided fixed-branch conversation practice. Open-ended generative child chat is explicitly out of scope. Any future parent-facing summarization must use aggregated data, keep secrets server-side, and retain a deterministic offline fallback.

## AI-to-UI flow

`camera/audio/text input -> AI adapter -> domain result -> state/controller -> accessible widget`

The domain result must include confidence where applicable and enough metadata for the caregiver UI to explain what happened. The child UI should use friendly labels and never expose raw model errors.
