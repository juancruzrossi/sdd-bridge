---
name: neural.interview
description: "[Neural SDD] Socratic interview that captures domain language, decisions, and ADRs inside .neural/wip/<feature>/. Part of the neural plugin — invoke via /neural.interview"
keep-coding-instructions: true
---

# Neural Interview — Clarify Before You Build

Interview the user relentlessly about every aspect of the feature until you reach a shared understanding. Walk down each branch of the design tree, resolving dependencies between decisions one-by-one. For each question, provide your recommended answer.

Ask one question at a time, waiting for the user's answer before continuing. If a question can be answered by exploring the codebase or docs, explore them instead of asking.

Respond in the user's language. Write `CONTEXT.md` and ADRs in that same language.

## Before pressing

1. Check git silently: `git rev-parse --is-inside-work-tree 2>/dev/null`.
2. Ask the feature name; normalize to kebab-case. Ask for the raw description.
3. Scan for existing context: `CONTEXT-MAP.md` (multi-context) or root `CONTEXT.md` (single-context), `docs/adr/`, related source and tests, and `.neural/{wip,archive}/*/CONTEXT.md`.
4. If `CONTEXT-MAP.md` exists, infer which bounded context this feature belongs to; ask only if unclear.

Create files lazily — only when there is something to write. Don't create `.neural/wip/<feature>/` until the first section is ready.

## During the session

Challenge the glossary: when a term conflicts with existing language in `CONTEXT.md`, call it out before moving on — "your glossary defines X as Y, but you mean Z — which is it?"

Sharpen fuzzy language: when a term is vague or overloaded, propose one canonical name and reject the rest. Be opinionated.

Stress-test relationships with concrete scenarios that probe edge cases and force precision about boundaries — ownership, cardinality, lifecycle.

Cross-reference with code: when the user states how something works, check the code agrees. Surface contradictions.

Update `CONTEXT.md` inline as terms resolve — don't batch. It is a glossary, not a spec or scratchpad: no implementation details. Use [CONTEXT-FORMAT.md](./CONTEXT-FORMAT.md).

Offer an ADR only when all three hold: hard to reverse, surprising without context, the result of a real trade-off. Otherwise skip it. Use [ADR-FORMAT.md](./ADR-FORMAT.md).

## Finish

List the assumptions you inferred; if the user corrects any, update `CONTEXT.md`.

If on a stable branch (`main`, `master`, `develop`, `stage`, `staging`, `production`, `release`), ask whether to create `feature/<slug>`, `enhancement/<slug>`, `fix/<slug>`, `hotfix/<slug>`, or stay.

Report:

```text
Interview complete for <feature>
Context: .neural/wip/<feature>/CONTEXT.md
ADRs: <count>
Open items: <count>
Next: /neural.plan
```
