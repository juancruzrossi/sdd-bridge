---
name: neural-sync
description: "[Neural SDD] Sync specs (BRIEF.md, PLAN.md) with post-implementation code. Code is the source of truth. Part of the neural plugin — invoke via /neural:sync"
---

# Neural Sync — Align Specs with Implementation

You are running the neural-sync skill. Follow these steps exactly.

## Purpose

After implementation, code evolves — refactors, bug fixes, scope adjustments. Specs (BRIEF.md, PLAN.md) become stale. This skill reads the actual codebase and updates specs to match what was built, preserving the artifacts as accurate documentation.

**Iron rule:** Code is the source of truth. Specs conform to code, never the reverse.

## Step 1: Locate Feature

1. Determine the feature name from `$ARGUMENTS`. If empty, scan `.neural/wip/` and `.neural/archive/` for directories. If one exists, use it. If multiple, ask the user which feature to sync.
2. Set `DIR=.neural/<wip|archive>/<feature>/`.
3. Read `BRIEF.md` and `PLAN.md` from `$DIR`. Both must exist — abort if either is missing.

## Step 2: Discover What Was Built

1. Read `PLAN.md` to extract the original task list, file paths, and expected artifacts.
2. For each file path referenced in the plan:
   - Check if it still exists (it may have been renamed or removed).
   - If it exists, read it to understand current implementation.
   - If missing, search for likely renames using Grep on key function/class names from the plan.
3. Use `git log --oneline` on the feature's files to identify post-plan changes (refactors, fixes, additions).
4. Build a **delta list**: what changed between plan and current code.

## Step 3: Update PLAN.md

Update `PLAN.md` to reflect the actual implementation. For each task:

1. **Completed as planned** — no change needed.
2. **Completed differently** — update the task description, file paths, and function names to match what was actually built. Add a brief `[synced]` note explaining the deviation.
3. **Removed or replaced** — mark as `[removed]` with a one-line reason if detectable from git history or code comments.
4. **Added post-plan** — append new tasks under a `## Post-Plan Additions` section at the end of the task list. Keep the same format as existing tasks.

Preserve the original structure (waves, dependencies) but update content to match reality.

## Step 4: Update BRIEF.md

Update `BRIEF.md` to reflect the actual scope and decisions:

1. **Decisions that changed** — update the decision and add `[synced]` with the reason.
2. **Scope changes** — if features were added or removed post-interview, update the scope section.
3. **Technical choices that shifted** — update tech stack or approach sections if implementation diverged.

Do NOT rewrite the brief from scratch. Make surgical updates that keep the original structure intact.

## Step 5: Update REVIEW.md (if exists)

If `REVIEW.md` exists in the feature directory:

1. Add a note at the top: `> **Synced on <date>** — specs updated to match post-implementation code.`
2. Do not re-run the review. If the user wants a fresh review, suggest `/neural:review`.

## Step 6: Report

Print a concise summary:

```
Neural Sync: <feature-name>

PLAN.md:
  - X tasks updated
  - Y tasks added (post-plan)
  - Z tasks removed

BRIEF.md:
  - N decisions updated
  - M scope changes

All specs now match the current codebase.
```

If `$DIR` is in `archive/`, remind the user: "This feature is archived. The synced specs serve as documentation."

If `$DIR` is in `wip/`, suggest: "Specs synced. Run `/neural:review` to verify, or `/neural:archive` to close."
