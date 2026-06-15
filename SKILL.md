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
| `docs/*.md` | deep references + **funky logic / gotchas**, one topic per file, with a `docs/index.md`; also per-topic dated change logs (`docs/<topic>-log.md`) and the prune archives (`docs/followups-archive/`, `docs/roadmap-archive/`) | per-subsystem | this |
| `FOLLOWUPS.md` (root) | in-scope tangents found mid-task — important to fix but would derail the task at hand; resolved before starting the next feature. Tracked as numbered `## N.` sections. **Always created (even empty), with an instructional header.** | churns | this |
| `ROADMAP.md` (root) | new features and larger planned / in-flight efforts, tracked as numbered `## N.` sections | churns | this |
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
`FOLLOWUP.md` exists, `git mv` it to `FOLLOWUPS.md` and fold its content in.

**Both files track their items as numbered `## N.` sections — not list bullets.** The
heading number gives each item a handle to reference ("follow-up 3", "roadmap item
2"), and the section body can hold code blocks, commands, and detail that wouldn't sit
cleanly in a list item.

**Numbers are permanent identifiers: assign once, never reuse, never renumber** (the
GitHub-issues model — issue #5 is #5 for life; closing it never shifts #6 down). Take
each new item's number from an all-time high-water counter kept in the file header
(`<!-- next-id: N -->`), not from "highest live item + 1" — when done items have been
pruned, the live max is *below* numbers still live in the archive, so "live max + 1"
silently recycles a number and makes every `(was #N)` handle ambiguous. Increment the
counter, never decrement it. Mark a finished item with a `**Status:** done` line rather
than deleting it; on a cleanup pass completed items get pruned to the archive (below) —
but the survivors **keep their numbers**, so gaps in the live sequence (1, 2, 5, 8…)
are expected and correct, not a defect to tidy up. This deletes the fragile
"renumber-then-grep-every-repo-to-fix-`#N`-refs" step entirely: a reference to `#N`
stays valid forever because `N` never moves. Seed `FOLLOWUPS.md` with:

```markdown
# Follow-ups

<!-- next-id: 1 -->

In-scope tangents found while working — important to fix, but they'd derail the task
at hand. Add a numbered `## N.` section below (take N from `next-id` above, then
increment it) instead of chasing them now, and **clear these before starting a new
feature.** New features and larger efforts go in ROADMAP.md, not here.

Numbers are permanent: never reused, never renumbered. Done items get pruned to
`docs/followups-archive/` keeping their original number as a `(was FOLLOWUPS #N)`
handle, so gaps in the live list are normal. **Referenced `#N` not in this file? It's
completed — `grep -rn 'was FOLLOWUPS #N' docs/followups-archive/`.**

<!-- Template — copy for each item; take N from next-id above, then bump next-id:
## N. Short title
**Status:** open
What needs doing and why. Code blocks, commands, and links are fine here.
Mark **Status:** done when resolved; pruned (never renumbered) on the next cleanup pass. -->

_No open follow-ups yet._
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

**Dated history is a log — never let it accrete in `CLAUDE.md`.** The most common
regrowth failure: each change "updates the docs" by appending one more dated sentence
("On <date> X was restructured — see …") to the relevant `CLAUDE.md` section, until the
section is a multi-thousand-character history paragraph. `CLAUDE.md` states what is
true *now*. Route the dated entries to a per-topic log — `docs/<topic>-log.md`, one
`## YYYY-MM-DD — title` section per change, each linking to its plan/spec doc — and
leave only a current-state summary + pointer in `CLAUDE.md`. Put the trigger in the
sync agreement ("change <subsystem> → append a dated entry to `docs/<topic>-log.md`
and refresh the summary"). A section that needs a second dated sentence has become a
log.

**Prune to an archive — but never renumber, so `#N` references never go stale.** On
the FOLLOWUPS/ROADMAP cleanup pass, move completed items to
`docs/followups-archive/<date>-completed.md` / `docs/roadmap-archive/<date>-completed.md`
— keep each item's full body and add a "(was FOLLOWUPS #N)" handle to its title. Then
**leave the surviving live items' numbers exactly as they are** (gaps are fine) and
**do not touch the `next-id` counter** — it only ever increments at creation time.
Because numbers never move, there is nothing to grep-and-fix: a `#N` reference anywhere
(live docs, dated plan/spec docs, sibling repos) resolves forever — either it's still
in the live file, or it's in the archive under `(was #N)`, which is now a *unique*
handle (it was ambiguous only back when renumbering recycled numbers). Never rewrite
history docs.

**Multi-repo workspaces:** `FOLLOWUPS.md`/`ROADMAP.md` live once, at the workspace
root — sub-repos must not grow their own. Per-effort plan/spec docs go in the repo
where the work lands; efforts spanning repos (or workspace-level contracts) go in the
workspace's docs. Historical dated docs stay where they were written — moving them
dangles references; fix routing only going forward.

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
  "hit a small in-scope tangent → add a numbered `## N.` section to `FOLLOWUPS.md`";
  "plan a new feature or larger effort → add a numbered `## N.` section to
  `ROADMAP.md`"; "ship a user-facing change → add a bullet
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
| Logging follow-up/roadmap items as plain bullets — uncitable, no room for code | Use numbered `## N.` sections so each has a handle ("follow-up 3"); mark done with a `**Status:**` line, prune (never renumber) on a cleanup pass |
| Documenting from code-reading but never testing cold onboarding | Run the cold-start test |
| Funky logic captured only by luck | Do the explicit funky-logic sweep; give each gotcha a home |
| Restating the README, or duplicating `CHANGELOG.md` release notes into other docs | Link the README (separate source of truth); keep `CHANGELOG.md` canonical but don't copy its notes elsewhere |
| Aspirational / unverified claims | Document only what's true now; verify specifics |
| `CLAUDE.md` bloated into a manual | Keep it a small router; depth lives in `ARCHITECTURE.md`/`docs/` |
| `CLAUDE.md` sections growing one dated sentence per change | Dated history is a log: move entries to `docs/<topic>-log.md`, leave current state + pointer |
| Renumbering FOLLOWUPS/ROADMAP on prune — recycles numbers, makes `(was #N)` handles ambiguous, dangles every `#N` ref | Never renumber or reuse: assign once from a `next-id` header counter, prune to the archive keeping the original number, leave gaps. `#N` then resolves forever with no grep-and-fix step |

## Red Flags — STOP

- "The docs are obviously clear" → run the cold-start test anyway; you have context the next agent won't.
- "I'll just call it `notes.md`/`work-log.md`" → use the canonical name.
- "I'll put it all in one file so it's not missed" → route by lifespan instead.
- "ROADMAP already handles deferred work, so FOLLOWUPS is redundant" → different lifespans; always create `FOLLOWUPS.md` with its instructional header, even empty.
- "I'll just append the change note to the relevant CLAUDE.md section" → that's history; append to the topic log (`docs/<topic>-log.md`) and refresh the current-state summary instead.
- "I pruned some done items, let me renumber the rest so they're tidy" → STOP. Numbers are permanent IDs; renumbering recycles them and dangles every `#N` reference. Leave gaps; only `next-id` moves, and only upward.
- "The code probably does X" → verify before you write it.
