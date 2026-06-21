---
paths:
  - "**/*UseCase.cs"
  - "**/Application/**"
  - "**/*Mapper.cs"
  - "**/*Validator.cs"
---

# Application layer (use cases)

- **Organize by vertical slice, not by technical layer.** Group code by feature/business capability
  (a folder per slice holding its use cases, DTOs, validators, mappers) rather than by `UseCases/`,
  `Dtos/`, `Validators/` type-buckets. Clean-architecture *dependency* rules still hold (the slice's
  inner types don't depend on web/infra); slicing is about folder layout, not loosened layering. Where
  a framework or existing repo layout forbids it, follow the repo — vertical slicing is the default,
  not an absolute.
- One use case per business operation. **Never call a use case from another** — share via services or
  the domain model. Keep use cases web-agnostic (no `HttpContext`).
- One `SaveChangesAsync` per use case = the single transaction boundary. No null-checks on inputs
  (validated upstream). Extract complex logic into pure helpers/services, not sibling use cases.
- **Command** use cases return IDs/void; **query** use cases return DTOs. After a command, the
  controller calls a separate query to fetch the read model.

## Validation
FluentValidation at the top of execution; `MustAsync` for domain rules (validators may call domain
services).

## Mappers & DTOs
- Mappers are **injectable classes** with a singleton `Instance` and `virtual` methods — NOT static
  `ToDto()` extension methods (so they're mockable/overridable):

  ```csharp
  // ✅ injectable, mockable, overridable
  public class ReleaseMapper
  {
      public static ReleaseMapper Instance { get; } = new();
      public virtual ReleaseDto ToDto(Release r) => new() { Id = r.Id, Name = r.Name };
  }
  // ❌ public static ReleaseDto ToDto(this Release r) => ...   // can't mock/override
  ```
- DTOs are `record`s with `init` setters. Naming taxonomy: `<Model>Reference` (id + label),
  `<Model>Dto` (list shape), `<Model>Detail` (full), `Create<Model>Request`, `Update<Model>Request`,
  `<Model>Query`.
