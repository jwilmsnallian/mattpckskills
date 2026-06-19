# What this repo is

This is **our copy of [`mattpocock/skills`](https://github.com/mattpocock/skills)** (pushed to
`jwilmsnallian/mattpckskills`). On top of Matt's skills we keep two kinds of local work:

1. **Personal skills/scripts** under `skills/joery/` — our own stuff, never pushed upstream.
2. **Edits to existing (shared) skills** — small, well-scoped tweaks to skills that also live upstream.

We periodically pull in new work from two sources:

- **`upstream`** → `mattpocock/skills` — the original.
- **`extended`** → [`erikpr1994/skills-extended`](https://github.com/erikpr1994/skills-extended) — a fork
  that tracks Matt's repo and adds extra skills/refinements. Syncing from `extended` therefore also
  pulls in whatever upstream work Erik has already merged.

**Keep our diff small.** Both sources keep moving, so the cost of our local edits is merge drift. Prefer
minimal changes to shared skills, and when an edit is really just "for us", put it in `skills/joery/`
instead of modifying a shared skill — new files never conflict, edited shared files do.

---

# Updating this repo (sync runbook)

This is a **merge-based** flow (not rebase) so history is preserved and every incoming conflict is
visible before it lands. We `origin` push, but **never push to `upstream` or `extended`** (read-only).

## 0. One-time remote setup (on a fresh clone)

```bash
git remote add upstream git@github.com:mattpocock/skills.git
git remote add extended git@github.com:erikpr1994/skills-extended.git
git remote -v   # expect: origin (mattpckskills), upstream (mattpocock), extended (erikpr1994)
```

In the rest of this runbook, set `SRC` to the source you want — `upstream/main` **or** `extended/main`:

```bash
SRC=upstream/main      # original Matt Pocock
# SRC=extended/main    # Erik's extended fork (also contains the upstream work Erik merged)
```

## 1. Fetch, then preview the impact BEFORE touching your tree

```bash
git fetch upstream extended

# What new commits are coming in?
git log --oneline HEAD..$SRC

# Which files change, and how big is the change?
git diff --stat HEAD..$SRC

# Confirm our personal folder is untouched by the incoming change (should print nothing):
git diff --stat HEAD..$SRC -- skills/joery/

# Which incoming files have WE also modified locally? These are the conflict candidates.
# (intersection of "files they changed" and "files we changed since the common base")
comm -12 \
  <(git diff --name-only $(git merge-base HEAD $SRC)..$SRC | sort) \
  <(git diff --name-only $(git merge-base HEAD $SRC)..HEAD | sort)
```

## 2. Dry-run the merge on a throwaway branch (never merge straight into `main`)

```bash
git switch -c sync/$(echo $SRC | tr '/' '-')   # e.g. sync/upstream-main
git merge --no-commit --no-ff $SRC

git status        # "both modified" lines = real conflicts to resolve
git diff --check   # flags conflict markers / whitespace errors
```

- **Clean (no conflicts):** review `git diff --cached`, then `git commit`.
- **Conflicts:** resolve each file (keep BOTH our intent and theirs), checking that none of our edits
  are silently dropped. Then `git add <file>` and `git commit`.
- **Bail out at any point:** `git merge --abort` — tree returns to exactly where it was.

## 3. Verify the repo is still self-consistent

Every shipped skill must be registered (see Repo conventions below). After a merge, check that the
skill folders and the manifest still agree:

```bash
# Skills registered in the manifest:
grep -o '"\./skills/[^"]*"' .claude-plugin/plugin.json | tr -d '"' | sort > /tmp/registered
# Skill folders that exist in shippable buckets:
ls -d skills/{engineering,productivity,misc}/*/ | sed 's:/$::;s:^:./:' | sort > /tmp/ondisk
diff /tmp/registered /tmp/ondisk   # investigate any difference (new skill to register, or removed one)
```

Run the project's own checks if present (`package.json` scripts), then sanity-check that
`skills/joery/` is intact.

## 4. Land it and push

```bash
git switch main
git merge --no-ff sync/upstream-main    # use the branch name you created in step 2
git push origin main
git branch -d sync/upstream-main         # clean up the throwaway branch
```

---

# Repo conventions

Skills are organized into bucket folders under `skills/`:

- `engineering/` — daily code work
- `productivity/` — daily non-code workflow tools
- `misc/` — kept around but rarely used
- `joery/` — our own personal skills/scripts, not promoted, never pushed upstream
- `personal/` — tied to an individual setup, not promoted
- `in-progress/` — drafts not yet ready to ship
- `deprecated/` — no longer used

Every skill in `engineering/`, `productivity/`, or `misc/` must have a reference in the top-level `README.md` and an entry in `.claude-plugin/plugin.json`. Skills in `joery/`, `personal/`, `in-progress/`, and `deprecated/` must not appear in either — this is also what keeps them out of the way during syncs (folders that don't exist upstream can never conflict).

`scripts/link-skills.sh` symlinks repo skills into `~/.claude/skills/` so they're usable everywhere. It links `engineering/`, `productivity/`, `misc/`, and `joery/`, and **skips** `personal/`, `in-progress/`, and `deprecated/`. Re-run it after adding a new skill.

Each skill entry in the top-level `README.md` must link the skill name to its `SKILL.md`.

Each bucket folder has a `README.md` that lists every skill in the bucket with a one-line description, with the skill name linked to its `SKILL.md`. Bucket `README.md`s and the top-level `README.md` group entries into **User-invoked** and **Model-invoked**.

Every `SKILL.md` is either user-invoked (`disable-model-invocation: true`, reachable only by the human) or model-invoked (model- or user-reachable). For the full definitions, description conventions, and why a user-invoked skill can invoke model-invoked skills but never another user-invoked one, see [docs/invocation.md](./docs/invocation.md).
