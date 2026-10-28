# Установка и зависимости

## Автоматическая установка

```bash
git clone https://github.com/EmcTROJ1N/dotnet-nvim ~/.config/nvim
bash ~/.config/nvim/install.sh
```

Скрипт определяет ОС и устанавливает всё необходимое:

| ОС | Пакетный менеджер |
|---|---|
| macOS | Homebrew |
| Ubuntu / Debian | apt |
| Fedora | dnf |
| Arch | pacman |

## Что устанавливает скрипт

- **Neovim** ≥ 0.10
- **ripgrep** — поиск текста внутри файлов (используется Telescope)
- **fd** — быстрый поиск файлов (используется Telescope)
- **Node.js** — нужен для LSP-серверов и tree-sitter-cli
- **tree-sitter-cli** — парсеры синтаксиса
- **JetBrainsMono Nerd Font** — шрифт с иконками
- **dotnet-ef** — глобальный инструмент EF Core (если установлен .NET)
- **xkb-switch** — только Linux, для отображения раскладки в строке состояния

## Ручная установка зависимостей

### macOS

```bash
brew install neovim ripgrep fd node
npm install -g tree-sitter-cli
brew install --cask font-jetbrains-mono-nerd-font
```

### Ubuntu / Debian

```bash
sudo apt-get install neovim ripgrep fd-find nodejs
sudo ln -sf $(which fdfind) /usr/local/bin/fd
npm install -g tree-sitter-cli
```

### .NET и dotnet-ef

```bash
# dotnet-ef глобально
dotnet tool install --global dotnet-ef

# или если проект использует локальный манифест
dotnet tool restore
```

## Первый запуск

При первом открытии `nvim` автоматически запустится **lazy.nvim** и установит все плагины. Это займёт около минуты.

Затем Mason установит LSP-серверы (lua_ls, ts_ls, html, cssls, omnisharp) — прогресс виден в `:Mason`.

## Настройка терминала

Обязательно поставь шрифт **JetBrainsMono Nerd Font** в настройках терминала — без него иконки в интерфейсе будут отображаться как символы.

Проверенные терминалы: Ghostty, iTerm2, WezTerm, Alacritty, Kitty.
