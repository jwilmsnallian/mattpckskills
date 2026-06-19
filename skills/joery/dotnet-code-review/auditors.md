# Auditors

The nine review auditors and the output format they share. Each auditor reads the **actual source files** in its scope before producing findings — no speculation. Where a hunt item is gated on a pattern ("If messaging exists…") and that pattern wasn't detected in Step 0, the item is N/A.

**Use the LSP, not guesswork.** When tracing code, reach for the language server rather than text search or assumption:

- **go-to-definition / find-references** to follow a symbol across projects and see every call site — text search misses overloads, partial classes, and generated code the LSP resolves.
- **hover** to read the real inferred type, signature, nullability, and XML docs of a symbol before reasoning about it.
- **diagnostics** to surface the compiler and analyzer **squiggles** already on the code (nullable warnings, unawaited tasks, dead code, analyzer rule violations) — an existing squiggle is often a confirmed finding, not a hypothesis.

## Per-finding output format

Every auditor reports in this shape:

```markdown
## Auditor N: [Name]

### Files Reviewed
- full paths of files actually inspected

### Findings

#### [SEVERITY: CRITICAL | HIGH | MEDIUM | LOW] — [Short Title]
**File:** `path/to/file.cs`, line(s) N–M
**What's wrong:** Precise description of the bug, bad handling, or oversight.
**Impact:** What goes wrong in production when this triggers.
**Fix:** Concrete code-level fix — show the corrected code or pattern, not vague advice.

### Summary
- Total findings: N (X critical, Y high, Z medium, W low)
```

If a scope has no issues, the auditor reports "No findings" and stops. An empty report beats a padded one.

---

## Auditor 1 — Exception Handling & Error Propagation

Role: Senior .NET reliability engineer. Scope: all projects. Hunt for:

- `catch` blocks that swallow exceptions silently (empty catch, catch-and-log-only where the caller expects a result).
- `catch (Exception ex)` without rethrowing or wrapping — especially in use cases returning a Result monad, where the caller may never learn something failed.
- Missing `catch` in async paths (unobserved `Task` exceptions).
- If messaging exists: exception handling in consumers/processors — what happens if deserialization throws, or the idempotency store throws? Is the message abandoned, dead-lettered, or silently lost? Does the error handler stop/restart the processor or let it silently die?
- If outbox exists: exception handling in outbox workers — if the send fails, is the message retried or permanently stuck?
- If job scheduling exists: does a job failure get logged **and** reported, or does the scheduler swallow it?
- `ConfigureAwait(false)` usage (or absence) in library-style code.
- Disposed `IServiceScope` or `DbContext` used after disposal in background services.
- Missing `CancellationToken` propagation in async chains.

## Auditor 2 — Multi-Tenancy & Tenant Isolation

Role: Senior application security engineer. Scope: tenant context implementations, DI registration, EF Core `DbContext`, connection-string / tenant-config resolution. If multi-tenancy is not detected, report "N/A — single-tenant application" and skip. Hunt for:

- Tenant context leaking across requests/jobs (scoped-lifetime issues in Workers where tenant context is resolved in a singleton-scoped hosted service).
- `DbContext` or connection string resolved once and cached instead of per-scope.
- Code that assumes a tenant without validating it (e.g. a use case taking a tenant code from job data but never checking it exists in config).
- Cross-tenant data access: any path where tenant A's connection could serve tenant B's data.
- Scheduled jobs sharing mutable state across tenant instances.
- Consumers that could process a message from the wrong tenant's queue due to misconfigured registration.
- Health-check connection strings hardcoded for specific tenants rather than checking all.

## Auditor 3 — Messaging & Concurrency

Role: Senior distributed-systems engineer. Scope: consumers, outbox, idempotency store, all concurrent background processing. Hunt for:

