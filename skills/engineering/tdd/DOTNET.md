# TDD in .NET

Language-specific companion to [SKILL.md](SKILL.md). Worked examples for the principles in [tests.md](tests.md) and [mocking.md](mocking.md). Examples use xUnit + NSubstitute; NUnit/MSTest and Moq are equivalent.

## Good vs bad tests

```csharp
// GOOD: tests observable behavior through the public API
[Fact]
public async Task User_can_checkout_with_valid_cart()
{
    var cart = CreateCart();
    cart.Add(product);

    var result = await _checkout.ProcessAsync(cart, paymentMethod);

    Assert.Equal(CheckoutStatus.Confirmed, result.Status);
}

// BAD: asserts on an internal collaborator call — tests HOW, not WHAT
[Fact]
public async Task Checkout_calls_payment_process()
{
    await _checkout.ProcessAsync(cart, payment);
    await _payment.Received(1).ProcessAsync(cart.Total);   // brittle: breaks on refactor
}
```

Verify through the interface, not the database:

```csharp
// BAD: bypasses the interface to verify
[Fact]
public async Task CreateUser_saves_to_database()
{
    await _users.CreateAsync(new("Alice"));
    var row = await _db.QuerySingleAsync("SELECT * FROM Users WHERE Name = @n", new { n = "Alice" });
    Assert.NotNull(row);
}

// GOOD: verifies through the interface
[Fact]
public async Task CreateUser_makes_user_retrievable()
{
    var user = await _users.CreateAsync(new("Alice"));
    var retrieved = await _users.GetAsync(user.Id);
    Assert.Equal("Alice", retrieved.Name);
}
```

## Property-based tests

Use [FsCheck](https://fscheck.github.io/FsCheck/) (or CsCheck) for invariants:

```csharp
// Example test: one case
[Fact]
public void Reverse_of_123_is_321() =>
    Assert.Equal(new[] { 3, 2, 1 }, Reverse(new[] { 1, 2, 3 }));

// Property test: the invariant for all inputs
[Property]
public bool Reversing_twice_returns_the_original(int[] xs) =>
    Reverse(Reverse(xs)).SequenceEqual(xs);
```

## Designing for mockability

```csharp
// Easy to mock: collaborator arrives through the constructor (DI)
public sealed class PaymentProcessor(IPaymentClient client)
{
    public Task<Receipt> ProcessAsync(Order order) => client.ChargeAsync(order.Total);
}

// Hard to mock: the class builds its own client
public sealed class PaymentProcessor
{
    public Task<Receipt> ProcessAsync(Order order)
    {
        var client = new StripeClient(Environment.GetEnvironmentVariable("STRIPE_KEY"));
        return client.ChargeAsync(order.Total);
    }
}
```

SDK-style port — one method per external operation, each independently substitutable:

```csharp
// GOOD: each member returns one specific shape
public interface IOrdersApi
{
    Task<User> GetUserAsync(UserId id);
    Task<IReadOnlyList<Order>> GetOrdersAsync(UserId userId);
    Task<Order> CreateOrderAsync(CreateOrder data);
}

// BAD: one generic call forces conditional logic inside the substitute
public interface IOrdersApi
{
    Task<HttpResponseMessage> SendAsync(string endpoint, HttpContent? body);
}
```

Recall the `IFoo` caution from [codebase-design/DOTNET.md](../codebase-design/DOTNET.md): only extract the interface when there's a real second adapter (here, production HTTP + a test substitute at a true-external boundary). For DB-backed tests, prefer a real stand-in (SQLite in-memory, Testcontainers) over mocking the data layer — the EF Core `InMemory` provider hides real query bugs.
