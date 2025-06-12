#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

echo "Starting macOS cleanup..."

# Clear system logs and caches (safer approach)
echo "Clearing system logs and caches..."
# Only remove log files, not directories
sudo find /private/var/log -type f -exec rm -f {} \;
sudo find /Library/Logs -type f -exec rm -f {} \;

# Clear user logs (safer approach)
echo "Clearing user logs..."
find ~/Library/Logs -type f -exec rm -f {} \;

# Clear Homebrew cache
echo "Clearing Homebrew cache..."
if command -v brew >/dev/null 2>&1; then
    brew cleanup -s
    brew autoremove
else
    echo "Homebrew not installed, skipping..."
fi

# Clear DNS cache
echo "Clearing DNS cache..."
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Empty the Trash (safer approach)
echo "Emptying the Trash..."
# Use osascript for safer trash emptying
osascript -e 'tell application "Finder" to empty trash' 2>/dev/null || echo "Could not empty trash via Finder"

# Rebuild Spotlight index
echo "Rebuilding Spotlight index..."
sudo mdutil -E /

# Clear temporary files
echo "Clearing temporary files..."
find /tmp -type f -atime +7 -delete 2>/dev/null || true
find ~/Library/Caches -type f -atime +30 -delete 2>/dev/null || true

# Report disk space saved
echo "Disk usage after cleanup:"
df -h /

echo "macOS cleanup completed successfully."
