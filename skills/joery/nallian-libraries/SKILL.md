---
name: nallian-libraries
description: >
  Look up any Nallian.* type or member you can't fully resolve in this repo — its
  definition, signature, factory methods, or usage. Covers symbols from a Nallian.*
  namespace not defined in this project, members of a type already used here (e.g.
  Result's factory methods: Result.NotFound, Result.Conflict, Result.UnAuthorized),
  the Notification Center SDK, and the Organisation Data API SDK. If you are about to
  run strings, decompile a DLL, or grep ~/.nuget/packages to find a Nallian.* symbol,
  stop and use this instead.
argument-hint: <library-name, "notification-center", or "organisation-sdk">
---

# Nallian Library Lookup

**Query**: $ARGUMENTS

## Routing

Based on the query, determine which reference to load. Load **only one**.

| Query matches | Reference file |
|---------------|----------------|
| "notification-center", "notification", `INotificationCenter`, `NotificationRequest`, receivers, audiences, `IEmailable`, `ISmsable`, `IFeedable` | [references/notification-center.md](references/notification-center.md) |
| `Result`, `Result.Ok`, `Result.NotFound`, `Result.Conflict`, `Result.UnAuthorized`, `FluentResult(s)`, error codes, `IError`, "which factory methods / error types does Result expose" | [references/fluent-result.md](references/fluent-result.md) — **content cheat-sheet, answer is on the page** |
| Other `Nallian.Common` surfaces (common exceptions, `Helper.SqlGuid`, reason/metadata system) | [references/extensions.md](references/extensions.md) (look up `Nallian.Common`) — see also [references/library-index.md](references/library-index.md) |
| "organisation-sdk", "org-sdk", `IOrganisationApi`, `OrganisationApiOptions`, consuming the Organisation Data API from another app | [references/organisation-sdk.md](references/organisation-sdk.md) |
| Any other `Nallian.*` namespace, type, or library name | [references/extensions.md](references/extensions.md) — also consult [references/library-index.md](references/library-index.md) to identify the library |

If no specific library was requested, consult [references/library-index.md](references/library-index.md) and ask the user which library they want to learn about.
