# Design notes — `documenting-repos-for-agents` skill

Captured during the skill's creation. This is the rationale behind what `SKILL.md`
teaches, plus the RED→GREEN→REFACTOR record it was built with. Kept for future
edits to the skill; not loaded at runtime.

## Problem

A fresh agent dropped into a repo re-derives the same things every time:
architecture, build commands, conventions, and the non-obvious "funky logic." That
burns context and tokens, and the knowledge evaporates when the session ends. The
goal is a persistent doc substrate that lets the next agent onboard cheaply and
that tracks work across sessions.

The catch (see RED below): **capable agents already write reasonable docs
unprompted.** So a skill that just says "write docs" adds nothing. The value is in
what unguided agents get *wrong*.

## Relationship to `creating-handoffs`

This skill is the **creation** side; `creating-handoffs` is the **session-state**
side. They deliberately share one taxonomy and meet at the same paths:

- This skill *provisions* `CLAUDE.md` / `ARCHITECTURE.md` / `docs/` / `FOLLOWUPS.md`
  / `ROADMAP.md` and the `docs/handoffs/` location.
- `creating-handoffs` *flows* ephemeral session state through
  `docs/handoffs/HANDOFF.md` and routes durable knowledge into the living docs this
  skill created.

Vocabulary reconciliation with the handoff skill: planned/deferred work is split —
`FOLLOWUPS.md` = small deferred findings (lightweight queue), `ROADMAP.md` = larger
planned / in-flight efforts.

## The taxonomy (routed by lifespan)

| File | Holds | Lifespan | Owner |
|------|-------|----------|-------|
| `CLAUDE.md` | router + conventions + pointers; loaded every session, kept small | stable | this |
| `ARCHITECTURE.md` | mental model, 1–2 core data flows, module map | semi-stable | this |
| `docs/*.md` | deep refs + funky logic / gotchas, one topic per file | per-subsystem | this |
| `FOLLOWUPS.md` | small deferred findings | churns | this |
| `ROADMAP.md` | larger planned / in-flight efforts | churns | this |
| plan/spec docs + `## Status` | per-effort progress, dead ends | per-effort | writing-plans |
| `docs/handoffs/HANDOFF.md` | ephemeral session router + verification commands | per-session | creating-handoffs |

## The scan procedure (the technique core)

1. Entry points & metadata (`package.json`/`main`, manifest, `Cargo.toml`, `go.mod`).
2. Build/test/release config → becomes `CLAUDE.md` commands.
3. Directory map by responsibility → becomes the `ARCHITECTURE.md` module map.
4. Trace 1–2 core data flows end to end → heart of `ARCHITECTURE.md`.
5. **Funky-logic sweep** — deliberately hunt workarounds/magic-numbers/"why"
   comments; give each a home (inline comment or `docs/` entry). This is where
   unguided agents under-deliver.
6. Link (don't restate) existing README / CHANGELOG.
7. Verify before writing — only document what's true now.

## Maintenance (anti-rot)

Setup is the easy half; *trust* is the hard half. The skill teaches: a concrete
"when you change X, update Y" sync agreement written into `CLAUDE.md`, routing new
knowledge by the taxonomy as you work (not into one catch-all log), and re-running
the cold-start test as a drift detector. CLAUDE.md-specific audits defer to the
`claude-md-management` skills.

## Cold-start verification

You wrote the docs with full context, so you can't see their gaps. A reader sees
*only* the docs (no source) and tries to restate what the project is, where to
start, and the top gotchas. Whatever it gets wrong is a gap. A subagent does this
best; in single-agent environments, a manual fresh-read pass plus independent
claim-verification against source is the sanctioned fallback.

## How it was built — RED → GREEN → REFACTOR

Built with the `writing-skills` TDD method.

### RED — baseline (no skill)

A cold agent was asked to set up onboarding docs for a real repo (an Obsidian
plugin). It produced *good* docs — root `CLAUDE.md` router, `docs/` split by
question type, an architecture doc, cross-referencing rather than duplicating. But
six gaps showed up:

1. **Bespoke taxonomy** — invented `docs/work-log.md`; never provisioned the
   `docs/handoffs/` location `creating-handoffs` expects.
2. **Collapsed lifespans** — one file mixed session-state + deferred + history.
3. **No session-state router** / verification commands.
4. **No anti-rot loop** — "keep current" with no concrete sync triggers.
5. **No cold-start verification** — verified its claims, never tested onboarding.
6. **Funky logic captured only by luck** — it *missed* a real API workaround
   (requesting `1-999` to dodge a single-chapter-book server bug).

These six gaps defined exactly what the skill needed to teach — and nothing more
(unguided agents already do the rest).

### GREEN — with the skill

A cold agent given the skill, on the same repo, hit every target signal: canonical
names (even `git mv`-ing a near-miss `FOLLOWUP.md` → `FOLLOWUPS.md`), correct
lifespan routing, a funky-logic sweep that **caught the `1-999` workaround** plus
four more gotchas (each given a home), and it ran a cold-start test that found and
fixed a real gap (no-tests verification gate).

### REFACTOR — loopholes closed

Three gaps the GREEN test surfaced, folded back into the skill:

1. **Cold-start step assumed a subagent-dispatch tool exists** — impossible in some
   harnesses. Added a sanctioned single-agent manual fallback.
2. **No guidance for a near-miss existing file** — added: `git mv` it to the
   canonical name and fold content in; never leave two competing files.
3. **`docs/handoffs/` placeholder filename unspecified** — clarified: a one-line
   `docs/handoffs/README.md` placeholder, not a stub `HANDOFF.md`.

## Later edits

### Numbered `## N.` sections for FOLLOWUPS / ROADMAP

Original seed tracked follow-ups as `- [ ]` checkbox bullets and gave ROADMAP no item
format. Two problems: bullets can't be cited ("the third one" drifts), and a list item
is a poor home for the code blocks / commands these entries often need. Switched both
files to numbered `## N.` header sections:

- The heading number is a referenceable handle ("follow-up 3", "roadmap item 2").
- A section body holds code blocks, commands, and detail that don't fit in a list.
- Finished items are marked with a `**Status:** done` line rather than deleted.
- Numbers are sequential-on-add, **not** permanently stable — completed items get
  pruned and the rest renumbered on a periodic cleanup pass, not per-edit. (Stable
  never-reused IDs were considered and rejected: the owner prefers periodic renumber
  over carrying gaps and tracking a next-id.)

## Possible future work

- Language-agnostic variation test (baseline/GREEN were both a TS Obsidian plugin;
  a bash/other-language repo would confirm the scan procedure generalizes).
- Trim for length if the skill proves heavier than it needs to be.
