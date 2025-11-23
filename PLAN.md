Modern terminal-first dev environment plan that keeps your current dotfiles strengths and folds in the new ideas.

## What you already have (keep)

- `configs/tmux.conf`: strong defaults (C-a prefix, vi keys, mouse, resize bindings, alt/arrow pane moves, yank/prefix highlight, resurrect/continuum, yank to system clipboard, status theming, TPM). Keep this as the baseline.
- `scripts/brew.sh`: installs core CLI tools (fzf, ripgrep, bat, eza, zoxide, lf, ncurses), tmux, vim, tmux plugins via TPM, and agent CLIs.
- Vim config (`configs/vimrc`): sensible defaults (relative numbers, splits, indentation rules, matchit, wildmenu). This is a good foundation to port to Neovim.

## Tmux plan (merge, don't overwrite)

1) Keep your current config and add truecolor TERM improvements:

```tmux
set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB"
```

Install the terminfo so remotes don't break:

```bash
infocmp -x tmux-256color > /tmp/tmux-256color.terminfo && tic -x /tmp/tmux-256color.terminfo
```

2) **Add `christoomey/vim-tmux-navigator`** to TPM plugins for seamless vim/tmux pane switching (complements your existing h/j/k/l bindings).
3) Status bar: your themed status is richer than the minimal one in the old plan—keep yours unless you want to simplify.
4) Mouse/scrolling bindings and large history are already handled—no change needed.
5) Continue using `renumber-windows`, base index 1, and copy-to-clipboard bindings you already have.

## Session/layout workflow

- **SKIP the 4-pane bootstrap script entirely.** Let `tmux-resurrect/continuum` handle your actual workflow layouts organically. Pre-configured layouts rarely match real usage patterns.
- For simple session creation, use:

```bash
tmux new-session -As <project-name>
```

- **Build a tmux sessionizer** (critical for IDE-less workflow):
  - Fuzzy-find projects using `fd` + `fzf`
  - Create/attach to named tmux sessions per project
  - Auto-open nvim in project root
  - Bind to a quick key (e.g., `Ctrl-f` in shell)
- Use `tmuxp` only for complex project-specific layouts if needed (e.g., server + logs + editor).

## Editor move (Vim → Neovim)

- Install Neovim (`brew install neovim`). Keep `vim` as fallback (not Helix—avoid learning two modal editors).
- **Use LazyVim starter** instead of kickstart for easier IDE transition:
  - Provides well-configured IDE experience out of the box
  - Easier to customize than building from scratch
  - Better defaults for LSP, formatting, git integration
  - Install: `git clone https://github.com/LazyVim/starter ~/.config/nvim`

### Essential Neovim plugins (beyond LazyVim defaults)

- **File navigation:**
  - `neo-tree.nvim` or `oil.nvim` (modern alternatives to NERDTree)
  - `telescope.nvim` with `telescope-fzf-native.nvim` (fuzzy finding)
  - `harpoon` (quick navigation to common files)
- **UI/UX:**
  - `which-key.nvim` (essential for learning keybindings)
  - `trouble.nvim` (better diagnostics/quickfix UI)
  - `lualine.nvim` (status line)
- **Development:**
  - `nvim-treesitter` (syntax highlighting, text objects)
  - LSP via `mason.nvim` + `mason-lspconfig.nvim` + `nvim-lspconfig`
  - `none-ls.nvim` (formatters/linters)
  - `neotest` (run tests in Neovim)
  - `nvim-dap` (debugging—critical for IDE replacement)
- **Git:**
  - `gitsigns.nvim` (git indicators in sign column)
  - `fugitive.vim` or `neogit` (git workflow)
  - `diffview.nvim` (better diff view)
- **AI integration:**
  - `copilot.vim` or `codeium.nvim` (inline completions)
  - `avante.nvim` or `codecompanion.nvim` (Claude integration in Neovim)
  - Keep dedicated tmux pane for `claude-code` CLI
- **Quality of life:**
  - `mini.nvim` suite (comment, surround, pairs, etc.)
  - `flash.nvim` or `leap.nvim` (fast motion)
  - `nvim-autopairs` (auto-close brackets)

## CLI/tooling additions

Add to `scripts/brew.sh` formulas:

