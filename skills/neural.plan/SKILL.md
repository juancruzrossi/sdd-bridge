---
name: neural.plan
description: "[Neural SDD] Implementation planning with adversarial review and optional Codex cross-review. Tasks are sequential vertical slices, each carrying its own testable behaviors. Part of the neural plugin — invoke via /neural.plan"
keep-coding-instructions: true
---

# Neural Plan — Implementation Planning

You are generating an implementation plan from the feature `CONTEXT.md` produced by interview. The plan feeds a test-driven execution loop, so every task must declare the **behaviors** it will deliver. Each behavior becomes one red→green slice in `/neural.execute`.

## 1. Locate the feature context

1. List directories under `.neural/wip/`.
2. If exactly one feature directory exists, use it automatically.
3. If multiple exist and `$ARGUMENTS` matches a feature name, use that one.
4. If multiple exist and no argument matches, list them and ask: "Which feature should I plan?"
5. Read `.neural/wip/<feature>/CONTEXT.md`. If missing, stop and tell the user to run `/neural.interview`.
6. Read any ADRs under `.neural/wip/<feature>/docs/adr/` — treat as binding.

## 1b. Explore the codebase

Before writing any plan, ground tasks in reality:

1. Scan the project structure — frameworks, patterns, conventions.
2. Read files related to the feature — existing models, routes, components, tests.
3. Identify dependencies and integration points.
4. Note existing patterns to follow (naming, folder structure, error handling).
5. Cross-check feature language against existing code. If `CONTEXT.md` contradicts the code, stop and ask the user to resolve it.
6. Detect the test runner (e.g., `vitest`, `jest`, `pytest`, `go test`) and note the canonical command. The execute phase will need it.

A plan grounded in the actual codebase is dramatically more executable than one based on guesswork.

## 2. Generate the plan (single pass)

Produce `.neural/wip/<feature>/PLAN.md` with this structure:

```markdown
# Plan: <feature-name>

## Overview
<!-- 2-3 sentences: what will be built and why -->

## Test Runner
<!-- The exact command the executor should run (e.g., `pnpm test`, `pytest -q`). State "none detected" if applicable. -->

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| src/auth/login.ts | Create | Login handler with JWT |
| src/auth/middleware.ts | Modify | Add token validation |

<!-- ALL files touched, with purpose. Prevents tasks from overlapping or forgetting files. -->

## Tasks

| # | Task | Depends on | Estimate |
|---|------|-----------|----------|
| 1 | ... | — | S/M/L |
| 2 | ... | 1 | S/M/L |

### Task details

#### Task 1: <title>
- **What**: concrete deliverable
- **Why**: how it advances the feature
- **Files**: the files this task will touch
- **Behaviors to verify**: bullet list of observable, testable statements. Each one becomes a red→green slice during execution.
  - e.g., "Submitting a valid login returns a JWT cookie."
  - e.g., "Invalid credentials return 401 without a cookie."
- **Acceptance**: how to know this task is done (usually: all behaviors have passing tests + build/lint green).

<!-- Repeat for each task -->

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| ... | H/M/L | H/M/L | ... |

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
<!-- Derived from CONTEXT.md acceptance criteria and ADRs. -->
```

Rules for task generation:

- Number tasks sequentially from 1.
- Each task is **atomic** — one clear deliverable.
- Declare dependencies explicitly (task numbers, or `—` for none).
- Estimate: S (< 30 min), M (30-120 min), L (> 2 hrs).
- Each task **must** list Behaviors to verify. The executor turns each into a single test. Tasks without testable behavior (pure config, formatter rules, dependency bumps) must say so explicitly — write `Behaviors to verify: N/A — non-testable change` and explain how it will be verified instead (build, lint, manual check).
- Derive acceptance criteria directly from `CONTEXT.md` and feature ADRs.

**No placeholders.** Every task must contain concrete, specific values. Banned phrases:

- "TBD", "TODO", "implement later", "to be determined"
- "add appropriate error handling" (specify what)
- "similar to Task N" (spell it out)
- "align X with Y" (state the concrete target)
- "add necessary tests" (the Behaviors list IS the test list — be specific)

If you cannot be specific, the feature context needs more detail — send the user back to `/neural.interview`.

## 3. Adversarial self-review

After writing the plan, do a second pass and answer:

1. **Missing edge cases** — inputs, states, or flows the tasks do not cover?
2. **Dependency gaps** — could any task fail because a predecessor is incomplete?
3. **Scope creep** — any task exceeds what `CONTEXT.md` asks for?
4. **Behavior coverage** — does every requirement from `CONTEXT.md` and the ADRs appear as a behavior in at least one task? List any uncovered requirements.
5. **Rollback** — if a task fails partway, can we revert cleanly? (Atomic commits per task should make this trivial; flag exceptions.)
6. **Behavior quality** — is each "Behavior to verify" observable through the public interface, or does it leak implementation? Rewrite leaky ones.

Append findings:

```markdown
## Adversarial Review

### Issues found
- ...

### Adjustments made
- ...
```

Update tasks and behaviors if the review surfaces real issues. Note what changed.

## 4. Optional Codex cross-review

After writing PLAN.md:

1. Check if `codex` is installed: `codex --version`. If missing, skip silently and go to step 5.
2. If available, ask: **"Codex is available. Want to send this plan for adversarial review?"**
3. If declined, go to step 5.
4. If accepted:
   a. Try `Skill("codex:adversarial-review")` first, passing the feature context, ADRs, and PLAN content.
   b. If the skill is unavailable or fails, fall back to running codex directly. Use `--dangerously-bypass-approvals-and-sandbox` to avoid git/trust prompts:
      ```
      codex exec --dangerously-bypass-approvals-and-sandbox -c 'model_reasoning_effort="high"' "Context: <project-name> (<tech stack>). Relevant docs: @/CLAUDE.md

You are an adversarial reviewer. Review this implementation plan against the feature context and ADRs. Find critical issues, missing edge cases, architectural risks, dependency gaps. Pay special attention to the Behaviors to verify — flag any that are coupled to implementation rather than observable through the public interface.

FEATURE CONTEXT:
<CONTEXT.md content>

FEATURE ADRS:
<ADR contents or 'none'>

PLAN:
<plan-content>

Output a structured review with CRITICAL issues, WARNINGS, and SUGGESTIONS. Cite task numbers."
      ```
   c. Show the full Codex review and ask:
      > "Codex review above. What do you want to do?"
      > 1. Apply all suggestions — I update the plan
      > 2. Cherry-pick — tell me which ones to apply
      > 3. Ignore — keep the plan as-is
   d. Do **not** modify the plan without explicit user approval.
   e. If the user applies changes, update PLAN.md and append:
      ```markdown
      ## Codex Review
      <!-- Codex feedback and user-approved changes noted here -->
      ```

## 5. Finalize

1. Write the final PLAN.md to `.neural/wip/<feature>/PLAN.md`.
2. Print a summary: task count, total behaviors, top risks.
3. Suggest: **"Ready to execute? Run `/neural.execute`."**
