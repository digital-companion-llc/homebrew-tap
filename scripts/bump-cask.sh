#!/usr/bin/env bash
# Usage: scripts/bump-cask.sh <cask-name> <owner/repo>
# Rewrites Casks/<cask>.rb to the repo's latest STABLE GitHub release.
# `gh release view` with no tag returns the latest non-prerelease, non-draft
# release, so betas are never picked up. Prints "bumped <version>" or "current".
set -euo pipefail
cask="$1" repo="$2"
file="Casks/${cask}.rb"

tag=$(gh release view --repo "$repo" --json tagName,isPrerelease --jq 'select(.isPrerelease|not)|.tagName')
[[ "$tag" =~ ^v([0-9]+\.[0-9]+\.[0-9]+)$ ]] || { echo "refusing non-stable tag: '$tag'" >&2; exit 1; }
version="${BASH_REMATCH[1]}"

current=$(sed -n 's/^  version "\(.*\)"/\1/p' "$file")
if [[ "$version" == "$current" ]]; then echo "current"; exit 0; fi

# The sha256 comes from the published DMG itself, not from a sidecar file.
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
gh release download "$tag" --repo "$repo" --pattern "*-${version}.dmg" --dir "$tmp"
sha=$(shasum -a 256 "$tmp"/*.dmg | cut -d' ' -f1)

sed -i.bak -E "s/^  version \".*\"/  version \"${version}\"/; s/^  sha256 \".*\"/  sha256 \"${sha}\"/" "$file"
rm -f "$file.bak"
echo "bumped ${version}"
