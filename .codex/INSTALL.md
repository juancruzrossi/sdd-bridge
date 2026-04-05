# Installing Neural for Codex

Install Neural in Codex as native skills.

For Codex, this repository should install as `skills` only:

- Neural does NOT install through `prompts/`
- Neural does NOT install through the repository `commands/` folder
- Neural does NOT rely on `~/.codex/commands/` for this Codex setup

The `commands/` directory in this repository exists for Claude Code plugin shims. Codex should ignore it.

## Why this install path

Codex officially documents skills as the reusable workflow format and `.agents/skills` as the discovery location for user- and repo-level skills.

For Codex CLI, the official slash-command documentation covers built-in slash commands such as `/model`, `/review`, `/status`, and `/init`. This Neural install does not add custom Codex slash commands.

That means the correct Codex install for this repository is:

1. clone the repo somewhere stable
2. expose `skills/` through `.agents/skills`
3. let Codex discover those skills

## What gets installed

1. Clone this repository to a stable local path
2. Expose only `skills/` to Codex
3. Restart Codex so it can discover the skills

Neural workflow artifacts still live in `.neural/` inside each project. That is separate from the framework install.

## Prerequisites

- Git
- Codex CLI already installed

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/juancruzrossi/neural.git ~/.codex/neural
   ```

2. Expose the Neural skills to Codex:
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/neural/skills ~/.agents/skills/neural
   ```

   If `~/.agents/skills/neural` already exists, remove it first and create the symlink again.

3. Restart Codex.

## Windows

Use a junction instead of a symlink:

```powershell
git clone https://github.com/juancruzrossi/neural.git "$env:USERPROFILE\.codex\neural"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\neural" "$env:USERPROFILE\.codex\neural\skills"
```

Then restart Codex.

## Verify

Run:

```bash
ls -la ~/.agents/skills/neural
find ~/.agents/skills/neural -maxdepth 2 -name SKILL.md | sort
```

You should see:

- `~/.agents/skills/neural` pointing to `~/.codex/neural/skills`
- the Neural skills available under that path

## How Codex should use Neural

After installation, Codex should use the skills from `skills/`.

This install does **not** create custom Codex slash commands.
This install does **not** use a prompts folder.
This install does **not** copy the repository `commands/` directory.

If you want to trigger Neural explicitly, reference the skill by name in your request, for example:

- `Use neural-interview for this feature`
- `Use neural-plan for the active Neural feature`
- `Use neural-review before we close this task`

## Available Skills

| Skill | Purpose |
|------|---------|
| `using-neural` | Session-level guidance, task suggestion, and resume help |
| `neural-interview` | Clarify requirements and write `BRIEF.md` |
| `neural-plan` | Explore the codebase and write `PLAN.md` |
| `neural-execute` | Execute the plan in dependency waves |
| `neural-review` | Verify implementation against brief and plan |
| `neural-address-review` | Fix issues found during review |
| `neural-quick` | Small-task fast path without `.neural/` artifacts |
| `neural-debug` | Root-cause debugging workflow |
| `neural-status` | Show active feature progress |
| `neural-archive` | Move completed work from `wip/` to `archive/` |

## Artifact Location

Neural stores workflow artifacts in `.neural/` at the project root:

```text
.neural/
├── wip/<feature-name>/
│   ├── BRIEF.md
│   ├── PLAN.md
│   └── REVIEW.md
└── archive/<feature-name>/
    ├── BRIEF.md
    ├── PLAN.md
    └── REVIEW.md
```

## Update

```bash
cd ~/.codex/neural && git pull
```

The symlink continues to point to the updated skills.

## Uninstall

```bash
rm ~/.agents/skills/neural
rm -rf ~/.codex/neural
```

## Troubleshooting

### Neural skills do not appear

1. Check the symlink:
   ```bash
   ls -la ~/.agents/skills/neural
   ```
2. Check that the repo was cloned correctly:
   ```bash
   ls ~/.codex/neural/skills
   ```
3. Restart Codex.

### Neural was installed into commands or prompts

That install is wrong for this repository.

Remove any misplaced Neural files from:

- `~/.codex/commands/`
- any `prompts/` directory you created for Neural

Then reinstall using the skills-only steps above.
