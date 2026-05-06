# Neural SDD — Project Rules

## What is this
A Spec-Driven Development plugin for Claude Code and Codex. Skills live in `skills/`.

## When adding or removing skills
1. Create/delete the skill directory in `skills/`
2. Update `README.md` — add/remove the skill section
3. Propose a version bump in `plugin.json`, `marketplace.json`, and `package.json`

## Conventions
- Skills contain all logic in `SKILL.md` — one file per skill
- Skill instructions in English, concise, imperative
- Skills are prefixed with `neural.` to avoid generic names such as `review` or `plan`
- Claude Code invokes skills as `/neural.<name>`
- Codex invokes skills with `$neural.<name>` or implicit matching
- Descriptions follow pattern: `"[Neural SDD] <what it does>. Part of the neural plugin — invoke via /neural.<name>"`
- Commits: conventional commits in English
- PRs: squash & merge, delete branch after
