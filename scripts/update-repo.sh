#!/bin/bash
# Repository metadata update script - cross-platform compatible
set -e

REPO_DIR="slackware64/packages"
cd "$REPO_DIR"

# Generate PACKAGES.TXT
echo "Generating PACKAGES.TXT..."
{
  echo "PACKAGES.TXT; $(date)"
  echo ""
  for pkg in *.txz; do
    if [ -f "$pkg" ]; then
      echo "PACKAGE NAME: $pkg"
      echo "PACKAGE LOCATION: ./$pkg"
      
      # Use portable file size detection without stat
      SIZE=$(ls -l "$pkg" | awk '{print $5}')
      echo "PACKAGE SIZE (compressed): $SIZE"
      
      # Calculate uncompressed size safely
      UNCOMPRESSED_SIZE=$(tar -tvf "$pkg" | awk '{sum += $3} END {print sum}')
      echo "PACKAGE SIZE (uncompressed): $UNCOMPRESSED_SIZE"
      
      echo "PACKAGE DESCRIPTION:"
      
      # Extract slack-desc safely without creating files
      if tar -tf "$pkg" | grep -q "install/slack-desc"; then
        # Extract to stdout only, not to filesystem
        tar -xOf "$pkg" "install/slack-desc" 2>/dev/null | 
          grep -v "^#" | grep -v "^$" || 
          echo "$pkg: Error extracting description"
      else
        echo "$pkg: Package description not available"
      fi
      echo ""
    fi
  done
} > PACKAGES.TXT

# Generate CHECKSUMS.md5
echo "Generating CHECKSUMS.md5..."
md5sum *.txz > CHECKSUMS.md5

# Generate MANIFEST.bz2 (detailed file listing)
echo "Generating MANIFEST.bz2..."
{
  for pkg in *.txz; do
    if [ -f "$pkg" ]; then
      echo "++=========================================="
      echo "||   Package: $pkg"
      echo "++=========================================="
      tar -tvf "$pkg"
      echo ""
    fi
  done
} | bzip2 > MANIFEST.bz2

echo "Repository metadata updated successfully!"