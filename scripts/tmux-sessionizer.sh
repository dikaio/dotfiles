#!/usr/bin/env bash
# tmux-sessionizer.sh
# Author: Don Dikaio <git@dika.io>
# Source: https://github.com/dikaio/dotfiles
# ===========================================
#
# Fuzzy-find project directories and create/attach to tmux sessions
# This is the secret sauce for productive terminal-based development

set -e

# Default search paths for projects
# Customize these to match your project locations
DEFAULT_SEARCH_PATHS=(
  "$HOME/projects"
  "$HOME/work"
  "$HOME/dev"
  "$HOME/.dotfiles"
  "$HOME"
)

# Filter out paths that don't exist
SEARCH_PATHS=()
for path in "${DEFAULT_SEARCH_PATHS[@]}"; do
  if [[ -d "$path" ]]; then
    SEARCH_PATHS+=("$path")
  fi
done

# If no search paths exist, fall back to home directory
if [[ ${#SEARCH_PATHS[@]} -eq 0 ]]; then
  SEARCH_PATHS=("$HOME")
fi

# Use fd if available (faster), otherwise fall back to find
if command -v fd &> /dev/null; then
  # fd is installed, use it for fast searching
  # Search for directories, max depth 3, exclude common non-project dirs
  selected=$(fd . "${SEARCH_PATHS[@]}" \
    --type d \
    --max-depth 3 \
    --exclude node_modules \
    --exclude .git \
    --exclude dist \
    --exclude build \
    --exclude target \
    --exclude .venv \
    --exclude venv \
    --exclude __pycache__ \
    | fzf --height 40% --reverse --border \
      --prompt "Select project: " \
      --preview "ls -la {}" \
      --preview-window=right:50%:wrap)
else
  # Fall back to find
  selected=$(find "${SEARCH_PATHS[@]}" \
    -mindepth 1 -maxdepth 3 \
    -type d \
    \( -name node_modules -o -name .git -o -name dist -o -name build -o -name target -o -name .venv -o -name venv -o -name __pycache__ \) -prune -o \
    -type d -print \
    | fzf --height 40% --reverse --border \
      --prompt "Select project: " \
      --preview "ls -la {}" \
      --preview-window=right:50%:wrap)
fi

# Exit if no selection was made (user pressed ESC)
if [[ -z $selected ]]; then
  exit 0
fi

# Get the basename of the selected directory for the session name
# Replace dots with underscores to avoid tmux naming issues
selected_name=$(basename "$selected" | tr . _)

# Check if we're already in a tmux session
tmux_running=$(pgrep tmux || true)

# If not in tmux and tmux is not running, start a new session
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  cd "$selected" && tmux new-session -s "$selected_name" -c "$selected" -n main
  exit 0
fi

# If the session doesn't exist, create it in detached mode
if ! tmux has-session -t="$selected_name" 2> /dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected" -n main
fi

# Switch to the session
if [[ -z $TMUX ]]; then
  # Not in tmux, attach to the session
  tmux attach-session -t "$selected_name"
else
  # Already in tmux, switch to the session
  tmux switch-client -t "$selected_name"
fi
