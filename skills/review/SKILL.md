---
name: review
description: "Plan vs implementation verification with goal-backward analysis and test-quality audit"
disable-model-invocation: true
keep-coding-instructions: true
---

# Neural Review — Plan vs Implementation Verification

You verify, inline, that the implementation actually delivers what `CONTEXT.md` and `PLAN.md` promised — and that the tests written along the way prove behavior rather than shape.

The review runs in this same context because `/neural:execute` no longer ships work through subagents — there is no "implementer bias" to escape from. The risk we still need to guard against is **confirmation bias**: treating the plan as proof. Counter it by gathering fresh evidence (read files, run tests, grep) every time. Never trust a prior REVIEW.md.

## Step 1: Locate the feature

1. Determine the feature name from `$ARGUMENTS`. If empty, scan `.neural/wip/` — one match → use it, multiple → ask.
2. Set `WIP=.neural/wip/<feature>/`.
3. Read `$WIP/CONTEXT.md` and `$WIP/PLAN.md`. If either is missing, abort: "Missing CONTEXT.md or PLAN.md — cannot review without specs."
4. Read any ADRs under `$WIP/docs/adr/`.

## Step 2: Load stack-relevant skills

1. From `CONTEXT.md` / `PLAN.md`, identify the tech stack.
2. For each technology, try to load a matching skill (e.g., `react-best-practices`) via the Skill tool.
3. If loaded, apply its guidelines while reviewing.
4. If no match exists, proceed silently — do not fail.

## Step 3: Code quality check (Claude Code only)

1. Try `Skill("simplify")` on the files changed for this feature. Skip silently if unavailable.
2. Hold the findings for the "Code Quality" section of `REVIEW.md`.

## Step 4: Layer 1 — Plan vs Implementation

1. Parse every task from `PLAN.md`. Each task carries: expected files, behaviors to verify, acceptance.
2. For each task, gather evidence:
   - **Files** — use Glob and Read to confirm the listed files exist and were actually changed.
   - **Functions / components / routes** — use Grep to confirm the expected symbols exist.
   - **Tests for each behavior** — use Glob and Grep to confirm a test exists that names or covers each behavior in the task's "Behaviors to verify" list.
3. Assign a status per task:
   - `✓ completed` — every expected artifact found and substantive, every behavior covered by a test.
   - `⚠️ partial` — some artifacts found, others missing or weakly covered.
   - `✗ missing` — task not implemented.
4. Completion score: `X/Y` (partial = 0.5).

## Step 5: Anti-pattern scan

Grep the files changed for this feature. Record any hits.

| Pattern | What to search | Severity |
|---------|----------------|----------|
| Incomplete work | `TODO`, `FIXME`, `XXX`, `HACK` | Warning |
| Placeholder content | `placeholder`, `coming soon`, `lorem ipsum`, `example.com` | Blocking |
| Empty implementations | `return null`, `return {}`, `return []`, `=> {}`, `pass` as sole function body | Blocking |
| Hardcoded secrets | `sk_test_`, `your-api-key-here`, `password123` | Blocking |
| Debug leftovers | `console.log`, `print(`, `debugger`, `binding.pry` | Warning |

## Step 6: Layer 2 — Goal-backward verification

1. Read the **Problem** section of `CONTEXT.md`.
2. Derive **observable truths** — testable statements that must hold if the problem is truly solved. Example: "A user can POST `/api/orders` and receive 201 with an order id."
3. For each truth, verify four levels:

   **L1 EXISTS** — the artifact exists at the expected path. Use Glob + Read.

   **L2 SUBSTANTIVE** — real implementation, not a stub. Look for empty bodies, `TODO`, `NotImplementedError`, hardcoded mocks, commented-out core logic.

   **L3 WIRED** — connected to the rest of the system. Is the route registered? Is the component rendered? Is the function imported somewhere? Flag orphan code.

   **L4 FUNCTIONAL** — runs and produces the expected outcome.
   - Run the project test suite (`npm test`, `pytest`, `cargo test`, whatever applies).
   - For the test quality audit, read [TEST-QUALITY.md](./TEST-QUALITY.md). It covers disabled tests, weak assertions, implementation-coupled tests, and circular tests — all things that make a passing test suite lie.

4. Assign per truth:
   - `PASS` — all four levels verified.
   - `PARTIAL` — EXISTS + SUBSTANTIVE but not fully WIRED or FUNCTIONAL.
   - `FAIL` — any level fails.

## Step 7: Generate REVIEW.md

Write `$WIP/REVIEW.md`:

```markdown
# Review: <feature-name>

**Date:** <current date>
**Verdict:** <PASS | PASS WITH WARNINGS | FAIL>

## Completion Score

**X/Y tasks completed**

| Task | Status | Notes |
|------|--------|-------|
| <task title> | ✓ / ⚠️ / ✗ | <details, including behavior coverage> |

## Goal-Backward Verification

### Truth: "<observable truth>"

| Level | Status | Evidence |
|-------|--------|----------|
| EXISTS | ✓ / ✗ | <path or detail> |
| SUBSTANTIVE | ✓ / ✗ | <detail> |
| WIRED | ✓ / ✗ | <import/route/reference> |
| FUNCTIONAL | ✓ / ✗ | <test result or gap> |

**Result:** PASS / PARTIAL / FAIL

<!-- Repeat for each truth -->

## Test Quality

- Disabled tests linked to feature requirements: <list or "none">
- Weak assertions on critical behaviors: <list or "none">
- Tests coupled to implementation (mocks of internal collaborators, asserting on call counts, bypassing the interface): <list or "none">
- Circular tests (system under test generates its own expected value): <list or "none">

## Issues

### Blocking
- ...

### Warnings
- ...

### Info
- ...

## Code Quality (via /simplify)
- <findings from Step 3, if any>
```

Verdict rules:

- **PASS** — every task completed, every truth passes, no blocking issues, no test-quality findings.
- **PASS WITH WARNINGS** — every task completed and every truth passes, but warnings exist.
- **FAIL** — any task missing, any truth fails, or any blocking issue exists.

## Step 8: Report

**Evidence freshness rule.** The verdict must be based on evidence gathered during **this** execution. Never reuse a previous `REVIEW.md` or assume results from a prior run still hold.

1. Print a summary.
2. Present options based on the verdict:
   - **PASS (no warnings):** "All clean. Run `/neural:archive` to archive this feature."
   - **PASS WITH WARNINGS:**
     > 1. `/neural:address-review` — fix the warnings automatically
     > 2. `/neural:archive` — archive as-is, warnings accepted
   - **FAIL:**
     > 1. `/neural:address-review` — fix blocking issues and gaps automatically
     > 2. `/neural:debug` — investigate manually
     > 3. Fix manually and run `/neural:review` again
