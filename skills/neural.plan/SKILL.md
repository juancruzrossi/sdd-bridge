---
name: neural.plan
description: "[Neural SDD] Implementation planning with adversarial review and optional Codex cross-review. Part of the neural plugin — invoke via /neural.plan"
keep-coding-instructions: true
---

# Neural Plan — Implementation Planning

You are generating an implementation plan from a BRIEF.md produced by interview.

## 1. Locate the brief

1. List directories under `.neural/wip/`.
2. If exactly one feature directory exists, use it automatically.
3. If multiple exist and the user passed `$ARGUMENTS` matching a feature name, use that one.
4. If multiple exist and no argument matches, list them and ask: "Which feature should I plan?"
5. Read `.neural/wip/<feature>/BRIEF.md`. If it does not exist, stop and tell the user to run `/neural.interview` first.

## 1b. Explore the codebase

Before writing any plan, explore the codebase to ground your tasks in reality:

1. Scan the project structure — identify frameworks, patterns, and conventions in use.
2. Read files related to the feature described in BRIEF.md — existing models, routes, components, tests.
3. Identify dependencies and integration points that tasks will need to interact with.
4. Note existing patterns the implementation should follow (naming conventions, folder structure, error handling style).

This step prevents plans based on assumptions. A plan grounded in the actual codebase is dramatically more executable than one based on guesswork.

## 2. Generate the plan (single pass)

Read the full BRIEF.md content. Then produce `.neural/wip/<feature>/PLAN.md` with this structure:

```markdown
# Plan: <feature-name>

## Overview
<!-- 2-3 sentence summary of what will be built and why -->

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| src/auth/login.ts | Create | Login handler with JWT |
| src/auth/middleware.ts | Modify | Add token validation |

<!-- List ALL files that will be created or modified, with their purpose. This prevents tasks from overlapping or forgetting files. -->

## Tasks

| # | Task | Depends on | Wave | Estimate |
|---|------|-----------|------|----------|
| 1 | ... | — | 1 | S/M/L |
| 2 | ... | 1 | 2 | S/M/L |

### Task details

#### Task 1: <title>
- **What**: ...
- **Why**: ...
- **Files**: likely touched files
- **Acceptance**: how to verify this task is done
- **Verification**: exact check to run or perform

<!-- Repeat for each task -->

## Waves

Group independent tasks into waves that can execute in parallel.
Each wave MUST be a vertical slice — end-to-end through all layers, not a horizontal layer.

- **Wave 1**: Tasks [1, 3] — complete feature slices, no dependencies
- **Wave 2**: Tasks [2, 4] — complete feature slices, depend on Wave 1
<!-- etc. -->

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| ... | H/M/L | H/M/L | ... |

## Acceptance Criteria

- [ ] Criterion 1
- [ ] Criterion 2
<!-- Derived from BRIEF.md requirements -->
```

Rules for task generation:
- Number tasks sequentially starting at 1.
- Each task must be atomic — one clear deliverable.
- Declare dependencies explicitly (task numbers or "—" for none).
- Estimate as S (< 30 min), M (30-120 min), L (> 2 hrs).
- Group into waves: tasks with no unmet dependencies share a wave.
- Derive acceptance criteria directly from the BRIEF's requirements.
- Each task must include a concrete Verification step: test command, build/lint command, manual check, or code inspection target.
- **Vertical slices are mandatory.** Every wave MUST deliver end-to-end functionality cutting through all layers (data → logic → interface → test), not horizontal slabs of a single layer. A wave that produces "all database models" or "all API endpoints" is a plan failure — restructure it so each wave delivers one complete, verifiable feature slice. Example: Wave 1 delivers login (schema + API + UI + test), not Wave 1 delivers all schemas.

**No placeholders allowed.** Every task must contain concrete, specific values. The following are banned from task descriptions:
- "TBD", "TODO", "implement later", "to be determined"
- "add appropriate error handling" (specify WHAT error handling)
- "similar to Task N" (spell out what's needed)
- "align X with Y" (state the concrete target)
- "add necessary tests" (specify WHICH test cases)

If you can't be specific, the brief needs more detail — go back to `/neural.interview`.

## 3. Adversarial self-review

After writing the plan, perform a second pass asking:

1. **Missing edge cases**: Are there inputs, states, or flows the tasks don't cover?
2. **Dependency gaps**: Could any task fail because a predecessor is incomplete?
3. **Scope creep**: Does any task exceed what the BRIEF asks for?
4. **Integration risk**: Will the waves actually work in parallel, or are there hidden coupling points?
5. **Rollback**: If a wave fails, can we revert cleanly?
6. **Requirements coverage**: Does every requirement from the BRIEF appear in at least one task? List any BRIEF requirements not covered by the plan.
7. **Vertical slice check**: Is every wave a vertical slice through all relevant layers? If any wave only touches one layer (e.g., "all models" or "all endpoints"), restructure it into feature-complete slices.

Append findings as a section to PLAN.md:

```markdown
## Adversarial Review

### Issues found
- ...

### Adjustments made
- ...
- If coverage gaps are found, add tasks to address them or document why they're intentionally deferred.
```

Update the task table and waves if the review surfaces real issues. Note what changed.

## 4. Optional Codex cross-review

After writing PLAN.md:

1. Check if `codex` CLI is installed by running `codex --version`. If the command fails or is not found, skip this section silently and go to step 5.
2. If codex is available, ask the user: **"Codex is available. Want to send this plan for adversarial review?"**
3. If the user declines, go to step 5.
4. If the user accepts:
   a. First, try to invoke `Skill("codex:adversarial-review")` passing the BRIEF and PLAN content.
   b. If the skill is not available or fails, fall back to running codex directly. **Important:** use `--dangerously-bypass-approvals-and-sandbox` to avoid git/trust prompts:
      ```
      codex exec --dangerously-bypass-approvals-and-sandbox -c 'model_reasoning_effort="high"' "Context: <project-name> (<tech stack detected from codebase>). Relevant docs: @/CLAUDE.md

You are an adversarial reviewer. Review this implementation plan against the brief. Find critical issues, missing edge cases, architectural risks, dependency gaps.

BRIEF:
<brief-content>

PLAN:
<plan-content>

Output a structured review with: CRITICAL issues, WARNINGS, and SUGGESTIONS. Be specific — cite task numbers."
      ```
   c. **Present Codex feedback to the user for decision.** Show the full Codex review and ask:
      > "Codex review above. What do you want to do?"
      > 1. Apply all suggestions — I update the plan
      > 2. Cherry-pick — tell me which ones to apply
      > 3. Ignore — keep the plan as-is
   d. **Do NOT modify the plan without explicit user approval.** Wait for the user's decision before making any changes.
   e. If the user chooses to apply changes, update PLAN.md and append:
      ```markdown
      ## Codex Review
      <!-- Codex feedback and user-approved changes noted here -->
      ```

## 5. Finalize

1. Write the final PLAN.md to `.neural/wip/<feature>/PLAN.md`.
2. Print a summary: number of tasks, number of waves, top risks.
3. Suggest: **"Ready to execute? Run `/neural.execute`"**
