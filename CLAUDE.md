# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

A single-file Neovim configuration (`init.lua`) for .NET / C# development. The entire config lives in one file — no split modules. Supporting files: `install.sh` (dependency installer), `docs/` (user-facing wiki), `README.md` / `README.ru.md` (bilingual).

## Key architectural decisions in init.lua

**Single file, top-to-bottom order matters.** Lua variables defined early (like `is_mac`, `is_linux`, `sys_open`, `sys_reveal`) are used by plugin configs defined later. Do not reorder major sections.

**OS detection helpers** are defined immediately after `vim.g.mapleader` and must remain there:
```lua
local is_mac   = vim.fn.has("mac") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac
local function sys_open(path) ... end
local function sys_reveal(path) ... end
```
All file-system open/reveal operations throughout the file use these helpers — never call `open`, `xdg-open`, or `explorer` directly.

**Plugin manager:** lazy.nvim. All plugins are declared in a single `require("lazy").setup({...})` call. Plugin configs live inline via `config = function() ... end`.

**LSP setup uses the new mason-lspconfig API** (`automatic_enable = true`, no `setup_handlers`). Capabilities are set globally via `vim.lsp.config("*", {...})` before mason-lspconfig loads.

**nvim-treesitter v1.x API** — `require("nvim-treesitter.configs")` does not exist. Highlighting is enabled via a `FileType` autocmd calling `vim.treesitter.start()`. Telescope previewer treesitter is disabled (`preview = { treesitter = false }`) because of this incompatibility.

**Per-project config** is loaded from `.neovim/run.json` and `.neovim/ef.json` in the project root via `VimEnter` / `DirChanged` autocmds. Both loaders are defined inside the `toggleterm` plugin config closure where `Terminal` is in scope.

**Run configurations** (`run.json`) support fields: `cmd`, `cwd`, `env`, `compound`. `compound` references other config names by string — resolved at runtime via `get_named_config()`. Multiple processes are tracked in the `run_terms` table (name → Terminal).

**EF Core commands** detect whether `dotnet-ef` is a global tool or a local manifest tool and switch between `dotnet ef` and `dotnet tool run dotnet-ef` accordingly.

## Deploying changes

After editing `init.lua`, sync it to the repo and push:

```bash
cp ~/.config/nvim/init.lua ~/Documents/dotnet-nvim/init.lua
cd ~/Documents/dotnet-nvim
git add init.lua
git commit -m "..."
git push origin main
```

The live config is at `~/.config/nvim/init.lua`. The repo copy at `~/Documents/dotnet-nvim/init.lua` is the distribution copy — keep them in sync manually after changes.

## docs/ conventions

Each file in `docs/` covers one feature area. Keybindings in `docs/keybindings.md` are the canonical reference — `:Keys` inside nvim opens this file. When adding a new feature with new keybindings, update both the which-key registration in `init.lua` and `docs/keybindings.md`.
