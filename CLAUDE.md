# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A modular Neovim configuration for .NET / C# development. Supporting files: `install.sh` (dependency installer), `docs/` (user-facing wiki), `README.md` / `README.ru.md` (bilingual).

## Directory structure

```
~/.config/nvim/
├── init.lua                  ← 15 lines: mapleader + lazy bootstrap + require("lazy").setup("plugins")
├── lua/
│   ├── core/
│   │   ├── platform.lua      ← is_mac, is_linux, sys_open, sys_reveal
│   │   ├── options.lua       ← vim.opt.*
│   │   ├── diagnostics.lua   ← vim.diagnostic.config + highlights + :Keys command
│   │   └── autocmds.lua      ← autosave autocmd
│   └── plugins/              ← 20 files, one plugin = one file
│       ├── alpha.lua
│       ├── autopairs.lua
│       ├── bufferline.lua
│       ├── cmp.lua
│       ├── colorizer.lua
│       ├── comment.lua
│       ├── diffview.lua
│       ├── gitsigns.lua
│       ├── indent-blankline.lua
│       ├── lsp.lua
│       ├── lualine.lua
│       ├── neo-tree.lua
│       ├── neogit.lua
│       ├── telescope.lua
│       ├── todo-comments.lua
│       ├── toggleterm.lua    ← Run configs + EF Core migrations
│       ├── tokyonight.lua
│       ├── treesitter.lua
│       ├── trouble.lua
│       └── which-key.lua
├── docs/
└── KEYS.md / SESSION_SUMMARY.md
```

lazy.nvim auto-discovers all files in `lua/plugins/` via `require("lazy").setup("plugins")` — no manual registration needed.

## Key architectural decisions

**Cross-platform helpers** live in `lua/core/platform.lua` and are imported where needed:
```lua
local p = require("core.platform")
-- p.is_mac, p.is_linux, p.sys_open(path), p.sys_reveal(path)
```
Never call `open`, `xdg-open`, or `explorer` directly — always use `p.sys_open` / `p.sys_reveal`.

**Plugin manager:** lazy.nvim. Each file in `lua/plugins/` returns a plugin spec table. Plugin config lives in `config = function() ... end` within that file.

**LSP setup uses the new mason-lspconfig API** (`automatic_enable = true`, no `setup_handlers`). Capabilities are set globally via `vim.lsp.config("*", {...})` before mason-lspconfig loads.

**nvim-treesitter v1.x API** — `require("nvim-treesitter.configs")` does not exist. Highlighting is enabled via a `FileType` autocmd calling `vim.treesitter.start()`. Telescope previewer treesitter is disabled (`preview = { treesitter = false }`) because of this incompatibility.

**Per-project config** is loaded from `.neovim/run.json` and `.neovim/ef.json` in the project root via `VimEnter` / `DirChanged` autocmds. Both loaders are defined inside `lua/plugins/toggleterm.lua` where `Terminal` is in scope.

**Run configurations** (`run.json`) support fields: `cmd`, `cwd`, `env`, `compound`. `compound` references other config names by string — resolved at runtime via `get_named_config()`. Multiple processes are tracked in the `run_terms` table (name → Terminal).

**EF Core commands** detect whether `dotnet-ef` is a global tool or a local manifest tool and switch between `dotnet ef` and `dotnet tool run dotnet-ef` accordingly.

## Deploying changes

After editing the local config, sync the entire structure to the repo and push:

```bash
cp ~/.config/nvim/init.lua ~/Documents/dotnet-nvim/init.lua
cp -r ~/.config/nvim/lua ~/Documents/dotnet-nvim/
cd ~/Documents/dotnet-nvim
git add init.lua lua/
git commit -m "..."
git push origin main
```

The live config is at `~/.config/nvim/`. The repo copy at `~/Documents/dotnet-nvim/` is the distribution copy — keep them in sync manually after changes.

## docs/ conventions

Each file in `docs/` covers one feature area. Keybindings in `docs/keybindings.md` are the canonical reference — `:Keys` inside nvim opens this file. When adding a new feature with new keybindings, update both the which-key registration in `lua/plugins/which-key.lua` and `docs/keybindings.md`.
