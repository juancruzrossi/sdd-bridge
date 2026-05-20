# CONTEXT.md Format

Path: `.neural/wip/<feature>/CONTEXT.md`. Write only sections that earn their place. Skip empty ones.

## Template

```md
# <Feature>

**Git:** yes|no
**Branch:** <branch>
**Parent context:** <name>  <!-- only when CONTEXT-MAP.md exists -->

## Problem
<1-2 sentences: what this feature is and why it exists.>

## Language

**<Term>**:
<one-sentence definition — what it IS, not what it does>
_Avoid_: <aliases>

## Relationships
- A **Term** belongs to exactly one **Other Term**

## Decisions
- <specific choice>

## Constraints
- <limit>

## Scenarios
- <flow or edge case>

## Non-goals
- <excluded>

## Decision Boundaries
- Agent may decide: <low-risk choices>
- Ask user before: <high-risk choices>

## Acceptance Criteria
- [ ] <testable outcome>

## Flagged Ambiguities
- "<term>" was used to mean both **A** and **B** — resolved: <which one wins, or kept distinct>

## Example Dialogue
> **Dev:** <question using bold domain terms>
> **Expert:** <answer that clarifies boundaries>

## Open Items
- <unresolved>
```

## Rules

- `Language` is a glossary, not a scratch pad. No implementation details, no decisions, no acceptance criteria — those have their own sections.
- Only domain-meaningful terms in `Language`. Skip generic programming concepts (timeouts, error types, utility patterns) even if the feature uses them.
- One sentence per definition — what it IS, not what it does.
- Be opinionated: when multiple words exist for the same concept, pick one and list the rest under `_Avoid_`.
- Express cardinality in `Relationships` when obvious.
- Flag genuine ambiguities explicitly under `Flagged Ambiguities` with a clear resolution.

## Multi-context repos

If `CONTEXT-MAP.md` exists at the repo root, the repo has multiple bounded contexts. Each feature `CONTEXT.md` declares its `**Parent context:**`. If unclear which context the feature belongs to, ask before writing.
