# TDD in TypeScript

Language-specific companion to [SKILL.md](SKILL.md). Worked examples for the principles in [tests.md](tests.md) and [mocking.md](mocking.md). Examples use vitest/jest syntax; any runner works.

## Good vs bad tests

```typescript
// GOOD: tests observable behavior through the public API
test("user can checkout with valid cart", async () => {
  const cart = createCart();
  cart.add(product);
  const result = await checkout(cart, paymentMethod);
  expect(result.status).toBe("confirmed");
});

// BAD: asserts on an internal collaborator call — tests HOW, not WHAT
test("checkout calls paymentService.process", async () => {
  const mockPayment = jest.mock(paymentService);
  await checkout(cart, payment);
  expect(mockPayment.process).toHaveBeenCalledWith(cart.total);
});
```

Verify through the interface, not the database:

```typescript
// BAD: bypasses the interface to verify
test("createUser saves to database", async () => {
  await createUser({ name: "Alice" });
  const row = await db.query("SELECT * FROM users WHERE name = ?", ["Alice"]);
  expect(row).toBeDefined();
});

// GOOD: verifies through the interface
test("createUser makes user retrievable", async () => {
  const user = await createUser({ name: "Alice" });
  const retrieved = await getUser(user.id);
  expect(retrieved.name).toBe("Alice");
});
```

## Property-based tests

Use [`fast-check`](https://github.com/dubzzz/fast-check) for invariants:

```typescript
import fc from "fast-check";

// Example test: one case
test("reverse([1,2,3]) is [3,2,1]", () => {
  expect(reverse([1, 2, 3])).toEqual([3, 2, 1]);
});

// Property test: the invariant for all inputs
test("reversing twice returns the original", () => {
  fc.assert(fc.property(fc.array(fc.integer()), (xs) => {
    expect(reverse(reverse(xs))).toEqual(xs);
  }));
});
```

## Designing for mockability

```typescript
// Easy to mock: dependency arrives as a parameter
function processPayment(order: Order, paymentClient: PaymentClient) {
  return paymentClient.charge(order.total);
}

// Hard to mock: the function builds its own client
function processPayment(order: Order) {
  const client = new StripeClient(process.env.STRIPE_KEY);
  return client.charge(order.total);
}
```

SDK-style interface — each operation independently mockable:

```typescript
// GOOD: each function returns one specific shape
const api = {
  getUser: (id) => fetch(`/users/${id}`),
  getOrders: (userId) => fetch(`/users/${userId}/orders`),
  createOrder: (data) => fetch("/orders", { method: "POST", body: data }),
};

// BAD: one generic fetcher forces conditional logic inside the mock
const api = {
  fetch: (endpoint, options) => fetch(endpoint, options),
};
```

Prefer a hand-written fake over `vi.mock`/`jest.mock` auto-mocks where a small fake captures the behavior — it tests through the seam instead of asserting on calls. For DB-backed tests, prefer a real stand-in (PGLite, `better-sqlite3` in-memory) over mocking the data layer — see [codebase-design/TYPESCRIPT.md](../codebase-design/TYPESCRIPT.md).
