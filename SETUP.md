# Modern Terminal Development Environment Setup

This guide will help you complete the migration to a modern, IDE-less development workflow.

## What's Been Done

### 1. Tmux Configuration (configs/tmux.conf:19-20,235)
- ✅ Updated to use `tmux-256color` for better color support
- ✅ Added `christoomey/vim-tmux-navigator` plugin for seamless vim/tmux navigation

### 2. Tmux Sessionizer Script (scripts/tmux-sessionizer.sh)
- ✅ Created fuzzy-finder script to quickly jump between projects
- ✅ Automatically creates/attaches to project-specific tmux sessions
- ✅ Opens nvim in project root on session creation
- ✅ Accessible via `ts` alias

### 3. Package Manager (scripts/brew.sh)
- ✅ Added modern CLI tools: fd, git-delta, lazygit, tig, gh-dash, mise, just, btop, starship, atuin, tmuxp
- ✅ Added neovim to formulas
- ✅ Replaced asdf with mise (faster, better env var handling)
- ✅ Commented out legacy asdf code for reference

### 4. Shell Aliases (configs/aliases)
- ✅ Updated `v` to use `nvim` instead of `vim`
- ✅ Added `vf` for fuzzy-find and open in Neovim
- ✅ Updated `c` to use `claude-code` CLI
- ✅ Added `lg` for lazygit
- ✅ Added `tg` for tig
- ✅ Added `ts` for tmux sessionizer
- ✅ Redirected `vim` and `vi` to `nvim`

### 5. Shell Configuration (configs/zshrc)
- ✅ Set `EDITOR` and `VISUAL` to `nvim`
- ✅ Added starship prompt initialization
- ✅ Added atuin history initialization
- ✅ Added zoxide smart cd initialization
- ✅ Enhanced FZF keybindings with preview support

### 6. Lazy Loading (.zshrc.d/lazy-loading.zsh)
- ✅ Replaced asdf with mise lazy loading
- ✅ Kept legacy asdf code commented for reference

## Next Steps

### 1. Install New Tools
Run the updated brew.sh script to install all the new tools:

```bash
cd ~/.dotfiles
./scripts/brew.sh
```

This will install:
- neovim
- fd, bat, eza, ripgrep (modern CLI tools)
- git-delta, lazygit, tig, gh-dash (git tools)
- mise (version manager)
- just (task runner)
- btop (system monitor)
- starship (prompt)
- atuin (shell history)
- tmuxp (tmux session manager)

### 2. Install Tmux Terminfo
For proper color support on remote servers:

```bash
infocmp -x tmux-256color > /tmp/tmux-256color.terminfo
tic -x /tmp/tmux-256color.terminfo
```

### 3. Install Tmux Plugins
Install TPM (Tmux Plugin Manager) if not already installed:

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Then install plugins:
1. Start tmux: `tmux`
2. Press `prefix + I` (default prefix is `Ctrl-a`, so `Ctrl-a + Shift-i`)
3. Wait for plugins to install

### 4. Set Up LazyVim
Install LazyVim for a complete Neovim IDE experience:

```bash
# Backup existing nvim config (if any)
mv ~/.config/nvim ~/.config/nvim.backup
mv ~/.local/share/nvim ~/.local/share/nvim.backup

# Clone LazyVim starter
git clone https://github.com/LazyVim/starter ~/.config/nvim

# Remove .git directory to make it your own
rm -rf ~/.config/nvim/.git

# Start Neovim - LazyVim will auto-install plugins
nvim
```

LazyVim comes with:
- LSP support (auto-install via Mason)
- Telescope (fuzzy finding)
- Neo-tree (file explorer)
- Treesitter (syntax highlighting)
- Git integration (gitsigns, lazygit integration)
- And much more!

### 5. Configure Starship Prompt
Create a starship config:

```bash
mkdir -p ~/.config
starship preset nerd-font-symbols > ~/.config/starship.toml
```

Or use a minimal config:

```bash
cat > ~/.config/starship.toml << 'EOF'
format = """
[┌───────────────────>](bold green)
[│](bold green)$directory$git_branch$git_status
[└─>](bold green) """

[directory]
style = "blue"
truncation_length = 3
truncate_to_repo = true

[git_branch]
symbol = " "
style = "bright-black"

[git_status]
style = "red"
EOF
```

