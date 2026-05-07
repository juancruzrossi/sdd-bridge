---
name: neural.sync
description: "[Neural SDD] Sync specs (BRIEF.md, PLAN.md) with post-implementation code — code as source of truth. Part of the neural plugin — invoke via /neural.sync"
keep-coding-instructions: true
---

# Neural Sync — Align Specs with Implementation

Specs drift after implementation — refactors, bug fixes, scope changes. This skill updates BRIEF.md and PLAN.md to match what was actually built, so the artifacts remain useful as documentation rather than a misleading snapshot of what was planned.

**Core principle:** Code as source of truth. Specs conform to code, never the reverse.

## Step 1: Locate Feature

1. Determine feature name from `$ARGUMENTS`. If empty, scan `.neural/wip/` and `.neural/archive/`. One match → use it. Multiple → ask the user.
2. Set `DIR=.neural/<wip|archive>/<feature>/`.
3. Read `BRIEF.md` and `PLAN.md` from `$DIR`. Both must exist — abort if missing.

## Step 2: Build the Delta

The goal is a lightweight scan, not a full re-read of the codebase — just enough to know what diverged.

1. Extract file paths, function/component names, and task descriptions from `PLAN.md`.
2. For each referenced path:
   - Exists → skim for structural changes (renamed exports, changed signatures, new modules).
   - Missing → Grep for key symbols to find renames. If truly deleted, note it.
3. Use `git log --oneline -- <paths>` to spot post-plan changes. Focus on commits after the plan was written (use PLAN.md's date or the earliest feature commit as baseline).
4. Produce a delta list: unchanged, changed, removed, added.

## Step 3: Update PLAN.md

For each task in the plan:

- **Completed as planned** — leave it.
- **Completed differently** — update description, paths, and names to match reality.
- **Removed** — mark `[removed: <one-line reason>]`.
- **Added post-plan** — append under a `## Post-Plan Additions` section, same format as existing tasks.

Preserve the original structure (waves, dependencies). Only touch content that diverged.

## Step 4: Update BRIEF.md

Surgical updates only — do not rewrite from scratch:

- **Decisions that changed** — update the decision text.
- **Scope changes** — add or remove items from the scope section.
- **Technical shifts** — update stack/approach if implementation diverged.

The brief should read as if it was written with knowledge of what was actually built.

## Step 5: Handle REVIEW.md

If `REVIEW.md` exists, delete it. A review based on stale specs is misleading — the user should run `/neural.review` fresh after sync.

## Step 6: Report

```
Neural Sync: <feature-name>

PLAN.md: X updated, Y added, Z removed
BRIEF.md: N decisions updated, M scope changes
```

If in `archive/`: "This feature is archived. Synced specs serve as documentation."
If in `wip/`: "Specs synced. Run `/neural.review` to verify, or `/neural.archive` to close."
