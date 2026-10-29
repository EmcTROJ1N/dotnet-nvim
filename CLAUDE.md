# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A modular Neovim configuration for .NET / C# development. Supporting files: `install.sh` (dependency installer), `docs/` (user-facing wiki), `README.md` / `README.ru.md` (bilingual).

## Directory structure

```
~/.config/nvim/
├── init.lua                  ← mapleader + lazy bootstrap + core requires + lazy.setup("plugins")
├── lua/
│   ├── core/
│   │   ├── platform.lua      ← is_mac, is_linux, sys_open, sys_reveal
│   │   ├── options.lua       ← vim.opt.*
│   │   ├── keymaps.lua       ← smart_close, Tab cycling, ZZ/ZQ, :Q/:Wq commands
│   │   ├── diagnostics.lua   ← vim.diagnostic.config + highlights + :Keys command
│   │   ├── logger.lua        ← intercepts vim.notify + LSP errors → file log; :Log/:LogLsp/:LogClear
│   │   └── autocmds.lua      ← autosave
│   └── plugins/              ← 20 files, one plugin = one file
│       ├── alpha.lua
│       ├── autopairs.lua
│       ├── bufferline.lua    ← mini.tabline with neo-tree offset
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

lazy.nvim auto-discovers all files in `lua/plugins/` via `require("lazy").setup("plugins")`.

## Load order in init.lua

```
core.logger   ← first: intercepts vim.notify before anything else loads
core.options
core.keymaps  ← before plugins: sets :Q/:Wq commands used everywhere
lazy.setup("plugins")
core.diagnostics
core.autocmds
```

## Key architectural decisions

**Cross-platform helpers** live in `lua/core/platform.lua`:
```lua
local p = require("core.platform")
-- p.is_mac, p.is_linux, p.sys_open(path), p.sys_reveal(path)
```

**Buffer-based close model.** `:q` and `:wq` are remapped via `cnoreabbrev` to `:Q` / `:Wq` (defined in `keymaps.lua`). These delete the buffer instead of closing the window — neo-tree sidebar is never touched. When the last real buffer is closed, Alpha dashboard opens. `:qa` still quits nvim entirely.

**Tab bar** uses `echasnovski/mini.tabline` with a custom `_G._tabline()` function that offsets the tabline by neo-tree's width so tabs start at the main editing area.

**Plugin manager:** lazy.nvim. Each file in `lua/plugins/` returns a plugin spec. Plugin config lives in `config = function() ... end`.

**LSP setup uses the new mason-lspconfig API** (`automatic_enable = true`, no `setup_handlers`). Capabilities are set globally via `vim.lsp.config("*", {...})` before mason-lspconfig loads.

**OmniSharp semantic tokens are disabled** — OmniSharp crashes with `ArgumentOutOfRangeException` on `textDocument/semanticTokens/range` requests, which caused nvim to freeze. Treesitter handles syntax highlighting instead.

**nvim-treesitter v1.x API** — `require("nvim-treesitter.configs")` does not exist. Highlighting is enabled via a `FileType` autocmd calling `vim.treesitter.start()`. Telescope previewer treesitter is disabled (`preview = { treesitter = false }`).

**Per-project config** is loaded from `.neovim/run.json` and `.neovim/ef.json` in the project root via `VimEnter` / `DirChanged` autocmds in `lua/plugins/toggleterm.lua`.

**Run configurations** (`run.json`) support fields: `cmd`, `cwd`, `env`, `compound`.

**EF Core commands** detect whether `dotnet-ef` is a global or local manifest tool.

**Debug logging** — `lua/core/logger.lua` intercepts `vim.notify` (WARN+) and LSP `window/showMessage` errors, writing to `~/.local/state/nvim/nvim-debug.log`.
- `:Log` — open debug log
- `:LogLsp` — open raw LSP log
- `:LogClear` — clear debug log

## Deploying changes

After editing the local config, sync and push:

```bash
cp ~/.config/nvim/init.lua ~/Documents/dotnet-nvim/init.lua
cp -r ~/.config/nvim/lua ~/Documents/dotnet-nvim/
cd ~/Documents/dotnet-nvim
git add init.lua lua/
git commit -m "..."
git push origin main
```

The live config is at `~/.config/nvim/`. The repo copy at `~/Documents/dotnet-nvim/` is the distribution copy.

## docs/ conventions

Each file in `docs/` covers one feature area. Keybindings in `docs/keybindings.md` are the canonical reference — `:Keys` opens this file. When adding new keybindings, update both `lua/plugins/which-key.lua` and `docs/keybindings.md`.
