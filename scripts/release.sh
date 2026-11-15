#!/bin/sh
# Creates a release from the Conventional Commits since the last final
# release: computes the version, tags the current commit and publishes a
# GitHub release whose notes are the changelog.
#
#   CHANNEL=beta|final   beta appends -beta.N to the upcoming version
#   DRY_RUN=true         print version and changelog, change nothing
#   CLIFF_CONFIG         path to cliff.toml
#
# Run in a full clone (fetch-depth: 0) with all tags. Needs git-cliff, and
# gh with GH_TOKEN unless DRY_RUN=true.
set -eu

CHANNEL="${CHANNEL:-beta}"
DRY_RUN="${DRY_RUN:-false}"
CLIFF_CONFIG="${CLIFF_CONFIG:-cliff.toml}"

case "$CHANNEL" in beta|final) ;; *) echo "CHANNEL must be beta or final" >&2; exit 2 ;; esac

# cliff.toml only recognizes final tags, so the next version and the
# changelog are always relative to the last final release.
cliff() { git-cliff --config "$CLIFF_CONFIG" "$@" 2>/dev/null; }

last="$(git tag --list 'v[0-9]*' --sort=-v:refname | grep -v -- '-beta\.' | head -n 1 || true)"
next="$(cliff --bumped-version)"

if [ -n "$last" ] && [ "$next" = "$last" ]; then
    echo "No feat, fix or breaking commits since $last: nothing to release." >&2
    exit 3
fi

if [ "$CHANNEL" = beta ]; then
    n="$(git tag --list "${next}-beta.*" | wc -l)"
    tag="${next}-beta.$((n + 1))"
else
    tag="$next"
fi

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
    echo "Tag $tag already exists." >&2
    exit 4
fi

notes="$(mktemp)"
cliff --unreleased --tag "$tag" > "$notes"

echo "version: $tag"
echo "--- changelog ---"
cat "$notes"

if [ -n "${GITHUB_OUTPUT:-}" ]; then
    { echo "tag=$tag"; echo "version=${tag#v}"; } >> "$GITHUB_OUTPUT"
fi

[ "$DRY_RUN" = true ] && exit 0

git tag -a "$tag" -F "$notes" --cleanup=verbatim
git push origin "refs/tags/$tag"
if [ "$CHANNEL" = beta ]; then
    gh release create "$tag" --title "$tag" --notes-file "$notes" --prerelease
else
    gh release create "$tag" --title "$tag" --notes-file "$notes"
fi
