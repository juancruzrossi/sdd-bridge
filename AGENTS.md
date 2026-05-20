# Neural SDD — Project Rules

## What is this
A Spec-Driven Development plugin for Claude Code. Codex installs the same root skills globally via `.codex/install.sh`. Skills live in `skills/`.

## When adding or removing skills
1. Create/delete the skill directory in `skills/`
2. Update `README.md` — add/remove the skill section
3. Propose a version bump in `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`

## Conventions
- Skill logic lives in `SKILL.md` — one per skill. Auxiliary reference files (e.g., format templates) may sit alongside `SKILL.md` and be linked from it, so they load on-demand and keep `SKILL.md` light at trigger time.
- Skill instructions in English, concise, imperative
- Skill folders use bare names (`interview`, `plan`, etc.) — plugin namespace is enforced by Claude Code
- Claude Code invokes skills as `/neural:<name>`
- Codex invokes skills with `$neural.<name>` or implicit matching
- Descriptions: just `"<what it does>"` — no boilerplate prefixes or suffixes
- All skills set `disable-model-invocation: true` — explicit invocation only
- Commits: conventional commits in English
- PRs: squash & merge, delete branch after
