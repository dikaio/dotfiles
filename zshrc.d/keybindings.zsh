# keybindings.zsh
# Zsh key bindings configuration

# Give us access to ^Q
stty -ixon

# Vi mode
bindkey -v

# Reduce key timeout for faster mode switching
export KEYTIMEOUT=1

# Handy emacs-style keybindings even in vi mode
bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^N" history-search-forward
bindkey "^Y" accept-and-hold
bindkey "^Q" push-line-or-edit
bindkey "^W" backward-kill-word

# Use vim keys in tab complete menu (only if menuselect is available)
# These will be set up when completions are loaded
__setup_menuselect_keys() {
  # Ensure complist module is loaded
  zmodload -i zsh/complist 2>/dev/null || return 1
  
  # Check if menuselect keymap exists
  if bindkey -l 2>/dev/null | grep -q '^menuselect$'; then
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'j' vi-down-line-or-history
  fi
}

# Don't try to set up menu keys here - wait for lazy loading
# The lazy-loading.zsh will call this function when completions are loaded

# Edit line in vim with v in normal mode
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Better searching in vi mode
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^u' backward-kill-line

# Change cursor shape for different vi modes
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] ||
     [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'  # Block cursor
  elif [[ ${KEYMAP} == main ]] ||
       [[ ${KEYMAP} == viins ]] ||
       [[ ${KEYMAP} = '' ]] ||
       [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'  # Beam cursor
  fi
}
zle -N zle-keymap-select

# Start with beam cursor
echo -ne '\e[5 q'