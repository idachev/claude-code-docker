#!/bin/bash
set -e

# Minimum version floor. The next computed version will never go below this.
# Bump this when starting a new MAJOR.MINOR series (e.g. 0.2.x -> 0.3.0).
# Override at runtime with: MIN_VERSION=0.4.0 ./scripts/get-next-version.sh
MIN_VERSION="${MIN_VERSION:-0.3.0}"

LATEST_TAG=$(git tag --list --sort=-version:refname | head -1)
if [ -z "$LATEST_TAG" ]; then
  LATEST_TAG="v0.1.0"
fi

echo "Latest tag: $LATEST_TAG"

VERSION=${LATEST_TAG#v}
IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"
PATCH=$((PATCH + 1))

# Apply the floor: if the computed version is below MIN_VERSION, snap to it.
IFS='.' read -r MIN_MAJOR MIN_MINOR MIN_PATCH <<< "$MIN_VERSION"
BELOW_FLOOR=0
if [ "$MAJOR" -lt "$MIN_MAJOR" ]; then
  BELOW_FLOOR=1
elif [ "$MAJOR" -eq "$MIN_MAJOR" ] && [ "$MINOR" -lt "$MIN_MINOR" ]; then
  BELOW_FLOOR=1
elif [ "$MAJOR" -eq "$MIN_MAJOR" ] && [ "$MINOR" -eq "$MIN_MINOR" ] && [ "$PATCH" -lt "$MIN_PATCH" ]; then
  BELOW_FLOOR=1
fi
if [ "$BELOW_FLOOR" = "1" ]; then
  echo "Computed $MAJOR.$MINOR.$PATCH is below floor $MIN_VERSION; snapping to floor."
  MAJOR="$MIN_MAJOR"
  MINOR="$MIN_MINOR"
  PATCH="$MIN_PATCH"
fi

NEW_VERSION="$MAJOR.$MINOR.$PATCH"
NEW_TAG="v$NEW_VERSION"

echo "New version: $NEW_VERSION"
echo "New tag: $NEW_TAG"

if [ -n "$GITHUB_OUTPUT" ]; then
  echo "version=$NEW_VERSION" >> $GITHUB_OUTPUT
  echo "tag=$NEW_TAG" >> $GITHUB_OUTPUT
fi

echo "NEW_VERSION=$NEW_VERSION"
echo "NEW_TAG=$NEW_TAG"