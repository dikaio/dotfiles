#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Default values
TARGET_DIR="${1:-.}"
TOP_N=20
HUMAN_READABLE=true

# Function to display usage
usage() {
    echo "Usage: $0 [directory] [-n number] [-b]"
    echo ""
    echo "Options:"
    echo "  directory    Directory to analyze (default: current directory)"
    echo "  -n          Number of top items to show (default: 20)"
    echo "  -b          Show sizes in bytes instead of human-readable"
    echo "  -h          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Analyze current directory"
    echo "  $0 /Users/john        # Analyze specific directory"
    echo "  $0 ~ -n 10            # Show top 10 items in home directory"
    exit 1
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            ;;
        -n)
            TOP_N="$2"
            shift 2
            ;;
        -b)
            HUMAN_READABLE=false
            shift
            ;;
        *)
            if [ -z "${TARGET_DIR_SET:-}" ]; then
                TARGET_DIR="$1"
                TARGET_DIR_SET=true
            fi
            shift
            ;;
    esac
done

# Verify directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory '$TARGET_DIR' does not exist" >&2
    exit 1
fi

# Get absolute path
TARGET_DIR=$(cd "$TARGET_DIR" && pwd)

echo "Analyzing disk usage for: $TARGET_DIR"
echo "This may take a moment for large directories..."
echo ""

# Function to format bytes
format_bytes() {
    local bytes=$1
    if [ "$HUMAN_READABLE" = true ]; then
        if [ $bytes -ge 1099511627776 ]; then
            echo "$(awk -v b=$bytes 'BEGIN {printf "%.2fT", b/1099511627776}')"
        elif [ $bytes -ge 1073741824 ]; then
            echo "$(awk -v b=$bytes 'BEGIN {printf "%.2fG", b/1073741824}')"
        elif [ $bytes -ge 1048576 ]; then
            echo "$(awk -v b=$bytes 'BEGIN {printf "%.2fM", b/1048576}')"
        elif [ $bytes -ge 1024 ]; then
            echo "$(awk -v b=$bytes 'BEGIN {printf "%.2fK", b/1024}')"
        else
            echo "${bytes}B"
        fi
    else
        echo "$bytes"
    fi
}

# Get total size of target directory
echo "Calculating total size..."
# macOS du doesn't support -b flag, use -k for kilobytes
TOTAL_SIZE=$(du -sk "$TARGET_DIR" 2>/dev/null | cut -f1)
TOTAL_SIZE=$((TOTAL_SIZE * 1024))  # Convert to bytes
echo "Total size: $(format_bytes $TOTAL_SIZE)"
echo ""

# Find largest files
echo "=== Top $TOP_N Largest Files ==="
# Use stat to get file sizes on macOS
find "$TARGET_DIR" -type f -exec stat -f "%z %N" {} \; 2>/dev/null | \
    sort -rn | \
    head -n "$TOP_N" | \
    while read size file; do
        printf "%-10s %s\n" "$(format_bytes $size)" "$file"
    done

echo ""

# Find largest directories
echo "=== Top $TOP_N Largest Directories ==="
# Use du -k for kilobytes on macOS
du -k "$TARGET_DIR"/* 2>/dev/null | \
    sort -rn | \
    head -n "$TOP_N" | \
    while read size dir; do
        size_bytes=$((size * 1024))  # Convert to bytes
        printf "%-10s %s\n" "$(format_bytes $size_bytes)" "$dir"
    done

# Show disk space summary
echo ""
echo "=== Disk Space Summary ==="
df -h "$TARGET_DIR" | tail -n 1 | awk '{
    print "Filesystem: " $1
    print "Total Space: " $2
    print "Used Space: " $3 " (" $5 ")"
    print "Free Space: " $4
}'

# Check for common space wasters
echo ""
echo "=== Checking for Common Space Wasters ==="

# Node modules
NODE_MODULES=$(find "$TARGET_DIR" -type d -name "node_modules" 2>/dev/null | wc -l | xargs)
if [ $NODE_MODULES -gt 0 ]; then
    NODE_SIZE=$(find "$TARGET_DIR" -type d -name "node_modules" -exec du -sk {} + 2>/dev/null | awk '{sum += $1} END {print sum * 1024}')
    echo "Found $NODE_MODULES node_modules directories using $(format_bytes ${NODE_SIZE:-0})"
fi

# Git repositories
GIT_REPOS=$(find "$TARGET_DIR" -type d -name ".git" 2>/dev/null | wc -l | xargs)
if [ $GIT_REPOS -gt 0 ]; then
    GIT_SIZE=$(find "$TARGET_DIR" -type d -name ".git" -exec du -sk {} + 2>/dev/null | awk '{sum += $1} END {print sum * 1024}')
    echo "Found $GIT_REPOS git repositories using $(format_bytes ${GIT_SIZE:-0})"
fi

# Cache directories
CACHE_DIRS=$(find "$TARGET_DIR" -type d \( -name "*cache*" -o -name "*Cache*" \) 2>/dev/null | wc -l | xargs)
if [ $CACHE_DIRS -gt 0 ]; then
    CACHE_SIZE=$(find "$TARGET_DIR" -type d \( -name "*cache*" -o -name "*Cache*" \) -exec du -sk {} + 2>/dev/null | awk '{sum += $1} END {print sum * 1024}')
    echo "Found $CACHE_DIRS cache directories using $(format_bytes ${CACHE_SIZE:-0})"
fi

echo ""
echo "Analysis complete!"