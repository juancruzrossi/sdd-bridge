---
name: neural.address-review
description: "[Neural SDD] Execute all fixes from a REVIEW.md — address warnings, blocking issues, and gaps found during review. Part of the neural plugin — invoke via /neural.address-review"
keep-coding-instructions: true
---

# Neural Address Review — Fix Review Findings

You are executing the fixes identified in a REVIEW.md produced by review.

## 1. Locate the review

1. List directories under `.neural/wip/`.
2. If exactly one feature directory exists, use it automatically.
3. If multiple exist and the user passed `$ARGUMENTS` matching a feature name, use that one.
4. If multiple exist and no argument matches, list them and ask: "Which feature's review should I address?"
5. Read `.neural/wip/<feature>/REVIEW.md`. If it does not exist, stop and tell the user to run `/neural.review` first.
6. Read `.neural/wip/<feature>/BRIEF.md` and `.neural/wip/<feature>/PLAN.md` for context.

## 2. Parse review findings

Extract all issues from REVIEW.md:

1. **Blocking issues** — these MUST be fixed. No exceptions.
2. **Warnings** — present each to the user and ask: "Fix this? (y/n/skip all warnings)"
   - If the user says "skip all warnings", skip remaining warnings.
3. **Info items** — skip unless the user explicitly asks to address them.

Also extract:
- Tasks marked as `⚠️ partial` or `✗ missing` from the Completion Score table.
- Goal-Backward truths marked as `PARTIAL` or `FAIL`.

## 3. Build fix plan

For each issue to address, create a concrete fix task:

```
Fix Plan:
1. [BLOCKING] <issue> → <what to do> in <file>
2. [WARNING] <issue> → <what to do> in <file>
3. [PARTIAL] Task N: <what's missing> → <what to do>
4. [FAIL] Truth "<truth>": <what failed at which level> → <what to do>
```

Show this plan to the user and wait for confirmation before executing.

## 4. Execute fixes

For each fix task:

1. Implement the fix.
2. If running on Claude Code, invoke `Skill("simplify")` on modified files. Skip silently on other runtimes.
3. Verify the fix addresses the specific issue (run relevant tests, check the file, confirm the anti-pattern is gone).
4. **If the project has git initialized**, make an atomic commit per fix:
   - `fix(<feature>): address review — <brief description>`
   - If no git, skip commits.

For multiple independent fixes, dispatch subagents in parallel.

## 5. Re-run verification

After all fixes are applied:

1. Run the project's test suite (if one exists).
2. Re-check the specific issues that were fixed — confirm they no longer appear.
3. If any fix introduced new issues, report them and ask the user how to proceed.

## 6. Report and suggest next step

Print a summary:

```
Address Review Complete:
  Fixed: N blocking issues, M warnings
  Remaining: K items (skipped by user)
```

Then suggest: **"Fixes applied. Run `/neural.review` again to verify, or `/neural.archive` if you're confident."**
