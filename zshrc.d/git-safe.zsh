# git-safe.zsh
# Trust git repositories by creating .git/safe directory

# Add trusted repository bin directories to PATH
# Usage: mkdir .git/safe in repos you trust
PATH=".git/safe/../../bin:$PATH"
PATH=".git/safe/../../node_modules/.bin:$PATH"

# Function to mark current repository as safe
mark-safe() {
  if [[ -d .git ]]; then
    mkdir -p .git/safe
    echo "Marked repository as safe. Local bin/ and node_modules/.bin/ are now in PATH."
  else
    echo "Not in a git repository"
    return 1
  fi
}

# Function to unmark repository as safe
unmark-safe() {
  if [[ -d .git/safe ]]; then
    rmdir .git/safe
    echo "Removed safe marking from repository."
  else
    echo "Repository is not marked as safe"
    return 1
  fi
}