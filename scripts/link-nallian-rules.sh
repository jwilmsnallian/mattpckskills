#!/usr/bin/env bash
set -euo pipefail

# Symlinks the shared Nallian .NET rules into a target repo's .claude/rules/,
# so they load natively in Claude Code. Run once per repo (existing or new).
#
#   scripts/link-nallian-rules.sh /path/to/a/nallian/repo
#
# Edits to skills/joery/nallian-rules/ then propagate to every linked repo.

REPO="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$REPO/skills/joery/nallian-rules"

if [ "$#" -ne 1 ]; then
  echo "usage: $(basename "$0") <target-repo-dir>" >&2
  exit 2
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "error: target '$TARGET' is not a directory" >&2
  exit 1
fi
if [ ! -d "$SRC" ]; then
  echo "error: source rules dir not found at $SRC" >&2
  exit 1
fi

mkdir -p "$TARGET/.claude/rules"
LINK="$TARGET/.claude/rules/nallian"

# Refuse to clobber a real directory; only (re)create our own symlink.
if [ -e "$LINK" ] && [ ! -L "$LINK" ]; then
  echo "error: $LINK exists and is not a symlink — refusing to overwrite" >&2
  exit 1
fi

ln -sfn "$SRC" "$LINK"
echo "linked $LINK -> $SRC"
