#!/bin/bash
set -e

echo "Building all packages..."

cd packages/atuin
./build.sh
cd ../..

cd packages/chezmoi  
./build.sh
cd ../..

rm -rf slackware64/packages/install || true

echo "Updating repository metadata..."
./scripts/update-repo.sh

echo "All packages built successfully!"
echo ""
echo "To test locally:"
echo "  cd slackware64/packages"
echo "  python3 -m http.server 8000"
echo ""
echo "Repository structure:"
find slackware64/packages -type f -exec ls -lh {} \;
