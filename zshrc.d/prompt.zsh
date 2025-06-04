# prompt.zsh
# Custom prompt configuration

# Enable colors
autoload -U colors && colors

# Enable command substitution in prompt
setopt promptsubst

# Git prompt info function
git_prompt_info() {
  local current_branch=$(git symbolic-ref --short HEAD 2> /dev/null)
  if [[ -n $current_branch ]]; then
    local git_status=""
    
    # Check for uncommitted changes
    if ! git diff --quiet 2> /dev/null; then
      git_status="*"
    fi
    
    # Check for untracked files
    if [[ -n $(git ls-files --other --exclude-standard 2> /dev/null) ]]; then
      git_status="${git_status}?"
    fi
    
    echo " %{$fg_bold[green]%}${current_branch}${git_status}%{$reset_color%}"
  fi
}

# Oh My Zsh style prompt - just a green arrow
PS1='%{$fg_bold[green]%}∼  %{$reset_color%}'

# Optional: Add current directory and git info before the arrow
# PS1='%{$fg_bold[cyan]%}%c%{$reset_color%}$(git_prompt_info) %{$fg_bold[green]%}➜ %{$reset_color%}'

# Optional: Right side prompt with time
# RPS1='%{$fg[yellow]%}%T%{$reset_color%}'

# Show user@host when in SSH session
if [[ -n "$SSH_CONNECTION" ]]; then
  PS1='%{$fg_bold[green]%}%n@%m%{$reset_color%} '$PS1
fi