-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Basic options
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- OS detection and cross-platform helpers
local is_mac   = vim.fn.has("mac") == 1
local is_linux = vim.fn.has("unix") == 1 and not is_mac

local function sys_open(path)
  if is_mac        then vim.fn.system("open "     .. vim.fn.shellescape(path))
  elseif is_linux  then vim.fn.system("xdg-open " .. vim.fn.shellescape(path))
  else                  vim.fn.system("explorer "  .. vim.fn.shellescape(path)) end
end

local function sys_reveal(path)
  if is_mac       then vim.fn.system("open -R "   .. vim.fn.shellescape(path))
  elseif is_linux then sys_open(vim.fn.fnamemodify(path, ":h"))
  else                 vim.fn.system("explorer /select," .. vim.fn.shellescape(path)) end
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"

-- Plugins
require("lazy").setup({
  -- Start screen
  {
    "goolord/alpha-nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")

      dashboard.section.header.val = {
        "                                        ",
        "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗ ",
        "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║ ",
        "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║ ",
        "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝ ",
        "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝  ",
        "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝   ",
        "                                        ",
      }

      local function get_info()
        local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
        local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
        local info = "  " .. cwd
        if branch ~= "" then info = info .. "    " .. branch end
        return info
      end

      dashboard.section.buttons.val = {
        dashboard.button("ctrl+t", "  Find file",        "<C-t>"),
        dashboard.button("alt+f",  "  Search in files",  "<M-f>"),
        dashboard.button("e",      "  File explorer",    "<cmd>Neotree toggle<CR>"),
        dashboard.button("g",      "  Git status",       "<cmd>Neogit<CR>"),
        dashboard.button("r",      "  Run project",      "<cmd>Run<CR>"),
        dashboard.button("space",  "  All keybindings",  "<Space>"),
        dashboard.button("q",      "  Quit",             "<cmd>qa<CR>"),
      }

      local info_block = {
        type = "text",
        val = get_info,
        opts = { hl = "Comment", position = "center" },
      }

      dashboard.config.layout = {
        { type = "padding", val = 4 },
        dashboard.section.header,
        { type = "padding", val = 1 },
        info_block,
        { type = "padding", val = 2 },
        dashboard.section.buttons,
        { type = "padding", val = 1 },
      }

      alpha.setup(dashboard.config)
    end,
  },

  -- Colorscheme with full treesitter support
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({ style = "night" })
      vim.cmd("colorscheme tokyonight-night")
    end,
  },

  -- Syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      -- v1.x: setup() only accepts install_dir; highlight is enabled via vim.treesitter
      require("nvim-treesitter").setup()
      -- Enable treesitter highlighting and indentation for every filetype
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason").setup()
      -- Set capabilities globally for all LSP servers (picked up by automatic_enable)
      vim.lsp.config("*", {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "ts_ls", "html", "cssls", "omnisharp" },
        automatic_enable = true,
      })

      -- LSP keymaps
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local opts = { buffer = ev.buf }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
        end,
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob=!.git/",
          },
          -- Disable treesitter in previewer: nvim-treesitter v1.x API incompatible
          preview = { treesitter = false },
        },
        pickers = {
          find_files = {
            find_command = { "fd", "--type=f", "--hidden", "--exclude=.git" },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            -- exact substring match gets highest score
            case_mode = "smart_case",
          },
        },
      })
      telescope.load_extension("fzf")
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
      vim.keymap.set("n", "<leader>fb", builtin.buffers)
      vim.keymap.set("n", "<leader>fh", builtin.help_tags)
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local Terminal = require("toggleterm.terminal").Terminal

      local function git_in_term(cmd)
        Terminal:new({ cmd = cmd, close_on_exit = false }):toggle()
      end

      vim.api.nvim_create_user_command("Branch", function()
        builtin.git_branches({
          attach_mappings = function(_, map)
            -- Enter: checkout (default)
            -- Ctrl+N: create new branch
            map("i", "<C-n>", function(prompt_bufnr)
              local name = action_state.get_current_line(prompt_bufnr)
              actions.close(prompt_bufnr)
              if name and name ~= "" then
                git_in_term("git checkout -b " .. name)
              end
            end)
            -- Ctrl+P: push current branch to origin
            map("i", "<C-p>", function(prompt_bufnr)
              local sel = action_state.get_selected_entry(prompt_bufnr)
              actions.close(prompt_bufnr)
              local branch = sel and sel.name or vim.fn.system("git branch --show-current"):gsub("\n", "")
              git_in_term("git push origin " .. branch)
            end)
            -- Ctrl+U: pull current branch
            map("i", "<C-u>", function(prompt_bufnr)
              actions.close(prompt_bufnr)
              git_in_term("git pull")
            end)
            return true
          end,
        })
      end, { desc = "Switch git branch" })

      -- Ctrl+T: quick file search like Rider
      vim.keymap.set("n", "<C-t>", builtin.find_files)
      vim.keymap.set("i", "<C-t>", function() builtin.find_files() end)
      -- Alt+F: search text inside files (Ctrl+Shift+F not reliable in terminals)
      vim.keymap.set("n", "<M-f>", builtin.live_grep)
      vim.keymap.set("i", "<M-f>", function() builtin.live_grep() end)
      -- ?: search all active keymaps
      vim.keymap.set("n", "<leader>?", builtin.keymaps, { desc = "Search keymaps" })
    end,
  },

  -- File explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        window = {
          position = "left",
          width = 35,
          mappings = {
            ["a"] = { "add",           config = { show_path = "relative" } },
            ["A"] = { "add_directory", config = { show_path = "relative" } },
            ["d"] = "delete",
            ["r"] = "rename",
            ["m"] = "move",
            ["y"] = "copy_to_clipboard",
            ["x"] = "cut_to_clipboard",
            ["p"] = "paste_from_clipboard",
            ["o"] = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()
              if node.type == "directory" then
                sys_open(path)
              else
                sys_reveal(path)
              end
            end,
          },
        },
        filesystem = {
          use_libuv_file_watcher = true,
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false,
          },
          follow_current_file = { enabled = false },
        },
      })
      vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
      vim.keymap.set("n", "<leader>E", ":Neotree reveal<CR>")
      -- Refresh lualine on buffer switch
      vim.api.nvim_create_autocmd("CursorMoved", {
        callback = function()
          if vim.bo.filetype == "neo-tree" then
            require("lualine").refresh()
          end
        end,
      })
      -- Open neo-tree automatically on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function()
          if vim.fn.argc() == 0 then
            vim.cmd("Neotree show")
          end
        end,
      })
    end,
  },

  -- Command menu (Space = show all available commands)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function()
      local wk = require("which-key")
      wk.setup({
        preset = "modern",
        delay = 400,
      })
      wk.add({
        { "<leader>?",  desc = "Search all keymaps" },
        { "<leader>f",  group = "Find" },
        { "<leader>ff", desc = "Find files (Ctrl+T)" },
        { "<leader>fg", desc = "Search in files (Alt+F)" },
        { "<leader>fb", desc = "Open buffers" },
        { "<leader>e",  desc = "File explorer toggle" },
        { "<leader>E",  desc = "Reveal current file in tree (also: click statusbar)" },

        { "<leader>g",  group = "Git" },
        { "<leader>gs", function() vim.cmd("Git") end,                                                                           desc = "Status / commit" },
        { "<leader>gd", function() vim.cmd("Git diff") end,                                                                     desc = "Diff" },
        { "<leader>gl", function() vim.cmd("Git log") end,                                                                      desc = "Log" },
        { "<leader>gb", function() vim.cmd("Branch") end,                                                                       desc = "Switch branch" },
        { "<leader>gn", function() vim.ui.input({ prompt = "New branch name: " }, function(name) if name then vim.fn.system("git checkout -b " .. name); vim.notify("Created: " .. name) end end) end, desc = "New branch" },
        { "<leader>gp", function() local b = vim.fn.system("git branch --show-current"):gsub("\n",""); require("toggleterm.terminal").Terminal:new({ cmd = "git push origin " .. b, close_on_exit = false }):toggle() end, desc = "Push" },
        { "<leader>gu", function() require("toggleterm.terminal").Terminal:new({ cmd = "git pull", close_on_exit = false }):toggle() end, desc = "Pull" },

        { "<leader>r",  group = "Run" },
        { "<leader>rr", function() vim.cmd("Run") end,      desc = "Run project" },
        { "<leader>rs", function() vim.cmd("Stop") end,     desc = "Stop project" },
        { "<leader>rt", function() vim.cmd("Term") end,     desc = "Open terminal" },
        { "<leader>rp", function() vim.cmd("RunSetup") end, desc = "Pick startup project" },

        { "<leader>l",  group = "LSP" },
        { "<leader>rn", desc = "Rename symbol" },
        { "<leader>ca", desc = "Code actions" },

        { "<leader>t",  group = "Tools" },
        { "<leader>te", function() vim.cmd("Errors") end,    desc = "Errors panel" },
        { "<leader>tt", function() vim.cmd("Todo") end,      desc = "TODO list" },
        { "<leader>x",  desc = "Close buffer" },

        { "<leader>m",  group = "EF Migrations" },
        { "<leader>mp", function() vim.cmd("EfSetup") end,  desc = "Pick projects (migrations + startup)" },
        { "<leader>mi", function() vim.cmd("EfStatus") end, desc = "Show current EF config" },
        { "<leader>ma", function() vim.cmd("EfAdd") end,    desc = "Add migration" },
        { "<leader>mu", function() vim.cmd("EfUpdate") end, desc = "Update database" },
        { "<leader>ml", function() vim.cmd("EfList") end,   desc = "List migrations" },
        { "<leader>mr", function() vim.cmd("EfRemove") end, desc = "Remove last migration" },
        { "<leader>ms", function() vim.cmd("EfScript") end, desc = "Generate SQL script" },
      })
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function input_lang()
        if is_mac then
          local out = vim.fn.system("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep 'KeyboardLayout Name' | head -1")
          local lang = out:match('"KeyboardLayout Name" = "([^"]+)"') or out:match('"KeyboardLayout Name" = (%a+)')
          if not lang then return "" end
          local labels = { Russian = "RU", ABC = "EN", ["U.S."] = "EN", ["USInternational-PC"] = "EN" }
          return labels[lang] or lang:sub(1, 2):upper()
        elseif is_linux then
          local out = vim.fn.system("xkb-switch 2>/dev/null"):gsub("%s+", "")
          if out ~= "" and not out:find("not found") then return out:sub(1,2):upper() end
        end
        return ""
      end

      require("lualine").setup({
        options = { theme = "auto" },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = {
            "filename",
            {
              function() return "[reveal in tree]" end,
              on_click = function() vim.cmd("Neotree reveal") end,
              color = { fg = "#7aa2f7" },
              cond = function()
                local ft = vim.bo.filetype
                local path = vim.fn.expand("%:p")
                return path ~= "" and ft ~= "neo-tree" and ft ~= "alpha" and ft ~= "toggleterm"
              end,
            },
            {
              function() return is_mac and "[ open in Finder]" or "[ open folder]" end,
              on_click = function()
                local ok, manager = pcall(require, "neo-tree.sources.manager")
                if not ok then return end
                local state = manager.get_state("filesystem")
                if not (state and state.tree) then return end
                local ok2, node = pcall(function() return state.tree:get_node() end)
                if not ok2 or not node then return end
                local path = node.type == "directory" and node:get_id() or vim.fn.fnamemodify(node:get_id(), ":h")
                sys_open(path)
              end,
              color = { fg = "#9ece6a" },
              cond = function() return true end,
            },
          },
          lualine_x = { input_lang, "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- Color preview (#ff0000 → actual color)
  {
    "NvChad/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },
        user_default_options = { mode = "background", css = true },
      })
    end,
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true, show_start = false },
      })
    end,
  },

  -- Buffer tabs at top
  {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({
        options = {
          diagnostics = "nvim_lsp",
          offsets = {{ filetype = "neo-tree", text = "Explorer", separator = true }},
          separator_style = "slant",
          -- Hide service buffers from tabs
          custom_filter = function(buf_number)
            local ft = vim.bo[buf_number].filetype
            local name = vim.fn.bufname(buf_number)
            local ignored = { "alpha", "neo-tree", "toggleterm", "TelescopePrompt", "lazy", "mason" }
            for _, f in ipairs(ignored) do
              if ft == f or name:find(f) then return false end
            end
            return true
          end,
        },
      })
      local last_tab_time = 0
      local function cycle_buf(dir)
        local now = vim.uv.hrtime() / 1e6
        if now - last_tab_time < 150 then return end
        last_tab_time = now
        vim.cmd(dir == 1 and "BufferLineCycleNext" or "BufferLineCyclePrev")
      end
      vim.keymap.set("n", "<Tab>",   function() cycle_buf(1) end)
      vim.keymap.set("n", "<S-Tab>", function() cycle_buf(-1) end)
      local function close_buf()
        local buf = vim.api.nvim_get_current_buf()
        local bufs = vim.fn.getbufinfo({ buflisted = 1 })
        if #bufs > 1 then
          vim.cmd("BufferLineCycleNext")
        end
        if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
          pcall(vim.cmd, "bdelete " .. buf)
        end
      end
      vim.keymap.set("n", "<leader>x", close_buf, { desc = "Close buffer" })
    end,
  },

  -- TODO/FIXME/HACK highlights
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("todo-comments").setup()
      vim.api.nvim_create_user_command("Todo", function()
        vim.cmd("TodoTelescope")
      end, { desc = "List all TODO/FIXME comments" })
    end,
  },

  -- Diagnostics panel
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("trouble").setup()
      vim.api.nvim_create_user_command("Errors", function()
        require("trouble").toggle("diagnostics")
      end, { desc = "Toggle diagnostics panel" })
      vim.api.nvim_create_user_command("TroubleRefs", function()
        require("trouble").toggle("lsp_references")
      end, { desc = "Show LSP references in trouble" })
    end,
  },

  -- Git diff viewer
  {
    "sindrets/diffview.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("diffview").setup()
    end,
  },

  -- Git UI (Magit-style)
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    config = function()
      require("neogit").setup({
        integrations = { diffview = true },
        graph_style = "unicode",
      })
      vim.api.nvim_create_user_command("Git", function(opts)
        local sub = opts.args
        if sub == "" or sub == "status" then
          require("neogit").open()
        elseif sub == "diff" then
          vim.cmd("DiffviewOpen")
        elseif sub == "log" then
          vim.cmd("DiffviewFileHistory")
        else
          vim.notify("Unknown subcommand. Use: Git, Git diff, Git log", vim.log.levels.WARN)
        end
      end, { nargs = "?", desc = "Git UI" })
    end,
  },

  -- Integrated terminal
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 15,
        open_mapping = [[<C-\>]],
        direction = "horizontal",
        shade_terminals = true,
        close_on_exit = false,
      })

      local Terminal = require("toggleterm.terminal").Terminal

      -- ── Run configurations (Rider-style) ─────────────────────────────
      local run_config = nil   -- parsed .neovim/run.json
      local run_terms  = {}    -- name → Terminal

      local function run_cfg_path() return vim.fn.getcwd() .. "/.neovim/run.json" end

      local function load_run_config()
        local path = run_cfg_path()
        if vim.fn.filereadable(path) == 0 then run_config = nil; return end
        local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
        run_config = (ok and type(data) == "table") and data or nil
      end

      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, { callback = load_run_config })

      local function get_named_config(name)
        if not (run_config and run_config.configurations) then return nil end
        for _, c in ipairs(run_config.configurations) do
          if c.name == name then return c end
        end
      end

      local function do_run_config(cfg)
        -- Compound: launch each sub-config by name
        if cfg.compound then
          for _, sub_name in ipairs(cfg.compound) do
            local sub = get_named_config(sub_name)
            if sub then do_run_config(sub)
            else vim.notify("Compound: config '" .. sub_name .. "' not found", vim.log.levels.WARN) end
          end
          return
        end
        local cwd = vim.fn.getcwd()
        local dir = cfg.cwd and (cwd .. "/" .. cfg.cwd) or cwd
        local cmd = cfg.cmd or (cfg.project and ("dotnet watch run --project " .. cfg.project))
        if not cmd then
          vim.notify("Config '" .. cfg.name .. "' needs 'cmd' or 'project'", vim.log.levels.WARN)
          return
        end
        -- Build env prefix from "env": { "KEY": "value" } field
        local env_prefix = ""
        if type(cfg.env) == "table" then
          local keys = vim.tbl_keys(cfg.env)
          table.sort(keys)
          for _, k in ipairs(keys) do
            env_prefix = env_prefix .. k .. "=" .. vim.fn.shellescape(tostring(cfg.env[k])) .. " "
          end
        end
        if run_terms[cfg.name] then pcall(function() run_terms[cfg.name]:shutdown() end) end
        run_terms[cfg.name] = Terminal:new({
          cmd = "cd " .. vim.fn.shellescape(dir) .. " && " .. env_prefix .. cmd,
          close_on_exit = false,
        })
        run_terms[cfg.name]:toggle()
        vim.notify("▶ " .. cfg.name, vim.log.levels.INFO)
      end

      -- Auto-detect fallback (no .neovim/run.json)
      local function auto_detect_cmd()
        local cwd = vim.fn.getcwd()
        -- .NET: find Web or Exe project, never pass .sln directly
        local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
        for _, p in ipairs(csprojs) do
          local c = table.concat(vim.fn.readfile(p), "\n")
          if c:find("Microsoft%.NET%.Sdk%.Web") then
            return "dotnet watch run --project " .. vim.fn.fnamemodify(p, ":.")
          end
        end
        for _, p in ipairs(csprojs) do
          local c = table.concat(vim.fn.readfile(p), "\n")
          if c:lower():find("<outputtype>exe</outputtype>") then
            return "dotnet watch run --project " .. vim.fn.fnamemodify(p, ":.")
          end
        end
        if csprojs[1] then
          return "dotnet watch run --project " .. vim.fn.fnamemodify(csprojs[1], ":.")
        end
        -- Node.js
        if vim.fn.filereadable(cwd .. "/package.json") == 1 then
          local c = table.concat(vim.fn.readfile(cwd .. "/package.json"), "\n")
          return c:find('"dev"') and "npm run dev" or "npm start"
        end
      end

      -- :Run — shows Telescope picker when .neovim/run.json exists
      vim.api.nvim_create_user_command("Run", function(opts)
        -- Explicit arg: config name or raw command
        if opts.args ~= "" then
          local cfg = get_named_config(opts.args)
          if cfg then do_run_config(cfg); return end
          -- Raw shell command
          if run_terms["__raw"] then pcall(function() run_terms["__raw"]:shutdown() end) end
          run_terms["__raw"] = Terminal:new({ cmd = opts.args, close_on_exit = false })
          run_terms["__raw"]:toggle()
          return
        end

        -- Has named configs → show picker
        if run_config and run_config.configurations and #run_config.configurations > 0 then
          local cfgs    = run_config.configurations
          local default = run_config.default
          local pickers = require("telescope.pickers")
          local finders = require("telescope.finders")
          local conf    = require("telescope.config").values
          local actions = require("telescope.actions")
          local astate  = require("telescope.actions.state")
          -- Put default first so it's pre-selected
          local sorted = {}
          for _, c in ipairs(cfgs) do
            if c.name == default then table.insert(sorted, 1, c) else table.insert(sorted, c) end
          end
          pickers.new({}, {
            prompt_title = "Run configuration",
            finder = finders.new_table({
              results = sorted,
              entry_maker = function(cfg)
                local marker = cfg.name == default and "▶ " or "  "
                local kind   = cfg.compound and ("compound [" .. table.concat(cfg.compound, ", ") .. "]")
                            or cfg.cmd or ("project: " .. (cfg.project or "?"))
                return {
                  value   = cfg,
                  display = marker .. cfg.name .. string.rep(" ", math.max(1, 26 - #cfg.name)) .. kind,
                  ordinal = cfg.name,
                }
              end,
            }),
            sorter = conf.generic_sorter({}),
            attach_mappings = function(buf, _)
              actions.select_default:replace(function()
                local sel = astate.get_selected_entry()
                actions.close(buf)
                do_run_config(sel.value)
              end)
              return true
            end,
          }):find()
          return
        end

        -- Fallback: auto-detect
        local cmd = auto_detect_cmd()
        if not cmd then
          vim.notify("No run config found. Use :RunSetup to create .neovim/run.json", vim.log.levels.WARN)
          return
        end
        if run_terms["__auto"] then pcall(function() run_terms["__auto"]:shutdown() end) end
        run_terms["__auto"] = Terminal:new({ cmd = cmd, close_on_exit = false })
        run_terms["__auto"]:toggle()
        vim.notify("▶ " .. cmd, vim.log.levels.INFO)
      end, { nargs = "?", desc = "Run project (picker if .neovim/run.json exists)" })

      -- :Stop — stop all running processes
      vim.api.nvim_create_user_command("Stop", function()
        local n = 0
        for name, term in pairs(run_terms) do
          pcall(function() term:shutdown() end)
          run_terms[name] = nil
          n = n + 1
        end
        vim.notify(n > 0 and ("Stopped " .. n .. " process(es)") or "Nothing is running",
          n > 0 and vim.log.levels.INFO or vim.log.levels.WARN)
      end, { desc = "Stop all running processes" })

      -- :Term — plain terminal
      vim.api.nvim_create_user_command("Term", function()
        Terminal:new({ direction = "horizontal" }):toggle()
      end, { desc = "Toggle terminal" })

      -- :RunSetup — create template or open existing .neovim/run.json
      vim.api.nvim_create_user_command("RunSetup", function()
        local cwd  = vim.fn.getcwd()
        local path = run_cfg_path()

        -- Already exists → just open for editing
        if vim.fn.filereadable(path) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(path))
          return
        end

        -- Build template from discovered projects
        local cfgs    = {}
        local names   = {}
        local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
        for _, p in ipairs(csprojs) do
          local name    = vim.fn.fnamemodify(p, ":t:r")
          local dir_rel = vim.fn.fnamemodify(p, ":.:h")  -- relative path to project dir
          table.insert(cfgs, {
            name = name,
            cmd  = "dotnet watch run",
            cwd  = dir_rel,
            env  = { ASPNETCORE_ENVIRONMENT = "Development" },
          })
          table.insert(names, name)
        end
        if vim.fn.filereadable(cwd .. "/package.json") == 1 then
          local c      = table.concat(vim.fn.readfile(cwd .. "/package.json"), "\n")
          local script = c:find('"dev"') and "npm run dev" or "npm start"
          table.insert(cfgs, { name = "Frontend", cmd = script })
          table.insert(names, "Frontend")
        end
        if #names > 1 then
          table.insert(cfgs, { name = table.concat(names, " + "), compound = names })
        end

        -- Serialize one config entry to JSON lines
        local function cfg_lines(cfg, is_last)
          local out = { "    {" }
          if cfg.compound then
            out[#out+1] = '      "name": "' .. cfg.name .. '",'
            local quoted = vim.tbl_map(function(n) return '"' .. n .. '"' end, cfg.compound)
            out[#out+1] = '      "compound": [' .. table.concat(quoted, ", ") .. "]"
          else
            local has_cwd = cfg.cwd ~= nil
            local has_env = cfg.env and next(cfg.env) ~= nil
            out[#out+1] = '      "name": "' .. cfg.name .. '",'
            out[#out+1] = '      "cmd":  "' .. cfg.cmd .. '"' .. ((has_cwd or has_env) and "," or "")
            if has_cwd then
              out[#out+1] = '      "cwd":  "' .. cfg.cwd .. '"' .. (has_env and "," or "")
            end
            if has_env then
              out[#out+1] = '      "env":  {'
              local env_keys = vim.tbl_keys(cfg.env)
              table.sort(env_keys)
              for j, k in ipairs(env_keys) do
                local comma = j < #env_keys and "," or ""
                out[#out+1] = '        "' .. k .. '": "' .. tostring(cfg.env[k]) .. '"' .. comma
              end
              out[#out+1] = "      }"
            end
          end
          out[#out+1] = is_last and "    }" or "    },"
          return out
        end

        -- Write human-readable JSON template
        local default_name = #cfgs > 0 and cfgs[#cfgs].name or ""
        local lines = {
          "{",
          '  "_help": {',
          '    "cmd":      "Shell command to run — any shell command works here",',
          '    "cwd":      "Optional: subdirectory to cd into before running (relative to project root)",',
          '    "env":      "Optional: environment variables passed to the process, like Rider Environment Variables",',
          '    "compound": "Optional: list of config names to launch together, like Rider compound run",',
          '    "default":  "Config pre-selected in the picker (Space → r → r)"',
          "  },",
          "",
          '  "configurations": [',
        }
        for i, cfg in ipairs(cfgs) do
          for _, l in ipairs(cfg_lines(cfg, i == #cfgs)) do
            table.insert(lines, l)
          end
        end
        lines[#lines + 1] = "  ],"
        lines[#lines + 1] = ""
        lines[#lines + 1] = '  "default": "' .. default_name .. '"'
        lines[#lines + 1] = "}"

        vim.fn.mkdir(cwd .. "/.neovim", "p")
        vim.fn.writefile(lines, path)
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        vim.notify("Template created — edit and save, then :Run to launch", vim.log.levels.INFO)
      end, { desc = "Create / edit run configurations (.neovim/run.json)" })

      -- EF Core migrations
      local ef_project = nil   -- project with Migrations/ folder
      local ef_startup = nil   -- project with DI / connection string

      local function neovim_dir()  return vim.fn.getcwd() .. "/.neovim" end
      local function ef_config_path() return neovim_dir() .. "/ef.json" end

      local function load_ef_config()
        local path = ef_config_path()
        if vim.fn.filereadable(path) == 0 then return end
        local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
        if not ok or type(data) ~= "table" then return end
        ef_project = data.migrations_project or nil
        ef_startup = data.startup_project or nil
      end

      local function save_ef_config()
        vim.fn.mkdir(neovim_dir(), "p")
        vim.fn.writefile(
          { vim.fn.json_encode({ migrations_project = ef_project, startup_project = ef_startup }) },
          ef_config_path()
        )
      end

      -- Auto-load on startup and when cwd changes
      vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
        callback = load_ef_config,
      })

      local function ef_bin()
        return vim.fn.executable("dotnet-ef") == 1 and "dotnet ef" or "dotnet tool run dotnet-ef"
      end

      local function ef_run(subcmd)
        local cwd = vim.fn.getcwd()
        local flags = ""
        if ef_project then flags = flags .. " --project " .. vim.fn.shellescape(ef_project) end
        if ef_startup then flags = flags .. " --startup-project " .. vim.fn.shellescape(ef_startup) end
        Terminal:new({
          cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " .. ef_bin() .. " " .. subcmd .. flags,
          close_on_exit = false,
        }):toggle()
      end

      -- Pick a .csproj from solution via Telescope
      local function pick_csproj(title, callback)
        local cwd = vim.fn.getcwd()
        local projects = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
        if #projects == 0 then vim.notify("No .csproj files found", vim.log.levels.WARN); return end
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf    = require("telescope.config").values
        local actions = require("telescope.actions")
        local astate  = require("telescope.actions.state")
        pickers.new({}, {
          prompt_title = title,
          finder = finders.new_table({
            results = projects,
            entry_maker = function(path)
              return { value = path, display = vim.fn.fnamemodify(path, ":."), ordinal = path }
            end,
          }),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(buf, _)
            actions.select_default:replace(function()
              local sel = astate.get_selected_entry()
              actions.close(buf)
              callback(sel.value)
            end)
            return true
          end,
        }):find()
      end

      -- :EfSetup — выбрать проекты и сохранить в .neovim/ef.json
      vim.api.nvim_create_user_command("EfSetup", function()
        pick_csproj("EF: Migrations project (where Migrations/ lives)", function(proj)
          ef_project = proj
          pick_csproj("EF: Startup project (DI + connection string)", function(startup)
            ef_startup = startup
            save_ef_config()
            vim.notify(
              "EF config saved to .neovim/ef.json\n"
              .. "  migrations: " .. vim.fn.fnamemodify(proj, ":.") .. "\n"
              .. "  startup:    " .. vim.fn.fnamemodify(startup, ":."),
              vim.log.levels.INFO
            )
          end)
        end)
      end, { desc = "Configure EF migrations + startup projects" })

      -- :EfStatus — показать текущие настройки
      vim.api.nvim_create_user_command("EfStatus", function()
        local p = ef_project and vim.fn.fnamemodify(ef_project, ":.") or "(auto-detect)"
        local s = ef_startup and vim.fn.fnamemodify(ef_startup, ":.") or "(none)"
        local saved = vim.fn.filereadable(ef_config_path()) == 1 and " [saved]" or " [session only]"
        vim.notify("EF migrations project: " .. p .. "\nEF startup project:    " .. s .. saved, vim.log.levels.INFO)
      end, { desc = "Show current EF project config" })

      vim.api.nvim_create_user_command("EfAdd", function(opts)
        local function do_add(name)
          if not name or name == "" then vim.notify("Migration name required", vim.log.levels.WARN); return end
          ef_run("migrations add " .. vim.fn.shellescape(name))
        end
        if opts.args ~= "" then do_add(opts.args) else vim.ui.input({ prompt = "Migration name: " }, do_add) end
      end, { nargs = "?", desc = "Add EF Core migration" })

      vim.api.nvim_create_user_command("EfUpdate", function()
        ef_run("database update")
      end, { desc = "Apply EF Core migrations to DB" })

      vim.api.nvim_create_user_command("EfList", function()
        ef_run("migrations list")
      end, { desc = "List EF Core migrations" })

      vim.api.nvim_create_user_command("EfRemove", function()
        ef_run("migrations remove")
      end, { desc = "Remove last EF Core migration" })

      vim.api.nvim_create_user_command("EfScript", function()
        ef_run("migrations script")
      end, { desc = "Generate SQL script for migrations" })

      vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
    end,
  },

  -- Git signs
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = {
          add = { text = "+" },
          change = { text = "~" },
          delete = { text = "_" },
        },
      })
    end,
  },

  -- Auto pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup()
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- Commenting
  {
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  },
}, {
  ui = { border = "rounded" },
})

-- :Keys — open keybinding reference
vim.api.nvim_create_user_command("Keys", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/KEYS.md")
end, { desc = "Open keybinding reference" })

-- Diagnostics: errors in red, warnings in yellow, underline + virtual text
vim.diagnostic.config({
  virtual_text = { spacing = 4, prefix = "●" },
  signs = true,
  underline = true,
  severity_sort = true,
})

vim.api.nvim_set_hl(0, "DiagnosticError",      { fg = "#ff0000", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticSignError",   { fg = "#ff0000", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { sp = "#ff0000", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#ff0000", italic = true })

-- Autosave: save on leaving insert mode or when text changes in normal mode
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].modified
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
      and not vim.bo[buf].readonly
    then
      vim.cmd("silent! write")
    end
  end,
})
