# Joery

My own skills — actively used (linked into `~/.claude/skills/` by `scripts/link-skills.sh`), not promoted in the plugin, never pushed upstream.

## User-invoked

Reachable only when I type them (`disable-model-invocation: true`).

- **[dotnet-code-review](./dotnet-code-review/SKILL.md)** — Multi-auditor bug hunt across a C# .NET Clean Architecture codebase; produces a visual HTML findings report, then publishes the fixes as issues via `/to-issues`.

## Model-invoked

Reachable by me (`/name`) or by another skill.

- **[roadmap](./roadmap/SKILL.md)** — Reconcile `ROADMAP.md` against ground truth (issue `Status:` lines, ADR status), derive candidate done-ness, and archive shipped candidates to `docs/roadmap/shipped.md`. Invoked by `/implement` when closing a feature's last issue.
