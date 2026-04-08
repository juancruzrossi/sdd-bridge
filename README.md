<div align="center">

# Neural

**A lightweight, token-efficient Spec-Driven Development framework for AI coding agents. Turns vague ideas into verified implementations through disciplined phases — no bloat, no ceremony, just structured execution that works.**

```
interview → plan → execute → review → archive
```

</div>

## Why Neural?

Most AI agent failures aren't about bad code — they're about unclear requirements, fantasy plans, context rot, and "done" without evidence. Neural addresses each failure mode with a specific phase:

| Failure Mode | Neural Phase | How |
|---|---|---|
| Vague requirements | Interview | Socratic questioning with selective pressure |
| Plans based on assumptions | Plan | Mandatory codebase exploration + adversarial self-review |
| Quality degradation as context window fills | Execute | Fresh context window per subagent |
| "Done" but it's stubs | Review | 4-level goal-backward verification |

## Installation

### Claude Code (via Plugin Marketplace)

Register the marketplace first:

```
/plugin marketplace add juancruzrossi/jx-marketplace
```

Then install the plugin:

```
/plugin install neural@jx-marketplace
```

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/juancruzrossi/neural/main/.codex/INSTALL.md
```

## The Workflow

### `/neural:interview` — Clarify before you build

Socratic interview that identifies gray areas in your requirements and resolves them one by one. Uses selective pressure — challenges assumptions only where risk is high. Locks decisions into a `BRIEF.md`. Detects git status and handles non-git projects gracefully.

### `/neural:plan` — Plan with adversarial review

Generates an implementation plan with tasks, dependencies, and wave grouping for parallel execution. Runs a self-adversarial pass ("what can go wrong?"). Optionally sends the plan to Codex for cross-review — you decide which suggestions to apply.

### `/neural:execute` — Parallel execution with fresh context

Groups tasks into dependency waves. Dispatches independent tasks to parallel subagents, each with a clean context window — no accumulated noise, no quality degradation. Smart model routing: routine tasks go to lightweight models, complex tasks to premium ones. Every subagent verifies its own work before committing.

### `/neural:review` — Verify against the goal, not the task list

Two-layer verification:
1. **Plan vs Implementation** — did every task get done?
2. **Goal-Backward** — does the code actually solve the original problem? Checks 4 levels: exists → substantive → wired → functional. Catches stubs, placeholders, and orphaned code.

### `/neural:address-review` — Fix what review found

Parses REVIEW.md, builds a fix plan from blocking issues and warnings, and executes fixes with verification. No manual triage needed.

### `/neural:quick` — Fast-path for small tasks

Three questions, inline plan, direct execution, light review. No files generated. For when the task is clear and small.

### `/neural:debug` — Root-cause investigation

Four-phase systematic debugging: investigate → analyze → hypothesize → implement. No fixes without root cause.

### `/neural:sync` — Align specs with reality

After implementation, code evolves — refactors, bug fixes, scope changes. Specs go stale. Sync reads the actual codebase and updates BRIEF.md and PLAN.md to match what was built. Code is the source of truth.

### `/neural:status` — Where am I?

Shows progress of all features in `.neural/wip/` with next-step suggestions. Detects in-progress work on session start.

### `/neural:archive` — Clean up

Moves completed features from `.neural/wip/` to `.neural/archive/`.

### `/neural:help` — Command reference

Lists all available Neural commands with brief descriptions. Quick reference for the workflow.

## Artifacts

All Neural artifacts live in `.neural/` at your project root:

```
.neural/
├── wip/
│   └── auth-system/
│       ├── BRIEF.md      ← interview output
│       ├── PLAN.md       ← plan output
│       └── REVIEW.md     ← review output
└── archive/
    └── user-onboarding/
        ├── BRIEF.md
        ├── PLAN.md
        └── REVIEW.md
```

Add `.neural/` to `.gitignore` or commit it — your choice. The artifacts are human-readable and useful for team context.

## Design Principles

1. **Clarify before you code.** The interview phase forces ambiguities to the surface before planning begins. Decisions are locked, not revisited.

2. **Fresh context per task.** Each execution subagent gets a clean context window with only what it needs. No accumulated noise, no quality degradation on task 8 because of what happened on task 1.

3. **Verify against goals, not tasks.** Task completion ≠ goal achievement. A "create chat component" task can complete when the component is a placeholder. Goal-backward verification catches this.

4. **Git-optional.** Works with or without version control. If git is initialized, Neural makes atomic commits per task. If not, it works fully local without nagging.

5. **Token-efficient.** No runtime, no daemon, no build step.
