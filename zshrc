# .zshrc
# Author: Donovan Dikaio <github@dikaio.com>
# Source: https://github.com/dikaio/dotfiles
# =============================================================================
# ZSH shell configuration defaults

# Load dotfiles
for file in ~/.{exports,aliases,functions}; do
	[ -r "$file" ] && [ -f "$file" ] && source "$file";
done;
unset file;

# Increase history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.history