- If idempotency exists: race between the idempotency check and processing (time-of-check/time-of-use). Is the check atomic with the processing?
- If messaging with concurrent consumers: when concurrent messages for the same entity arrive, is the SQL-level or application-level concurrency actually correct in every consumer?
- If outbox exists: if `SaveChangesAsync` succeeds but writing to the outbox channel/queue fails (crash, channel full), does a poller fallback cover the gap? If two worker instances run the poller, can the same message be sent twice — is there a SQL lock or `Sent` flag check?
- If messaging exists: lock-expiry — if processing exceeds the lock duration the message becomes visible to another consumer mid-processing. Is there a max retry on retryable outcomes, or can a poison message loop forever? Are dead-lettered messages monitored/alerted, or do they silently accumulate?
- If outbox cleanup exists: does it delete messages that haven't been sent? That's data loss.
- If channels are used: bounded vs unbounded — if unbounded, memory pressure under load?
- General: any shared mutable state read/written from multiple threads without synchronisation; static collections or caches written concurrently.

## Auditor 4 — Data Integrity & SQL

Role: Senior database engineer (SQL Server). Scope: EF Core mappings, repositories, raw SQL, migrations, GUID generation. Hunt for:

- `SaveChangesAsync` without a transaction where multi-entity writes must be atomic.
- Missing indexes implied by query patterns (frequent composite-key lookups without a covering index).
- If COMB GUIDs exist: verify the timestamp bit-shifting — an off-by-one in byte positions yields non-sequential GUIDs and page splits.
- If optimistic concurrency exists: is `DbUpdateConcurrencyException` caught and handled everywhere `RowVersion` is used, or does it bubble up unhandled?
- If SQL hints (`UPDLOCK`, `HOLDLOCK`) are used: applied consistently across all upsert paths? Via raw SQL or interceptors?
- If delta accumulation exists (`SET Col = Col + @delta`): what if the row doesn't exist yet — is there an atomic INSERT-or-UPDATE?
- If an inbox/dedup table exists: is it ever cleaned up, or does it grow unbounded?
- Connection-string resolution: connections properly pooled per tenant, or pool fragmentation?
- EF model config: missing decimal precision, missing string max-length, wrong cascade-delete behaviour.

## Auditor 5 — API Security & Input Validation

Role: Senior application security engineer (OWASP). Scope: API project — controllers, middleware, auth, model binding. If no API project exists, report "N/A" and skip. Hunt for:

- Missing `[Authorize]` on controllers/actions that should be protected.
- If multi-tenancy exists: can a user forge a tenant claim and reach another tenant's data?
- Model binding without validation: are request DTOs validated (FluentValidation / DataAnnotations / manual) before reaching use cases?
- Missing Content-Type validation on file-upload endpoints.
- SQL-injection vectors in any raw SQL.
- Mass assignment / over-posting on update endpoints (accepting a full entity instead of a scoped DTO).
- Missing rate limiting on ingestion or write-heavy endpoints.
- Overly permissive CORS.
- Swagger/OpenAPI exposed in production.
- Health endpoints (`/health`, `/ready`) leaking sensitive infrastructure detail.
- Missing anti-forgery protections where applicable.

## Auditor 6 — Background Service Lifecycle

Role: Senior .NET platform engineer. Scope: all `BackgroundService`/`IHostedService`. If none exist, report "N/A" and skip. Hunt for:

