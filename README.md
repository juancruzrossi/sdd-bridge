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
| Stubs and over-built code | Execute | Vertical-slice TDD loop — every line of code answers a failing test |
| "Done" but it's stubs | Review | 4-level goal-backward verification |

## Installation

### Claude Code (via Plugin Marketplace)

Register the Neural marketplace:

```
/plugin marketplace add juancruzrossi/neural
```

Then install the plugin:

```
/plugin install neural@neural
```

### Codex

Install the Neural skills globally:

```bash
curl -fsSL https://raw.githubusercontent.com/juancruzrossi/neural/main/.codex/install.sh | bash
```

## The Workflow

### `/neural.interview` — Clarify before you build

Socratic interview that clarifies requirements and captures concise feature context in `CONTEXT.md`.

### `/neural.plan` — Plan with adversarial review

Generates a sequential task list with dependencies and explicit per-task **Behaviors to verify** — each behavior becomes one red→green slice during execution. Runs a self-adversarial pass ("what can go wrong?"). Optionally sends the plan to Codex for cross-review — you decide which suggestions to apply.

### `/neural.execute` — Test-driven execution loop

Walks the plan one task at a time, in dependency order. For each task, follows a vertical-slice TDD loop: one failing test → minimum code to pass → next test → refactor on green. No subagents, no waves — fewer tokens, more discipline, no stubs. Commits are atomic per task and only happen with explicit user approval at the end.

### `/neural.review` — Verify against the goal, not the task list

Two-layer verification:
1. **Plan vs Implementation** — did every task get done?
2. **Goal-Backward** — does the code actually solve the original problem? Checks 4 levels: exists → substantive → wired → functional. Catches stubs, placeholders, and orphaned code.

### `/neural.address-review` — Fix what review found

Parses REVIEW.md, builds a fix plan from blocking issues and warnings, and executes fixes with verification. No manual triage needed.

### `/neural.quick` — Fast-path for small tasks

Three questions, inline plan, direct execution, light review. No files generated. For when the task is clear and small.

### `/neural.debug` — Root-cause investigation

Four-phase systematic debugging: investigate → analyze → hypothesize → implement. No fixes without root cause.

### `/neural.sync` — Align specs with reality

After implementation, code evolves — refactors, bug fixes, scope changes. Specs go stale. Sync reads the actual codebase and updates CONTEXT.md and PLAN.md to match what was built. Code is the source of truth.

### `/neural.status` — Where am I?

Shows progress of all features in `.neural/wip/` with next-step suggestions. Detects in-progress work on session start.

### `/neural.archive` — Clean up

Moves completed features from `.neural/wip/` to `.neural/archive/`.

### `/neural.help` — Command reference

Shows all available Neural plugin commands with short descriptions and the recommended workflow.

## Artifacts

All Neural artifacts live in `.neural/` at your project root:

```
.neural/
├── wip/
│   └── auth-system/
│       ├── CONTEXT.md    ← interview output
│       ├── docs/adr/     ← optional feature decisions
│       ├── PLAN.md       ← plan output
│       └── REVIEW.md     ← review output
└── archive/
    └── user-onboarding/
        ├── CONTEXT.md
        ├── docs/adr/
        ├── PLAN.md
        └── REVIEW.md
```
