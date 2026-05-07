---
name: neural.review
description: "[Neural SDD] Plan vs implementation verification with goal-backward analysis. Part of the neural plugin — invoke via /neural.review"
keep-coding-instructions: true
---

# Neural Review — Plan vs Implementation Verification

## Step 1: Dispatch Independent Reviewer

The review must run in a clean context window — a reviewer biased by the implementer's context will confirm rather than verify.

1. Determine the feature name from `$ARGUMENTS`. If empty, scan `.neural/wip/` — one match → use it, multiple → ask.
2. Set `WIP=.neural/wip/<feature>/`.
3. Read `$WIP/BRIEF.md` and `$WIP/PLAN.md`. If either is missing, abort: "Missing BRIEF.md or PLAN.md — cannot review without specs."
4. Dispatch a subagent using the Agent tool. The subagent prompt must include:
   - The WIP path so it can read BRIEF.md, PLAN.md, and write REVIEW.md
   - Steps 2 through 8 below as its procedure
5. When the subagent completes, relay its verdict and options to the user verbatim.

**You (the parent) stop here. Everything below is the subagent's procedure.**

---

## Step 2: Load Stack-Relevant Skills

1. Read BRIEF.md and PLAN.md to identify the tech stack (frameworks, databases, languages).
2. For each technology identified, attempt to load a matching skill using the Skill tool (e.g., "react-best-practices").
3. If a skill exists and loads, use its guidelines during the review to catch stack-specific issues.
4. If no matching skill exists, proceed without it — do not fail or warn.

## Step 3: Code Quality Check (optional)

1. **Claude Code only:** Attempt to invoke `Skill("simplify")` to check for code quality issues in files changed by this feature. If not available, skip silently.
2. Note any findings — they will be included in the review report under "Code Quality".

## Step 4: Layer 1 — Plan vs Implementation (Completeness Check)

1. Parse every task from PLAN.md. Each task typically has: description, expected files, expected functions/components, expected tests.
2. For each task, verify:
   - **Files created/modified** — use Glob and Read to confirm the files exist and were changed.
   - **Functions/components added** — use Grep to confirm the expected symbols exist in the codebase.
   - **Tests written** — use Glob and Grep to confirm test files exist and cover the task.
3. Assign a status to each task:
   - `✓ completed` — all expected artifacts found and substantive.
   - `⚠️ partial` — some artifacts found but others missing or incomplete.
   - `✗ missing` — task not implemented at all.
4. Calculate completion score: `X/Y tasks completed` (partial counts as 0.5).

## Step 5: Anti-pattern Scan

Scan ALL files modified by this feature. Use targeted searches:

| Pattern | What to search | Severity |
|---------|---------------|----------|
| Incomplete work | `TODO`, `FIXME`, `XXX`, `HACK` | Warning |
| Placeholder content | `placeholder`, `coming soon`, `lorem ipsum`, `example.com` | Blocking |
| Empty implementations | `return null`, `return {}`, `return []`, `=> {}`, `pass` as sole function body | Blocking |
| Hardcoded secrets | `sk_test_`, `your-api-key-here`, `password123` | Blocking |
| Debug leftovers | `console.log`, `print(`, `debugger`, `binding.pry` | Warning |

Use Grep to execute these searches across the changed files. Record all findings — they feed into the Issues section of REVIEW.md.

## Step 6: Layer 2 — Goal-Backward Verification

1. Read the **Problem** section of BRIEF.md.
2. Derive "observable truths" — concrete, testable statements that must hold if the problem is truly solved. Example: "A user can POST /api/orders and receive a 201 with an order ID."
3. For each observable truth, verify 4 levels:

   **Level 1: EXISTS**
   - The artifact (file, function, route, component) exists at the expected path.
   - Use Glob and Read to confirm.

   **Level 2: SUBSTANTIVE**
   - The artifact contains real implementation, not stubs or placeholders.
   - Detect anti-patterns:
     - Empty function/handler bodies
     - `TODO`, `FIXME`, `PLACEHOLDER`, `NotImplementedError`, `pass` as sole body
     - Hardcoded mock/dummy return values
     - Commented-out core logic
   - Use Grep and Read to inspect contents.

   **Level 3: WIRED**
   - The artifact is connected to the rest of the system.
   - Check: is it imported somewhere? Is the route registered? Is the component rendered?
   - Use Grep to search for imports, references, route registrations.
   - Flag orphaned code that exists but is never called.

   **Level 4: FUNCTIONAL**
   - The artifact actually works when invoked.
   - Run existing tests (`npm test`, `pytest`, `cargo test`, or whatever the project uses).
   - If no tests exist for this truth, note it as a gap.
   - Check test output for passes and failures.
   - **Test quality audit** — passing tests are not enough. Verify the tests actually prove what they claim:
     - **Disabled test scan**: Search for `it.skip`, `describe.skip`, `xit`, `xdescribe`, `@pytest.mark.skip`, `@Disabled`, `@Ignore`. Any disabled test linked to a feature requirement means that requirement is NOT tested.
     - **Assertion strength check**: Classify test assertions. `toBeDefined()` or `assertNotNull` only prove existence — if the requirement demands specific behavior, the test must assert specific values or outcomes. Weak assertions on critical requirements = gap.
     - **Circular test detection**: Watch for tests that generate expected values by running the system under test. These prove consistency, not correctness. Example: `expect(calculate(x)).toBe(calculate(x))` proves nothing.
   - Flag any findings as warnings in the review.

4. Assign a status per truth:
   - `PASS` — all 4 levels verified.
   - `PARTIAL` — EXISTS + SUBSTANTIVE but not fully WIRED or FUNCTIONAL.
   - `FAIL` — any level fails.

## Step 7: Generate REVIEW.md

1. Create `<WIP>/REVIEW.md` with this structure:

```markdown
# Review: <feature-name>

**Date:** <current date>
**Verdict:** <PASS | PASS WITH WARNINGS | FAIL>

## Completion Score

**X/Y tasks completed**

| Task | Status | Notes |
|------|--------|-------|
| <task description> | ✓ / ⚠️ / ✗ | <details> |

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

## Issues

### Blocking
- <issue description>

### Warnings
- <issue description>

### Info
- <issue description>

## Code Quality (via /simplify)
- <findings from Step 3, if any>
```

2. Determine the verdict:
   - **PASS** — all tasks completed, all truths pass, no blocking issues.
   - **PASS WITH WARNINGS** — all tasks completed, all truths pass, but warnings exist.
   - **FAIL** — any task missing, any truth fails, or any blocking issue exists.

## Step 8: Report

**Evidence freshness rule.** The verdict must be based on evidence gathered during THIS execution. Never reuse a previous REVIEW.md or assume results from a prior run still hold.

1. Print a summary of the review.
2. Based on the verdict, present options:
   - **PASS (no warnings):** "All clean! Run `/neural.archive` to archive this feature."
   - **PASS WITH WARNINGS:** "Review passed but there are warnings."
     > 1. `/neural.address-review` — fix the warnings automatically
     > 2. `/neural.archive` — archive as-is, warnings accepted
   - **FAIL:** "Issues found."
     > 1. `/neural.address-review` — fix blocking issues and gaps automatically
     > 2. `/neural.debug` — investigate manually
     > 3. Fix manually and run `/neural.review` again
