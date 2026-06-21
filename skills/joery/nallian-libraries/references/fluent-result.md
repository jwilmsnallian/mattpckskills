# Nallian.Common.FluentResult — Result cheat-sheet

The full, authoritative surface for `Nallian.Common.FluentResult.Result`. This is **content**,
not a procedure — the answer is on this page. Source of truth:
`~/nalcode/Nallian.Extensions/src/Nallian.Common/FluentResult/`. This API is small and stable;
only re-derive from source if a signature here looks wrong for your installed version.

## Creating results — static factories on `Result`

All are `public static` on the `Result` partial class, so you call them as `Result.X(...)`.

| Factory | Returns |
|---------|---------|
| `Result.Ok()` | success, no value |
| `Result.Ok<TValue>(TValue value)` | `Result<TValue>` success carrying a value |
| `Result.Fail(IError error)` | failure with a custom `IError` |
| `Result.NotFound()` | failure — `NALLIAN-NOT-FOUND` |
| `Result.NotFound(string key)` | not found, identifying the missing key |
| `Result.NotFound(string key, string message)` | not found, key + message |
| `Result.NotFound<T>(T key)` where `T : struct` | not found, struct key (e.g. `Guid`, `int`) |
| `Result.NotFound<T>(T key, string message)` where `T : struct` | not found, struct key + message |
| `Result.NotAllowed()` | failure — `NALLIAN-NOT-ALLOWED` |
| `Result.UnAuthorized()` | failure — `NALLIAN-UNAUTHORIZED` |
| `Result.Conflict(string message)` | failure — `NALLIAN-CONFLICT` |
| `Result.VersionConflict(string key)` | conflict, message `"Version conflict: {key}"` |
| `Result.VersionConflict<T>(T key)` where `T : struct` | version conflict, struct key |
| `Result.ValidationFailure(string key, string error)` | failure — `NALLIAN-VALIDATION-ERROR` |
| `Result.ValidationFailure(string key, params string[] errors)` | validation failure, many errors |
| `Result.Exception(Exception exception)` | failure — `NALLIAN-UNEXPECTED-ERROR` |
| `Result.FromValidationResult(ValidationResult validationResult)` | maps FluentValidation result to validation errors |

Fluent helper (extension method): `result.WithValidationFailure(key, error)` /
`result.WithValidationFailure(key, params errors)` — append a validation error to an existing result.

## Error types and their codes

Each factory above produces an `IError` of one of these classes. Match on `ErrorCode` (string
constants on `ErrorCodes`), not on the concrete type:

| `IError` class | `ErrorCode` constant | Value |
|----------------|----------------------|-------|
| `NotFoundError` | `ErrorCodes.NotFound` | `NALLIAN-NOT-FOUND` |
| `ConflictError` | `ErrorCodes.Conflict` | `NALLIAN-CONFLICT` |
| `ConcurrencyError` | `ErrorCodes.Concurrency` | `NALLIAN-CONCURRENCY` |
| `UnAuthorizedError` | `ErrorCodes.UnAuthorized` | `NALLIAN-UNAUTHORIZED` |
| `NotAllowedError` | `ErrorCodes.NotAllowed` | `NALLIAN-NOT-ALLOWED` |
| `ValidationFailureError` | `ErrorCodes.ValidationFailure` | `NALLIAN-VALIDATION-ERROR` |
| `ExceptionError` | `ErrorCodes.Exception` | `NALLIAN-UNEXPECTED-ERROR` |

## Consuming a result

`Result` implements `IResultBase`; `Result<TValue>` implements `IResult<TValue>`:

```csharp
result.IsSuccess        // bool
result.IsFailed         // bool
result.Errors           // List<IError>  (empty when successful)
typedResult.Value       // TValue — THROWS if the result is failed
typedResult.ValueOrDefault  // TValue — default(TValue) if failed, no throw
```

Each `IError` exposes `ErrorCode` (string) and `Message` (string). Branch on the code:

```csharp
if (result.IsFailed)
{
    var error = result.Errors[0];
    return error.ErrorCode switch
    {
        ErrorCodes.NotFound      => /* 404 */,
        ErrorCodes.UnAuthorized  => /* 401 */,
        ErrorCodes.Conflict      => /* 409 */,
        _                        => /* 500, use error.Message */,
    };
}
```

## Anything beyond this page

For the reason/metadata system (`WithError`, `WithReasons`, `WithSuccess`), `ToResult<T>` mapping,
or other `Nallian.Common` types, fall back to the procedure in
[extensions.md](extensions.md) and read the source under `src/Nallian.Common/`.
