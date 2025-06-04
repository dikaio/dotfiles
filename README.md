# Dotfiles

Personal dotfiles configuration for macOS.

## Structure

```
.
├── install.sh          # Main installation script
├── configs/           # Dotfile configurations
│   ├── aliases        # Shell aliases
│   ├── gitconfig      # Git configuration
│   ├── tmux.conf      # Tmux configuration
│   ├── vimrc          # Vim configuration
│   ├── zshrc          # Zsh configuration
│   └── ...           # Other config files
├── scripts/          # Installation scripts
│   └── brew.sh       # Homebrew packages installation
└── zshrc.d/          # Additional Zsh configurations
    └── README.md
```

## Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles ~/.dotfiles

# Run the installer
cd ~/.dotfiles
./install.sh
```

## What it does

1. **Installs Homebrew** (if not already installed)
2. **Installs packages** via Homebrew (see `scripts/brew.sh`)
3. **Creates symlinks** from `configs/*` to `~/.*`
4. **Sets up Zsh** as the default shell
5. **Configures macOS** defaults

## Manual Steps After Installation

- Set up GPG keys for git commit signing
- Configure asdf versions: `asdf install <language> <version>`
- Create `~/.zshenv.secrets` for sensitive environment variables

## Customization

- Add new dotfiles to `configs/`
- Update Homebrew packages in `scripts/brew.sh`
- Add Zsh customizations to `zshrc.d/`