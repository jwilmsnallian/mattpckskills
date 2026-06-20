---
paths:
  - "**/*IntegrationTests/**"
  - "**/*IntegrationTest.cs"
  - "**/EndToEnd/**"
  - "**/*E2ETests/**"
---

# Integration / end-to-end tests (.NET)

Unit-test conventions are in `testing.md`; this covers the **e2e** layer — tests that boot the real
host against real infrastructure. Write these for behaviour that only emerges from the full pipeline:
auth/authorization, antiforgery, model binding/validation, EF against real SQL, paging headers,
cascades. Pure logic stays a unit test.

- **Boot the real host with `WebApplicationFactory<TProgram>`.** Target `Program` directly (declare
  `public partial class Program` if needed); no separate assembly marker.
- **Set config via process environment variables, NOT `UseSetting` / `ConfigureAppConfiguration`.**
  On .NET 10 the `WebApplication` + `WebApplicationFactory` pattern reads startup-validation values
  during host construction — *before* in-memory config sources are visible — so in-memory config
  silently doesn't apply. Env vars are picked up by the default providers and surface reliably. Use
  the double-underscore section binding:

  ```csharp
  Environment.SetEnvironmentVariable("OpenIdConnect__Authority", "https://sts-test.example.com");
  Environment.SetEnvironmentVariable("ConnectionStrings__AppDbContext", fixture.ConnectionString);
  ```

  Override only test-time services in `ConfigureWebHost` → `ConfigureTestServices` (test auth, blob
  storage, stubs).

- **Real infra via Testcontainers**, one set per run: `MsSqlContainer` (+ `AzuriteContainer` etc.).
  **Pin the SQL CU explicitly** (e.g. `2022-CU18`) — `latest` has shipped CUs that hang the readiness
  probe. Create + migrate **one** database per run with the app's real `MigrateAsync` (never
  `EnsureCreated`), exposed via `[assembly: AssemblyFixture(typeof(...))]` + `IAsyncLifetime`.
- **One xUnit collection fixture** (`[Collection("...")]` on every e2e class) so xUnit doesn't build
  multiple factories in parallel against the shared container/DB.
- **Reset per test, don't recreate.** A `TestDataSeeder` does clean → seed in `IAsyncLifetime.InitializeAsync`.
  Clean with raw `DELETE` ordered child→parent (tracked `DbSet` deletes load every row first — far
  slower). Keep transactional vs reference cleanup separate so role/token suites can opt into a fully
  empty slate.
- **Exercise real authorization with a test auth scheme.** A `TestAuthenticationHandler` maps an
  `Authorization: TestAuth <identity>` header to a synthetic `ClaimsPrincipal` mirroring the
  production OIDC claims; a `KnownIdentities` table holds one identity per role; `client.As<Role>()`
  extensions set the header. Test the rung-below-needed role for 403, anonymous for 401 — not just
  happy paths. For state-changing requests, mint the XSRF token first (`client.WithXsrfTokenAsync()`).

## Reflection convention guards (no host, no DB)

Cheap, deterministic drift catches that load no host and hit no DB — pure reflection over the
controller assembly. High value per millisecond. Examples worth having:

- Every `[RequiresRight("…")]` references a right that exists in the rights catalogue (a typo fails
  closed — endpoint unreachable for everyone, confusing 403 with no cause).
- Every state-changing action is covered by the global antiforgery filter or explicitly opts out via
  the project's canonical `[IgnoreAntiforgeryToken]` — no hand-rolled escape hatch.
- Every controller route compiles under the expected version prefix (`v1/…`).

Repo-specifics (the exact env-var list, role identities, rights catalogue, the antiforgery filter
type) live in that repo's own `.claude/rules/`, not here.
