# install.sh
# Author: Donovan Dikaio <github@dikaio.com>
# Source: https://github.com/dikaio/dotfiles
# =============================================================================
# Runs entire install on new macOS!

brew install macvim --with-override-system-vim

tap "crisidev/chunkwm"
tap "homebrew/core"
tap "homebrew/cask"
tap "homebrew/bundle"
tap "homebrew/services"
tap "minio/stable"
tap "koekeishiya/formulae"
tap "burntsushi/ripgrep", "https://github.com/BurntSushi/ripgrep.git"
tap "universal-ctags/universal-ctags"
cask "xquartz"
brew "asciinema"
brew "autoconf"
brew "automake"
brew "awscli"
brew "cmake"
brew "coreutils"
brew "cowsay"
brew "curl"
brew "direnv"
brew "fish"
brew "fortune"
brew "fzf"
brew "gettext"
brew "gawk"
brew "ghc"
brew "git"
brew "git-imerge"
brew "git-lfs"
brew "git-test"
brew "gnupg", link: false
brew "graphviz"
brew "htop"
brew "httpie"
brew "hub"
brew "imagemagick"
brew "jpegoptim"
brew "jq"
brew "keychain"
brew "kubernetes-cli"
brew "libyaml"
brew "lnav"
brew "minio-mc"
brew "mit-scheme"
brew "mmv"
brew "ncdu"
brew "neovim"
brew "optipng"
brew "osquery"
brew "pandoc"
brew "parallel"
brew "pkg-config"
brew "postgis"
brew "pv"
brew "rclone"
brew "terminal-notifier"
brew "tree"
brew "the_silver_searcher"
brew "watchman"
brew "wget"
brew "wrk"
brew "wxmac"
brew "xsv"
brew "yarn", args: ["without-node"]
brew "burntsushi/ripgrep/ripgrep-bin"
brew "crisidev/chunkwm/chunkwm"
brew "koekeishiya/formulae/skhd"
brew "minio/stable/minio"
brew "universal-ctags/universal-ctags/universal-ctags", args: ["HEAD"]
