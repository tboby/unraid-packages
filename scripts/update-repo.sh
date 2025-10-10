#!/bin/bash
# Repository metadata update script - cross-platform compatible
set -e

REPO_DIR="slackware64/packages"
mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# Detect upstream changes by comparing sorted checksums of package files.
# If nothing changed, avoid touching any tracked files to keep git clean.
TMP_MD5=".CHECKSUMS.md5.new"
if ls *.txz >/dev/null 2>&1; then
  md5sum *.txz | sort > "$TMP_MD5"
else
  # No packages present; create an empty temp file for comparison
  : > "$TMP_MD5"
fi

# If there are no packages and no existing CHECKSUMS.md5, skip updating metadata
if ! ls *.txz >/dev/null 2>&1 && [ ! -f CHECKSUMS.md5 ]; then
  echo "No packages present and no existing repository metadata. Skipping update."
  rm -f "$TMP_MD5"
  exit 0
fi

# Normalize existing CHECKSUMS.md5 (line endings and order) before comparison to avoid metadata-only updates
if [ -f CHECKSUMS.md5 ]; then
  TMP_MD5_EXISTING=".CHECKSUMS.md5.existing"
  # Strip CRLF if present, then sort to normalize order
  tr -d '\r' < CHECKSUMS.md5 | sort > "$TMP_MD5_EXISTING"
  if cmp -s "$TMP_MD5" "$TMP_MD5_EXISTING"; then
    echo "No upstream updates detected. Skipping repository metadata update."
    rm -f "$TMP_MD5" "$TMP_MD5_EXISTING"
    exit 0
  fi
fi

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

# Write CHECKSUMS.md5 from the precomputed, sorted list
echo "Generating CHECKSUMS.md5..."
mv -f "$TMP_MD5" CHECKSUMS.md5
# Cleanup normalized temp if it exists
rm -f "$TMP_MD5_EXISTING"

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

# Generate FILELIST.TXT in proper Slackware format
echo "Generating FILELIST.TXT..."
{
  # Header
  echo "$(date +'%a %b %d %H:%M:%S %Z %Y')"
  echo ""
  echo "Here is the file list for https://github.com/0xjams/unraid-packages,"
  echo "maintained by <hi(at)0xjams(dot)com>"
  echo ""

  # File listing with permissions, owner, group, size, date and relative path
  for file in $(find . -type f | sort); do
    # Get all file info from ls -l directly (works on both macOS and Linux)
    fileinfo=$(ls -la "$file")
    perms=$(echo "$fileinfo" | awk '{print $1}')
    links=$(echo "$fileinfo" | awk '{print $2}')
    owner=$(echo "$fileinfo" | awk '{print $3}')
    group=$(echo "$fileinfo" | awk '{print $4}')
    size=$(echo "$fileinfo" | awk '{print $5}')
    
    # Get date from ls output - the format is slightly different between macOS and Linux
    # but using the full ls output ensures we get whatever format the system provides
    month=$(echo "$fileinfo" | awk '{print $6}')
    day=$(echo "$fileinfo" | awk '{print $7}')
    yeartime=$(echo "$fileinfo" | awk '{print $8}')
    
    echo "$perms $links $owner $group $size $month $day $yeartime $file"
  done
} > FILELIST.TXT

echo "Repository metadata updated successfully!"
echo "Generated: PACKAGES.TXT, CHECKSUMS.md5, MANIFEST.bz2, FILELIST.TXT"