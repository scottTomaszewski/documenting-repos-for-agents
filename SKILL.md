---
name: documenting-repos-for-agents
description: Use when a repo lacks a persistent doc substrate for agents, when a fresh agent has to re-scan the whole tree to get oriented, when onboarding/architecture/gotchas live only in code or someone's head, or when setting up or refreshing CLAUDE.md / ARCHITECTURE.md / docs so future agents start cheaply. Covers both initial setup and ongoing upkeep.
---

# Documenting Repos for Agents

## Overview

A repo's doc substrate exists so a **future agent with zero context** can orient
and start working without re-scanning the tree — and so work state survives across
sessions. Docs only deliver that if they are **canonical** (predictable names/
locations), **lifespan-routed** (each fact in exactly one place), and **trusted**
(verified true, kept in sync). Stale or bespoke docs are worse than none.

**Core principle:** route every fact by how long it lives, into a canonical file
the next agent already knows to open. This is the *creation* side of
**creating-handoffs**, which is the *session-state* side — they share one taxonomy.

## When to Use

- Setting up docs in a repo that has none (or only a README).
- A new agent burned context re-deriving architecture/conventions/gotchas.
- "Funky logic" (workarounds, magic numbers, non-obvious decisions) lives only in code.
- Refreshing docs that have drifted from the code.

Capable agents already write *reasonable* docs unprompted. This skill exists to make
them **canonical, lifespan-routed, and verified** instead of bespoke and unchecked.

## The canonical taxonomy (do not invent your own)

Every repo gets the same predictable set. Same names every time — that predictability
is the whole point. Create only what the repo warrants, but keep the names —
**except `FOLLOWUPS.md`, which is always created (see below).** **If a
near-miss file already exists** (e.g. `FOLLOWUP.md` where the canonical name is
`FOLLOWUPS.md`, or `NOTES.md` doing a `docs/` job), `git mv` it to the canonical
name and fold its content in — never leave two competing files for the same role.

| File | Holds | Lifespan | Owner skill |
|------|-------|----------|-------------|
| `CLAUDE.md` (root) | small router: what this is, key commands, where things live, conventions, **pointers to everything below**. Loaded every session — keep it tight. | stable | this |
| `ARCHITECTURE.md` | the "don't re-scan" quickstart: mental model, 1–2 core data flows end-to-end, module map (one line each) | semi-stable | this |
| `docs/*.md` | deep references + **funky logic / gotchas**, one topic per file, with a `docs/index.md` | per-subsystem | this |
| `FOLLOWUPS.md` (root) | in-scope tangents found mid-task — important to fix but would derail the task at hand; resolved before starting the next feature. **Always created (even empty), with an instructional header.** | churns | this |
| `ROADMAP.md` (root) | new features and larger planned / in-flight efforts | churns | this |
| `CHANGELOG.md` (root) | shipped release history: `# <Project> Releases` h1, one `## <tag>` per release (header text **exactly** the tag), bullet list of changes; new items land under a temp `## Unreleased` | append-per-release | this |
| plan/spec docs + their `## Status` | per-effort progress, what's half-done, dead ends | per-effort | writing-plans |
| `docs/handoffs/HANDOFF.md` | ephemeral "you are here" session router + verification commands | per-session | creating-handoffs |

