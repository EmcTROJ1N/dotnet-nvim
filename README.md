# nvim-config

Готовая Neovim-сборка для разработки на **C# / .NET**, **TypeScript**, **JavaScript**, **HTML**, **CSS**.
Ориентирована на разработчиков переходящих с JetBrains Rider.

## Что внутри

- Подсветка синтаксиса через Tree-sitter
- LSP + автодополнение (C#, TypeScript, JavaScript, HTML, CSS)
- Файловое дерево с live-обновлением
- Fuzzy поиск файлов и текста (Telescope + fzf)
- Git UI в стиле Magit (Neogit + DiffView)
- Запуск проектов с именованными конфигурациями (как Rider Run Configurations)
- EF Core миграции прямо из редактора
- Буфер-вкладки, диагностика, TODO-комментарии
- Стартовый экран, строка состояния с кликабельными кнопками
- Полностью на одном файле `init.lua` — легко читать и менять

## Требования

| Инструмент | Зачем |
|---|---|
| Neovim ≥ 0.10 | — |
| git | плагины и Git-интеграция |
| ripgrep | поиск текста внутри файлов |
| fd | поиск файлов |
| Node.js | LSP-серверы и tree-sitter-cli |
| JetBrainsMono Nerd Font | иконки в интерфейсе |
| dotnet + dotnet-ef | только для C# / EF Core |
| xkb-switch | только для Linux, раскладка в строке состояния |

## Установка

```bash
git clone https://github.com/YOUR_USERNAME/nvim-config ~/.config/nvim
bash ~/.config/nvim/install.sh
```

Скрипт сам установит все зависимости на macOS (Homebrew) и Linux (apt / dnf / pacman).

После установки:
1. Поставь шрифт терминала: **JetBrainsMono Nerd Font**
2. Открой `nvim` — плагины установятся автоматически при первом запуске
3. Напиши `:Keys` чтобы увидеть все хоткеи

## Быстрый старт

```
Ctrl+T          найти файл
Alt+F           найти текст в файлах
Space           меню всех команд
Space+?         поиск по хоткеям
:Keys           полный справочник
```

## Per-project конфигурация

Сборка поддерживает `.neovim/` папку в корне проекта для хранения настроек которые меняются от проекта к проекту. Добавь её в `.gitignore`.

### Конфигурации запуска — `.neovim/run.json`

Аналог Rider Run Configurations. Создаётся через `:RunSetup`.

```json
{
  "configurations": [
    {
      "name": "API",
      "cmd": "dotnet run",
      "cwd": "src/Api",
      "env": {
        "ASPNETCORE_ENVIRONMENT": "Development"
      }
    },
    {
      "name": "Frontend",
      "cmd": "npm start",
      "cwd": "src/ClientApp"
    },
    {
      "name": "API + Frontend",
      "compound": ["API", "Frontend"]
    }
  ],
  "default": "API + Frontend"
}
```

Запуск: `Space+r+r` → Telescope-пикер с конфигурациями.

### EF Core — `.neovim/ef.json`

Создаётся через `:EfSetup` (Telescope-пикер выбирает migrations-проект и startup-проект).

```json
{
  "migrations_project": "src/Infrastructure/Infrastructure.csproj",
  "startup_project": "src/Api/Api.csproj"
}
```

## Хоткеи

Полный список: `:Keys` внутри nvim или см. [KEYS.md](KEYS.md).

Основные:

```
Space           меню всех команд (which-key)
Space+?         поиск по всем хоткеям

Ctrl+T          найти файл
Alt+F           поиск текста в файлах
Space+e         файловое дерево
Space+E         показать файл в дереве

Space+g         Git (статус, diff, лог, ветки, push, pull)
Space+r         запуск проекта
Space+m         EF Core миграции
Space+t         инструменты (ошибки, TODO)

gd              перейти к определению
K               документация
Space+ca        code actions
```

## Структура

```
~/.config/nvim/
├── init.lua        полная конфигурация (один файл)
├── KEYS.md         справочник хоткеев
├── README.md
└── install.sh      установочный скрипт
```

## Плагины

Управляются через [lazy.nvim](https://github.com/folke/lazy.nvim). При первом запуске nvim все плагины устанавливаются автоматически.

| Плагин | Назначение |
|---|---|
| nvim-treesitter | подсветка синтаксиса |
| nvim-lspconfig + mason | LSP серверы |
| nvim-cmp + LuaSnip | автодополнение |
| telescope.nvim | fuzzy поиск |
| neo-tree.nvim | файловое дерево |
| neogit + diffview | Git UI |
| toggleterm.nvim | интегрированный терминал |
| lualine.nvim | строка состояния |
| bufferline.nvim | вкладки |
| alpha-nvim | стартовый экран |
| which-key.nvim | меню хоткеев |
| todo-comments + trouble | TODO и диагностика |
| tokyonight.nvim | цветовая схема |

## Лицензия

MIT
