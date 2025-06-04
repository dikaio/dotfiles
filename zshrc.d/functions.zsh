# functions.zsh
# Custom shell functions

# Make directory and change into it
mcd() {
  mkdir -p "$1" && cd "$1"
}

# Create a new directory and enter it
mkd() {
  mkdir -p "$@" && cd "$_"
}

# Change to the root of the current git repository
cdg() {
  local root=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$root" ]]; then
    cd "$root"
  else
    echo "Not in a git repository"
    return 1
  fi
}

# Quick backup of a file
backup() {
  if [[ -f "$1" ]]; then
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "Backed up $1"
  else
    echo "File not found: $1"
    return 1
  fi
}

# Change file extensions recursively in current directory
# Usage: change-extension erb haml
change-extension() {
  foreach f (**/*.$1)
    mv $f $f:r.$2
  end
}

# Load .env file into shell session for environment variables
envup() {
  if [ -f .env ]; then
    export $(sed '/^ *#/ d' .env)
    echo "Loaded .env file"
  else
    echo 'No .env file found' 1>&2
    return 1
  fi
}

# Unload .env file variables
envdown() {
  if [ -f .env ]; then
    unset $(sed '/^ *#/ d' .env | cut -d= -f1)
    echo "Unloaded .env file"
  else
    echo 'No .env file found' 1>&2
    return 1
  fi
}