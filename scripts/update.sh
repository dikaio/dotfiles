#!/bin/bash

# Exit on error, undefined variables, and pipe failures
set -euo pipefail

# Track what was updated
updated_items=()

echo "Updating asdf..."
if command -v asdf >/dev/null 2>&1; then
    if command -v brew >/dev/null 2>&1 && brew list asdf >/dev/null 2>&1; then
        brew upgrade asdf && updated_items+=("asdf")
    fi
    asdf plugin-update --all && updated_items+=("asdf plugins")
else
    echo "asdf not installed, skipping..."
fi

echo "Updating Homebrew and its packages..."
if command -v brew >/dev/null 2>&1; then
    brew update
    
    # Check for outdated packages first
    outdated_formula=$(brew outdated --formula | wc -l)
    outdated_casks=$(brew outdated --cask | wc -l)
    
    if [ $outdated_formula -gt 0 ]; then
        echo "Upgrading $outdated_formula formula packages..."
        brew upgrade --formula && updated_items+=("Homebrew formulas")
    fi
    
    if [ $outdated_casks -gt 0 ]; then
        echo "Upgrading $outdated_casks cask packages..."
        brew upgrade --cask && updated_items+=("Homebrew casks")
    fi
    
    brew cleanup
else
    echo "Homebrew not installed, skipping..."
fi

echo "Updating bun and global packages..."
if command -v bun >/dev/null 2>&1; then
    bun upgrade && updated_items+=("bun") # Updates bun itself
    bun update -g && updated_items+=("bun global packages") # Updates global packages
else
    echo "bun not installed, skipping..."
fi

echo "Checking for macOS software updates..."
# List available updates first
available_updates=$(softwareupdate -l 2>&1)
if echo "$available_updates" | grep -q "No new software available"; then
    echo "No macOS updates available"
else
    echo "Installing macOS updates..."
    sudo softwareupdate -i -a && updated_items+=("macOS")
fi

echo "Updating RubyGems and installed gems..."
if command -v gem >/dev/null 2>&1; then
    # Update RubyGems itself
    sudo gem update --system --no-document && updated_items+=("RubyGems")
    
    # Update all gems
    outdated_gems=$(gem outdated | wc -l)
    if [ $outdated_gems -gt 0 ]; then
        echo "Updating $outdated_gems outdated gems..."
        sudo gem update --no-document && updated_items+=("Ruby gems")
    fi
    
    # Clean up old gem versions
    sudo gem cleanup
else
    echo "RubyGems not installed, skipping..."
fi

# Summary
echo ""
echo "=== Update Summary ==="
if [ ${#updated_items[@]} -eq 0 ]; then
    echo "Nothing was updated - all systems are up to date!"
else
    echo "Successfully updated:"
    for item in "${updated_items[@]}"; do
        echo "  ✅ $item"
    done
fi
echo "====================="
echo "All update checks completed successfully."