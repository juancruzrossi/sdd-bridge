# Neural SDD — Project Rules

## What is this
A Spec-Driven Development plugin for Claude Code. Commands live in `commands/`, skills in `skills/`.

## When adding or removing commands/skills
1. Create/delete the command file in `commands/` and skill directory in `skills/`
2. Update `commands/help.md` — keep the reference table current
3. Update `skills/using-neural/SKILL.md` — command table and workflow diagram
4. Update `README.md` — add/remove the command section
5. Propose a version bump in `plugin.json`, `marketplace.json`, and `package.json`

## Conventions
- Commands are thin wrappers that load a skill via `Skill("neural-<name>")`
- Skills contain all logic in `SKILL.md` — one file per skill
- Skill instructions in English, concise, imperative
- Descriptions follow pattern: `"[Neural SDD] <what it does>. Part of the neural plugin — invoke via /neural:<name>"`
- Commits: conventional commits in English
- PRs: squash & merge, delete branch after
