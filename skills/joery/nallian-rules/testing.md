---
paths:
  - "**/*Tests.cs"
  - "**/*Test.cs"
  - "**/tests/**"
---

# Tests (.NET)

- **XUnit v3**: `[Fact]` / `[Theory]`. Always pass `TestContext.Current.CancellationToken` in async
  tests.
- **NSubstitute** `Substitute.For<T>()` for dependencies; no hand-rolled fakes unless necessary.
- Mock `ISystemClock` and `IGuidGenerator` in every test that creates entities or asserts on time/IDs
  — never real `DateTime.UtcNow` / `Guid.NewGuid()`. Time-travel by advancing the mocked clock.
- Naming: `MethodName_StateUnderTest_ExpectedBehavior`. Structure: dependencies mocked in the
  constructor, success cases first, failure cases next, private helpers at the bottom.
