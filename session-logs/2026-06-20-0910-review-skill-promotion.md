# Session — 2026-06-20-0910
_Written: 2026-06-20 09:10_

1. **User asked about two `.scratch` issue folders in `nallian-sqlreporting-mcp`** — `code-review-fixes/` (13 bug-hunt issues from `/dotnet-code-review`) vs `tool-result-envelope/` (4 ADR-0001 refactor issues). Wanted my opinion + pushback on whether separate folders are correct and which to work next. I reconstructed the git timeline: the envelope refactor predates the code review (it's a deliberate ADR-driven feature, already partly built — envelope issues 01+02 committed), so the review did NOT spawn it. Verdict: keep folders separate (different work types: planned refactor vs defect remediation), but the real risk is unmanaged overlap — ~4-5 bug fixes rewrite the same tool methods the envelope conversion rewrites. Pushed back that "first list OR code-review fixes" is a false binary; it's a sequencing problem. Recommended: decoupled security fixes now → finish envelope conversions → coupled tool-body fixes last.

2. **User: yes add Blocked-by/overlaps notes to coupled issues; also asked whether to scope code review to changed code + check all issue items are handled (like `in-progress/review`)** — Added explicit cross-folder *Blocked by / overlaps* sections to code-review-fixes issues 01, 05, 08 (pointing at envelope issues 03/04), and expanded the `code-review-fixes/README.md` with the 3-step ordering. Answered the scoping question: don't bolt diff-scoping onto `dotnet-code-review` (it's a whole-codebase audit by design); use a separate per-issue gate — exactly what `review` does (Spec axis = acceptance-criteria coverage, scoped to the diff). Flagged `review` was unshipped (`in-progress/`, `internal:true`) and that a clean read ≠ proven (must also run tests).

3. **User: promote `review`, make it accept the issue path as spec, goal is `/implement` works, and make it available in home folder** — Done. `git mv` review to `engineering/`; dropped `internal:true` (now model-invoked so user-invoked `/implement` can call it); made caller/user-supplied issue path the first-priority spec source with per-checkbox completion check; wired `/implement` to capture base commit then run `/review` against it with the issue path as spec before declaring done; registered in plugin.json + both READMEs; re-ran `link-skills.sh` (symlinked to `~/.claude/skills/review`). Flagged pre-existing drift: 4 `misc/` skills missing from plugin.json (left untouched).

4. **User: just commit on main, all uncommitted** — Committed everything in one commit `36526dd` (incl. a pre-existing unrelated `resume-handoff` tweak, noted in the message). Working tree clean, not pushed.

## Current state
- All work committed on `main` as `36526dd` ("feat(skills): promote review to engineering, wire into /implement"). Working tree clean. NOT pushed to origin.
- `review` skill is shipped in `engineering/`, model-invoked, registered everywhere, symlinked into `~/.claude/skills/`.
- `/implement` now ends with a `/review` spec-coverage gate.
- `nallian-sqlreporting-mcp/.scratch` edits (issues 01/05/08 + README) were made in that OTHER repo and are NOT part of this commit — they live in `/Users/joery/gitbase/nallian-sqlreporting-mcp` and are uncommitted there.

## Next steps
- OPEN: 4 unregistered `misc/` skills (`git-guardrails-claude-code`, `migrate-to-shoehorn`, `scaffold-exercises`, `setup-pre-commit`) missing from `plugin.json` — pre-existing drift, user hasn't decided register-vs-move. I offered to handle next.
- Optional: push `main` to origin (user hasn't asked).
- The `.scratch` issue-file edits in `nallian-sqlreporting-mcp` are uncommitted in that repo.

## Decisions made
- Keep `code-review-fixes/` and `tool-result-envelope/` as separate folders — different work categories (defect remediation vs planned ADR refactor), preserves audit trail.
- Sequencing over either/or: decoupled security fixes → envelope conversions → coupled tool-body fixes.
- `review` made model-invoked (not user-invoked) specifically so `/implement` (user-invoked) can invoke it — per `docs/invocation.md` rule.
- Diff-scoping handled by construction (review diffs HEAD vs a base point); `/implement` supplies the correct base. Did NOT add auto-detection of "code this issue changed" (guesswork).

## Files touched (this repo, mattpckskills)
- `skills/engineering/review/SKILL.md` — moved from `in-progress/`; dropped internal:true; issue-path-as-spec + per-checkbox completion check.
- `skills/engineering/implement/SKILL.md` — capture base commit, run /review with issue path as spec before done.
- `.claude-plugin/plugin.json` — registered `./skills/engineering/review`.
- `README.md` + `skills/engineering/README.md` — added review under Model-invoked.
- `skills/productivity/resume-handoff/SKILL.md` — pre-existing tweak (temp-dir fallback), committed along.

## Files touched (other repo, nallian-sqlreporting-mcp — uncommitted there)
- `.scratch/code-review-fixes/issues/{01,05,08}-*.md` — added Blocked-by/overlaps cross-folder notes.
- `.scratch/code-review-fixes/README.md` — added 3-step ordering vs envelope refactor.
