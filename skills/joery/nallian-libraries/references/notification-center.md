# Nallian Notification Center SDK Lookup

## Dynamic Context

Before starting, determine the context by running these checks yourself:

1. **Local clone available?** — Check if `~/nalcode/Nallian.NotificationCenter/` exists
2. **Installed SDK version** — Find the version of `Nallian.NotificationCenter.Sdk` in
   `Directory.Packages.props` or `*.csproj` files
3. **Matching tag** — If the clone exists, find the matching git tag:
   ```
   git -C ~/nalcode/Nallian.NotificationCenter tag | grep <installed-version>
   ```
   If versions differ significantly, warn the user.
   To read files at a specific version without modifying the clone:
   ```
   git -C ~/nalcode/Nallian.NotificationCenter show <tag>:<relative-path>
   ```
   **Do NOT checkout a different branch or tag** — the developer may have uncommitted work.

## Lookup Strategy

Follow this fallback chain in order. Stop as soon as you find the information you need.

### 1. Local Clone (preferred)

If `~/nalcode/Nallian.NotificationCenter/` exists, read files at the installed version's tag.

**SDK abstractions (consumer API):**

| What | Path |
|------|------|
| INotificationCenter interface | `src/Nallian.NotificationCenter.Sdk.Abstractions/INotificationCenter.cs` |
| NotificationRequest model | `src/Nallian.NotificationCenter.Sdk.Abstractions/NotificationRequest.cs` |
| ProducerContext | `src/Nallian.NotificationCenter.Sdk.Abstractions/ProducerContext.cs` |
| Receivers (Email, SMS, Feed) | `src/Nallian.NotificationCenter.Sdk.Abstractions/Receivers/` |
| Audiences (Principal, Community, Organisation) | `src/Nallian.NotificationCenter.Sdk.Abstractions/Audiences/` |
| DI registration | `src/Nallian.NotificationCenter.Sdk/Extensions/ServiceCollectionExtensions.cs` |
| Validation rules | `src/Nallian.NotificationCenter.Sdk/Validators/` |

**Handler side (how your payload is received):**

| What | Path |
|------|------|
| Handler interfaces (IEmailable, ISmsable, IFeedable) | `src/Nallian.NotificationCenter.BaseModule.Core/Interfaces/` |
| NotificationContext (what the handler receives) | `src/Nallian.NotificationCenter.BaseModule.Core/Models/NotificationContext.cs` |
| Subscription interfaces (ISubscribable, IAutoSubscribable) | `src/Nallian.NotificationCenter.BaseModule.Core/Interfaces/` |
| Example handlers | `modules/TestModule/Handlers/` |

**Documentation in the repo:**

| What | Path |
|------|------|
| Module & handler development guide | `docs/modules.md` |
| SDK v1.0 upgrade guide | `upgrading/version-1.0.md` |

### 2. Current Project Usage

Always search the current project for existing notification patterns:
- Notification type constants (grep for `NotificationTypes`)
- Existing handlers that call `INotificationCenter.SendAsync`
- Payload model definitions
- DI registration (grep for `AddNotificationCenterSdk`)

Existing patterns in the current project are the best guide for consistency.

### 3. Suggest Cloning

If no local clone exists:
- **HTTPS**: `git clone https://nallian@dev.azure.com/nallian/Alfa-Scrum/_git/Nallian.NotificationCenter ~/nalcode/Nallian.NotificationCenter`
- **SSH**: `git clone git@ssh.dev.azure.com:v3/nallian/Alfa-Scrum/Nallian.NotificationCenter ~/nalcode/Nallian.NotificationCenter`

## Quick Reference

### Receiver vs Audience

| | Receiver | Audience |
|---|---------|----------|
| **What** | Explicit recipient with contact details | Group of users resolved by the backend |
| **Delivery** | Always receives the notification | Subscription-based (user can unsubscribe) |
| **Types** | `EmailReceiver`, `SmsReceiver`, `FeedReceiver` | `PrincipalAudience`, `CommunityAudience`, `OrganisationAudience` |
| **Use when** | You know the exact contact (e.g. invite email, password reset) | Notifying a group (e.g. "new join request for community X") |

### Building a NotificationRequest

A request consists of:
- **Type** — string key matching a registered handler (e.g. `"PENDINGINVITATION"`)
- **Context** — `ProducerContext(appTag, appInstallationTag)` with optional `CommunityTag`, `OrganisationId`
- **Version** — notification version for handler matching
- **Receivers** — explicit recipients (always delivered)
- **Audiences** — group recipients (subscription-based)
- **References** — optional key/value pairs for tracking/lookup
- **Payload** — typed object serialized as JSON, deserialized by the handler

### How the handler receives your payload

The handler gets a `NotificationContext` containing:
- `Payload` — your payload as a JSON string (handler deserializes it)
- `Language` — from the receiver or resolved from the audience member
- `TimeZoneInfo` — receiver's timezone
- `CommunityTimeZoneInfo` — community's timezone
- `CommunityTag`, `AppInstallationTag`
- `Version` — from your request

The handler implements channel interfaces to generate output:
- `IEmailable` → `GenerateEmailAsync(context)` → MimeMessage
- `ISmsable` → `GenerateSmsAsync(context)` → string
- `IFeedable` → `GenerateFeedAsync(context)` → FeedItemDto

### Language & timezone

Set `Language` and `TimeZone` on each `Receiver`. For audiences, the backend
resolves these from the user's profile. The handler receives them via
`NotificationContext.Language` and `NotificationContext.TimeZoneInfo`.

## What to Report

1. **How to build the request** — NotificationRequest with correct receivers/audiences
2. **How to define the payload** — what the handler will deserialize
3. **Receiver vs audience choice** — based on the notification scenario
4. **Always** — show matching examples from the current project first
