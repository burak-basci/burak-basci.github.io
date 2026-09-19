#!/usr/bin/env bash
# Build the site and publish it to GitHub Pages.
#
# Layout of this repository:
#   source  - the Flutter project (this branch)
#   main    - the built site, served by GitHub Pages as www.burakbasci.de
#
# The script builds `web/` into build/web, copies the result onto a detached
# checkout of origin/main (everything except .git and CNAME is replaced, so
# stale files disappear), commits with a reference to the source commit and
# pushes. Requires a clean working tree and the Flutter version from
# .github/workflows/main.yml.
#
#   tools/deploy.sh                  # message = subject of HEAD
#   tools/deploy.sh "deploy: ..."    # custom message
set -euo pipefail

cd "$(dirname "$0")/.."
if [ -n "$(git status --porcelain)" ]; then
  echo "working tree is not clean - commit or stash first" >&2
  exit 1
fi

src_sha=$(git rev-parse --short HEAD)
src_branch=$(git rev-parse --abbrev-ref HEAD)
msg=${1:-"deploy: $(git log -1 --format=%s)"}

flutter build web --release
[ -f build/web/index.html ] || { echo "build/web/index.html missing" >&2; exit 1; }

git fetch -q origin main
wt=$(mktemp -d)
trap 'git worktree remove --force "$wt" 2>/dev/null || true' EXIT
git worktree add -q --detach "$wt" origin/main

rsync -a --delete --exclude .git --exclude CNAME build/web/ "$wt"/
git -C "$wt" add -A
if git -C "$wt" diff --cached --quiet; then
  echo "nothing to deploy - main already matches the build"
  exit 0
fi
git -C "$wt" commit -q -m "$msg" -m "Source: $src_sha on $src_branch."
git -C "$wt" push origin HEAD:main
echo "deployed $src_sha -> main ($(git -C "$wt" rev-parse --short HEAD))"
