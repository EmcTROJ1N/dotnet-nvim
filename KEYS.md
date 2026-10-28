# Neovim — всё что реализовано

---

## Навигация по файлам

Ctrl+T              найти файл (Telescope fuzzy search)
Alt+F               поиск текста внутри файлов (live grep)
Space+e             открыть/закрыть файловое дерево (neo-tree)
Space+E             показать текущий файл в дереве (reveal)
Space+?             поиск по всем активным хоткеям (Telescope keymaps)

---

## Файловое дерево (neo-tree)

?                   показать все маппинги дерева (встроенный попап)
a                   создать файл (с вводом пути)
A                   создать папку
r                   переименовать
d                   удалить (с подтверждением)
m                   переместить
y                   скопировать в буфер
x                   вырезать
p                   вставить
o                   открыть папку/файл в Finder
Enter               открыть файл

---

## Буферы и вкладки

Tab                 следующий буфер
Shift+Tab           предыдущий буфер
Space+x             закрыть текущий буфер (умное закрытие)

---

## LSP — автодополнение и навигация по коду

gd                  перейти к определению
K                   показать документацию (hover)
gr                  показать все ссылки
Space+rn            переименовать символ
Space+ca            код-экшены (quick fix, refactor)
Ctrl+Space          вызвать автодополнение вручную
Enter               подтвердить выбранный вариант
Tab / Shift+Tab     навигация по вариантам
Ctrl+e              закрыть автодополнение
Ctrl+b / Ctrl+f     скролл документации в попапе

---

## Git (Space+g)

Space+gs            Git статус / коммит (Neogit)
Space+gd            Diff текущего состояния (DiffView)
Space+gl            История коммитов (DiffView file history)
Space+gb            Переключить ветку (Telescope picker)
Space+gn            Создать новую ветку (с вводом имени)
Space+gp            Push в origin
Space+gu            Pull

:Git                открыть Neogit
:Git diff           открыть DiffView
:Git log            история файла
:Branch             пикер веток

В пикере веток (Space+gb / :Branch):
  Enter             переключиться на ветку
  Ctrl+N            создать новую ветку из введённого имени
  Ctrl+P            запушить текущую ветку
  Ctrl+U            сделать pull

---

## Запуск проекта (Space+r)

Space+rr            запустить проект (пикер конфигураций)
Space+rs            остановить все запущенные процессы
Space+rt            открыть терминал
Space+rp            выбрать стартовый проект (RunSetup)

:Run                то же что Space+rr
:Run <имя>          запустить конфигурацию по имени
:Run <команда>      запустить произвольную команду
:Stop               остановить всё
:Term               открыть/закрыть терминал
:RunSetup           создать или открыть .neovim/run.json

Ctrl+\              свернуть/развернуть терминал
Esc (в терминале)   выйти из режима ввода в терминале

Конфигурации хранятся в .neovim/run.json
Поддерживаемые поля:
  "cmd"      — команда запуска
  "cwd"      — рабочая директория (относительно корня проекта)
  "env"      — переменные окружения { "KEY": "value" }
  "compound" — запуск нескольких конфигов одновременно
  "default"  — какой конфиг выбирается первым в пикере

---

## EF Core миграции (Space+m)

Space+mp            выбрать проект с миграциями + startup-проект (EfSetup)
Space+mi            показать текущий конфиг EF (EfStatus)
Space+ma            добавить миграцию (спросит имя если не задано)
Space+mu            применить миграции к БД (database update)
Space+ml            список всех миграций
Space+mr            удалить последнюю миграцию
Space+ms            сгенерировать SQL-скрипт

:EfSetup            настроить проекты (Telescope picker x2)
:EfStatus           показать текущие настройки
:EfAdd [имя]        добавить миграцию
:EfUpdate           применить миграции
:EfList             список миграций
:EfRemove           удалить последнюю
:EfScript           сгенерировать SQL

Настройки хранятся в .neovim/ef.json
Загружаются автоматически при открытии проекта.

---

## Диагностика и ошибки (Space+t)

Space+te            открыть/закрыть панель ошибок (Trouble)
Space+tt            список всех TODO/FIXME в проекте

:Errors             панель диагностики (все ошибки и варнинги)
:TroubleRefs        ссылки на символ через Trouble
:Todo               поиск TODO/FIXME/HACK/NOTE через Telescope

TODO/FIXME/HACK/NOTE/BUG в коде подсвечиваются автоматически.

---

## Комментарии

gcc                 закомментировать/раскомментировать строку
gc                  закомментировать выделение (visual mode)

---

## Строка состояния (lualine)

[reveal in tree]    клик → показать файл в дереве
[open in Finder]    клик → открыть папку в Finder
Правый блок         раскладка клавиатуры (RU/EN), кодировка, тип файла

---

## Конфигурационные файлы проекта (.neovim/)

.neovim/run.json    конфигурации запуска (как Rider Run Configurations)
.neovim/ef.json     настройки EF Core (проект с миграциями + startup)

Добавь .neovim/ в .gitignore чтобы не попало в репозиторий.

---

## Установленные плагины

nvim-treesitter         подсветка синтаксиса
nvim-lspconfig          Language Server Protocol
mason.nvim              установка LSP серверов
nvim-cmp + LuaSnip      автодополнение и сниппеты
telescope.nvim          fuzzy поиск (файлы, текст, keymaps, ветки)
telescope-fzf-native    быстрый алгоритм сортировки для telescope
neo-tree.nvim           файловое дерево
lualine.nvim            строка состояния
bufferline.nvim         вкладки буферов
alpha-nvim              стартовый экран
which-key.nvim          меню хоткеев по Space
neogit                  Git UI (стиль Magit)
diffview.nvim           просмотр diff и истории
toggleterm.nvim         интегрированный терминал
gitsigns.nvim           отметки изменений в gutter
nvim-autopairs          автозакрытие скобок и кавычек
Comment.nvim            комментирование
todo-comments.nvim      подсветка TODO/FIXME/HACK
trouble.nvim            панель диагностики
nvim-colorizer          предпросмотр цветов (#hex → фон)
indent-blankline.nvim   направляющие линии отступов
tokyonight.nvim         цветовая схема

LSP серверы (через Mason):
  lua_ls      Lua
  ts_ls       TypeScript / JavaScript
  html        HTML
  cssls       CSS
  omnisharp   C# / .NET
