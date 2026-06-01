# documenting-repos-for-agents

A Claude Code skill for setting up — and keeping current — a persistent markdown
**doc substrate** in a repo, so a fresh agent with zero context can orient and
start working *without re-scanning the whole tree*, and so work state survives
across sessions.

It's the **creation counterpart** to the
[`creating-handoffs`](https://github.com/scottTomaszewski/handoffs) skill:
that one routes *session state* through a repo's living docs; this one *creates*
those living docs in the first place. The two share one taxonomy and meet at the
same paths.

## What it does

Capable agents already write *reasonable* docs unprompted. The problem is they
write **bespoke, unverified** ones — every agent invents different file names and
collapses everything into one log that rots. This skill makes the output
**canonical, lifespan-routed, and verified** instead.

It imposes one predictable file taxonomy, routed by how long each fact lives:

| File | Holds | Lifespan |
|------|-------|----------|
| `CLAUDE.md` (root) | small router: what this is, key commands, where things live, conventions, pointers | stable |
| `ARCHITECTURE.md` | the "don't re-scan" quickstart: mental model, core data flows, module map | semi-stable |
| `docs/*.md` | deep references + **funky logic / gotchas**, one topic per file | per-subsystem |
| `FOLLOWUPS.md` (root) | small deferred findings — the lightweight queue | churns |
| `ROADMAP.md` (root) | larger planned / in-flight efforts | churns |
| `docs/handoffs/HANDOFF.md` | ephemeral "you are here" session state — owned by `creating-handoffs` | per-session |

Key ideas:

- **Canonical names, every repo.** Predictability is the point — the next agent
  (and the `creating-handoffs` skill) always knows where to look.
- **A deliberate funky-logic sweep.** Workarounds, magic numbers, and non-obvious
  decisions get a definite home (a precise inline comment, or a `docs/` entry) —
  instead of being captured only by luck.
- **Anti-rot maintenance.** A "when you change X, update Y" sync agreement written
  into `CLAUDE.md`, plus a re-runnable drift check. Docs only save tokens if
  they're trusted.
- **Cold-start verification.** Before declaring the docs done, a reader (subagent,
  or a manual fresh pass) sees *only* the docs and tries to onboard — whatever it
  gets wrong is a gap. You have the context; you can't see your own blind spots.

See `SKILL.md` for the full skill and `DESIGN.md` for the rationale and the
RED→GREEN→REFACTOR record it was built with.

## Contents

| File | Role | Installs to |
|------|------|-------------|
| `SKILL.md` | The skill | `~/.claude/skills/documenting-repos-for-agents/SKILL.md` |
| `DESIGN.md` | Design rationale + test record (not installed) | — |
| `install.sh` | Symlinks the skill into `~/.claude` | — |

There's no command file: Claude Code auto-generates a
`/documenting-repos-for-agents` slash command from the skill.

## Install

Clone the repo wherever you like, then symlink the skill into `~/.claude`.
Symlinks mean a `git pull` updates your installed copy instantly.

### Quick way (recommended)

```bash
git clone <repo-url> documenting-repos-for-agents
cd documenting-repos-for-agents
./install.sh
```

`install.sh` is idempotent, creates the needed directories, backs up any existing
non-symlink file, and links from this clone — so it works no matter where you
cloned it.

### Manual way

```bash
REPO="$(pwd)"   # run from inside the clone
mkdir -p ~/.claude/skills/documenting-repos-for-agents
ln -sfn "$REPO/SKILL.md" ~/.claude/skills/documenting-repos-for-agents/SKILL.md
```

Start a new Claude Code session afterward so the skill is picked up.

## Usage

- `/documenting-repos-for-agents` — set up (or refresh) the doc substrate in the
  current repo.
- The skill also triggers automatically when a repo lacks docs, when a fresh agent
  has to re-scan the tree to get oriented, or when onboarding/architecture/gotchas
  live only in code.

## Updating

```bash
cd documenting-repos-for-agents && git pull
```

The symlink points at the clone, so the new version is live in your next session —
no reinstall needed.

## Uninstall

```bash
rm -r ~/.claude/skills/documenting-repos-for-agents
```
