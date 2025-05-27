#!/bin/bash
set -e

# Get latest version from GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/atuinsh/atuin/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')

echo "Building Atuin version: $LATEST_VERSION"

# Build the package (no need to modify the SlackBuild)
VERSION=$LATEST_VERSION ./atuin.SlackBuild

# Move package to repository
mkdir -p ../../slackware64/packages

echo "Atuin $LATEST_VERSION built successfully"