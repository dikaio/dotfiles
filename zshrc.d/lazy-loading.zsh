# lazy-loading.zsh
# Author: Don Dikaio <git@dika.io>
# Source: https://github.com/dikaio/dotfiles
# ===========================================
#
# Lazy loading configurations for heavy tools to improve shell startup time

# ====================
# ASDF VERSION MANAGER
# ====================

# Set ASDF data directory
export ASDF_DATA_DIR="$HOME/.asdf"

# Lazy load ASDF - only load when first used
asdf() {
  unfunction asdf
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  asdf "$@"
}

# Create wrapper functions for common asdf-managed commands
# These will trigger asdf loading when needed
_asdf_lazy_load_wrapper() {
  local cmd=$1
  eval "
    $cmd() {
      unfunction $cmd
      . /opt/homebrew/opt/asdf/libexec/asdf.sh
      $cmd \"\$@\"
    }
  "
}

# Common commands that might be managed by asdf
for cmd in ruby python node npm yarn pnpm go cargo rustc elixir erl; do
  if ! command -v $cmd >/dev/null 2>&1; then
    _asdf_lazy_load_wrapper $cmd
  fi
done

# ====================
# FZF (FUZZY FINDER)
# ====================

# Export FZF configuration early
export FZF_DEFAULT_OPTS='
  --height 40%
  --layout=reverse
  --border
  --inline-info
  --color=dark
  --color=fg:-1,bg:-1,hl:#5fff87,fg+:-1,bg+:-1,hl+:#ffaf5f
  --color=info:#af87ff,prompt:#5fff87,pointer:#ff87d7,marker:#ff87d7,spinner:#ff87d7
'

# Set default command if fd is available
if command -v fd >/dev/null 2>&1; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi

# Lazy load FZF
fzf() {
  unfunction fzf
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  fzf "$@"
}

# Lazy load FZF key bindings - triggered on first use
__fzf_load_keybindings() {
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
}

# Create wrapper for common FZF keybindings
# This ensures they work when needed without loading FZF immediately
if [[ -z "$FZF_CTRL_R_LOADED" ]]; then
  # Override Ctrl-R to load FZF on first use
  __fzf_history_search() {
    __fzf_load_keybindings
    zle fzf-history-widget
  }
  zle -N __fzf_history_search
  bindkey '^R' __fzf_history_search
  
  # Override Ctrl-T to load FZF on first use
  __fzf_file_search() {
    __fzf_load_keybindings
    zle fzf-file-widget
  }
  zle -N __fzf_file_search
  bindkey '^T' __fzf_file_search
fi

# ====================
# COMPLETIONS
# ====================

# Lazy load heavy completion systems
__load_completions() {
  # Only run once
  if [[ -z "$COMPLETIONS_LOADED" ]]; then
    export COMPLETIONS_LOADED=1
    
    # Initialize completions
    autoload -Uz compinit
    if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qNmh+24) ]]; then
      compinit -C  # Skip security check for speed
    else
      compinit
    fi
    
    # Background compile completion dump
    {
      [[ -f ~/.zcompdump ]] && [[ ! -f ~/.zcompdump.zwc || ~/.zcompdump -nt ~/.zcompdump.zwc ]] && zcompile ~/.zcompdump
    } &!
    
    # Set up menuselect keybindings now that completion is loaded
    # The menuselect keymap might not exist until menu selection is triggered
    # Set up the completion styles that enable menu selection
    zstyle ':completion:*' menu select
    
    # Now try to set up the keybindings
    if typeset -f __setup_menuselect_keys >/dev/null; then
      __setup_menuselect_keys
    fi
  fi
}

# Trigger completion loading on first tab press
__lazy_complete() {
  __load_completions
  # Restore normal tab completion
  zle expand-or-complete
}
zle -N __lazy_complete
bindkey '^I' __lazy_complete

# ====================
# CLI TOOL COMPLETIONS
# ====================

# GitHub CLI - lazy load completions
gh() {
  unfunction gh
  # Load completions if gh exists
  if command -v gh >/dev/null 2>&1; then
    eval "$(command gh completion -s zsh)"
  fi
  command gh "$@"
}

# Stripe CLI - lazy load completions
stripe() {
  unfunction stripe
  # Add stripe completions to fpath if directory exists
  if [[ -d ~/.stripe ]]; then
    fpath=(~/.stripe $fpath)
    __load_completions  # Ensure compinit is loaded
  fi
  command stripe "$@"
}

# Bun - lazy load completions
if [[ -d "$HOME/.bun" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
  
  # Lazy load bun completions
  bun() {
    unfunction bun
    [[ -s "${BUN_INSTALL}/_bun" ]] && source "${BUN_INSTALL}/_bun"
    command bun "$@"
  }
fi

# ====================
# UTILITY FUNCTIONS
# ====================

# Function to check if lazy loading is working
lazy_loading_status() {
  echo "Lazy Loading Status:"
  echo "-------------------"
  
  # Check if functions are still lazy
  if typeset -f asdf >/dev/null 2>&1; then
    echo "✓ ASDF: Lazy (not loaded)"
  else
    echo "• ASDF: Loaded"
  fi
  
  if typeset -f fzf >/dev/null 2>&1 && [[ $(typeset -f fzf) == *"unfunction"* ]]; then
    echo "✓ FZF: Lazy (not loaded)"
  else
    echo "• FZF: Loaded"
  fi
  
  if [[ -z "$COMPLETIONS_LOADED" ]]; then
    echo "✓ Completions: Lazy (not loaded)"
  else
    echo "• Completions: Loaded"
  fi
  
  if typeset -f gh >/dev/null 2>&1 && [[ $(typeset -f gh) == *"unfunction"* ]]; then
    echo "✓ GitHub CLI: Lazy (not loaded)"
  else
    echo "• GitHub CLI: Loaded"
  fi
}

# Function to force load all lazy components (useful for testing)
lazy_load_all() {
  echo "Force loading all lazy components..."
  
  # Load ASDF
  . /opt/homebrew/opt/asdf/libexec/asdf.sh
  
  # Load FZF
  [[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
  
  # Load completions
  __load_completions
  
  # Load CLI completions
  command -v gh >/dev/null 2>&1 && eval "$(command gh completion -s zsh)"
  
  echo "All components loaded!"
}