# Codebase Design in TypeScript

Language-specific companion to [SKILL.md](SKILL.md). Same vocabulary — **module, interface, seam, adapter, depth, leverage**. This file holds the TS worked examples and TS-specific notes.

## Accept dependencies, don't create them

```typescript
// Testable: dependency arrives as a parameter
function processOrder(order: Order, paymentGateway: PaymentGateway) {}

// Hard to test: the module constructs its own collaborator
function processOrder(order: Order) {
  const gateway = new StripeGateway();
}
```

Inject through a parameter, a factory, or a small constructor. The same applies to ambient dependencies — `Date.now()`, `fetch`, `crypto.randomUUID()` — pass a clock / fetch impl rather than reaching for the global.

## Return results, don't produce side effects

```typescript
// Testable
function calculateDiscount(cart: Cart): Discount {}

// Hard to test
function applyDiscount(cart: Cart): void {
  cart.total -= discount;
}
```

## Dependency categories → TS tooling

Maps the four categories in [DEEPENING.md](DEEPENING.md) to what you actually reach for:

| Category | TS stand-in for tests |
|---|---|
| In-process | none — test the deep module directly |
| Local-substitutable | **PGLite** for Postgres, an in-memory filesystem (`memfs`), `better-sqlite3` in-memory |
| Remote but owned | a fetch/HTTP client behind a port; in-memory adapter for tests |
| True external | inject a port; `vi.mock` / a hand-written fake in tests |

Prefer hand-written fakes over `vi.mock` auto-mocks where a small fake captures the behaviour — they test through the seam rather than asserting on calls.

## The `interface` keyword note

TS is structurally typed: any object matching the shape satisfies the interface, so you often don't need a nominal `interface` declaration to define a seam — a type alias or even an inline parameter type is a seam. As in [SKILL.md](SKILL.md), "interface" in this skill means every fact a caller must know, not the `interface` keyword.

## Domain term → type

When a term settles in the glossary (`domain-modeling` / `CONTEXT.md`), give it a type that makes illegal states unrepresentable — the type system carries the invariant so callers can't violate it and tests don't have to police it:

- **Branded types** — model `CustomerId`/`OrderId` as branded strings (`string & { __brand: 'CustomerId' }`, or a `zod`/`Effect` schema) so a function taking a `CustomerId` can't be handed an `OrderId`; the `_Avoid_` list in `CONTEXT.md` becomes a type error rather than a review note.
- **Discriminated unions** — a fixed set of states is a union with a `kind`/`type` tag, so an exhaustive `switch` (with a `never` default) forces every case to be handled.
- **Parse, don't validate** — validate at the edge (a `zod` schema / constructor function) into a precise type, then pass the parsed type inward; the deep module accepts the validated shape and never re-checks.
- **`readonly` / `as const`** — prefer immutable value shapes so a half-built or mutated value can't drift.

The glossary stays implementation-free; this is where its terms cross into code.
