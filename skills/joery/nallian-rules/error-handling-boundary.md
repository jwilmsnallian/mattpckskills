---
paths:
  - "**/Program.cs"
  - "**/*ExceptionHandler*.cs"
  - "**/*Middleware*.cs"
  - "**/*Controller.cs"
  - "**/Tools/*.cs"
  - "**/*Mcp*.cs"
---

# Error boundary (entry points only)

The single catch site for a request. Core principles are in `00-core.md`.

## HTTP — custom `IExceptionHandler` → RFC 7807 `ProblemDetails`
- **Development**: include exception type, message, stack trace.
- **Production**: `traceId` only in the body; log the full exception with structured properties under
  the same trace id. The user always gets an id to quote in a ticket.
- `OperationCanceledException` from a client disconnect → 499 / framework default; do **not** log as 500.
- Transient infra (DB down, upstream 503) → 503 with `Retry-After`.

## MCP
Same Dev-verbose / Prod-sanitized split, but emit the **MCP-protocol error shape**, not
`ProblemDetails`. A shared translation *helper* is fine; a shared *response shape* across HTTP and MCP
is not.

## Correlation
- Scope `Activity.Current?.TraceId` (W3C 32-hex — not `RootId`) into the logger at the entry point so
  every line for the request carries it; emit the **same** id in
  `ProblemDetails.Extensions["traceId"]`. The two must be byte-identical.
- Skip the scope if your sink already enriches TraceId (App Insights direct does; stdout→K8s does not).
- Don't stamp fields the SDK already enriches (`TraceId`, `operation_Id`, `cloud_RoleName`, path).
