# Nallian Extensions Lookup

## Dynamic Context

Before starting, determine the context by running these checks yourself:

1. **Local clone available?** — Check if `~/nalcode/Nallian.Extensions/` exists (use Glob or Bash `ls`)
2. **Installed version** — Find the version of any `Nallian.*` package (exclude `Nallian.*Sdk` packages,
   those are project-specific). All Nallian.Extensions packages share the same version. Check in order:
   - `Directory.Packages.props` (if central package management is used)
   - `*.csproj` files (grep for `Nallian.` PackageReference entries)
3. **Local clone version** — If the clone exists, run `git -C ~/nalcode/Nallian.Extensions describe --tags`
   to see what version it's on

## Lookup Strategy

Follow this fallback chain in order. Stop as soon as you find the information you need.

### 1. Local Clone (preferred)

If the local clone exists at `~/nalcode/Nallian.Extensions/`:

1. **Version check**: Compare the installed version (from Dynamic Context above) with the local
   clone version. If they differ significantly, warn the user. To find the matching tag:
   ```
   git -C ~/nalcode/Nallian.Extensions tag | grep <installed-version>
   ```
   If you need to read files at a specific version without modifying the clone, use:
   ```
   git -C ~/nalcode/Nallian.Extensions show <tag>:<relative-path>
   ```
   **Do NOT checkout a different branch or tag** — the developer may have uncommitted work.

2. **Find the library** by consulting `library-index.md` or searching:
   - Source code: `~/nalcode/Nallian.Extensions/src/<LibraryName>/`
   - Documentation (markdown): `~/nalcode/Nallian.Extensions/docs/packages/<LibraryName>/`
   - Tests: `~/nalcode/Nallian.Extensions/tests/` (search for matching test projects)
   - Samples: `~/nalcode/Nallian.Extensions/samples/`

3. **Read the key files**:
   - DI registration: look for `Add*` or `Use*` extension methods in `ServiceCollectionExtensions.cs`
     or similar files
   - Public interfaces and abstractions (especially in `.Abstractions` companion projects)
   - Configuration options classes
   - The package's doc markdown files

4. **Check samples**: The `samples/` directory contains complete working examples for most libraries.
   Sample projects follow the naming convention `Nallian.<LibraryName>.Sample*` or
   `Nallian.<LibraryName>.Test*`. These are the best place to see end-to-end usage including
   DI registration in `Program.cs`, configuration in `appsettings.json`, and actual API/service usage.
   Key samples per library area:
   - **API/SDK**: `Nallian.Api.Common.Sample`, `Nallian.Api.Common.Sample.Sdk`
   - **Azure Blob**: `Nallian.BlobStorage.Sample.Api`
   - **Azure Queues**: `Nallian.AzureQueues.Sample`, `Nallian.AzureQueues.Outbox`
   - **Cache**: `Nallian.Cache.Api`
   - **Data/Audit**: `Nallian.Data.Audit.Sample`, `Nallian.Data.Audit.Sample.Api`
   - **Logging/Monitoring**: `Nallian.Logging.TestApi`, `Nallian.Monitoring.Sample.Api`
   - **Quartz**: `Nallian.Quartz.Single.Sample`, `Nallian.Quartz.Distributed.Sample`
   - **Security**: `Nallian.Security.New.Test.Api`, `Nallian.Security.Test.Api`
   - **Service Bus**: `Nallian.ServiceBus.Sample`
   - **SMTP**: `Nallian.Smtp.Sample.Api`
   - **DataProtection**: `Nallian.DataProtection.TestApi`
   - **Availability**: `Nallian.Extensions.Availability.Sample`

### 2. Online Documentation

If no local clone is available, fetch from `https://extensions.nallian.dev/`:

| Content | URL Pattern |
|---------|-------------|
| Package documentation | `https://extensions.nallian.dev/packages/<LibraryName>/index.html` |
| Upgrading guides | `https://extensions.nallian.dev/upgrading/index.html` |
| Changelog | `https://extensions.nallian.dev/CHANGELOG.html` |
| API reference | `https://extensions.nallian.dev/api/<Namespace>.html` |

Some packages have sub-pages linked from their index (e.g. `implementation.html`, `domain-events.html`).
Start from the package index page and follow links to discover them.

If you get a **403 error**, tell the user:
> The Nallian Extensions documentation site requires VPN access. Please connect to the VPN and try again.

### 3. Suggest Cloning

If neither source is available, suggest the user clone the repository **outside** of the current project:

- **HTTPS**: `git clone https://nallian@dev.azure.com/nallian/Alfa-Scrum/_git/Nallian.Extensions ~/nalcode/Nallian.Extensions`
- **SSH**: `git clone git@ssh.dev.azure.com:v3/nallian/Alfa-Scrum/Nallian.Extensions ~/nalcode/Nallian.Extensions`

After cloning, checkout the tag matching the installed version and retry.

## What to Report

When investigating a library, gather and summarize:

1. **Purpose** — What problem does it solve? (1-2 sentences)
2. **Registration** — How to add it to DI (`services.AddNallian...()`)
3. **Configuration** — Required settings (config section names, keys)
4. **Key interfaces** — The main abstractions the consuming project interacts with
5. **Usage examples** — From the current project first (grep for existing usage), then from
   samples/tests in Extensions

## Also Check Current Project Usage

Before reporting, always search the current project for existing usage of the library:
```
Grep for the library's namespace or key types in the current codebase
```
This gives the most relevant, project-specific examples of how the library is already used.
