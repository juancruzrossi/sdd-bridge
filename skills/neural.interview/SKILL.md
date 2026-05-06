---
name: neural.interview
description: "[Neural SDD] Socratic interview with gray-area detection and selective pressure to clarify requirements before planning. Use when starting a new feature, building something complex, or when requirements are ambiguous. Part of the neural plugin — invoke via /neural.interview"
keep-coding-instructions: true
---

# Neural Interview

Turn vague ideas into execution-ready briefs through structured Socratic interrogation. This skill identifies what's ambiguous, resolves it through targeted questions, and locks decisions into a BRIEF.md that feeds directly into `/neural.plan`.

## Why This Exists

Most implementation failures trace back to unclear requirements, not bad code. Developers skip straight to planning with unresolved ambiguities — hidden assumptions, unclear scope boundaries, missing edge cases. This interview forces those ambiguities to the surface before a single line of planning happens.

## Language

Respond in the same language as the user.

## Procedure

### Phase 1: Setup

1. **Check git status.** Run `git rev-parse --is-inside-work-tree 2>/dev/null` silently.
   - If the project IS a git repo: proceed silently (no message to user).
   - If the project is NOT a git repo: ask the user: "This project doesn't have git initialized. Want me to run `git init`? (If not, we'll work without version control — no commits during execute.)"
     - If user says yes: run `git init` and proceed.
     - If user says no: proceed without git. Set a mental flag: **NO_GIT=true** — skip all git/commit operations in subsequent phases.

2. **Ask for the feature name.** This becomes the directory slug. Ask: "What should we call this feature? (This becomes the folder name in `.neural/wip/<name>/`)"
   - Accept kebab-case, spaces, or camelCase — normalize to kebab-case internally
   - Example: "user authentication" → `user-authentication`

3. **Create the working directory.** Run: `mkdir -p .neural/wip/<feature-name>/`

4. **Capture the initial description.** Ask the user to describe what they want in their own words. Do not interrupt — let them dump everything first.

### Phase 2: Gray Area Identification (internal)

After the user describes their idea, analyze it silently. Identify **gray areas** — points where the description is ambiguous, underspecified, or could be interpreted multiple ways.

Categorize each gray area into one of these dimensions:

| Dimension | What's unclear |
|-----------|---------------|
| **Problem** | Why this needs to exist, what pain it solves |
| **Scope** | How far the change should go, what's included vs excluded |
| **Constraints** | Technical limits, business rules, dependencies |
| **Edge Cases** | Unusual inputs, error states, boundary conditions |
| **Non-goals** | What this explicitly should NOT do |

List the gray areas internally (do not show the user the full list). Prioritize by **risk** — which ambiguity, if left unresolved, would cause the most rework later?