- `ExecuteAsync` not respecting `CancellationToken` (service won't stop gracefully).
- `ExecuteAsync` throwing and killing the host silently (in .NET 8+ this crashes the host by default — is it handled?).
- If job scheduling exists: `WaitForJobsToComplete = true` with long-running jobs — does shutdown time out before jobs finish?
- If messaging exists: `StopProcessingAsync` not called during graceful shutdown.
- Memory leaks: event-handler registrations in `ExecuteAsync` that accumulate on repeated calls.
- `IServiceProvider.CreateScope()` scopes not disposed in `finally`.
- Startup when the database isn't ready: crash loop or graceful backoff?
- Timer-based workers: `PeriodicTimer` vs `Task.Delay` — if `Task.Delay`, is the token passed?
- Startup ordering: a service depending on another that hasn't started.

## Auditor 7 — Test Coverage Gap

Role: Senior QA engineer (.NET). Scope: all test projects, cross-referenced against Auditors 1–6. **Runs after 1–6.** Hunt for:

- For every CRITICAL and HIGH finding from 1–6, check whether a test exists that would catch it. If not, flag it.
- Missing coverage for critical paths found in discovery: outbox interceptor, idempotency store, consumer error paths, tenant resolution, GUID ordering, concurrency scenarios.
- If multi-tenant: integration tests that don't actually test isolation (only one tenant).
- Architecture tests: do they enforce the Clean Architecture dependency rules (e.g. Domain must not reference Infrastructure)? Any missing rules?
- Tests asserting on implementation details rather than behaviour (brittle, won't catch regressions).
- Missing negative/edge-case tests: malformed input, empty files, duplicate submissions, invalid tenant codes, concurrent writes.

For each untested CRITICAL/HIGH finding, output:

```markdown
#### UNTESTED — [Original Finding Title from Auditor N]
**Original finding:** Auditor N, [severity]
**Test that should exist:**
- **Test name:** `Should_[expected behavior]_When_[condition]`
- **Arrange:** [setup]
- **Act:** [action]
- **Assert:** [expected outcome]
```

## Auditor 8 — Performance & Resource Leaks

Role: Senior .NET performance engineer. Scope: all projects, focus on hot paths (ingestion, message processing, transformation, export). Hunt for:

- Unbounded allocations in hot paths: string concat in loops, `ToList()` on large queryables where `IAsyncEnumerable` streaming would suffice, excessive LINQ materialisation.
- Missing `IDisposable`/`IAsyncDisposable` on types holding disposable resources (`ServiceBusClient`, `ServiceBusSender`, `ServiceBusProcessor`, `BlobContainerClient`, `SqlConnection`, `HttpClient`, …).
- EF queries loading full entity graphs where a `.Select()` projection would do — especially read-heavy paths.
- N+1 query patterns: a DB query per loop iteration instead of batching.
- Missing `AsNoTracking()` on read-only queries.
- `HttpClient` instantiated per-request instead of via `IHttpClientFactory`.
- Large object allocations: `byte[]` for blob upload/download instead of Stream-based APIs.
- If per-tenant job iteration exists: holding resources across tenants (e.g. a `DbContext` for tenant A not disposed before tenant B).
- If channels are used: backpressure — can a fast producer overwhelm a slow consumer?
- Ingestion string parsing: regex not compiled/cached, `string.Split` allocations in per-record loops.
- Missing `StringComparison.Ordinal` on hot-path string comparisons.

## Auditor 9 — Configuration & Secrets Hygiene

Role: Senior DevSecOps engineer. Scope: all `appsettings*.json`, `Program.cs`, `docker-compose.yml`, deployment scripts, env-var references, Key Vault / secret-store integration. Hunt for:

- Hardcoded connection strings, keys, passwords, or secrets anywhere (including `docker-compose.yml`, `appsettings.json`, checked-in `.env`).
- Missing startup validation of required config: does the app fail fast with a clear error, or throw a `NullReferenceException` later at runtime?
- Unsafe defaults for optional config: if an optional schedule/feature flag is missing, does the feature silently not register, or crash?
- If Key Vault / secret store exists: is the credential chain correct for both local dev and cloud? Does the fallback chain make sense?
- If deployment scripts exist: do they leak secrets via command-line args visible in process listings? Do they validate prerequisites before destructive operations?
- Environment config: risk of running Development settings in production (`ASPNETCORE_ENVIRONMENT` unset, or `IsDevelopment()` gating security-relevant behaviour)?
- Serilog / logging: are sensitive fields (connection strings, message bodies, JWTs, request bodies) logged at Information or below?
- App Insights / telemetry: instrumentation key or connection string hardcoded vs sourced from config?
- `docker-compose.yml` SA password / test credentials: could they leak via CI config or shared repos?
