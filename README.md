# Bridge SDD

A Spec-Driven Development framework for AI coding agents. Bridge enforces a structured workflow that turns vague ideas into verified implementations through disciplined phases.

```
interview → plan → execute → review → archive
```

No ambiguity survives the interview. No plan ships without adversarial review. No code merges without goal-backward verification.

## Installation

### Claude Code (via Plugin Marketplace)

Register the marketplace first:

```
/plugin marketplace add juancruzrossi/cc-marketplace
```

Then install the plugin:

```
/plugin install bridge@cc-marketplace
```

### Codex

Tell Codex:

```
Fetch and follow instructions from https://raw.githubusercontent.com/juancruzrossi/sdd-bridge/main/.codex/INSTALL.md
```

## The Workflow

### `/bridge:interview` — Clarify before you build

Socratic interview that identifies gray areas in your requirements and resolves them one by one. Uses selective pressure — challenges assumptions only where risk is high. Locks decisions into a `BRIEF.md`.

### `/bridge:plan` — Plan with adversarial review

Generates an implementation plan with tasks, dependencies, and wave grouping. Runs a self-adversarial pass ("what can go wrong?"). Optionally sends the plan to Codex for cross-review.

### `/bridge:execute` — Parallel execution with fresh context

Groups tasks into dependency waves. Dispatches independent tasks to parallel subagents, each with a clean context window. Every subagent verifies its work (tests, build) before committing. No context rot.

### `/bridge:review` — Verify against the goal, not the task list

Two-layer verification:
1. **Plan vs Implementation** — did every task get done?
2. **Goal-Backward** — does the code actually solve the original problem? Checks 4 levels: exists → substantive → wired → functional. Catches stubs, placeholders, and orphaned code.

### `/bridge:quick` — Fast-path for small tasks

Three questions, inline plan, direct execution, light review. No files generated. For when the task is clear and small.

### `/bridge:debug` — Root-cause investigation

Four-phase systematic debugging: investigate → analyze → hypothesize → implement. No fixes without root cause.

### `/bridge:status` — Where am I?

Shows progress of all features in `.bridge/wip/` with next-step suggestions. Detects in-progress work on session start.

### `/bridge:archive` — Clean up

Moves completed features from `.bridge/wip/` to `.bridge/archive/`.

## Artifacts

All Bridge artifacts live in `.bridge/` at your project root:

```
.bridge/
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

Add `.bridge/` to `.gitignore` or commit it — your choice. The artifacts are human-readable and useful for team context.

## How It Works

Bridge is built on three principles:

1. **Clarify before you code.** The interview phase forces ambiguities to the surface before planning begins. Decisions are locked, not revisited.

2. **Fresh context per task.** Each execution subagent gets a clean context window with only what it needs. No accumulated noise, no quality degradation on task 8 because of what happened on task 1.

3. **Verify against goals, not tasks.** Task completion ≠ goal achievement. A "create chat component" task can complete when the component is a placeholder. Goal-backward verification catches this.

## License

MIT
