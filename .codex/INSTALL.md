# Installing Neural for Codex

Neural has two components: **commands** (what the user invokes) and **skills** (the logic behind each command).

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/juancruzrossi/neural.git ~/.codex/neural
   ```

2. Install skills:
   ```bash
   mkdir -p ~/.agents/skills
   ln -s ~/.codex/neural/skills ~/.agents/skills/neural
   ```

3. Install commands — for each `.md` file in `~/.codex/neural/commands/`, create a corresponding file in `~/.codex/commands/` named `neural-<command>.md`. Adapt the content: replace `Skill("neural-<name>")` with `Read the skill file at ~/.agents/skills/neural/neural-<name>/SKILL.md and follow its instructions exactly.` Keep the description and $ARGUMENTS as-is.

### Windows

```powershell
git clone https://github.com/juancruzrossi/neural.git "$env:USERPROFILE\.codex\neural"
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.agents\skills"
cmd /c mklink /J "$env:USERPROFILE\.agents\skills\neural" "$env:USERPROFILE\.codex\neural\skills"
```

Then follow step 3 above, placing adapted commands in `$env:USERPROFILE\.codex\commands\`.

## Verify

```bash
ls ~/.agents/skills/neural/*/SKILL.md
ls ~/.codex/commands/neural-*.md
```

You should see 10 skills and 9 commands.

## Update

```bash
cd ~/.codex/neural && git pull
```

After pulling, re-run step 3 if new commands were added.

## Uninstall

```bash
rm -f ~/.codex/commands/neural-*.md
rm -f ~/.agents/skills/neural
rm -rf ~/.codex/neural
```
