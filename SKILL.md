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
is the whole point. Create only what the repo warrants, but keep the names. **If a
near-miss file already exists** (e.g. `FOLLOWUP.md` where the canonical name is
`FOLLOWUPS.md`, or `NOTES.md` doing a `docs/` job), `git mv` it to the canonical
name and fold its content in — never leave two competing files for the same role.

| File | Holds | Lifespan | Owner skill |
|------|-------|----------|-------------|
| `CLAUDE.md` (root) | small router: what this is, key commands, where things live, conventions, **pointers to everything below**. Loaded every session — keep it tight. | stable | this |
| `ARCHITECTURE.md` | the "don't re-scan" quickstart: mental model, 1–2 core data flows end-to-end, module map (one line each) | semi-stable | this |
| `docs/*.md` | deep references + **funky logic / gotchas**, one topic per file, with a `docs/index.md` | per-subsystem | this |
| `FOLLOWUPS.md` (root) | small deferred findings — the lightweight "captured so it isn't lost" queue | churns | this |
| `ROADMAP.md` (root) | larger planned / in-flight efforts | churns | this |
| plan/spec docs + their `## Status` | per-effort progress, what's half-done, dead ends | per-effort | writing-plans |
| `docs/handoffs/HANDOFF.md` | ephemeral "you are here" session router + verification commands | per-session | creating-handoffs |

**Provision the `docs/handoffs/` location with a one-line `docs/handoffs/README.md`
placeholder** (not a stub `HANDOFF.md` — that's session state) **and link it from
`CLAUDE.md`. Don't write session state here** — that's `creating-handoffs`' job. The
point is that the two skills meet at the same paths.

## The scan procedure

Read in this order; stop when you can explain the repo to a newcomer:

1. **Entry points & metadata** — `package.json`/`main`, `manifest.json`, `Cargo.toml`, `go.mod`, etc. What is this and what's its shape?
2. **Build/test/release config** — scripts, `justfile`, CI. These become `CLAUDE.md` commands.
3. **Directory map by responsibility** — one line per dir/major file. This becomes the `ARCHITECTURE.md` module map.
4. **Trace 1–2 core data flows** end to end (the main thing the code *does*). This is the heart of `ARCHITECTURE.md`.
5. **Funky-logic sweep (don't skip — this is where agents under-deliver).** Deliberately hunt non-obvious code: `grep -rin 'workaround\|hack\|FIXME\|TODO\|XXX\|gotcha\|do not\|don.t'`, magic numbers/constants, and comments that explain *why*. **Give each one a home:** a precise inline code comment if it's local, a `docs/*.md` entry if it's cross-cutting. (A real example: an API that needs `1-999` requested to dodge a server bug — invisible unless deliberately captured.)
6. **Existing README / CHANGELOG** — link to them, never restate them. They are separate sources of truth.
7. **Verify before writing** — only document what is **true now**. No aspirations, no unverified "tests pass." Flag observations vs. commitments.

## Maintenance (anti-rot)

Setup is the easy half; trust is the hard half.

- **Write a sync agreement into `CLAUDE.md`**: concrete "when you change X, update Y"
  triggers (e.g. "new service → add it to the `ARCHITECTURE.md` module map";
  "defer something → add a `FOLLOWUPS.md` entry"). Make updating docs part of "done."
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
| Documenting from code-reading but never testing cold onboarding | Run the cold-start test |
| Funky logic captured only by luck | Do the explicit funky-logic sweep; give each gotcha a home |
| Restating README/CHANGELOG | Link to them; they're separate sources of truth |
| Aspirational / unverified claims | Document only what's true now; verify specifics |
| `CLAUDE.md` bloated into a manual | Keep it a small router; depth lives in `ARCHITECTURE.md`/`docs/` |

## Red Flags — STOP

- "The docs are obviously clear" → run the cold-start test anyway; you have context the next agent won't.
- "I'll just call it `notes.md`/`work-log.md`" → use the canonical name.
- "I'll put it all in one file so it's not missed" → route by lifespan instead.
- "The code probably does X" → verify before you write it.
