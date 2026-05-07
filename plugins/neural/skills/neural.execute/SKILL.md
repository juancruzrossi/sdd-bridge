---
name: neural.execute
description: "[Neural SDD] Wave-based parallel execution with fresh subagents and atomic commits. Part of the neural plugin — invoke via /neural.execute"
keep-coding-instructions: true
---

# Neural Execute — Wave-Based Parallel Execution

You are executing an implementation plan from a PLAN.md produced by plan.

## 1. Locate the feature

1. List directories under `.neural/wip/`.
2. If exactly one feature directory exists, use it automatically.
3. If multiple exist and the user passed `$ARGUMENTS` matching a feature name, use that one.
4. If multiple exist and no argument matches, list them and ask: "Which feature should I execute?"
5. Read `.neural/wip/<feature>/PLAN.md`. If it does not exist, stop and tell the user to run `/neural.plan` first.
6. Read `.neural/wip/<feature>/BRIEF.md` for context. If it does not exist, warn but continue with PLAN.md only.

## 2. Parse tasks and build the dependency graph

1. Extract the task table from PLAN.md — each row has: task number, title, dependencies, wave, estimate.
2. Extract the detailed task descriptions from the "Task details" section.
3. Extract the "Waves" section to determine execution order.
4. Build a dependency graph: for each task, record which tasks must complete before it can start.
5. Validate the graph: check for circular dependencies. If found, stop and report the cycle to the user.

## 3. Execute wave by wave

For each wave (starting from Wave 1):

### 3a. Prepare the wave

1. Identify all tasks in the current wave.
2. Verify all dependencies for each task are satisfied (completed successfully in previous waves).
3. **Check for file conflicts within the wave.** Collect all files listed in the "Files" field of each task in this wave. If two or more tasks modify the same file, they cannot run in parallel — split them into sequential execution within this wave or move one to the next wave. Announce any conflicts found.
4. If any dependency failed and was not resolved, ask the user how to proceed before starting the wave.
5. Announce: **"Starting Wave N — Tasks [X, Y, Z]"**

### 3b. Dispatch parallel subagents

For each task in the wave, dispatch a subagent using the Agent tool with the following prompt structure:

```
You are executing Task <N>: <title>

## Context
<Full BRIEF.md content>

## Implementation Plan
<Full PLAN.md content>

## Your Task
<Detailed task description from PLAN.md, including What, Why, Files, Acceptance>

## Instructions
1. Implement the task as described.
2. Only modify the files listed in the task (or closely related files if needed).
3. Follow existing code style and conventions in the codebase.
4. After implementation, verify your work:
   - If tests exist: run the relevant test suite and ensure tests pass.
   - If a build system exists: run the build and ensure it succeeds.
   - If a linter is configured: run it and fix any issues.
   - If none of the above exist: manually verify the acceptance criteria.
5. **Do NOT commit.** The orchestrator handles all git writes at the end of `/neural.execute`, gated by user approval.
   - Never run `git add`, `git commit`, `git stash`, `git restore`, or any command that mutates git state.
   - `git diff` / `git status` are fine (read-only).
6. Report back with:
   - Status (DONE / DONE_WITH_CONCERNS / BLOCKED / NEEDS_CONTEXT).
   - **Files modified** (absolute paths, one per line).
   - **Files created** (absolute paths, one per line).
   - **Files deleted** (absolute paths, one per line).
   - Verification results (tests, build, lint).
   - Any concerns or deviations.

## Decision Boundaries
Check BRIEF.md for the "Decision Boundaries" section. It defines what you can decide on your own and what requires user approval for THIS specific feature. Apply those boundaries first. For anything not covered by Decision Boundaries, fall back to the generic Deviation Rules below.

## Deviation Rules
When you encounter something not explicitly covered in the task or in Decision Boundaries:

**Auto-fix (just do it, mention in report):**
- Bug found while implementing (wrong logic, broken import, typo)
- Missing dependency/import needed for your task
- Build or lint error caused by your changes
- Test that needs minor adjustment to match new behavior

**Auto-add (do it, flag in report):**
- Input validation the task forgot to mention
- Error handling for obvious failure paths
- Null/undefined guards on data you're consuming

**Ask (report BLOCKED):**
- Database schema changes not in the plan
- Adding a new external dependency/library
- Changing a public API contract or interface
- Architectural decisions (new patterns, new abstractions)
- Modifying files not listed in your task

When in doubt, do less and report BLOCKED. Incomplete honest work beats complete wrong work.

## Status Protocol
When you finish, report one of these statuses:
- DONE — task completed, all acceptance criteria verified.
- DONE_WITH_CONCERNS — task completed but you noticed potential issues (describe them).
- BLOCKED — cannot complete without additional information or a dependency fix (explain what's missing).
- NEEDS_CONTEXT — need to understand more about the codebase before proceeding (list specific questions).

If you encounter something unexpected or realize the task is more complex than described, STOP and report BLOCKED. Incomplete work that claims to be done is worse than honestly reporting you're stuck.
```

