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

# Generate FILELIST.TXT in proper Slackware format
echo "Generating FILELIST.TXT..."
{
  # Header
  echo "$(date +'%a %b %d %H:%M:%S %Z %Y')"
  echo ""
  echo "Here is the file list for your https://github.com/0xjams/unraid-packages,"
  echo "maintained by <hi(at)0xjams(dot)com"
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
echo "Generated: PACKAGES.TXT, CHECKSUMS.md5, MANIFEST.bz2, FILELIST.TXT, FILELIST.TXT.gz"