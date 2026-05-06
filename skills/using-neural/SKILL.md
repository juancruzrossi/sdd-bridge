---
name: using-neural
description: "[Neural SDD] Session hook — detects complex tasks, suggests the SDD workflow, and resumes in-progress features from .neural/wip/"
keep-coding-instructions: true
---

# Neural SDD Framework

Neural is a Spec-Driven Development framework. It provides a structured workflow that turns vague ideas into verified implementations through disciplined phases.

## Available Skills

| Claude Code | Codex | Phase | Purpose |
|-------------|-------|-------|---------|
| `/neural.interview` | `$neural.interview` | Clarification | Socratic interview → generates BRIEF.md |
| `/neural.plan` | `$neural.plan` | Planning | Implementation plan with adversarial review → generates PLAN.md |
| `/neural.execute` | `$neural.execute` | Implementation | Wave-based parallel execution with fresh subagents |
| `/neural.review` | `$neural.review` | Verification | Plan vs implementation + goal-backward verification |
| `/neural.address-review` | `$neural.address-review` | Remediation | Fix blocking issues and warnings from REVIEW.md |
| `/neural.quick` | `$neural.quick` | Fast-path | Mini-interview + inline plan + execute + light review (no files) |
| `/neural.debug` | `$neural.debug` | Diagnosis | Root-cause investigation for bugs and failures |
| `/neural.status` | `$neural.status` | State | Show progress of all features in .neural/wip/ |
| `/neural.sync` | `$neural.sync` | Maintenance | Sync specs with post-implementation code (code as source of truth) |
| `/neural.archive` | `$neural.archive` | Cleanup | Move completed feature from wip/ to archive/ |
| `/neural.help` | `$neural.help` | Reference | Show all available Neural plugin commands with descriptions |

## The Workflow

```
interview → plan → execute → review → archive
                                ↕         ↑
                         debug / sync   address-review
```

## When to Suggest Neural

Evaluate every user request. If the task is **complex, ambiguous, or multi-step** (new feature, architectural change, multi-file refactor), suggest starting with `/neural.interview`.

Do NOT suggest neural for:
- Simple bug fixes with obvious solutions
- Single-line changes or typo fixes
- Questions about existing code
- Tasks the user explicitly wants done quickly without process

## State Detection

On session start, check if `.neural/wip/` exists in the current working directory. If it does:

1. List all feature directories in `.neural/wip/`
2. For each, check which artifacts exist (BRIEF.md, PLAN.md, REVIEW.md)
3. Announce: "Neural SDD: Found in-progress feature(s)" and suggest the next step

Example:
```
Neural SDD: Found in-progress feature "auth-system"
  ✓ BRIEF.md (interview complete)
  ✓ PLAN.md (plan complete)
  ✗ REVIEW.md (not yet reviewed)
  → Suggest: /neural.execute or /neural.review
```

## Artifact Location

All Neural artifacts live in `.neural/` at the project root:

```
.neural/
├── wip/<feature-name>/
│   ├── BRIEF.md      ← interview output
│   ├── PLAN.md       ← plan output
│   └── REVIEW.md     ← review output
└── archive/<feature-name>/
    ├── BRIEF.md
    ├── PLAN.md
    └── REVIEW.md
```
