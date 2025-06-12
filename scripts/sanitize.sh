#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Define array of target directories
TARGET_DIRS=(
    "$HOME/.lmstudio/conversations"
    "$HOME/.lmstudio/user-files"
)

# Function to validate directory
validate_dir() {
    local dir="$1"
    if [ ! -d "$dir" ]; then
        echo "Warning: Directory '$dir' does not exist, skipping..."
        return 1
    fi
    return 0
}

# Check if any target directories exist
valid_dirs=0
for dir in "${TARGET_DIRS[@]}"; do
    if validate_dir "$dir"; then
        valid_dirs=$((valid_dirs + 1))
    fi
done

if [ $valid_dirs -eq 0 ]; then
    echo "Error: None of the target directories exist"
    exit 1
fi

# Process each target directory
for TARGET_DIR in "${TARGET_DIRS[@]}"; do
    if ! validate_dir "$TARGET_DIR"; then
        continue
    fi

    echo "Processing directory: $TARGET_DIR"
    
    # Count files first
    file_count=$(find "$TARGET_DIR" -type f | wc -l)
    echo "Found $file_count files to remove"
    
    # Remove files with rm -P (secure deletion)
    # Note: rm -P is macOS specific for overwriting file contents
    find "$TARGET_DIR" -type f -print0 | while IFS= read -r -d $'\0' file; do
        echo "Securely removing: $(basename "$file")"
        rm -P "$file" 2>/dev/null || {
            echo "  Warning: Could not securely remove, using standard rm"
            rm -f "$file"
        }
    done
    
    # Remove empty directories
    find "$TARGET_DIR" -type d -empty -delete 2>/dev/null || true
done

# Sync and clear cache
echo "Running cleanup..."
sync                   # Sync filesystem

# Check if purge command exists (macOS specific)
if command -v purge >/dev/null 2>&1; then
    sudo purge        # Clear filesystem cache
else
    echo "Note: 'purge' command not available on this system"
fi

echo "Secure removal and cleanup complete"

# Final verification
for dir in "${TARGET_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        remaining=$(find "$dir" -type f | wc -l)
        if [ $remaining -gt 0 ]; then
            echo "Warning: $remaining files still remain in $dir"
        fi
    fi
done
