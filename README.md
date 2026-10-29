# dotnet-nvim

**[English]** · [Русский](README.ru.md)

Neovim configuration for **.NET / C#** development.

## Installation

```bash
git clone https://github.com/EmcTROJ1N/dotnet-nvim ~/.config/nvim
bash ~/.config/nvim/install.sh
```

After installation set your terminal font to **JetBrainsMono Nerd Font**, open `nvim` — plugins install automatically on first launch.

## Requirements

- Neovim ≥ 0.10
- git, ripgrep, fd, Node.js
- .NET SDK (for C# / EF Core)

## Features

- **Smart buffer close** — `:q` / `:wq` close the buffer (not the window), neo-tree sidebar always stays in place. Last buffer → Alpha dashboard. `:qa` exits nvim.
- **Run configurations** — Rider-style `.neovim/run.json` with `cmd`, `cwd`, `env`, `compound`. Auto-detects `.csproj` / `package.json`. (`Space+r`)
- **EF Core migrations** — add, update, list, remove, SQL script via `Space+m`. Config in `.neovim/ef.json`.
- **Debug logging** — all WARN/ERROR notifications + LSP errors written to a log file. `:Log` / `:LogLsp` open it inside nvim.
- **Cross-platform** — macOS + Linux (`sys_open` / `sys_reveal`).

## Plugins

| Plugin | Purpose |
|---|---|
| `lazy.nvim` | Plugin manager |
| `tokyonight.nvim` | Color scheme |
| `lualine.nvim` | Status line |
| `mini.tabline` | Tab bar with neo-tree offset |
| `neo-tree.nvim` | File explorer sidebar |
| `telescope.nvim` + `fzf-native` | Fuzzy finder (`Ctrl+T`, `Alt+F`) |
| `nvim-lspconfig` + `mason.nvim` | LSP (OmniSharp, lua_ls, ts_ls, html, css) |
| `nvim-cmp` | Autocompletion |
| `nvim-treesitter` | Syntax highlighting |
| `toggleterm.nvim` | Terminal, Run configs, EF Core |
| `neogit` + `diffview.nvim` + `gitsigns.nvim` | Git integration |
| `trouble.nvim` | Diagnostics panel |
| `todo-comments.nvim` | TODO/FIXME highlights |
| `which-key.nvim` | Keybinding hints |
| `alpha-nvim` | Dashboard / welcome screen |
| `nvim-autopairs` | Auto-close brackets |
| `Comment.nvim` | Toggle comments |
| `indent-blankline.nvim` | Indent guides |
| `nvim-colorizer.lua` | Inline color preview |

## Documentation

Full guides in [`docs/`](docs/):

- [Installation & dependencies](docs/installation.md)
- [File explorer](docs/file-explorer.md)
- [Run configurations](docs/run-configurations.md)
- [EF Core migrations](docs/ef-migrations.md)
- [Git integration](docs/git.md)
- [Keybindings](docs/keybindings.md)
- [Per-project config](docs/per-project-config.md)

## License

MIT
