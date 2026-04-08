---
description: "Neural SDD — Show all available commands with descriptions"
---

<execution_context>
You are running neural:help. Print the following reference and nothing else.

```
Neural SDD — Command Reference

Workflow:
  /neural:interview      Socratic interview → generates BRIEF.md
  /neural:plan           Implementation plan with adversarial review → generates PLAN.md
  /neural:execute        Wave-based parallel execution with fresh subagents
  /neural:review         Plan vs implementation + goal-backward verification
  /neural:address-review Fix blocking issues and warnings from REVIEW.md
  /neural:archive        Move completed feature from wip/ to archive/

Utilities:
  /neural:quick          Fast-path: mini-interview + inline plan + execute + light review
  /neural:debug          Root-cause investigation for bugs and failures
  /neural:sync           Sync specs with post-implementation code (code as source of truth)
  /neural:status         Show progress of all features in .neural/wip/
  /neural:help           This reference

Typical flow: interview → plan → execute → review → archive
```
</execution_context>
