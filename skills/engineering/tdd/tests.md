# Good and Bad Tests

The characteristics below are language-neutral. For idiomatic, worked examples in each language, see [DOTNET.md](DOTNET.md) (xUnit/NUnit) and [TYPESCRIPT.md](TYPESCRIPT.md) (vitest/jest).

## Good Tests

**Integration-style**: test through real interfaces, not mocks of internal parts. A good test exercises a public entry point and asserts on the observable result — "user can checkout with a valid cart" → assert the returned status, not which collaborators were called.

Characteristics:

- Tests behavior users/callers care about
- Uses public API only
- Survives internal refactors
- Describes WHAT, not HOW
- One logical assertion per test

## Bad Tests

**Implementation-detail tests**: coupled to internal structure.

Red flags:

- Mocking internal collaborators
- Testing private methods
- Asserting on call counts/order (e.g. "checkout called `payment.process`") — this tests HOW, not WHAT
- Test breaks when refactoring without behavior change
- Test name describes HOW not WHAT
- **Verifying through external means instead of the interface** — e.g. asserting a row exists by querying the database directly after `createUser`, instead of round-tripping through `getUser`. Verify through the interface: create, then retrieve through the public API, and assert on what comes back.

## Property-Based Tests

When the behavior is an **invariant** rather than one concrete case, assert the invariant over generated inputs instead of hardcoded values. This catches edge cases example tests miss and describes WHAT must always hold.

- Example test: one case — `reverse([1,2,3])` is `[3,2,1]`.
- Property test: the invariant for all inputs — reversing twice returns the original; encoding then decoding round-trips; the result always satisfies some constraint.

Good fits: round-trips (`encode`/`decode`), idempotence, commutativity, results that must always satisfy a constraint. Reach for an example test when the expected output is a specific known value, not a rule. See the companions for the per-language PBT library (FsCheck/CsCheck in .NET, fast-check in TS).
