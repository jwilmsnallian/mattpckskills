# Nallian shared .NET rules

Single source of truth for the **transferable** Nallian .NET/React coding conventions. Each Nallian
repo symlinks this directory into its own `.claude/rules/` so the rules load natively in Claude Code.

## How loading works (and why it scales with project complexity)

Claude Code loads `.claude/rules/*.md` natively:

- A rule **without** `paths:` front-matter loads every session. Only `00-core.md` is like this — the
  handful of conventions that hold for any C# project.
- A rule **with** `paths:` loads only when Claude reads a file matching one of its globs.

The globs match by **file nature, not location** (`**/*DbContext.cs`, `**/*Controller.cs`,
`**/*UseCase.cs`, …), so they work regardless of a repo's folder layout — and a rule only loads when
the project actually contains that kind of file. A flat MCP service with no `*Controller.cs` /
`*UseCase.cs` never loads the clean-architecture rules; a layered API does. **Complexity is read from
which file-shapes exist**, not guessed by the agent.

| File | Loads when |
|---|---|
| `00-core.md` | always |
| `error-handling-boundary.md` | touching entry points (`Program.cs`, handlers, controllers, MCP) |
| `data-ef.md` | touching `*DbContext.cs`, `Migrations/`, `Data/`, repos, UoW |
| `controllers.md` | touching `*Controller.cs` |
| `application-usecases.md` | touching `*UseCase.cs`, `Application/`, mappers, validators |
| `mcp-tools.md` | touching `Tools/`, `*Mcp*` |
| `frontend.md` | touching `*.ts` / `*.tsx` |
| `testing.md` | touching `*Tests.cs`, `tests/` |
| `integration-tests.md` | touching `*IntegrationTests/`, `EndToEnd/`, `*E2ETests/` |

## What is NOT here

Project-specific rules (domain quirks, this app's auth model, named layers, app-specific services)
stay in each repo's own `.claude/rules/`. This set is only the conventions that transfer across
Nallian .NET projects.

## Bootstrap a repo

From the skills repo:

```bash
scripts/link-nallian-rules.sh /path/to/a/nallian/repo
```

This symlinks this directory to `<repo>/.claude/rules/nallian`. Run it once per repo (existing or
new). Edits here then propagate to every linked repo automatically.
