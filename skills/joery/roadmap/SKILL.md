---
name: roadmap
description: Reconcile a project's ROADMAP.md against ground truth (issue Status lines, ADR status) and archive shipped candidates to docs/roadmap/shipped.md. Use when a roadmap candidate's status looks stale, after closing the last issue of a feature, or when asked to update/tidy/sync the roadmap.
---

# Roadmap

Keep `ROADMAP.md` honest by **deriving** each candidate's done-ness from the issue tracker instead of trusting the hand-written header. The roadmap header is a copy of state that lives authoritatively in `.scratch/<feature>/issues/*.md` — copies go stale. This skill reconciles the copy against the source, then archives finished work.

This is a **drift detector + fixer**, not a roadmap writer. It never invents narrative; it only moves status to match reality and relocates done entries.

## The candidate convention

`ROADMAP.md` lists deferred / in-flight design branches as `## Candidate <X> — <title>` blocks. The file holds work that **isn't finished** — done candidates belong in the shipped log, not here.

Each candidate should carry structured fields directly under its heading so reconciliation is a glob + grep, not prose-parsing:

```
## Candidate B — ICurrentUserResolver (concentrate ClaimsPrincipal → User)
Feature: current-user-resolver
ADR: docs/adr/0002-current-user-resolver.md
Status: building
```

- **`Feature:`** — the `.scratch/<slug>` directory backing this candidate (omit for pure ideas with no issues yet).
- **`ADR:`** — path to the candidate's ADR (omit if none).
- **`Status:`** — the lifecycle state, **derived, never hand-edited** once a `Feature:` exists.

If a candidate has no structured fields yet (older prose-only entries), recover the links from the prose — scan for a `.scratch/<slug>` path and a `docs/adr/` link — and offer to add the fields as part of the reconcile.

## Candidate lifecycle (derived from issues)

For a candidate with a `Feature:`, read the `Status:` line of every `.scratch/<feature>/issues/*.md` (that line is authoritative — see the local issue-tracker convention; do not infer from acceptance-criteria checkboxes) and derive:

| Issues state | Derived candidate status |
|---|---|
| no `Feature:` / no issues yet | `deferred` or `designed` — **author's intent, left as-is** (not derivable) |
| issues exist, none started | `designed` |
| some `in-progress` or some `done`, not all `done` | `building` |
| **all `done`** | `done` |

`done` is the only state the reconcile asserts against ground truth — it is exactly the drift that bites. `deferred`/`designed` express *intent to build* and stay under the author's control.

## Process

### 1. Find the roadmap and the shipped log

`ROADMAP.md` at the repo root; shipped log at `docs/roadmap/shipped.md` (create it on first archive if missing). If the repo has no `ROADMAP.md`, say so and stop — there is nothing to reconcile.

### 2. Compute drift

For each candidate, derive its status (table above) and check, if a `done` candidate has an `ADR:`, that the ADR's own `Status:` line reads `Accepted`. Build a report comparing **claimed vs actual**:

```
Candidate   Claimed      Derived    ADR        Action
B           DESIGNED     done       Proposed   → set Status: done, accept ADR 0002, archive
C           deferred     deferred   —          (in sync)
```

If everything is in sync, report that and stop — running with no drift changes nothing (idempotent).

### 3. Confirm, then apply

Show the report and the exact edits before touching files. Get the user's go-ahead, then for each drifting candidate:

1. **Update `Status:`** to the derived value (add the structured fields first if the entry was prose-only).
2. **Accept the ADR** if the candidate is `done` and its ADR still reads `Proposed` — flip the ADR's `Status:` line to `Accepted`. Flipping an ADR to Accepted is a real decision; call it out explicitly in the confirmation, never silently.
3. **Archive `done` candidates** to `docs/roadmap/shipped.md`:
   - Move the full candidate block to the **top** of the shipped log under a `## <title> — shipped <YYYY-MM-DD>` heading (use today's date; run `date +%F` if unsure). Preserve its links (PRD, ADR, decision ledger, issues) and the outcome paragraph.
   - Leave a one-line tombstone in `ROADMAP.md` under a `## Shipped` section at the bottom: `- Candidate B — ICurrentUserResolver — done <date> → [shipped.md](docs/roadmap/shipped.md)`.
   - The active roadmap now holds only unfinished work, matching the file's purpose.

Do all of a candidate's edits or none — a half-moved candidate is worse than a stale one.

### 4. Report

Summarise what changed: which candidates moved status, which ADRs were accepted, what was archived. Note anything left deliberately (e.g. a piece carried into a later candidate) rather than dropping it.

## Notes

- **Carried-over work is not done work.** If a candidate's prose says a piece was deferred into another candidate, that text moves with the archived entry *and* is reflected in the receiving candidate — don't let the hand-off vanish during the move.
- This skill is safe to invoke from `/implement`'s close-the-loop step: after the last issue of a feature flips to `done`, a reconcile rolls the backing candidate up automatically. It is a no-op for repos without a `ROADMAP.md`.
