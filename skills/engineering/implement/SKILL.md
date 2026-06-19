---
name: implement
description: "Implement a piece of work based on a PRD or set of issues."
disable-model-invocation: true
---

Implement the work described by the user in the PRD or issues.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once done, use /code-review to review the work.

In a .NET codebase, make it a .NET review of the code you changed — scan for swallowed exceptions and dropped error results, missing `CancellationToken` / unobserved async, EF Core data-integrity and concurrency bugs, undisposed resources, unvalidated input, and leaked configuration or secrets.

Commit your work to the current branch.
