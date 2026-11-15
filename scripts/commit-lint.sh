#!/bin/sh
# Checks that the subjects of the commits in a range follow Conventional
# Commits. Usage: commit-lint.sh <base> <head>
set -eu
base="$1"; head="$2"
pattern='^(feat|fix|docs|style|refactor|perf|test|build|ci|chore|revert)(\([a-z0-9._/-]+\))?!?: .+'
bad=0
# A base of all zeros means a new branch: check only the head commit.
case "$base" in *[!0]*) range="$base..$head" ;; *) range="$head~1..$head" ;; esac
for sha in $(git rev-list --no-merges "$range" 2>/dev/null || git rev-list --no-merges -n 1 "$head"); do
    subject="$(git log -1 --format=%s "$sha")"
    if ! printf '%s\n' "$subject" | grep -Eq "$pattern"; then
        echo "not a conventional commit: $(printf '%.7s' "$sha") $subject" >&2
        bad=1
    fi
done
exit "$bad"