- **File navigation:** `fd`, `ripgrep` (already have), `bat` (already have)
- **Git:** `git-delta`, `lazygit`, `tig`, `gh`, `gh-dash`
- **Shell:** `starship` or `powerlevel10k` (fast, beautiful prompts), `atuin` (SQLite shell history)
- **Dev tools:** `mise` (replaces asdf—faster, better env var handling), `just` (modern make), `entr` (watch files)
- **System:** `btop` (better than htop), `tmuxp`
- **Already in brew.sh:** `fzf`, `eza`, `zoxide`, `lf`, `universal-ctags`, `jq`

**Package manager choice:** Switch from `asdf` to **`mise`** (formerly rtx):

- Faster (Rust-based)
- Compatible with asdf plugins
- Better environment variable handling
- Native support for `.tool-versions`

Enable fzf keybindings:

```bash
$(brew --prefix)/opt/fzf/install --key-bindings --completion
```

## Terminal choice

- You have `ghostty` in brew.sh—good choice if it works well
- Alternatives: `wezterm`, `alacritty`, `kitty`
- Must support: true color, ligatures, fast rendering

## AI/dev assistants

- Keep `claude-code` CLI installed via brew
- Don't assume claude-code pane in layouts—let sessionizer/resurrect handle real workflow
- Shell aliases: `alias v='nvim'`, `alias c='claude-code'`
- Consider piping fzf selections into claude-code for context-aware prompts

## Shell quality-of-life

- Update `$EDITOR` and `$VISUAL` to `nvim`
- Install `starship` or `powerlevel10k` for a fast, informative prompt
- Install `atuin` for better shell history (searchable, SQLite-backed)
- Add file navigation shortcuts:
  - `alias v='nvim $(fzf)'` (fuzzy file open)
  - `alias lg='lazygit'`
  - `cd` replacement using `zoxide` (already in brew.sh)

## Workflow integration (the secret sauce)

1. **Tmux sessionizer script** (most critical addition):
   - Fuzzy-find project directories
   - Create/attach to project-named tmux sessions
   - Open nvim in project root
   - Bind globally (e.g., `Ctrl-f` or leader key)

2. **File navigation strategy:**
   - Telescope in Neovim for project-wide fuzzy finding
   - `lf` for visual tree browsing
   - `zoxide` for quick directory jumping
   - Tmux sessionizer for project switching

3. **Git workflow:**
   - `lazygit` in dedicated tmux pane
   - Git integration in Neovim (gitsigns, fugitive/neogit)
   - `git-delta` for beautiful diffs in terminal

4. **Testing/debugging:**
   - `neotest` for running tests without leaving Neovim
   - `nvim-dap` for debugging (replaces IDE debugger)
   - Dedicated tmux pane for server/logs

## Next actions

1. **Tmux:**
   - Merge truecolor settings and install terminfo
   - Add `vim-tmux-navigator` to TPM plugins
   - Create tmux sessionizer script (bind to `Ctrl-f`)

2. **Neovim:**
   - Install LazyVim starter
   - Port essential vimrc settings to lua
   - Configure LSP for your languages (TypeScript, Python, Go, etc.)
   - Set up neotest and nvim-dap

3. **CLI tools:**
   - Update `scripts/brew.sh`:
     - Add: `fd`, `git-delta`, `lazygit`, `tig`, `gh-dash`, `mise`, `just`, `btop`, `starship`, `atuin`, `tmuxp`
     - Replace asdf plugins with mise
   - Enable fzf keybindings
   - Install starship or p10k for prompt

4. **Shell:**
   - Update `EDITOR`/`VISUAL` to `nvim`
   - Add navigation aliases
   - Configure starship/p10k
   - Set up atuin

5. **AI integration:**
   - Configure Neovim AI plugins (copilot/codeium + avante/codecompanion)
   - Create workflow for using claude-code with fzf

## Migration checklist

- [ ] Backup current vim/tmux configs
- [ ] Install Neovim and LazyVim
- [ ] Update tmux.conf with truecolor and vim-tmux-navigator
- [ ] Build tmux sessionizer script
- [ ] Update brew.sh with new tools
- [ ] Run updated brew.sh
- [ ] Configure mise (replace asdf)
- [ ] Port vim settings to Neovim lua
- [ ] Configure LSP for primary languages
- [ ] Set up neotest and nvim-dap
- [ ] Install and configure shell prompt (starship/p10k)
- [ ] Set up atuin for shell history
- [ ] Configure AI tools in Neovim
- [ ] Update shell aliases and environment variables
- [ ] Test workflow for 1 week before removing VSCode/Cursor
