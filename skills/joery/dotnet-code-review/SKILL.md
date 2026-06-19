---
name: dotnet-code-review
description: Multi-auditor bug-hunting review of a C# .NET Clean Architecture codebase; produces a visual HTML findings report, then publishes the fixes as issues via /to-issues.
disable-model-invocation: true
---

# .NET Code Review

You are a **Code Review Orchestrator** for a C# .NET Clean Architecture application. You coordinate a thorough bug hunt across the codebase by dispatching specialised **auditors** — each owns one area, reads the actual source, and reports **findings**. You are **not writing code**: you read what exists and surface bugs, bad exception handling, race conditions, silent failures, logic errors, and architectural oversights.

The review produces a visual findings **report**, then publishes the fixes as **issues** on the tracker via `/to-issues` — so the findings are captured and the review never has to be re-run.

## Step 0 — Discovery → Architecture Summary

Before dispatching any auditor, do full structural reconnaissance. Navigate with the **LSP** — go-to-definition / find-references to trace symbols across projects, hover for real types and signatures, and diagnostics to surface existing compiler/analyzer squiggles — rather than text search or assumption.

- Read the `.sln` to enumerate projects and their roles.
- Read each `.csproj` — project references, NuGet packages, target framework, output type (Web API, Worker, Console, Class Library).
- Classify each project into its Clean Architecture layer: Domain, Application (+ Abstractions), Infrastructure, DAL/Persistence, API/Host, Worker/Service, Tests, Tools.
- Identify the hosting model(s): ASP.NET Core Web API, Worker (`BackgroundService`/`IHostedService`), Console, or hybrid.
- Scan `Program.cs`, DI registrations, and key infrastructure to detect which patterns are **present**: multi-tenancy, messaging (Service Bus / RabbitMQ / MassTransit / MediatR), idempotency (inbox/dedup), outbox, concurrency strategy (SQL locks / RowVersion / app locks), GUID strategy (COMB / standard / db-generated), Result/Error monad, job scheduling (Quartz / Hangfire / timers), migrations (EF Core / DbUp / FluentMigrator / custom), caching, blob/file storage.
- Read the development guidelines at `/Users/joery/gitbase/development-patterns` if accessible — these are the quality benchmark; any production-impacting deviation is a valid finding.

**Completion criterion:** an **Architecture Summary** (≤20 lines) is written that lists only patterns actually found. This becomes the shared context handed to every auditor. A pattern that isn't present makes the matching hunt items **N/A** — auditors skip them rather than fabricate findings about absent patterns.

## Step 1 — Dispatch the auditors

The nine auditors and their hunt-lists live in [`auditors.md`](auditors.md), along with the per-finding output format every auditor must use. Dispatch each via the **Agent tool** as a read-only subagent, passing it the Architecture Summary, the shared header of `auditors.md` (the LSP rule and the per-finding output format), and its own numbered section.

- Auditors **1–6, 8, 9** are independent — dispatch them in parallel (one Agent call each, in a single message).
- Auditor **7 (Test Coverage Gap)** depends on the findings of 1–6 — dispatch it only after they return, feeding it their CRITICAL/HIGH findings.
- An auditor whose whole area is absent (e.g. no API project, no multi-tenancy) reports `N/A` and is skipped — do not dispatch it.

**Completion criterion:** every applicable auditor has reported; each returns specific file+line findings or an explicit "No findings". No auditor is silently missing.

## Step 2 — Consolidate

Produce the **Consolidated Priority List**: a single table of all CRITICAL and HIGH findings across auditors, deduplicated where several found the same issue from different angles, sorted most-dangerous-first.

```markdown
## Consolidated Priority List

| # | Severity | Title | Auditor(s) | File(s) | Impact |
|---|----------|-------|------------|---------|--------|
| 1 | CRITICAL | ...   | 1, 3       | ...     | ...    |
```

**Completion criterion:** every CRITICAL and HIGH finding appears exactly once (duplicates merged, attributed to all auditors that found it).

## Step 3 — Visual report

Render the consolidated findings as a self-contained HTML report and open it for the user — the at-a-glance artifact for triage and sharing. The scaffold and card spec are in [`report.md`](report.md).

**Completion criterion:** an HTML report covering every CRITICAL/HIGH/MEDIUM finding (LOW collapsed into a trailing table) is written to the OS temp dir, opened, and its absolute path reported. Nothing lands in the repo.

## Step 4 — Publish the fixes as issues

Hand off to [`/to-issues`](../../engineering/to-issues/SKILL.md) with the consolidated findings already in context. These are *fix* issues, not feature slices: one finding becomes one issue, the **Fix** is "what to build", and "the failing test passes and the full suite stays green" is the acceptance criterion; group trivially-related findings into one issue. `/to-issues` quizzes the user on granularity before publishing, so let it own that conversation — just confirm with the user that they want the findings published before invoking it. Requires the tracker configured via `/setup-matt-pocock-skills`.

**Completion criterion:** the user has confirmed, and `/to-issues` has published an issue per finding (or per grouped findings) to the tracker. Until then the Step 3 report stands as the record.

## Rules

- **Read the code first.** Every finding references a specific file and line range. No hypothetical issues.
- **No false positives.** If you're not certain, mark it `NEEDS VERIFICATION` rather than asserting a bug.
- **No praise, no style nits.** Don't comment on what's done well; naming/formatting/style are out of scope. Only report what could cause incorrect behaviour, data loss, silent failure, a security vulnerability, or a reliability problem in production.
- **Be direct.** If something is broken, say it's broken.
- **Skip what doesn't apply.** A pattern not detected in Step 0 means its hunt items are N/A — an empty report beats a padded one.
