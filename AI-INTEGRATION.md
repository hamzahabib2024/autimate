# AI Integration

## Boundary

AI work belongs under `mobile/lib/features/ai/`. The UI should depend on `AiEngine` or `ExpressionPracticeService`, never on a concrete model, camera plugin, or preprocessing implementation.

Existing contracts:

- `AiEngine.initialise()` loads a model and prepares runtime resources.
- `AiEngine.predict(Object input)` returns a `PredictionResult` with a label, confidence, and model version.
- `ExpressionPracticeService` exposes support detection, a stream of `ExpressionReading`, and stop/dispose behavior.
- `MockAiEngine` and `PlaceholderExpressionPracticeService` keep the app runnable while AI is absent.

Every unfinished method is marked `TODO: AI IMPLEMENTATION`.

## Planned P1 expression pipeline

Camera input should be throttled and processed locally through ML Kit face detection. The output is a practice signal such as smile probability, not a claim about a person's true emotional state. Frames must remain in memory only; they must never be uploaded or stored.

The future implementation belongs in `features/ai/data/` and should expose `ExpressionReading` to a state/controller under the relevant presentation feature. Camera permission denial, unsupported devices, model loading, and inference failures must become explicit loading/error states.

## Deferred capabilities

The scope documents design, but do not ship yet: a multi-class emotion classifier, speech-to-text, and guided fixed-branch conversation practice. Open-ended generative child chat is explicitly out of scope. Any future parent-facing summarization must use aggregated data, keep secrets server-side, and retain a deterministic offline fallback.

## AI-to-UI flow

`camera/audio/text input -> AI adapter -> domain result -> state/controller -> accessible widget`

The domain result must include confidence where applicable and enough metadata for the caregiver UI to explain what happened. The child UI should use friendly labels and never expose raw model errors.
