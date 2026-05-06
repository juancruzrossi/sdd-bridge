---
name: neural.quick
description: "[Neural SDD] Fast-path for small tasks — mini-interview, inline plan, execute, and light review in one pass. No files generated. Part of the neural plugin — invoke via /neural.quick"
keep-coding-instructions: true
---

# Neural Quick — Fast-Path Execution

Self-contained fast-path for small, clear tasks. No files are generated (no BRIEF.md, PLAN.md, or .neural/ artifacts). The entire cycle happens in the conversation.

## When to Use

Ideal for:
- Single-file changes
- Adding a small feature or utility
- Quick refactors (rename, extract function, simplify logic)
- Bug fixes where the cause is already known
- Config tweaks, dependency bumps, small wiring

Do NOT use for: multi-module features, architectural changes, or tasks requiring stakeholder alignment. Use the full neural flow for those.

## Procedure

### Step 1 — Mini-Interview (3 questions max)

Ask ONLY the questions that are not already answered by the user's arguments or context. Skip any question whose answer is obvious.

1. **What do you want to build/change?** — Skip if the user already described the task in their arguments.
2. **Where in the codebase?** — Identify the affected files or modules. If unclear, scan the repo to propose candidates and confirm.
3. **Anything we should NOT touch?** — Non-goals, constraints, files to leave alone. Skip if the task is narrowly scoped and obvious.

If all three answers are clear from the arguments, skip the interview entirely and move to Step 2.

### Step 2 — Inline Plan

Produce a short numbered task list directly in the conversation. Format:

```
Plan:
1. <action> in <file>
2. <action> in <file>
3. ...
```

Rules:
- Keep it to 1-6 items. If more than 6, this task is too big for quick — suggest the full neural flow instead.
- Each item is one concrete action (create function, modify condition, add import, update test, etc.).
- Show the plan to the user and wait for confirmation before executing. If the user passed clear arguments and the plan is obvious (1-2 items), you may proceed without asking.

### Step 3 — Execute

Implement the tasks from the plan.

- For small work (1-2 tasks): execute directly, sequentially.
- For 3+ independent tasks: use subagents to parallelize.
- Follow existing code style and conventions in the repo.
- Do NOT create documentation files, READMEs, or architectural docs unless explicitly requested.

### Step 4 — Light Review

After implementation, perform a quick verification:

1. **Run tests/build** — If the project has a test runner or build command, run it. If tests fail, fix immediately.
2. **Spot check** — Re-read the changed files. Does the change match what was asked? Any obvious issues (typos, missing imports, broken logic)?
3. **Report result** — Summarize what was done in 2-4 sentences. List files changed. Mention test results if applicable.

## Important

- This is the complete cycle. Do NOT hand off to other neural skills.
- Do NOT generate any files in `.neural/` or elsewhere as process artifacts.
- If during execution you realize the task is bigger than expected, stop and suggest switching to the full neural flow.