Key principles for subagent dispatch:
- Each subagent gets a **fresh context window** — no shared state between subagents. This prevents context rot.
- Each subagent receives the full BRIEF.md and PLAN.md so it understands the broader picture.
- Each subagent is responsible for its own verification. **The orchestrator owns all git operations** — subagents must not mutate git state.
- Dispatch all tasks in the wave **in parallel** using separate Agent tool calls.

**Model routing (optional).** If the runtime supports model selection for subagents, classify each task before dispatch:
- **ROUTINE** (file creation, config, formatting, simple wiring) → use `haiku` or cheapest available model.
- **MODERATE** (business logic, API endpoints, component implementation) → use `sonnet` or mid-tier model.
- **COMPLEX** (debugging, architectural wiring, security-sensitive, error handling) → use `opus` or premium model.
If the runtime does not support model selection, ignore this and dispatch all with the default model.

### 3c. Collect results

1. Wait for all subagents in the wave to complete.
2. For each task, record the outcome: **completed** or **failed**.
3. **Verify each completed task.** For each task that reported DONE or DONE_WITH_CONCERNS, dispatch a **verification subagent** (separate from the implementer) with this prompt:

```
You are verifying Task <N>: <title>

The implementer claims this task is complete. Do NOT trust their report blindly — verify independently.

## Verification checklist
1. Read the files the implementer claims to have changed. Confirm they exist and contain real implementation.
2. Check for stubs: empty function bodies, TODO comments, placeholder returns, hardcoded mock values.
3. Verify the acceptance criteria from the plan are actually met — not just claimed.
4. If tests were supposed to be written, confirm they exist AND test meaningful behavior (not just that the function is defined).
5. Report: VERIFIED, CONCERNS (list them), or FAILED (explain why).
```

If the verification returns CONCERNS or FAILED, report to the user before proceeding.

4. Print a wave summary:

```
Wave N complete:
  ✓ Task X: <title> — <brief summary of changes>
  ✓ Task Y: <title> — <brief summary of changes>
  ✗ Task Z: <title> — FAILED: <error summary>
```

### 3c-bis. Track task → files mapping (do NOT commit)

Accumulate each completed task's files (modified + created + deleted), title, and inferred commit type. This mapping feeds § 5's commit phase. No git writes between waves — the orchestrator is the single writer, run once, on the user's signal.

### 3d. Handle failures

If any task in the wave failed:

1. Report the failure details clearly: what went wrong, which files were affected, error output.
2. Ask the user how to proceed. Present options:
   - **Retry**: Re-dispatch the failed task with additional context about the failure.
   - **Skip**: Mark the task as skipped and continue. Warn if downstream tasks depend on it.
   - **Abort**: Stop execution entirely. Report progress so far.
3. If the user chooses to skip a task that has dependents, list the affected downstream tasks and confirm.
4. Wait for user decision before proceeding.