### 6. Set Up Atuin
Initialize atuin for better shell history:

```bash
atuin import auto  # Import existing zsh history
```

### 7. Configure Mise
Set up mise for version management:

```bash
# Install common runtimes
mise use -g node@lts
mise use -g python@latest
mise use -g ruby@latest

# Check installed tools
mise list
```

### 8. Set Up Git Delta
Configure git to use delta for diffs:

```bash
git config --global core.pager delta
git config --global interactive.diffFilter 'delta --color-only'
git config --global delta.navigate true
git config --global delta.light false
git config --global delta.side-by-side true
```

### 9. Reload Shell
Apply all changes:

```bash
reload  # Or: exec $SHELL -l
```

### 10. Test Your Setup

```bash
# Test tmux sessionizer
ts  # Should open fzf to select a project

# Test neovim
v  # Should open neovim

# Test fuzzy file finding
vf  # Should open fzf, then open selected file in neovim

# Test lazygit
lg  # Should open lazygit TUI

# Test starship
# Your prompt should look different (if starship is configured)

# Test atuin
# Press Ctrl-r to search history with atuin

# Test zoxide
z ~/.dotfiles  # Should jump to dotfiles
```

## Customizing Your Setup

### Neovim Plugins
LazyVim includes an extras system. To add more features:

1. Open Neovim: `nvim`
2. Press `<leader>x` (space + x) to open LazyExtras
3. Select extras to enable (lang.typescript, lang.python, etc.)

### Tmux Sessionizer Paths
Edit `scripts/tmux-sessionizer.sh` to customize project search paths:

```bash
DEFAULT_SEARCH_PATHS=(
  "$HOME/projects"
  "$HOME/work"
  "$HOME/dev"
  # Add your project directories here
)
```

### Keybindings
Add a global keybinding for tmux sessionizer in your terminal:
- Ghostty: Add to config
- Alacritty: Add to alacritty.yml
- iTerm2: Preferences > Keys > Key Bindings

Example binding: `Ctrl-f` to run `~/.dotfiles/scripts/tmux-sessionizer.sh`

## Troubleshooting

### Colors not working in tmux
```bash
echo $TERM  # Should show 'tmux-256color'
# If not, check tmux.conf and reload
```

### Neovim not found
```bash
which nvim  # Check if installed
brew install neovim  # If not found
```

### FZF keybindings not working
```bash
# Install fzf keybindings
$(brew --prefix)/opt/fzf/install --key-bindings --completion
```

### Tmux plugins not loading
```bash
# Check TPM is installed
ls ~/.tmux/plugins/tpm

# Reload tmux config
tmux source ~/.tmux.conf

# Install plugins: prefix + I
```

## Migration Checklist

- [ ] Run updated brew.sh to install new tools
- [ ] Install tmux terminfo for remote servers
- [ ] Install tmux plugins via TPM
- [ ] Install LazyVim
- [ ] Configure starship prompt
- [ ] Set up atuin and import history
- [ ] Configure mise and install runtimes
- [ ] Set up git delta
- [ ] Reload shell and test all features
- [ ] Customize tmux sessionizer paths
- [ ] Set up global keybinding for sessionizer
- [ ] Configure Neovim LSPs for your languages
- [ ] Add AI plugins to Neovim (copilot/codeium)
- [ ] Test workflow for 1 week before removing VSCode/Cursor

## Useful Resources

- [LazyVim Documentation](https://www.lazyvim.org/)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)
- [Starship Configuration](https://starship.rs/config/)
- [Mise Documentation](https://mise.jdx.dev/)
- [FZF Examples](https://github.com/junegunn/fzf/wiki/examples)

## Tips for Success

1. **Learn incrementally**: Don't try to learn everything at once
2. **Use which-key**: In Neovim, press `<space>` and wait - which-key will show available commands
3. **Tmux prefix**: Remember your prefix is `Ctrl-a` (not default `Ctrl-b`)
4. **Sessionizer is key**: Use `ts` frequently to jump between projects
5. **Customize gradually**: Start with defaults, customize as you find friction
6. **Keep a cheat sheet**: Write down common commands you forget

Good luck with your IDE-less journey!
