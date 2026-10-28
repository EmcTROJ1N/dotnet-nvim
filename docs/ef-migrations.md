# EF Core миграции

## Обзор

Все операции с миграциями доступны через меню `Space → m` или команды `:Ef*`. Настройки проектов хранятся в `.neovim/ef.json` и загружаются автоматически при открытии проекта.

## Первоначальная настройка

Запусти `:EfSetup` — откроется Telescope-пикер где нужно последовательно выбрать два проекта:

1. **Migrations project** — проект где лежит папка `Migrations/` (обычно Infrastructure)
2. **Startup project** — проект с точкой входа и DI/connection string (обычно Api или Web)

Настройки сохраняются в `.neovim/ef.json`.

## Команды

| Хоткей | Команда | Описание |
|---|---|---|
| `Space+mp` | `:EfSetup` | Выбрать проекты (пикер) |
| `Space+mi` | `:EfStatus` | Показать текущие настройки |
| `Space+ma` | `:EfAdd [имя]` | Добавить миграцию |
| `Space+mu` | `:EfUpdate` | Применить миграции к БД |
| `Space+ml` | `:EfList` | Список всех миграций |
| `Space+mr` | `:EfRemove` | Удалить последнюю миграцию |
| `Space+ms` | `:EfScript` | Сгенерировать SQL-скрипт |

## Формат ef.json

```json
{
  "migrations_project": "src/Infrastructure/Infrastructure.csproj",
  "startup_project": "src/Api/Api.csproj"
}
```

## dotnet-ef — установка

Инструмент должен быть доступен как глобальный или локальный:

```bash
# Глобально
dotnet tool install --global dotnet-ef

# Или восстановить из манифеста проекта
dotnet tool restore
```

Конфиг автоматически определяет наличие инструмента и использует `dotnet ef` или `dotnet tool run dotnet-ef`.

## Особенности multi-project решений

В решениях где миграции и startup-проект разделены (например, Clean Architecture), `dotnet ef` требует явного указания обоих проектов через флаги `--project` и `--startup-project`. `:EfSetup` настраивает это автоматически.

Каждая команда выполняется в терминале — видно полный вывод включая ошибки.

## Автозагрузка настроек

`.neovim/ef.json` загружается при старте nvim и при смене рабочей директории (`DirChanged`). При открытии другого проекта настройки переключаются автоматически.
