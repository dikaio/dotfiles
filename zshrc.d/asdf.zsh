# asdf.zsh
# ASDF version manager setup

# Try loading ASDF from common locations
if [ -f "$HOME/.asdf/asdf.sh" ]; then
  # Standard home directory installation
  . "$HOME/.asdf/asdf.sh"
elif command -v brew >/dev/null && [ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]; then
  # Homebrew installation
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Load ASDF completions if available
if [ -f "$HOME/.asdf/completions/asdf.bash" ]; then
  . "$HOME/.asdf/completions/asdf.bash"
fi