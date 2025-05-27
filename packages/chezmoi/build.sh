#!/bin/bash
set -e

# Get latest version from GitHub API
LATEST_VERSION=$(curl -s https://api.github.com/repos/twpayne/chezmoi/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/v//')

echo "Building Chezmoi version: $LATEST_VERSION"

# Build the package (no need to modify the SlackBuild)
VERSION=$LATEST_VERSION ./chezmoi.SlackBuild

# Move package to repository
mkdir -p ../../slackware64/packages

echo "Chezmoi $LATEST_VERSION built successfully"