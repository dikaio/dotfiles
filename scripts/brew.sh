#!/usr/bin/env bash
# laptop.local
# Author: Don Dikaio <git@dika.io>
# Source: https://github.com/dikaio/dotfiles
# ===========================================
#
# This script sets up a macOS laptop with development tools.
# It should be run after the main laptop script.

set -uo pipefail  # Removed -e to prevent script from exiting on errors

# ====================
# HELPER FUNCTIONS
# ====================

# Color output helpers
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() {
  echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
  echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
  echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# ====================
# HOMEBREW SETUP
# ====================

# Ensure Homebrew is installed
if ! command_exists brew; then
  error "Homebrew is not installed. Please install it first."
  exit 1
fi

info "Updating Homebrew..."
brew update

# ====================
# HOMEBREW TAPS
# ====================

taps=(
  "universal-ctags/universal-ctags" # Better ctags
  "supabase/tap"                    # Supabase CLI
  "tursodatabase/tap"               # Turso database
  "stripe/stripe-cli"               # Stripe CLI
)

info "Adding Homebrew taps..."
installed_taps=$(brew tap)

for tap in "${taps[@]}"; do
  if ! echo "$installed_taps" | grep -q "$tap"; then
    info "Tapping: $tap"
    brew tap "$tap"
  else
    success "Tap already installed: $tap"
  fi
done

# ====================
# HOMEBREW FORMULAS
# ====================

formulas=(
  # Build tools
  "autoconf"
  "automake"
  "cmake"
  "libtool"
  "pkg-config"
  
  # Core utilities
  "coreutils"     # GNU core utilities
  "findutils"     # GNU find, xargs, etc
  "moreutils"     # Additional Unix utilities
  "the_silver_searcher" # ag - fast file searcher
  "jq"            # JSON processor
  "wget"          # Web downloader
  
  # Development tools
  "git"
  "gh"            # GitHub CLI
  "vim"
  "tmux"
  "htop"          # Better top
  "ncurses"
  "readline"
  
  # System Administration tools
  "nmap"
  "netcat"
  "tcpdump"
  "wireshark"
  "tcpflow"

  # Shell and linting
  "zsh"
  "shellcheck"    # Shell script linter
  "biome"         # TypeScript linter
  "codex"         # AI-powered code editor
  
  # Security
  "openssl"
  "libressl"
  "libsodium"
  "gnupg"
  
  # Database
  "postgresql@16"
  "postgis"
  "libpq"
  "redis"
  
  # Programming languages support
  "libyaml"       # YAML parser
  "libffi"        # Foreign function interface
  "gmp"           # GNU multiple precision arithmetic
  "pcre"          # Perl compatible regular expressions
  
  # Media tools
  "ffmpeg"
  "imagemagick"
  
  # Infrastructure tools
  "caddy"         # Web server
  "flyctl"        # Fly.io CLI
  "pulumi"        # Infrastructure as code
  "stripe"        # Stripe CLI
  "supabase"      # Supabase CLI
  "turso"         # Turso database CLI
  
  # Language-specific tools
  #"php"
  "poetry"        # Python dependency management
  "pipx"          # Install Python apps in isolated environments
  "yarn"          # JavaScript package manager
  
  # Other tools
  "rcm"             # Dotfile management
  "llm"             # CLI for LLMs
  "wiki"            # Wikipedia CLI
  "dotenvx"         # Dotenv management
  "universal-ctags" # Code navigation
  "tor"             # Tor 
  
  # Graphics/Game development
  "assimp"        # 3D model loader
  "molten-vk"     # Vulkan on macOS
  "miniupnpc"     # UPnP client
)

info "Installing Homebrew formulas..."
installed_formulas=$(brew list --formula)

for formula in "${formulas[@]}"; do
  if ! echo "$installed_formulas" | grep -q "^${formula}$"; then
    info "Installing formula: $formula"
    brew install "$formula"
  else
    success "Formula already installed: $formula"
  fi
done

# ====================
# HOMEBREW CASKS
# ====================

casks=(
  # Security & Privacy
  "1password"           # Password manager
  "gpg-suite-no-mail"   # GPG tools
  "little-snitch"       # Network monitor
  "micro-snitch"        # Camera/mic monitor
  "mullvad-vpn"          # VPN
  
  # Development
  "cursor"              # AI-powered code editor
  "github"              # GitHub Desktop
  "kaleidoscope"        # Diff tool
  "tableplus"           # Database GUI
  "ghostty"             # Terminal emulator
  
  # Browsers
  "firefox"
  "google-chrome"
  "opera"
  
  # Communication
  "signal"
  "slack"
  
  # Design
  "figma"
  "sketch"
  "iconjar"             # Icon organizer
  
  # Productivity
  "claude"              # Claude desktop app
  "raycast"             # Launcher & productivity
  "superwhisper"        # Voice transcription
  "topnotch"            # Menu bar organizer
  "rocket-typist"
  # "cleanshot"           # Screenshot tool
  
  # Media
  "downie"              # Video downloader
  "permute"             # Media converter
  
  # Storage & Backup
  "arq"                 # Backup software
  "mountain-duck"       # Mount cloud storage
  
  # Other
  "appcleaner"          # App uninstaller
  "raindropio"          # Bookmark manager
  "tradingview"         # Trading charts
)

info "Installing Homebrew casks..."
installed_casks=$(brew list --cask)

for cask in "${casks[@]}"; do
  if ! echo "$installed_casks" | grep -q "^${cask}$"; then
    info "Installing cask: $cask"
    if brew install --cask "$cask" 2>/dev/null; then
      success "Installed cask: $cask"
    else
      # Check if it's already installed in /Applications
      if [[ "$cask" == "cleanshot" && -e "/Applications/CleanShot X.app" ]]; then
        warning "CleanShot X already installed in Applications folder"
      elif brew list --cask "$cask" &>/dev/null; then
        warning "Cask $cask appears to be installed but not listed properly"
      else
        error "Failed to install cask: $cask (continuing anyway)"
      fi
    fi
  else
    success "Cask already installed: $cask"
  fi
done

# ====================
# ASDF VERSION MANAGER
# ====================

# Check if asdf is installed
if ! command_exists asdf; then
  warning "asdf is not installed. Skipping plugin installation."
else
  desired_plugins=(
    # Languages
    "ruby"
    "nodejs"
    "python"
    "golang"
    "rust"
    "elixir"
    "erlang"
    "julia"
    "kotlin"
    "lua"
    "ocaml"
    "scala"
    "zig"
    
    # JavaScript runtimes
    "deno"
    "pnpm"
    
    # Infrastructure
    "terraform"
    "pulumi"
    "packer"
    "vault"
    
    # Databases
    "sqlite"
    
    # Other
    "haskell"
    "venom"
  )
  
  info "Setting up asdf plugins..."
  installed_plugins=$(asdf plugin list 2>/dev/null || echo "")
  
  for plugin in "${desired_plugins[@]}"; do
    if ! echo "$installed_plugins" | grep -q "^${plugin}$"; then
      info "Installing asdf plugin: $plugin"
      asdf plugin add "$plugin" || warning "Failed to install $plugin plugin"
    else
      success "Plugin already installed: $plugin"
      info "Updating plugin: $plugin"
      asdf plugin update "$plugin" || warning "Failed to update $plugin plugin"
    fi
  done
  
  info "Reshimming asdf..."
  asdf reshim
fi

# ====================
# BUN PACKAGES
# ====================

# Check if bun is installed
if command_exists bun; then
  bun_packages=(
    # Build tools
    "turbo"               # Monorepo build system
    "esbuild"             # Fast bundler
    "rollup"              # Module bundler
    "webpack"             # Module bundler
    "vite"                # Fast build tool
    
    # Frameworks CLI
    "create-next-app"     # Next.js
    "create-vite"         # Vite
    "create-svelte"       # SvelteKit
    "create-t3-app"       # T3 Stack
    "create-remix"        # Remix
    "@vue/cli"            # Vue.js
    
    # Development utilities
    "typescript"          # TypeScript compiler
    "tsx"                 # TypeScript executor
    "ts-node"             # TypeScript Node.js
    "typedoc"             # TypeScript documentation
    
    # Server utilities
    "serve"               # Static file server
    "nodemon"             # Auto-restart Node.js
    "pm2"                 # Process manager
    "concurrently"        # Run multiple commands
    "json-server"         # Mock REST API
    
    # Maintenance tools
    "npm-check-updates"   # Update dependencies
    "npkill"              # Clean node_modules
    "rimraf"              # Cross-platform rm -rf
  )
  
  info "Installing global Bun packages..."
  installed_bun_packages=$(bun pm ls -g 2>/dev/null || echo "")
  
  for package in "${bun_packages[@]}"; do
    if ! echo "$installed_bun_packages" | grep -q "$package"; then
      info "Installing $package globally..."
      bun install -g "$package"
    else
      success "Package already installed: $package"
    fi
  done
else
  warning "Bun is not installed. Skipping global package installation."
fi

# ====================
# POST-INSTALL SETUP
# ====================

# PostgreSQL setup
if command_exists psql; then
  info "Setting up PostgreSQL..."
  
  # Fix permissions on PostgreSQL data directory
  PG_DATA_DIR="/opt/homebrew/var/postgresql@16"
  if [[ -d "$PG_DATA_DIR" ]]; then
    current_perms=$(stat -f "%Lp" "$PG_DATA_DIR" 2>/dev/null || stat -c "%a" "$PG_DATA_DIR" 2>/dev/null)
    if [[ "$current_perms" != "700" ]]; then
      info "Fixing PostgreSQL data directory permissions..."
      chmod 700 "$PG_DATA_DIR"
      success "PostgreSQL permissions fixed"
    fi
  fi
  
  if ! brew services list | grep -q "postgresql.*started"; then
    brew services start postgresql@16
    success "PostgreSQL service started"
  else
    success "PostgreSQL service already running"
  fi
fi

# Redis setup
if command_exists redis-server; then
  info "Setting up Redis..."
  if ! brew services list | grep -q "redis.*started"; then
    brew services start redis
    success "Redis service started"
  else
    success "Redis service already running"
  fi
fi

# Caddy setup
if command_exists caddy; then
  info "Setting up Caddy..."
  CADDYFILE="/opt/homebrew/etc/Caddyfile"
  
  if [[ ! -f "$CADDYFILE" ]]; then
    info "Creating default Caddyfile..."
    mkdir -p "$(dirname "$CADDYFILE")"
    cat > "$CADDYFILE" << 'EOF'
# Default Caddyfile configuration
# https://caddyserver.com/docs/caddyfile

# Example configuration for localhost
:2015 {
    respond "Hello, Caddy!"
}

# To serve files from a directory:
# :8080 {
#     root * /path/to/your/files
#     file_server
# }
EOF
    success "Created default Caddyfile at $CADDYFILE"
  else
    success "Caddyfile already exists"
  fi
fi

# Tor setup
if command_exists tor; then
  info "Setting up Tor..."
  TORRC="/opt/homebrew/etc/tor/torrc"
  TOR_DATA_DIR="/opt/homebrew/var/lib/tor"
  
  # Create Tor directories if they don't exist
  mkdir -p "$(dirname "$TORRC")"
  mkdir -p "$TOR_DATA_DIR"
  
  if [[ ! -f "$TORRC" ]]; then
    info "Creating default torrc configuration..."
    cat > "$TORRC" << 'EOF'
# Default Tor configuration
# https://www.torproject.org/docs/tor-manual.html

# Enable control port for applications
ControlPort 9051
CookieAuthentication 1

# Logging
Log notice file /opt/homebrew/var/log/tor.log

# Uncomment to run a relay
# ORPort 9001
# ExitPolicy reject *:*

# Uncomment for hidden service
# HiddenServiceDir /opt/homebrew/var/lib/tor/hidden_service/
# HiddenServicePort 80 127.0.0.1:8080
EOF
    success "Created default torrc at $TORRC"
  else
    success "torrc already exists"
  fi
  
  # Check if we can copy the sample file if it exists
  if [[ ! -f "$TORRC" && -f "/opt/homebrew/etc/tor/torrc.sample" ]]; then
    cp "/opt/homebrew/etc/tor/torrc.sample" "$TORRC"
    success "Copied torrc.sample to torrc"
  fi
fi

# ====================
# CLEANUP
# ====================

info "Cleaning up Homebrew..."
brew cleanup
brew autoremove

# ====================
# FINAL CHECKS
# ====================

success "Laptop setup completed!"
info "You may need to:"
echo "  - Restart your terminal for all changes to take effect"
echo "  - Configure your installed applications"
echo "  - Set up GPG keys for git commit signing"
echo "  - Configure asdf versions with: asdf install <language> <version>"

# Show summary
echo ""
info "Installed summary:"
echo "  - Homebrew taps: ${#taps[@]}"
echo "  - Homebrew formulas: ${#formulas[@]}"
echo "  - Homebrew casks: ${#casks[@]}"
if command_exists asdf; then
  echo "  - asdf plugins: ${#desired_plugins[@]}"
fi
if command_exists bun; then
  echo "  - Bun global packages: ${#bun_packages[@]}"
fi