**Provision the `docs/handoffs/` location with a one-line `docs/handoffs/README.md`
placeholder** (not a stub `HANDOFF.md` — that's session state) **and link it from
`CLAUDE.md`. Don't write session state here** — that's `creating-handoffs`' job. The
point is that the two skills meet at the same paths.

**Always create `FOLLOWUPS.md`, even with zero items** — provision it with an
instructional header so the next agent knows what belongs there and adds entries
in the right place. `FOLLOWUPS.md` and `ROADMAP.md` are **not** interchangeable and
serve different lifespans: follow-ups are small tangents off the *current* task that
must be cleared before starting a new feature; the roadmap is for *new features and
larger efforts*. Never fold one into the other, and never redirect deferred findings
to `ROADMAP.md` on the grounds that it "already covers deferred work." If a singular
`FOLLOWUP.md` exists, `git mv` it to `FOLLOWUPS.md` and fold its content in. Seed the
file with:

```markdown
# Follow-ups

In-scope tangents found while working — important to fix, but they'd derail the task
at hand. Add an entry instead of chasing them now, and **clear these before starting
a new feature.** New features and larger efforts go in ROADMAP.md, not here.

- [ ] _(none yet)_
```

**`CHANGELOG.md` records shipped history, one entry per release.** The format is
fixed so release tooling can parse it:

```markdown
# <Project> Releases

## Unreleased
- Change you just made, in user-facing terms.

## 1.4.0
- ...
```

- h1 is the project/repo name followed by `Releases`.
- Each release is an `## ` header whose text is **exactly the tag name** (no
  decoration, no leading `v` if the project's tags carry none) — release tooling
  matches on it.
- Under each header, an unordered list of the changes in that release.
- **New changes go under a temporary `## Unreleased` header** as you make them. A
  release recipe (often `just release <version>`) promotes `## Unreleased` to the
  version header at release time, so don't hand-version unreleased work. Check the
  repo's `justfile`/CI for the exact mechanic before editing.

## The scan procedure

Read in this order; stop when you can explain the repo to a newcomer:

1. **Entry points & metadata** — `package.json`/`main`, `manifest.json`, `Cargo.toml`, `go.mod`, etc. What is this and what's its shape?
2. **Build/test/release config** — scripts, `justfile`, CI. These become `CLAUDE.md` commands.
3. **Directory map by responsibility** — one line per dir/major file. This becomes the `ARCHITECTURE.md` module map.
4. **Trace 1–2 core data flows** end to end (the main thing the code *does*). This is the heart of `ARCHITECTURE.md`.
5. **Funky-logic sweep (don't skip — this is where agents under-deliver).** Deliberately hunt non-obvious code: `grep -rin 'workaround\|hack\|FIXME\|TODO\|XXX\|gotcha\|do not\|don.t'`, magic numbers/constants, and comments that explain *why*. **Give each one a home:** a precise inline code comment if it's local, a `docs/*.md` entry if it's cross-cutting. (A real example: an API that needs `1-999` requested to dodge a server bug — invisible unless deliberately captured.)
6. **Existing README** — link to it, never restate it; it's a separate source of truth. **`CHANGELOG.md`** is canonical here (see taxonomy + format note): keep it current, but never duplicate its release notes into other docs.
7. **Verify before writing** — only document what is **true now**. No aspirations, no unverified "tests pass." Flag observations vs. commitments.

## Maintenance (anti-rot)

Setup is the easy half; trust is the hard half.

- **Write a sync agreement into `CLAUDE.md`**: concrete "when you change X, update Y"
  triggers (e.g. "new service → add it to the `ARCHITECTURE.md` module map";
  "hit a small in-scope tangent → add a `FOLLOWUPS.md` entry"; "plan a new feature or
  larger effort → add it to `ROADMAP.md`"; "ship a user-facing change → add a bullet
  under `## Unreleased` in `CHANGELOG.md`"). Make updating docs part of "done."
- **Route new knowledge by the taxonomy above as you work** — don't let it pool in
  one catch-all log. (Catch-all logs are the #1 thing baseline agents produce; they
  collapse four lifespans into one file and rot.)
- **Re-run the cold-start test (below) when docs may have drifted.** It's the drift
  detector, not just a setup gate.
- For CLAUDE.md quality audits specifically, defer to **claude-md-management**.

## Cold-start verification (required)

You wrote the docs with full context, so you **cannot see their gaps**. Test the
actual goal, not just your claims:

1. Dispatch a subagent that may read **only** the docs (`CLAUDE.md` + what it links) — **no source code**.
2. Ask it to restate: what the project is, where it would start for a concrete task, and the top gotchas.
3. Whatever it gets wrong or has to grep the code for **is a gap** in the docs. Fix it and re-run if substantial.

**No subagent-dispatch tool in your environment?** Don't skip the test — do a manual
pass: in a fresh read, open **only** `CLAUDE.md` and the files it links (no source),
answer the three questions above from the docs alone, and note anything you can't
answer without opening code — that's the gap. Then separately verify every specific
claim (file names, commands, flows, magic numbers) against the actual repo.

The claim-verification step is also how you verify docs against code at write time.

## Common Mistakes

| Mistake (seen in baseline) | Fix |
|---|---|
| Inventing names like `docs/work-log.md` | Use the canonical taxonomy so `creating-handoffs` and the next agent find them |
| One file mixing session-state + deferred + history | Route by lifespan: HANDOFF vs FOLLOWUPS/ROADMAP vs CHANGELOG/git |
| Skipping `FOLLOWUPS.md` because `ROADMAP.md` "already covers deferred work" | Different lifespans: FOLLOWUPS = in-scope tangents to clear before the next feature; ROADMAP = new/larger efforts. Always create `FOLLOWUPS.md` (even empty); never merge them |
| Documenting from code-reading but never testing cold onboarding | Run the cold-start test |
| Funky logic captured only by luck | Do the explicit funky-logic sweep; give each gotcha a home |
| Restating the README, or duplicating `CHANGELOG.md` release notes into other docs | Link the README (separate source of truth); keep `CHANGELOG.md` canonical but don't copy its notes elsewhere |
| Aspirational / unverified claims | Document only what's true now; verify specifics |
| `CLAUDE.md` bloated into a manual | Keep it a small router; depth lives in `ARCHITECTURE.md`/`docs/` |

## Red Flags — STOP

- "The docs are obviously clear" → run the cold-start test anyway; you have context the next agent won't.
- "I'll just call it `notes.md`/`work-log.md`" → use the canonical name.
- "I'll put it all in one file so it's not missed" → route by lifespan instead.
- "ROADMAP already handles deferred work, so FOLLOWUPS is redundant" → different lifespans; always create `FOLLOWUPS.md` with its instructional header, even empty.
- "The code probably does X" → verify before you write it.
