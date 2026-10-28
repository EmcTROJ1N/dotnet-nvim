return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim",
      build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release" },
  },
  config = function()
    local telescope    = require("telescope")
    local builtin      = require("telescope.builtin")
    local actions      = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case", "--hidden", "--glob=!.git/",
        },
        -- nvim-treesitter v1.x API incompatible with telescope previewer
        preview = { treesitter = false },
      },
      pickers = {
        find_files = { find_command = { "fd", "--type=f", "--hidden", "--exclude=.git" } },
      },
      extensions = {
        fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
      },
    })
    telescope.load_extension("fzf")

    -- Keymaps
    vim.keymap.set("n", "<leader>ff", builtin.find_files)
    vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    vim.keymap.set("n", "<leader>fb", builtin.buffers)
    vim.keymap.set("n", "<leader>fh", builtin.help_tags)
    vim.keymap.set("n", "<C-t>",      builtin.find_files)
    vim.keymap.set("i", "<C-t>",      function() builtin.find_files() end)
    vim.keymap.set("n", "<M-f>",      builtin.live_grep)
    vim.keymap.set("i", "<M-f>",      function() builtin.live_grep() end)
    vim.keymap.set("n", "<leader>?",  builtin.keymaps, { desc = "Search keymaps" })

    -- :Branch — git branch switcher with push/pull/create
    vim.api.nvim_create_user_command("Branch", function()
      local function git_in_term(cmd)
        require("toggleterm.terminal").Terminal:new({ cmd = cmd, close_on_exit = false }):toggle()
      end
      builtin.git_branches({
        attach_mappings = function(_, map)
          map("i", "<C-n>", function(prompt_bufnr)
            local name = action_state.get_current_line(prompt_bufnr)
            actions.close(prompt_bufnr)
            if name and name ~= "" then git_in_term("git checkout -b " .. name) end
          end)
          map("i", "<C-p>", function(prompt_bufnr)
            local sel    = action_state.get_selected_entry(prompt_bufnr)
            actions.close(prompt_bufnr)
            local branch = sel and sel.name or vim.fn.system("git branch --show-current"):gsub("\n", "")
            git_in_term("git push origin " .. branch)
          end)
          map("i", "<C-u>", function(prompt_bufnr)
            actions.close(prompt_bufnr)
            git_in_term("git pull")
          end)
          return true
        end,
      })
    end, { desc = "Switch git branch" })
  end,
}
