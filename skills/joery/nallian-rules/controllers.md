---
paths:
  - "**/*Controller.cs"
---

# Controllers & REST

- **Thin**: delegate to use cases, no logic. **No try-catch** — domain failures go via `Result<T>` →
  `Failure(result)` (check `result.IsFailed` first); infra/invariant exceptions bubble to the global
  handler. No null-checks (DI guarantees non-null).
- Authorize with attributes (e.g. `[RequiresRight]`), not inline role-string comparisons or
  policy-string literals.

## REST surface
- Plural, kebab-case, lowercase resource names; no CRUD verbs in URIs; sub-resources nested; custom
  actions as POST (`.../{id}/retry`). URL-path versioning (`v1/...`).
- Empty collection → `200` + `[]`, never `404`. Paging via `X-Paging-*` response headers. Complex
  filters → `POST .../search`, not a long query string.
