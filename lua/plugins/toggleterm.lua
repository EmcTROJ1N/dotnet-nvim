return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size          = 15,
      open_mapping  = [[<C-\>]],
      direction     = "horizontal",
      shade_terminals = true,
      close_on_exit = false,
    })

    local Terminal = require("toggleterm.terminal").Terminal

    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })

    -- ── Run configurations ────────────────────────────────────────────────────
    local run_config = nil
    local run_terms  = {}

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

    local function auto_detect_cmd()
      local cwd     = vim.fn.getcwd()
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
      if csprojs[1] then return "dotnet watch run --project " .. vim.fn.fnamemodify(csprojs[1], ":.") end
      if vim.fn.filereadable(cwd .. "/package.json") == 1 then
        local c = table.concat(vim.fn.readfile(cwd .. "/package.json"), "\n")
        return c:find('"dev"') and "npm run dev" or "npm start"
      end
    end

    vim.api.nvim_create_user_command("Run", function(opts)
      if opts.args ~= "" then
        local cfg = get_named_config(opts.args)
        if cfg then do_run_config(cfg); return end
        if run_terms["__raw"] then pcall(function() run_terms["__raw"]:shutdown() end) end
        run_terms["__raw"] = Terminal:new({ cmd = opts.args, close_on_exit = false })
        run_terms["__raw"]:toggle()
        return
      end
      if run_config and run_config.configurations and #run_config.configurations > 0 then
        local cfgs    = run_config.configurations
        local default = run_config.default
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf    = require("telescope.config").values
        local actions = require("telescope.actions")
        local astate  = require("telescope.actions.state")
        local sorted  = {}
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
      local cmd = auto_detect_cmd()
      if not cmd then
        vim.notify("No run config found. Use :RunSetup to create .neovim/run.json", vim.log.levels.WARN)
        return
      end
      if run_terms["__auto"] then pcall(function() run_terms["__auto"]:shutdown() end) end
      run_terms["__auto"] = Terminal:new({ cmd = cmd, close_on_exit = false })
      run_terms["__auto"]:toggle()
      vim.notify("▶ " .. cmd, vim.log.levels.INFO)
    end, { nargs = "?", desc = "Run project" })

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

    vim.api.nvim_create_user_command("Term", function()
      Terminal:new({ direction = "horizontal" }):toggle()
    end, { desc = "Toggle terminal" })

    vim.api.nvim_create_user_command("RunSetup", function()
      local cwd  = vim.fn.getcwd()
      local path = run_cfg_path()
      if vim.fn.filereadable(path) == 1 then
        vim.cmd("edit " .. vim.fn.fnameescape(path))
        return
      end
      local cfgs, names = {}, {}
      local csprojs = vim.fn.glob(cwd .. "/**/*.csproj", false, true)
      for _, p in ipairs(csprojs) do
        local name    = vim.fn.fnamemodify(p, ":t:r")
        local dir_rel = vim.fn.fnamemodify(p, ":.:h")
        table.insert(cfgs, { name = name, cmd = "dotnet watch run", cwd = dir_rel, env = { ASPNETCORE_ENVIRONMENT = "Development" } })
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
          if has_cwd then out[#out+1] = '      "cwd":  "' .. cfg.cwd .. '"' .. (has_env and "," or "") end
          if has_env then
            out[#out+1] = '      "env":  {'
            local env_keys = vim.tbl_keys(cfg.env); table.sort(env_keys)
            for j, k in ipairs(env_keys) do
              out[#out+1] = '        "' .. k .. '": "' .. tostring(cfg.env[k]) .. '"' .. (j < #env_keys and "," or "")
            end
            out[#out+1] = "      }"
          end
        end
        out[#out+1] = is_last and "    }" or "    },"
        return out
      end
      local default_name = #cfgs > 0 and cfgs[#cfgs].name or ""
      local lines = {
        "{",
        '  "_help": {',
        '    "cmd":      "Shell command to run — any shell command works here",',
        '    "cwd":      "Optional: subdirectory to cd into before running (relative to project root)",',
        '    "env":      "Optional: environment variables passed to the process",',
        '    "compound": "Optional: list of config names to launch together",',
        '    "default":  "Config pre-selected in the picker (Space → r → r)"',
        "  },",
        "",
        '  "configurations": [',
      }
      for i, cfg in ipairs(cfgs) do
        for _, l in ipairs(cfg_lines(cfg, i == #cfgs)) do table.insert(lines, l) end
      end
      lines[#lines+1] = "  ],"; lines[#lines+1] = ""; lines[#lines+1] = '  "default": "' .. default_name .. '"'; lines[#lines+1] = "}"
      vim.fn.mkdir(cwd .. "/.neovim", "p")
      vim.fn.writefile(lines, path)
      vim.cmd("edit " .. vim.fn.fnameescape(path))
      vim.notify("Template created — edit and save, then :Run to launch", vim.log.levels.INFO)
    end, { desc = "Create / edit run configurations" })

    -- ── EF Core migrations ────────────────────────────────────────────────────
    local ef_project = nil
    local ef_startup = nil

    local function neovim_dir()    return vim.fn.getcwd() .. "/.neovim" end
    local function ef_config_path() return neovim_dir() .. "/ef.json" end

    local function load_ef_config()
      local path = ef_config_path()
      if vim.fn.filereadable(path) == 0 then return end
      local ok, data = pcall(vim.fn.json_decode, table.concat(vim.fn.readfile(path), "\n"))
      if not ok or type(data) ~= "table" then return end
      ef_project = data.migrations_project or nil
      ef_startup = data.startup_project   or nil
    end

    local function save_ef_config()
      vim.fn.mkdir(neovim_dir(), "p")
      vim.fn.writefile(
        { vim.fn.json_encode({ migrations_project = ef_project, startup_project = ef_startup }) },
        ef_config_path()
      )
    end

    vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, { callback = load_ef_config })

    local function ef_bin()
      return vim.fn.executable("dotnet-ef") == 1 and "dotnet ef" or "dotnet tool run dotnet-ef"
    end

    local function ef_run(subcmd)
      local cwd   = vim.fn.getcwd()
      local flags = ""
      if ef_project then flags = flags .. " --project "         .. vim.fn.shellescape(ef_project) end
      if ef_startup then flags = flags .. " --startup-project " .. vim.fn.shellescape(ef_startup) end
      Terminal:new({
        cmd = "cd " .. vim.fn.shellescape(cwd) .. " && " .. ef_bin() .. " " .. subcmd .. flags,
        close_on_exit = false,
      }):toggle()
    end

    local function pick_csproj(title, callback)
      local cwd      = vim.fn.getcwd()
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

    vim.api.nvim_create_user_command("EfStatus", function()
      local p    = ef_project and vim.fn.fnamemodify(ef_project, ":.") or "(auto-detect)"
      local s    = ef_startup and vim.fn.fnamemodify(ef_startup, ":.") or "(none)"
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

    vim.api.nvim_create_user_command("EfUpdate", function() ef_run("database update") end,   { desc = "Apply EF Core migrations" })
    vim.api.nvim_create_user_command("EfList",   function() ef_run("migrations list") end,   { desc = "List EF Core migrations" })
    vim.api.nvim_create_user_command("EfRemove", function() ef_run("migrations remove") end, { desc = "Remove last EF migration" })
    vim.api.nvim_create_user_command("EfScript", function() ef_run("migrations script") end, { desc = "Generate SQL script" })
  end,
}
