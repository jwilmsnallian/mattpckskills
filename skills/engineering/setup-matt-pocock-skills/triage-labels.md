# Triage Labels

The skills speak in terms of eight canonical triage roles. This file maps those roles to the actual label strings used in this repo's issue tracker.

| Label in mattpocock/skills | Label in our tracker | Meaning                                  |
| -------------------------- | -------------------- | ---------------------------------------- |
| `needs-triage`             | `needs-triage`       | Maintainer needs to evaluate this issue  |
| `needs-info`               | `needs-info`         | Waiting on reporter for more information |
| `ready-for-agent`          | `ready-for-agent`    | Fully specified, ready for an AFK agent  |
| `ready-for-human`          | `ready-for-human`    | Requires human implementation            |
| `paused`                   | `paused`             | Specified, but blocked until a prerequisite closes |
| `in-progress`              | `in-progress`        | An agent or human has started implementing it |
| `done`                     | `done`               | Implemented and verified — terminal      |
| `wontfix`                  | `wontfix`            | Will not be actioned                     |

When a skill mentions a role (e.g. "apply the AFK-ready triage label"), use the corresponding label string from this table.

`done` is the terminal "it's built" state. On trackers with a real open/closed bit (GitHub, GitLab), represent `done` by **closing the issue** rather than applying a `done` label — closed *is* the done signal. On local-markdown (no open/closed bit), `done` is the `Status:` value, which is the authoritative done signal for that tracker.

Edit the right-hand column to match whatever vocabulary you actually use.
