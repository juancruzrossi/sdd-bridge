---
name: neural.help
description: "[Neural SDD] Show all Neural plugin commands with descriptions and the recommended workflow. Part of the neural plugin — invoke via /neural.help"
keep-coding-instructions: true
---

# Neural Help

Show the Neural command reference for the current agent.

## Detect Platform

1. If running in Claude Code, use slash commands: `/neural.<name>`.
2. If running in Codex, use skill commands: `$neural.<name>`.
3. If the platform is unclear, default to slash commands like Claude Code: `/neural.<name>`.

## Claude Code Output

```text
Neural SDD — Plugin Commands

Workflow:
  /neural.interview       Detailed interview → generates BRIEF.md
  /neural.plan            Implementation plan with adversarial review → generates PLAN.md
  /neural.execute         Wave-based parallel execution with fresh subagents
  /neural.review          Plan vs implementation + goal-backward verification → generates REVIEW.md
  /neural.address-review  Fix blocking issues and warnings from REVIEW.md
  /neural.archive         Move completed feature from wip/ to archive/

Utilities:
  /neural.quick           Fast-path: mini-interview + inline plan + execute + light review
  /neural.debug           Root-cause investigation for bugs and failures
  /neural.sync            Sync specs with post-implementation code
  /neural.status          Show progress of all features in .neural/wip/
  /neural.help            Show this command reference

Typical flow: interview → plan → execute → review → archive
```

## Codex Output

```text
Neural SDD — Plugin Commands

Workflow:
  $neural.interview       Detailed interview → generates BRIEF.md
  $neural.plan            Implementation plan with adversarial review → generates PLAN.md
  $neural.execute         Wave-based parallel execution with fresh subagents
  $neural.review          Plan vs implementation + goal-backward verification → generates REVIEW.md
  $neural.address-review  Fix blocking issues and warnings from REVIEW.md
  $neural.archive         Move completed feature from wip/ to archive/

Utilities:
  $neural.quick           Fast-path: mini-interview + inline plan + execute + light review
  $neural.debug           Root-cause investigation for bugs and failures
  $neural.sync            Sync specs with post-implementation code
  $neural.status          Show progress of all features in .neural/wip/
  $neural.help            Show this command reference

Typical flow: interview → plan → execute → review → archive
```

Print only the selected reference output. Do not include the detection rules or extra explanation.
