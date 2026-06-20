# Codebase Design in .NET

Language-specific companion to [SKILL.md](SKILL.md). Same vocabulary — **module, interface, seam, adapter, depth, leverage**. This file holds the C#/.NET worked examples and the .NET-specific smells.

## The `IFoo` + `Foo` reflex — the #1 shallow-module smell in .NET

.NET codebases accumulate interfaces with exactly one implementation, extracted "for DI" or "for mocking":

```csharp
public interface IOrderService { Task<Receipt> PlaceAsync(Order order); }
public sealed class OrderService : IOrderService { /* ... */ }
```

If `OrderService` is the only implementation and the only other "implementation" is a Moq mock in tests, that interface is **indirection, not a seam**. Recall the principle: *one adapter means a hypothetical seam; two means a real one.* A production class plus its test mock is one real adapter and one ghost — the mock exists only because the interface does.

What to do instead:

- **Don't extract an interface until something varies across it.** A class is already a module with an interface (its public members). You can deepen and test it directly.
- **Extract the interface when there's a genuine second adapter** — a second provider, a process/network boundary you must fake, or a true external you don't control (categories 3–4 in [DEEPENING.md](DEEPENING.md)).
- **Prefer a real local stand-in over a mock** where one exists (see the table below) — it tests behaviour *through* the seam instead of asserting on calls.

This is the same point as the `interface`-keyword warning in [SKILL.md](SKILL.md): the C# `interface` keyword is a way to *express* a seam, not proof that one exists.

## Accept dependencies, don't create them = constructor injection

.NET makes this the path of least resistance. Inject collaborators through the constructor; register them once in `Program.cs`.

```csharp
// Deep + testable: collaborators arrive through the constructor
public sealed class OrderProcessor(IPaymentGateway gateway, TimeProvider clock)
{
    public async Task<Receipt> ProcessAsync(Order order) { /* ... */ }
}

// Hard to test: the module reaches out and builds its own world
public sealed class OrderProcessor
{
    public async Task<Receipt> ProcessAsync(Order order)
    {
        var gateway = new StripeGateway();   // can't substitute
        var now = DateTime.UtcNow;           // can't control time
    }
}
```

`DateTime.UtcNow`, `new HttpClient()`, `Guid.NewGuid()`, static singletons — each is an un-injected dependency that pins a test to the real world. Inject `TimeProvider`, an `IHttpClientFactory`-built client, etc.

## Return results, don't mutate

Prefer returning immutable values over mutating shared state. `record` / `readonly record struct` make the result-returning style cheap and pair with the value objects from `domain-modeling`.

```csharp
// Testable: pure, returns a value
public Discount Calculate(Cart cart) => /* ... */;

// Harder: mutates the argument, test must reconstruct state
public void Apply(Cart cart) => cart.Total -= /* ... */;
```

## Dependency categories → .NET tooling

Maps the four categories in [DEEPENING.md](DEEPENING.md) to what you actually reach for:

| Category | .NET stand-in for tests |
|---|---|
| In-process | none — test the deep module directly |
| Local-substitutable | EF Core `InMemory` provider, **SQLite in-memory** (closer to real SQL), **Testcontainers** (real Postgres/SQL Server in a container) |
| Remote but owned | a typed `HttpClient` via `IHttpClientFactory` behind a port; in-memory adapter for tests, HTTP adapter for prod |
| True external | inject a port; provide a **Moq**/**NSubstitute** mock adapter in tests |

Prefer Testcontainers or SQLite-in-memory over the EF Core InMemory provider when query behaviour matters — InMemory isn't a relational database and hides real query bugs.

## A module is scale-agnostic

A "module" here can be a vertical slice, not just a class: a MediatR request + its handler + the types it returns is a deep module whose interface is the request type. Deepen at whatever scale hides the most behaviour behind the smallest interface.

## Domain term → type

When a term settles in the glossary (`domain-modeling` / `CONTEXT.md`), give it a type that makes illegal states unrepresentable — the type system carries the invariant so callers can't violate it and tests don't have to police it:

- **Value objects** — model `Money`, `EmailAddress`, `Quantity` as a `readonly record struct` that validates in its constructor, not as a bare `decimal`/`string`. The deep module then accepts the validated type and never re-checks.
- **Strongly-typed IDs** — `CustomerId`/`OrderId` as distinct `record struct`s, not raw `Guid`. A method that takes `CustomerId` can't be handed an `OrderId` by mistake; the `_Avoid_` list in `CONTEXT.md` becomes a compile error rather than a code-review note.
- **Closed sets** — a fixed set of states is an `enum` or a sealed hierarchy (`abstract record` + cases), so the compiler forces every `switch` to handle each case.
- **No nulls for "absent"** — enable nullable reference types and use `required` members / non-nullable constructors so a half-built aggregate can't exist.

The glossary stays implementation-free; this is where its terms cross into code.