Prioritize gray areas in this order: first resolve **Problem** and **Scope** (why this exists and how far it goes), then **Constraints** and **Edge Cases** (limits and unusual scenarios), then **Non-goals** (what's excluded). Understanding intent and boundaries before diving into technical details produces sharper interviews.

### Phase 3: Socratic Interview Loop

Work through gray areas one question at a time, highest risk first.

**Rules:**
- Ask exactly ONE question per message. Never batch questions.
- After the user answers, evaluate whether the gray area is resolved.
- If resolved, move to the next gray area.
- If partially resolved, ask a follow-up on the same gray area.
- New gray areas may emerge from answers — add them to the queue.

**Selective Pressure** — After an answer, apply pressure ONLY when the answer is vague, risky, or based on unstated assumptions.

When an answer is vague or risky, escalate through pressure levels in sequence — start with Evidence, then Assumption, then Boundary, then Essence. Stop as soon as the answer becomes clear. Most answers only need one level; reserve Essence for persistent vagueness.

| Pressure | When to apply | Example |
|----------|--------------|---------|
| **Evidence** | User makes a claim without backing | "Can you give a concrete example of when this would happen?" |
| **Assumption** | Answer relies on something unstated | "What assumption is that based on? What if it's wrong?" |
| **Boundary** | Scope is expanding or unclear | "Where exactly does this stop? What would you explicitly NOT include?" |
| **Essence** | User describes symptoms, not root cause | "Is that the actual problem, or a symptom of something deeper?" |

Do NOT apply pressure on every answer. If the answer is clear and specific, accept it and move on. Pressure is a tool for risk, not a ritual.

**Challenge Modes** — Activate these when specific patterns emerge:

- **Contrarian**: When the user states something as obvious without evidence. Challenge the core assumption. "What if the opposite were true? What would break?"
- **Simplifier**: When scope keeps expanding. Push for minimal viable version. "What's the absolute simplest version that still solves the problem? What can we cut?"
- **Reframer**: When the user keeps describing symptoms instead of root problems. Redirect to the underlying need. "You're describing what happens — what's the actual problem that causes this?"

**Scope Guardrail** — If the user introduces a capability that's clearly a separate feature:
> "That sounds like its own feature, not part of `<current-feature>`. Want me to note it for later? For now, let's stay focused on `<current-scope>`."

Capture deferred ideas in the Non-goals/Out-of-scope section of the BRIEF.

**Acceptance Criteria Elicitation** — Before closing gray areas, ask "How will we know this is done?" at least once during the interview to derive concrete, testable acceptance criteria for the BRIEF.

**Reframe Vague Requirements** — When the user states a requirement that's subjective or unmeasurable, reframe it into concrete, testable criteria before accepting it. Example:
> User: "It should be fast"
> You: "Let's make that specific. Do you mean: page loads under 2s? API response under 500ms? Something else?"

Do this inline during the interview — don't wait until the readiness check. Vague acceptance criteria are the #1 source of "done but not done" during review.

### Phase 4: Readiness Check

Before closing the interview, verify the **minimum checklist**:

```
□ Problem statement — clear WHY this needs to exist
□ Scope — explicit boundaries of what's included
□ Constraints — technical/business limits identified
□ Edge cases — at least 2-3 non-obvious scenarios addressed
□ Non-goals — explicit list of what this does NOT do
□ Decision boundaries — clear what the agent can decide vs what needs user approval
```

If any item is uncovered, ask targeted questions to fill the gap. If the user says "that's enough" or "let's move on" before the checklist is complete, respect it — warn them which items are uncovered but proceed.

Example:
> "We haven't explicitly discussed edge cases yet. I'd like to cover at least a couple — but if you'd rather move on, I can note it as an open item in the brief."

### Phase 4b: Assume-Out-Loud

Before generating the BRIEF, surface your assumptions explicitly. Present them to the user:

> **Assumptions I'm making based on our conversation:**
> 1. <assumption about technology, architecture, or approach>
> 2. <assumption about user behavior or data>
> 3. <assumption about scope or integration>
> → Correct me now or I'll bake these into the brief.

Only list assumptions that weren't explicitly stated by the user — things you inferred, defaulted to, or filled in mentally. If the user corrects any assumption, update the relevant decisions before generating the BRIEF.

This step is cheap and prevents the most expensive type of rework: building on wrong premises.

### Phase 5: Generate BRIEF.md

**Git context.** Add git metadata at the top of BRIEF.md:
- If NO_GIT was set: `**Git:** no — skip all commit/branch operations in subsequent phases`
- If git is initialized: `**Git:** yes` (the Branch line will be added in Phase 6)

Write `.neural/wip/<feature-name>/BRIEF.md` with this structure:

```markdown
# <Feature Name>

## Problem
<Why this needs to exist. What pain it solves. 2-3 sentences max.>

## Decisions
<Bulleted list of every decision locked during the interview. Each one specific and actionable.>

- Decision: <what was decided>
- Decision: <what was decided>

## Constraints
<Technical limits, business rules, dependencies, performance requirements.>

## Edge Cases
<Non-obvious scenarios that must be handled.>

## Non-goals
<What this feature explicitly does NOT do.>

## Decision Boundaries
<What the agent can decide on its own without asking. What requires explicit user approval.>

## Out-of-scope
<Ideas that came up but belong to separate features.>

## Acceptance Criteria
<Concrete, testable statements that prove this feature works. At least 3.>

## Open Items
<Anything the user chose to skip or defer. Empty if everything was covered.>
```

Guidelines for the BRIEF:
- Decisions must be **specific and actionable**, not vague. Bad: "Use a good auth system". Good: "Use JWT with 24h expiry, refresh tokens stored in httpOnly cookies"
- Each section should be concise — this is a brief, not a spec
- If the user forced early close, list uncovered checklist items under Open Items

### Phase 6: Branch Setup (git repos only)

Skip this phase entirely if NO_GIT=true.

1. Run `git branch --show-current` to get the current branch.
2. **Stable branches:** `main`, `master`, `develop`, `stage`, `staging`, `production`, `release`.
3. If the current branch IS a stable branch, ask the user:
   > "You're on `<branch>`. Want to create a new branch for this work? Pick a type:"
   > - `feature/<slug>` — new functionality
   > - `enhancement/<slug>` — improve existing functionality
   > - `fix/<slug>` — bug fix
   > - `hotfix/<slug>` — urgent production fix
   > - Skip — stay on `<branch>`
   - If the user picks a type: run `git checkout -b <type>/<feature-slug>` and confirm.
   - If the user picks "skip" or declines: proceed on the current branch.
4. If the current branch is NOT a stable branch (e.g., already on `feature/something`): proceed silently — the user already branched.
5. Record the final branch name in BRIEF.md by appending `**Branch:** <branch-name>` below the `**Git:** yes` line.

### Phase 7: Handoff

After writing the BRIEF.md, present a summary:

> **Interview complete for `<feature-name>`**
>
> Brief saved to `.neural/wip/<feature-name>/BRIEF.md`
>
> Decisions locked: <count>
> Open items: <count or "none">
>
> Ready to plan? Run `/neural.plan`

If there are open items, also mention:
> "Note: <N> items were deferred. `/neural.plan` will work with what we have, but you may want to revisit these during planning."
