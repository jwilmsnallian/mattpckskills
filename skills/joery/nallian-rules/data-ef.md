---
paths:
  - "**/*DbContext.cs"
  - "**/Migrations/**"
  - "**/Data/**/*.cs"
  - "**/*Repository.cs"
  - "**/*UnitOfWork.cs"
---

# Data access & EF Core

## EF Core
- **`ValueGeneratedNever()` for every manually-assigned GUID key.** Omit it and EF emits UPDATE
  instead of INSERT — a silent, hard-to-find bug.

  ```csharp
  // in IEntityTypeConfiguration<Release>.Configure(builder)
  builder.HasKey(x => x.Id);
  builder.Property(x => x.Id).ValueGeneratedNever(); // we assign Ids via IGuidFactory, not the DB
  ```
- Generate keys with your `IGuidFactory` port (SQL-sequential GUIDs; the adapter delegates to
  `Nallian.Common.Helper.SqlGuid(...)`) to avoid clustered-index fragmentation.
- Global UTC `DateTime` value converters in `ConfigureConventions`; enums via `HasConversion<int>()`.
- One `IEntityTypeConfiguration<T>` per entity. Index FK columns; composite indexes for common queries.
- Reads use `AsNoTracking()`. Multiple independent includes use `AsSplitQuery()`. No lazy loading —
  explicit `Include()`.

## Repositories (when the project has them)
- Never expose `IQueryable<T>` — return concrete `List<T>` / `T`.
- Domain-specific methods per aggregate. No generic `IRepository<T>` / `GetAll()`.
- Separate read/write repository interfaces; `AsNoTracking()` in read repos.

## Unit of Work (when present)
- One domain-specific `IUnitOfWork` per bounded context — no generic UoW. It exposes
  `SaveChangesAsync` **only**; it does NOT expose repositories. Inject repos and the UoW separately.
  `SaveChangesAsync` is the sole transaction boundary.

## Migrations
- **Never migrate at app startup** — a dedicated migrator (e.g. an `UpgradeDb` console app) applies them.
- Adding a non-nullable column: add nullable → backfill with inline SQL in `Up()` → alter to
  non-nullable. Never in one step without a server-side default.
- Keep transformation SQL inline in `Up()` so intent is review-visible. Organize migrations by schema
  to isolate bounded contexts.
