---
name: implement
description: "Implement a piece of work based on a PRD or set of issues."
disable-model-invocation: true
---

Implement the work described by the user in the PRD or issues.

Before changing anything, note the current commit (`git rev-parse HEAD`) — this is the base the final review diffs against. If you're working a specific issue/PRD file (e.g. `.scratch/<feature>/issues/NN-*.md`), keep its path; it's the spec.

Use /tdd where possible, at pre-agreed seams.

Run typechecking regularly, single test files regularly, and the full test suite once at the end.

Once the work passes, use /code-review to review it for bugs.

In a .NET codebase, make it a .NET review of the code you changed — scan for swallowed exceptions and dropped error results, missing `CancellationToken` / unobserved async, EF Core data-integrity and concurrency bugs, undisposed resources, unvalidated input, and leaked configuration or secrets.

Commit your work to the current branch.

Then run /review against the base commit you noted, passing the issue/PRD path as the spec source — this confirms the change follows the repo's standards (Standards axis) and fully implements the spec, walking every acceptance criterion (Spec axis), scoped to just your diff. Address anything it reports as missing or partial, then commit the follow-up. Don't consider the work done until the Spec axis is clean.
