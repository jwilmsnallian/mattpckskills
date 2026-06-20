# Nallian Organisation Data SDK Lookup

## Dynamic Context

Before starting, determine the context by running these checks yourself:

1. **Local clone available?** — Check if `~/nalcode/Nallian.OrganisationData/` exists
2. **Installed SDK version** — Find the version of `Nallian.OrganisationData.Api.Sdk` in
   `Directory.Packages.props` or `*.csproj` files
3. **Matching tag** — If the clone exists, find the matching git tag:
   ```
   git -C ~/nalcode/Nallian.OrganisationData tag | grep <installed-version>
   ```
   If versions differ significantly, warn the user.
   To read files at a specific version without modifying the clone:
   ```
   git -C ~/nalcode/Nallian.OrganisationData show <tag>:<relative-path>
   ```
   **Do NOT checkout a different branch or tag** — the developer may have uncommitted work.

## Lookup Strategy

Follow this fallback chain in order. Stop as soon as you find the information you need.

### 1. Local Clone (preferred)

If `~/nalcode/Nallian.OrganisationData/` exists, read files at the installed version's tag.

**Public contract:**

| What | Path |
|------|------|
| IOrganisationApi interface | `src/Nallian.OrganisationData.Api.Abstractions/IOrganisationApi.cs` |
| OrganisationApiOptions | `src/Nallian.OrganisationData.Api.Abstractions/OrganisationApiOptions.cs` |
| DI registration | `src/Nallian.OrganisationData.Api.Sdk/Extensions/ServiceCollectionExtensions.cs` |
| Response models/DTOs | `src/Nallian.OrganisationData.Api.Abstractions/Models/` |

**SDK implementation (by domain):**

| Domain | Path |
|--------|------|
| Organisations | `src/Nallian.OrganisationData.Api.Sdk/PartialOrganisations.cs` |
| Communities | `src/Nallian.OrganisationData.Api.Sdk/PartialCommunity.cs` |
| Principals | `src/Nallian.OrganisationData.Api.Sdk/PartialPrincipals.cs` |
| Apps & installations | `src/Nallian.OrganisationData.Api.Sdk/PartialApps.cs` |
| Community apps | `src/Nallian.OrganisationData.Api.Sdk/PartialCommunityApp.cs` |
| Community roles | `src/Nallian.OrganisationData.Api.Sdk/PartialCommunityRoles.cs` |
| Identities | `src/Nallian.OrganisationData.Api.Sdk/PartialIdentities.cs` |
| Identification codes | `src/Nallian.OrganisationData.Api.Sdk/PartialIdentificationCodes.cs` |
| Principal join requests | `src/Nallian.OrganisationData.Api.Sdk/PartialPrincipalJoinRequests.cs` |

**Documentation & examples:**

| What | Path |
|------|------|
| SDK documentation | `docs/Nallian.OrganisationData.Api.Sdk.md` |
| Manual testing examples | `tools/Nallian.OrganisationData.Sdk.ManualTesting/` |

### 2. Current Project Usage

Always search the current project for existing SDK usage:
- Grep for `IOrganisationApi` to find injection and method calls
- Grep for `AddOrganisationSdk` to find DI registration
- Check appsettings for `OrganisationApi` configuration section

Existing patterns in the current project are the best guide for consistency.

### 3. Suggest Cloning

If no local clone exists:
- **HTTPS**: `git clone https://nallian@dev.azure.com/nallian/Alfa-Scrum/_git/Nallian.OrganisationData ~/nalcode/Nallian.OrganisationData`
- **SSH**: `git clone git@ssh.dev.azure.com:v3/nallian/Alfa-Scrum/Nallian.OrganisationData ~/nalcode/Nallian.OrganisationData`

## Quick Reference

### DI setup

```csharp
services.AddOrganisationSdk(configuration);
```

```json
"OrganisationApi": {
  "Uri": "https://platform-pld.nallian.dev/api/organisation"
}
```

### API surface by domain

The SDK is split into partial classes, each covering a domain:
- **Organisations** — list, get by ID, get by app, batch get by IDs
- **Communities** — get by tag or ID, members, notification settings, legal documents
- **Principals** — lookup active principals, get detail, batch get by IDs
- **Apps** — get app/installation by tag or ID, tag-to-ID resolution
- **Community apps** — get community app details, subscription status, installation URLs
- **Community roles** — get role details by community and role tag
- **Identities** — get by ID, batch get by IDs (async enumerable)
- **Identification codes** — lookup orgs by codes, list codes for org
- **Principal join requests** — create join request

### Key patterns

- **Async enumeration** — paginated methods return `IAsyncEnumerable<T>`, streaming results page by page
- **Batch chunking** — methods accepting lists automatically chunk (e.g. 100 per batch for orgs, 50 for users)
- **Tag or ID** — many methods have overloads accepting either a tag (string) or ID (Guid)
- **Token management** — the SDK handles M2M and client credential tokens via `IAccessTokenService`
- **Error handling** — throws `SdkOperationException` on API errors, returns `null` on 404

## What to Report

1. **How to set up the SDK** — DI registration and configuration
2. **Available methods** — for the domain the user is asking about
3. **Response models** — the DTOs returned by those methods
4. **Always** — show matching examples from the current project first
