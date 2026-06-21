# Nallian .NET — core conventions (always on)

Applies to every Nallian .NET/C# project. Project-specific rules (domain quirks, this app's auth
model, named layers) live in this repo's own `.claude/rules/`.

## C# language
- Nullable reference types are **enabled** (the .NET default, and what every Nallian repo ships).
  Annotate honestly: `string?` for a genuinely-nullable reference, non-nullable otherwise. Don't
  reach for the null-forgiving `!` to silence a warning you haven't actually reasoned about.
- Initialize collections with `= []`, not `= new()` / `= new List<T>()`.
- **One file per type.** One public class/interface/record/enum per file, file named after the
  type. Don't stack multiple top-level types in one file. (Tightly-coupled exceptions: a type and
  its small private nested helpers, or a `partial` split across generated + hand-written files.)

## Time & identity — never call the ambient APIs
Define your **own** `ISystemClock` and `IGuidFactory` ports in your core and inject them — **never**
`DateTime.UtcNow` / `DateTime.Now` / `Guid.NewGuid()` in entities, services, handlers, or tools
(keeps the core dependency-free and time/ID behaviour testable: advance the clock, assert
deterministic IDs). Implement them in Infrastructure: `IGuidFactory` delegates to
`Nallian.Common.Helper.SqlGuid(...)` for SQL-sequential keys; `ISystemClock` wraps `DateTime.UtcNow`.

## Errors travel — catch once at the edge
- `Result<T>` for **domain outcomes the caller branches on** (not-found, validation, conflict,
  forbidden). **Throw** for invariant violations and infrastructure failures and let them bubble to
  the entry-point boundary (HTTP `IExceptionHandler`, MCP error shape). The use case stays
  exception-transparent — it is *not* the catch site.
- Distinguish **absence vs failure vs forbidden**. Never collapse them into one sentinel
  (`null`, `Guid.Empty`, `[]`, `false`) — the caller must be able to tell what happened.
- The only permitted `catch (Exception)` shape is: perform a **compensating** side-effect (e.g.
  delete an orphaned blob whose row failed to commit) **then rethrow**. Bare log-and-rethrow is not
  it — use a logging scope instead.

  ```csharp
  // ✅ compensate, then rethrow
  try { await _repo.SaveAsync(row, ct); }
  catch (Exception)
  {
      await _blobs.DeleteAsync(blobName, ct); // undo the side-effect the failed row owned
      throw;                                  // let it bubble to the boundary
  }
  // ❌ catch (Exception ex) { _log.LogError(ex, "..."); throw; }  // log-only → use a logging scope
  ```

## Defaults live at boundaries, not in internal signatures
- Allowed only at boundaries: controller/tool query params, `CancellationToken ct = default`, and a
  single config-bind site.
- **Banned** in internal use-case → service → repository signatures (`pageSize = 20`,
  `throwOnError = true`, `sortDirection = "asc"`). The use case decides; lower layers obey.

## Code-review rejects — any of these
- `catch {}` or `catch { return <sentinel>; }`
- `if (x == null) return;` / `continue;` with no log line and no reason
- `?? fallback` on a value from an external call (config is fine)
- `FirstOrDefault()` then using the result with no explicit failure path
- default parameter values in non-boundary signatures
- returning `null` / `Guid.Empty` / `[]` / `false` to signal a failure the caller can't disambiguate
- catching infra exceptions (`SqlException`, `HttpRequestException`, …) below the entry-point boundary
- `DateTime.UtcNow` / `Guid.NewGuid()` outside the clock/guid abstractions
