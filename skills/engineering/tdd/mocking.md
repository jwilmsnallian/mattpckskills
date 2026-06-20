# When to Mock

Mock at **system boundaries** only:

- External APIs (payment, email, etc.)
- Databases (sometimes — prefer a real test DB or stand-in; see the dependency-category tooling in [codebase-design/DOTNET.md](../codebase-design/DOTNET.md) / [codebase-design/TYPESCRIPT.md](../codebase-design/TYPESCRIPT.md))
- Time/randomness
- File system (sometimes)

Don't mock:

- Your own classes/modules
- Internal collaborators
- Anything you control

## Designing for Mockability

At system boundaries, design interfaces that are easy to mock. These principles are language-neutral; for idiomatic worked examples (NSubstitute/Moq vs vitest/jest), see [DOTNET.md](DOTNET.md) and [TYPESCRIPT.md](TYPESCRIPT.md).

**1. Use dependency injection.** Pass external dependencies in rather than constructing them internally — a function that receives a payment client can be handed a fake; one that calls `new StripeClient(...)` itself cannot. (In .NET this is constructor injection through the DI container; in TS a parameter or factory.)

**2. Prefer SDK-style interfaces over generic fetchers.** Create a specific method per external operation (`getUser`, `getOrders`, `createOrder`) instead of one generic `fetch(endpoint, options)` with conditional logic. The SDK approach means:

- Each mock returns one specific shape
- No conditional logic in test setup
- Easier to see which endpoints a test exercises
- Type safety per endpoint
