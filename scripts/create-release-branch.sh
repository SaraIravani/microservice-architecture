#!/usr/bin/env bash

set -e

BUMP_TYPE=$1

git checkout master
git pull
npm install

CURRENT_BRANCH="$(git symbolic-ref --short -q HEAD)"

success() {
  echo -e "\033[32;1m$1"
}

error() {
  echo -e "\033[31;1m$1"
}

if [ -z "$CURRENT_BRANCH" ]; then
  error "Not in a branch. Stopping release."
  exit 1
fi

if [ -z "$BUMP_TYPE" ]; then
  echo "Grabbing recommended bump type..."
  BUMP_TYPE="$(node_modules/.bin/conventional-recommended-bump -p angular)"
fi

if [ -z "$BUMP_TYPE" ]; then
  error "Unable to set the type of version bump"
  exit 1
fi

echo "==> Bumping version"
VERSION="$(npm version --no-git-tag-version $BUMP_TYPE | sed 's/v//g')"

echo "==> Updating Changelog"
node_modules/.bin/conventional-changelog -i CHANGELOG.md -o CHANGELOG.md -p angular

echo "==> Cleaning Build directory"
rm -rf ./dist

echo "==> Creating build files"
npm run build

echo "==> Committing changes"

git checkout -b "release-$VERSION"
git add --all
git commit --message "chore(release): adding $VERSION"
git push --set-upstream origin "release-$VERSION"

success "release-$VERSION branch has been pushed"