#!/usr/bin/env bash
set -euo pipefail

repo="juancruzrossi/neural"
ref="${NEURAL_REF:-main}"
codex_home="${CODEX_HOME:-$HOME/.codex}"
target="$codex_home/skills"

tmp="$(mktemp -d)"
cleanup() {
  rm -rf "$tmp"
}
trap cleanup EXIT

mkdir -p "$target"

archive_url="https://codeload.github.com/$repo/tar.gz/$ref"
curl -fsSL "$archive_url" | tar -xz -C "$tmp"

root="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
src="$root/skills"

if [ ! -d "$src" ]; then
  printf 'error: skills directory not found in %s@%s\n' "$repo" "$ref" >&2
  exit 1
fi

count=0
for skill in "$src"/*; do
  [ -d "$skill" ] || continue
  [ -f "$skill/SKILL.md" ] || continue

  name="neural.$(basename "$skill")"
  rm -rf "$target/$name"
  cp -R "$skill" "$target/$name"
  count=$((count + 1))
done

printf 'Installed %s Neural skill(s) into %s\n' "$count" "$target"
printf 'Restart Codex, then use skills like $neural.interview or $neural.plan.\n'
