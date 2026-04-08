---
name: neural-review
description: "[Neural SDD] Plan vs implementation verification with goal-backward analysis. Part of the neural plugin — invoke via /neural:review"
keep-coding-instructions: true
---

# Neural Review — Plan vs Implementation Verification

## Step 0: Dispatch with Fresh Context

The review must run in a clean context window — free from execution noise, prior assumptions, and accumulated state. This is critical: a reviewer biased by the implementer's context will confirm rather than verify.

1. Read `$ARGUMENTS` to determine the feature name. If empty, scan `.neural/wip/` — one match → use it, multiple → ask.
2. Read `.neural/wip/<feature>/BRIEF.md` and `.neural/wip/<feature>/PLAN.md`.
3. Dispatch a single subagent using the Agent tool with this prompt:

```
You are an independent reviewer for the Neural SDD framework. You have NOT seen the implementation process — you are verifying from scratch.

## Feature Specs
<Full BRIEF.md content>

## Implementation Plan
<Full PLAN.md content>

## Your Task
Follow the review procedure below exactly. Write REVIEW.md and report the verdict.

<Paste Steps 1-8 below into the subagent prompt>
```

4. When the subagent completes, relay its verdict and options to the user. Do not add your own interpretation.

**Stop here.** Everything below is the procedure the subagent executes — do not run it yourself.

---

## Step 1: Setup

1. Determine the feature name from `$ARGUMENTS`. If empty, scan `.neural/wip/` for a single directory — use it. If multiple exist, ask the user which feature to review.
2. Set `WIP=.neural/wip/<feature>/`.
3. Read `$WIP/BRIEF.md` and `$WIP/PLAN.md`. If either is missing, abort with: "Missing BRIEF.md or PLAN.md. Run /neural:plan first."

## Step 2: Load Stack-Relevant Skills

1. Read BRIEF.md and PLAN.md to identify the tech stack (frameworks, databases, languages).
2. For each technology identified, attempt to load a matching skill using the Skill tool (e.g., "react-best-practices").
3. If a skill exists and loads, use its guidelines during the review to catch stack-specific issues.
4. If no matching skill exists, proceed without it — do not fail or warn.

## Step 3: Code Quality Check (optional)

1. **Claude Code only:** Attempt to invoke `Skill("simplify")` to check for code quality issues in files changed by this feature. If you are not running on Claude Code, or the skill is not available, skip this step silently and continue.
2. Note any findings — they will be included in the review report under "Code Quality".

## Step 4: Layer 1 — Plan vs Implementation (Completeness Check)

1. Parse every task from `PLAN.md`. Each task typically has: description, expected files, expected functions/components, expected tests.
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

Scan ALL files modified by this feature (not just those linked to specific truths). Use targeted searches:

| Pattern | What to search | Severity |
|---------|---------------|----------|
| Incomplete work | `TODO`, `FIXME`, `XXX`, `HACK` | Warning |
| Placeholder content | `placeholder`, `coming soon`, `lorem ipsum`, `example.com` | Blocking |
| Empty implementations | `return null`, `return {}`, `return []`, `=> {}`, `pass` as sole function body | Blocking |
| Hardcoded secrets | `sk_test_`, `your-api-key-here`, `password123` | Blocking |
| Debug leftovers | `console.log`, `print(`, `debugger`, `binding.pry` | Warning |

Use Grep to execute these searches across the changed files. Record all findings — they feed into the Issues section of REVIEW.md.

## Step 6: Layer 2 — Goal-Backward Verification

1. Read the **Problem** section of `BRIEF.md`.
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

1. Create `$WIP/REVIEW.md` with this structure:

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
- <findings from Step 1, if any>
```

2. Determine the verdict:
   - **PASS** — all tasks completed, all truths pass, no blocking issues.
   - **PASS WITH WARNINGS** — all tasks completed, all truths pass, but warnings exist.
   - **FAIL** — any task missing, any truth fails, or any blocking issue exists.

## Step 8: Report to User

**Evidence freshness rule.** The verdict in REVIEW.md must be based on evidence gathered during THIS execution of neural-review. Never reuse a previous REVIEW.md or assume results from a prior run still hold. If Step 6 Level 4 requires running tests, you must run them now and report the actual output — not recall or assume what they would produce.

1. Print a summary of the review to the conversation.
2. Based on the verdict, present the user with options:
   - **PASS (no warnings):** Say: "All clean! Run `/neural:archive` to archive this feature."
   - **PASS WITH WARNINGS:** Say: "Review passed but there are warnings. What do you want to do?"
     > 1. `/neural:address-review` — fix the warnings automatically
     > 2. `/neural:archive` — archive as-is, warnings accepted
   - **FAIL:** Say: "Issues found. What do you want to do?"
     > 1. `/neural:address-review` — fix blocking issues and gaps automatically
     > 2. `/neural:debug` — investigate manually
     > 3. Fix manually and run `/neural:review` again
