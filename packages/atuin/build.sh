#!/bin/bash
set -e

# Get latest version from GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/atuinsh/atuin/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')

REPO_DIR="../../slackware64/packages"
PKG_FILE="$REPO_DIR/atuin-${LATEST_VERSION}-x86_64-1_unRAID.txz"

# Idempotent: skip rebuild if package for latest version already exists
if [ -f "$PKG_FILE" ]; then
  echo "Atuin $LATEST_VERSION already built at $PKG_FILE. Skipping rebuild."
  exit 0
fi

echo "Building Atuin version: $LATEST_VERSION"

# Build the package (no need to modify the SlackBuild)
VERSION=$LATEST_VERSION ./atuin.SlackBuild

# Ensure repository directory exists and move built package if found
mkdir -p "$REPO_DIR"
# Try to find the produced package for this version and move it into the repo
if compgen -G "./atuin-${LATEST_VERSION}-*.txz" > /dev/null; then
  # Prefer x86_64-1_unRAID naming if present
  if [ -f "./atuin-${LATEST_VERSION}-x86_64-1_unRAID.txz" ]; then
    mv -f "./atuin-${LATEST_VERSION}-x86_64-1_unRAID.txz" "$PKG_FILE"
  else
    # Fallback: move the first matching .txz into the repo, keeping its name
    FIRST_MATCH=$(ls -1 "./atuin-${LATEST_VERSION}-"*.txz | head -n 1)
    mv -f "$FIRST_MATCH" "$REPO_DIR/"
  fi
fi

echo "Atuin $LATEST_VERSION built successfully"