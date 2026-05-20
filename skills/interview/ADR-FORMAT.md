# ADR Format

Path: `.neural/wip/<feature>/docs/adr/NNNN-slug.md`.

Numbering: scan existing `docs/adr/` (root and feature), take the highest number, increment.

## Template

```md
# <Decision>

<1-3 sentences: context, decision, why.>
```

A single paragraph is often enough. The value is recording *that* a decision was made and *why* — not filling sections.

## Optional sections

Add only when they earn their place:

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`) — when decisions get revisited.
- **Considered Options** — when rejected alternatives are worth remembering.
- **Consequences** — when non-obvious downstream effects need calling out.

## When to write one

All three must hold:

1. **Hard to reverse** — changing your mind later costs real effort.
2. **Surprising without context** — a future reader will wonder "why?"
3. **The result of a real trade-off** — genuine alternatives existed.

Skip otherwise.

## What qualifies

- **Architectural shape** — monorepo vs polyrepo, event-sourced write model, projection-based reads.
- **Integration patterns** — events vs sync HTTP, shared DB vs API, queue topology.
- **Technology choices with lock-in** — database, message bus, auth provider, deployment target. Not every library — only ones that would take weeks to swap.
- **Boundary and scope decisions** — which context owns which data; the explicit "no"s are as valuable as the "yes"s.
- **Deliberate deviations from the obvious path** — manual SQL instead of an ORM, custom auth instead of a provider. Stops the next engineer from "fixing" something deliberate.
- **Constraints invisible in code** — compliance limits, partner SLAs, hardware ceilings.
- **Rejected alternatives with non-obvious reasoning** — otherwise someone will re-propose them in six months.
