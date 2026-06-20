---
name: nallian-libraries
description: >
  Look up Nallian library documentation, source code, and usage patterns.
  Use when you encounter code from a Nallian.* namespace not defined in this project,
  when sending notifications via the Notification Center SDK, or when consuming the
  Organisation Data API SDK. Any type, interface, or extension method under a Nallian.*
  namespace that you cannot find in this repository is most likely provided by one of
  these libraries.
argument-hint: <library-name, "notification-center", or "organisation-sdk">
---

# Nallian Library Lookup

**Query**: $ARGUMENTS

## Routing

Based on the query, determine which reference to load. Load **only one**.

| Query matches | Reference file |
|---------------|----------------|
| "notification-center", "notification", `INotificationCenter`, `NotificationRequest`, receivers, audiences, `IEmailable`, `ISmsable`, `IFeedable` | [references/notification-center.md](references/notification-center.md) |
| "organisation-sdk", "org-sdk", `IOrganisationApi`, `OrganisationApiOptions`, consuming the Organisation Data API from another app | [references/organisation-sdk.md](references/organisation-sdk.md) |
| Any other `Nallian.*` namespace, type, or library name | [references/extensions.md](references/extensions.md) — also consult [references/library-index.md](references/library-index.md) to identify the library |

If no specific library was requested, consult [references/library-index.md](references/library-index.md) and ask the user which library they want to learn about.
