#!/usr/bin/env bash
#
# Install the documenting-repos-for-agents skill into ~/.claude by symlinking
# from this clone. Idempotent; backs up any existing real file.
#
set -euo pipefail

# Resolve the directory this script lives in (the repo clone), following symlinks.
SOURCE="${BASH_SOURCE[0]}"
while [ -L "$SOURCE" ]; do
  DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
  SOURCE="$(readlink "$SOURCE")"
  [[ "$SOURCE" != /* ]] && SOURCE="$DIR/$SOURCE"
done
REPO="$(cd -P "$(dirname "$SOURCE")" && pwd)"

CLAUDE="${CLAUDE_HOME:-$HOME/.claude}"

link() {
  local src="$1" dest="$2"
  if [ ! -e "$src" ]; then
    echo "error: source not found: $src" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$dest")"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "backed up existing $dest -> $backup"
  fi
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}

# Skill: <repo>/SKILL.md -> ~/.claude/skills/documenting-repos-for-agents/SKILL.md
link "$REPO/SKILL.md" "$CLAUDE/skills/documenting-repos-for-agents/SKILL.md"

echo
echo "Done. Start a new Claude Code session to pick up the"
echo "'documenting-repos-for-agents' skill. Claude auto-generates a matching"
echo "/documenting-repos-for-agents slash command from it."
