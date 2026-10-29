return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local p = require("core.platform")

    require("neo-tree").setup({
      window = {
        position = "left",
        width    = 35,
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
            if node.type == "directory" then p.sys_open(path) else p.sys_reveal(path) end
          end,
        },
      },
      filesystem = {
        use_libuv_file_watcher = true,
        filtered_items = { hide_dotfiles = false, hide_gitignored = false },
        follow_current_file = { enabled = false },
      },
    })

    vim.keymap.set("n", "<leader>e", ":Neotree toggle<CR>")
    vim.keymap.set("n", "<leader>E", ":Neotree reveal<CR>")

    vim.api.nvim_create_autocmd("CursorMoved", {
      callback = function()
        if vim.bo.filetype == "neo-tree" then require("lualine").refresh() end
      end,
    })
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then vim.cmd("Neotree show") end
      end,
    })

    -- Auto-show neo-tree when opening a real file (e.g. from Alpha dashboard)
    vim.api.nvim_create_autocmd("BufRead", {
      callback = function()
        if vim.bo.buftype ~= "" then return end
        local ft = vim.bo.filetype
        if ft == "" or ft == "alpha" or ft == "neo-tree" then return end
        local has_tree = false
        for _, w in ipairs(vim.api.nvim_list_wins()) do
          if vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree" then
            has_tree = true; break
          end
        end
        if not has_tree then
          vim.schedule(function() pcall(vim.cmd, "Neotree show") end)
        end
      end,
    })
  end,
}
