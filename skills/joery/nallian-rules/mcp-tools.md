---
paths:
  - "**/Tools/*.cs"
  - "**/*McpTool*.cs"
  - "**/*Mcp*.cs"
---

# MCP tools

- An MCP tool is a **thin boundary**, like a controller: delegate to use cases/services, enforce input
  length limits, audit-log the call, no business logic.
- Errors → **MCP-protocol error shape** (Dev-verbose / Prod-sanitized), not HTTP `ProblemDetails`
  (see `error-handling-boundary.md`).
- The server should be disableable per environment via a config flag.
- Auth is typically Azure AD OAuth (single-tenant) and/or personal API tokens validated by DB hash
  lookup with role claims. Keep token semantics documented next to the auth code.
