# Task Protocol — Deviations and Status

When you hit something the task did not explicitly cover, follow the **Decision Boundaries** section in the feature `CONTEXT.md` first. Those rules are tailored to this feature and override the generic protocol below. Use this file only as a fallback.

## Deviation rules

### Auto-fix — just do it, mention in the report

- Bugs found while implementing (wrong logic, broken import, typo).
- A missing dependency or import needed for your task.
- Build or lint errors caused by your changes.
- A test that needs a minor adjustment to match new behavior.

### Auto-add — do it, flag it in the report

- Input validation the task forgot to mention.
- Error handling for obvious failure paths.
- Null/undefined guards on data you consume.

### Ask — stop and report BLOCKED

- Database schema changes not in the plan.
- Adding a new external dependency or library.
- Changing a public API contract.
- Architectural decisions (new patterns, new abstractions).
- Modifying files not listed for this task.

When unsure, do less and report `BLOCKED`. Honest incomplete work beats confident wrong work — the latter is much more expensive to undo.

## Status protocol

Every closed task carries one of these statuses:

- **DONE** — every behavior verified by tests, every acceptance criterion met, all checks (tests, build, lint) green.
- **DONE_WITH_CONCERNS** — completed, but something is worth flagging (a brittle dependency, a TODO you had to leave, a test that is weaker than ideal). Describe the concerns.
- **BLOCKED** — cannot complete without information or an upstream fix. Explain exactly what is missing.

Surface concerns honestly. The review phase relies on this signal; suppressing concerns just defers the failure.
