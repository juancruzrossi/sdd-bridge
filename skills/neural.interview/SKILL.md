---
name: neural.interview
description: "[Neural SDD] Socratic interview that captures domain language, decisions, and ADRs inside .neural/wip/<feature>/. Part of the neural plugin — invoke via /neural.interview"
keep-coding-instructions: true
---

# Neural Interview

Run a Socratic interview that pressure-tests every aspect of the feature until you reach a shared understanding. Walk the design tree depth-first, resolving dependencies between decisions one-by-one.

## Rules

- Respond in the user's language. Write `CONTEXT.md` and ADRs in that same language.
- One question at a time. Include your recommended answer when you can.
- If code/docs can answer the question, inspect them instead of asking.
- Cross-check user claims against code. If they conflict, surface it before continuing.
- Sharpen fuzzy terms — propose a canonical name, list aliases to avoid.
- Stress-test relationships with concrete scenarios that probe boundaries.
- Be opinionated: when multiple words exist for the same concept, pick one and reject the rest.
- Update `CONTEXT.md` inline as terms resolve. Don't batch.
- Create files lazily — only when there is something to write.
- ADRs only when hard to reverse + surprising without context + a real trade-off.

## Setup

1. Check git silently: `git rev-parse --is-inside-work-tree 2>/dev/null`.
2. Ask feature name. Normalize to kebab-case.
3. Ask for the raw feature description.
4. Scan before pressing:
   - `CONTEXT-MAP.md` (multi-context repos), root `CONTEXT.md` (single-context)
   - `docs/adr/`
   - related source files/tests
   - `.neural/wip/*/CONTEXT.md`, `.neural/archive/*/CONTEXT.md`
5. If `CONTEXT-MAP.md` exists, infer which bounded context this feature belongs to. Ask if unclear.
6. Do not create `.neural/wip/<feature>/` until the first section is ready to write.

## Interview

Open branches in risk order, but follow dependencies wherever they lead:

1. Problem — why this exists.
2. Scope — included behavior and explicit boundaries.
3. Language — canonical terms vs aliases. Sharpen anything fuzzy.
4. Relationships — ownership, cardinality, lifecycle. Probe with scenarios.
5. Scenarios — normal flow, edge cases, failure states.
6. Constraints — technical/business limits.
7. Decisions — chosen approach, rejected alternatives.
8. Non-goals — what not to build.
9. Acceptance — concrete done criteria.

Pressure tools when useful:

- Evidence: "Concrete case?"
- Assumption: "Based on what?"
- Boundary: "Where does this stop?"
- Essence: "Root or symptom?"
- Glossary conflict: "Your glossary says X, but you mean Y — which is it?"

When a term conflicts with existing language, stop and resolve it before moving on.

## Writing artifacts

When ready to write the feature `CONTEXT.md`, read [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

When a decision earns an ADR, read [ADR-FORMAT.md](./ADR-FORMAT.md).

## Finish

Before finalizing, list inferred assumptions. If the user corrects any, update `CONTEXT.md`.

If on a stable branch (`main`, `master`, `develop`, `stage`, `staging`, `production`, `release`), ask whether to create `feature/<slug>`, `enhancement/<slug>`, `fix/<slug>`, `hotfix/<slug>`, or stay.

Report:

```text
Interview complete for <feature>
Context: .neural/wip/<feature>/CONTEXT.md
ADRs: <count>
Open items: <count>
Next: /neural.plan
```
