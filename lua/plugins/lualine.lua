return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local p = require("core.platform")

    local function input_lang()
      if p.is_mac then
        local out  = vim.fn.system("defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources 2>/dev/null | grep 'KeyboardLayout Name' | head -1")
        local lang = out:match('"KeyboardLayout Name" = "([^"]+)"') or out:match('"KeyboardLayout Name" = (%a+)')
        if not lang then return "" end
        local labels = { Russian = "RU", ABC = "EN", ["U.S."] = "EN", ["USInternational-PC"] = "EN" }
        return labels[lang] or lang:sub(1, 2):upper()
      elseif p.is_linux then
        local out = vim.fn.system("xkb-switch 2>/dev/null"):gsub("%s+", "")
        if out ~= "" and not out:find("not found") then return out:sub(1, 2):upper() end
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
              local ft   = vim.bo.filetype
              local path = vim.fn.expand("%:p")
              return path ~= "" and ft ~= "neo-tree" and ft ~= "alpha" and ft ~= "toggleterm"
            end,
          },
          {
            function() return p.is_mac and "[ open in Finder]" or "[ open folder]" end,
            on_click = function()
              local ok, manager = pcall(require, "neo-tree.sources.manager")
              if not ok then return end
              local state = manager.get_state("filesystem")
              if not (state and state.tree) then return end
              local ok2, node = pcall(function() return state.tree:get_node() end)
              if not ok2 or not node then return end
              local path = node.type == "directory" and node:get_id() or vim.fn.fnamemodify(node:get_id(), ":h")
              p.sys_open(path)
            end,
            color = { fg = "#9ece6a" },
            cond  = function() return true end,
          },
        },
        lualine_x = { input_lang, "encoding", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    })
  end,
}
