#!/usr/bin/env bash
# install.sh
# Author: Don Dikaio <git@dika.io>
# Source: https://github.com/dikaio/dotfiles
# ===========================================
#
# Main installer for personal dotfiles
# This replaces thoughtbot's laptop + dotfiles

set -uo pipefail  # Removed -e to prevent script from exiting on errors

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ====================
# HOMEBREW
# ====================

install_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for this session
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    success "Homebrew already installed"
  fi
  
  info "Running Homebrew setup..."
  bash "${DOTFILES_DIR}/scripts/brew.sh"
}

# ====================
# DOTFILES
# ====================

link_dotfiles() {
  info "Linking dotfiles..."
  
  # Create symlinks for all config files
  for file in "${DOTFILES_DIR}"/configs/*; do
    if [[ -f "$file" ]]; then
      basename=$(basename "$file")
      target="${HOME}/.${basename}"
      
      # Backup existing file if it exists and isn't a symlink
      if [[ -e "$target" && ! -L "$target" ]]; then
        warning "Backing up existing $target to ${target}.backup"
        mv "$target" "${target}.backup"
      fi
      
      # Remove broken symlinks
      if [[ -L "$target" && ! -e "$target" ]]; then
        rm "$target"
        warning "Removed broken symlink: $target"
      fi
      
      # Create symlink
      if [[ ! -e "$target" ]]; then
        ln -sf "$file" "$target"
        success "Linked $basename -> .${basename}"
      elif [[ -L "$target" ]]; then
        # Check if existing symlink points to the right place
        current_target=$(readlink "$target")
        if [[ "$current_target" != "$file" ]]; then
          rm "$target"
          ln -sf "$file" "$target"
          success "Updated symlink: $basename -> .${basename}"
        else
          info ".${basename} already correctly linked"
        fi
      else
        error ".${basename} exists but is not a symlink"
      fi
    fi
  done
}

# ====================
# ASDF SETUP
# ====================

setup_asdf() {
  if command -v asdf >/dev/null 2>&1; then
    info "Setting up asdf plugins..."
    
    # Install global tool versions if file exists
    if [[ -f "${DOTFILES_DIR}/tool-versions" ]]; then
      cp "${DOTFILES_DIR}/tool-versions" "${HOME}/.tool-versions"
      asdf install
    fi
  else
    warning "asdf not found, skipping language setup"
  fi
}

# ====================
# ZSH SETUP
# ====================

setup_zsh() {
  info "Setting up Zsh..."
  
  # Set Zsh as default shell if not already
  if [[ "$SHELL" != "$(which zsh)" ]]; then
    info "Setting Zsh as default shell..."
    sudo chsh -s "$(which zsh)" "$USER"
  fi
  
  # Create directories
  mkdir -p "${HOME}/.config"
  mkdir -p "${HOME}/.local/bin"
}

# ====================
# MACOS DEFAULTS
# ====================

setup_macos() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    info "Configuring macOS defaults..."
    
    # Show hidden files in Finder
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
    
    # Set fast key repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Require password immediately after sleep
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    
    killall Finder || true
  fi
}

# ====================
# MAIN
# ====================

main() {
  info "Starting dotfiles installation..."
  
  # Ask for sudo password upfront
  sudo -v
  
  # Keep sudo alive
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
  
  # Run installation steps
  install_homebrew
  link_dotfiles
  setup_zsh
  setup_asdf
  setup_macos
  
  success "Installation complete!"
  info "Please restart your terminal for all changes to take effect"
  
  # Source zshrc if running in zsh
  if [[ -n "$ZSH_VERSION" ]]; then
    source "${HOME}/.zshrc"
  fi
}

# Run main function
main "$@"