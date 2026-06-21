---
paths:
  - "**/*Tests.cs"
  - "**/*Test.cs"
  - "**/tests/**"
---

# Tests (.NET)

This covers **unit tests**. End-to-end tests that boot the host against real infra (Testcontainers,
`WebApplicationFactory`, test auth) are in `integration-tests.md`.

- **XUnit v3**: `[Fact]` / `[Theory]`. Always pass `TestContext.Current.CancellationToken` in async
  tests.
- **NSubstitute** `Substitute.For<T>()` for dependencies; no hand-rolled fakes unless necessary.
- Mock `ISystemClock` / `IGuidFactory` in the **code under test** whenever it stamps timestamps or
  generates IDs, and assert against the mocked values — never let the behaviour under test reach real
  `DateTime.UtcNow` / `Guid.NewGuid()`. Time-travel by advancing the mocked clock. Throwaway
  **arrange-data** in builders/seeders may call `DateTime.UtcNow` / `Guid.NewGuid()` directly — the
  ban is about determinism of what you assert on, not seed rows you never assert on.
- **Repository tests** run against the EF Core **InMemory** provider
  (`UseInMemoryDatabase(uniqueName)`), a fresh uniquely-named DB per test — a lighter path than the
  Testcontainers e2e stack. Use it for repository query/shape logic; reserve real SQL (Testcontainers)
  for full e2e where provider-specific behaviour matters.
- Naming: `MethodName_StateUnderTest_ExpectedBehavior`. Structure: dependencies mocked in the
  constructor, success cases first, failure cases next, private helpers at the bottom.