### 3e. Post-wave checkpoint

Before advancing, run a quick health check:

1. **Tests pass?** Run the project test suite (if one exists). If tests fail, stop and report — don't start the next wave on broken foundations.
2. **Build OK?** Run the build command (if one exists). A failing build means the current wave left something broken.
3. If both pass (or neither exists), proceed silently. If either fails, report the failure and ask the user whether to fix now or continue.

This prevents cascading errors across waves — a bug in Wave 1 that goes undetected makes Waves 2-N wrong.

### 3f. Advance to next wave

1. Update the dependency graph: mark completed tasks as satisfied.
2. Move to the next wave.
3. Repeat from step 3a.

## 4. Progress tracking

Maintain a running progress summary throughout execution. After each wave, display:

```
Progress: N/M tasks completed | Wave K/T done
Completed: [1, 2, 3]
Remaining: [4, 5]
Failed: [6] (skipped)
```

## 5. Post-execution cleanup

After all waves complete (or execution is aborted):

1. If running on Claude Code, invoke `Skill("simplify")` on all modified files. Skip silently if unavailable or on a different runtime.
2. Review modified files for AI-generated noise:
   - Comments restating what the code already says (e.g. `// increment counter` above `counter++`).
   - Over-documentation: excessive JSDoc on obvious methods, redundant type annotations.
   - Stray `console.log` / debug output.
3. Re-run the test suite after cleanup. If tests fail, revert the cleanup for that file.

## 6. Final report

1. Print: tasks completed / failed / skipped, subagent warnings. Note that the working tree still holds uncommitted changes — they will be addressed in § 7.
2. If all succeeded, signal readiness for `/neural.review` (but only after § 7 resolves).
3. If any failed or were skipped, note that those should be addressed before review.

## 7. Commit phase (LAST step — always ask the user)

This is the final, isolated step of `/neural.execute`. All prior steps left the working tree unstaged on purpose; only here do commits happen, and only with the user's explicit approval.

Skip this entire step if BRIEF.md has `**Git:** no` or `git rev-parse --is-inside-work-tree` fails — in that case, `/neural.execute` ends after § 6.

1. Print the task → files mapping accumulated in § 3c-bis:
   ```
   Changes ready to commit (feature <feature-name>):
     Task 1 — <title>: <file1>, <file2>
     Task 2 — <title>: <file3>
     ...
   Total: N tasks, M files, working tree unstaged.
   ```
2. Ask the user:
   > "All waves completed. Progressively commit, one commit per task, in task-number order?"
   > 1. Yes — commit now.
   > 2. Show full diff first (`git diff` + per-task file list), then decide.
   > 3. No — leave unstaged; I'll handle commits manually.
3. Wait for the user's decision.
4. **If Yes** — for each `DONE` / `DONE_WITH_CONCERNS` task, in task-number order:
   a. Stage only the task's files by explicit path: `git add <file1> <file2> ...`. **Never use `git add -A`, `git add .`, or `git commit -am`.** Exclude `.neural/**` and files owned by other tasks.
      - If a file is touched by multiple tasks, assign it to the last task that modified it.
   b. Run `git diff --cached --name-only` and verify the staged set matches the task's file list. If it drifts, stop and report; do not commit.
   c. Commit with `<type>(<feature-slug>): <task-title>` (type inferred: feature / fix / refactor / chore / test / docs).
   d. Record the commit hash.

   After the loop: run `git log --oneline <base>..HEAD` and confirm commit count equals successful task count. If it diverges, surface it.
   If a `git commit` fails (hook rejection, hook auto-fix re-dirties the tree), stop and ask: fix & retry / skip that task / abort. Never `--no-verify`.
5. **If Show diff** — print `git status` + per-task file list, then re-prompt from step 2.
6. **If No** — note the working tree is left unstaged; the user owns commits from here.

After this step, suggest `/neural.review`.
