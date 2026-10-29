# dotnet-nvim

[English](README.md) · **[Русский]**

Neovim-сборка для разработки на **.NET / C#**.

## Установка

```bash
git clone https://github.com/EmcTROJ1N/dotnet-nvim ~/.config/nvim
bash ~/.config/nvim/install.sh
```

После установки поставь шрифт терминала **JetBrainsMono Nerd Font**, открой `nvim` — плагины установятся автоматически.

## Требования

- Neovim ≥ 0.10
- git, ripgrep, fd, Node.js
- .NET SDK (для C# / EF Core)

## Возможности

- **Умное закрытие буферов** — `:q` / `:wq` закрывают буфер (не окно), дерево файлов всегда остаётся на месте. Последний буфер → Alpha-дашборд. `:qa` выходит из nvim.
- **Run configurations** — `.neovim/run.json` в стиле Rider: `cmd`, `cwd`, `env`, `compound`. Авто-определение `.csproj` / `package.json`. (`Space+r`)
- **EF Core миграции** — add, update, list, remove, SQL-скрипт через `Space+m`. Конфиг в `.neovim/ef.json`.
- **Логирование ошибок** — все WARN/ERROR-уведомления и LSP-ошибки пишутся в файл лога. `:Log` / `:LogLsp` открывают его прямо в nvim.
- **Кросс-платформенность** — macOS + Linux (`sys_open` / `sys_reveal`).

## Плагины

| Плагин | Назначение |
|---|---|
| `lazy.nvim` | Менеджер плагинов |
| `tokyonight.nvim` | Цветовая схема |
| `lualine.nvim` | Статус-бар |
| `mini.tabline` | Вкладки буферов с отступом под дерево |
| `neo-tree.nvim` | Файловое дерево |
| `telescope.nvim` + `fzf-native` | Fuzzy-поиск (`Ctrl+T`, `Alt+F`) |
| `nvim-lspconfig` + `mason.nvim` | LSP (OmniSharp, lua_ls, ts_ls, html, css) |
| `nvim-cmp` | Автодополнение |
| `nvim-treesitter` | Подсветка синтаксиса |
| `toggleterm.nvim` | Терминал, Run configs, EF Core |
| `neogit` + `diffview.nvim` + `gitsigns.nvim` | Git-интеграция |
| `trouble.nvim` | Панель диагностики |
| `todo-comments.nvim` | Подсветка TODO/FIXME |
| `which-key.nvim` | Подсказки хоткеев |
| `alpha-nvim` | Дашборд / экран приветствия |
| `nvim-autopairs` | Автозакрытие скобок |
| `Comment.nvim` | Комментирование |
| `indent-blankline.nvim` | Направляющие отступов |
| `nvim-colorizer.lua` | Превью цветов inline |

## Документация

Подробные гайды в папке [`docs/`](docs/):

- [Установка и зависимости](docs/installation.md)
- [Файловое дерево](docs/file-explorer.md)
- [Запуск проектов](docs/run-configurations.md)
- [EF Core миграции](docs/ef-migrations.md)
- [Git-интеграция](docs/git.md)
- [Хоткеи](docs/keybindings.md)
- [Per-project конфигурация](docs/per-project-config.md)

## Лицензия

MIT
