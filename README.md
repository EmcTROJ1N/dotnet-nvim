# dotnet-nvim

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
