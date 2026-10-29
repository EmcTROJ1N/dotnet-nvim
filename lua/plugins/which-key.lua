return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  config = function()
    local wk = require("which-key")
    wk.setup({ preset = "modern", delay = 400 })
    wk.add({
      { "<leader>?",  desc = "Search all keymaps" },

      { "<leader>f",  group = "Find" },
      { "<leader>ff", desc = "Find files (Ctrl+T)" },
      { "<leader>fg", desc = "Search in files (Alt+F)" },
      { "<leader>fb", desc = "Open buffers" },
      { "<leader>e",  desc = "File explorer toggle" },
      { "<leader>E",  desc = "Reveal current file in tree" },

      { "<leader>g",  group = "Git" },
      { "<leader>gs", function() vim.cmd("Git") end,       desc = "Status / commit" },
      { "<leader>gd", function() vim.cmd("Git diff") end,  desc = "Diff" },
      { "<leader>gl", function() vim.cmd("Git log") end,   desc = "Log" },
      { "<leader>gb", function() vim.cmd("Branch") end,    desc = "Switch branch" },
      { "<leader>gn", function()
          vim.ui.input({ prompt = "New branch name: " }, function(name)
            if name then vim.fn.system("git checkout -b " .. name); vim.notify("Created: " .. name) end
          end)
        end, desc = "New branch" },
      { "<leader>gp", function()
          local b = vim.fn.system("git branch --show-current"):gsub("\n", "")
          require("toggleterm.terminal").Terminal:new({ cmd = "git push origin " .. b, close_on_exit = false }):toggle()
        end, desc = "Push" },
      { "<leader>gu", function()
          require("toggleterm.terminal").Terminal:new({ cmd = "git pull", close_on_exit = false }):toggle()
        end, desc = "Pull" },

      { "<leader>r",  group = "Run" },
      { "<leader>rr", function() vim.cmd("Run") end,      desc = "Run project" },
      { "<leader>rs", function() vim.cmd("Stop") end,     desc = "Stop project" },
      { "<leader>rt", function() vim.cmd("Term") end,     desc = "Open terminal" },
      { "<leader>rp", function() vim.cmd("RunSetup") end, desc = "Pick startup project" },

      { "<leader>l",   group = "LSP / Logs" },
      { "<leader>rn",  desc = "Rename symbol" },
      { "<leader>ca",  desc = "Code actions" },
      { "<leader>ll",  function() vim.cmd("Log") end,    desc = "Open debug log" },
      { "<leader>lL",  function() vim.cmd("LogLsp") end, desc = "Open LSP log" },
      { "<leader>lc",  function() vim.cmd("LogClear") end, desc = "Clear debug log" },

      { "<leader>t",  group = "Tools" },
      { "<leader>te", function() vim.cmd("Errors") end, desc = "Errors panel" },
      { "<leader>tt", function() vim.cmd("Todo") end,   desc = "TODO list" },
      { "<leader>x",  desc = "Close buffer" },

      { "<leader>m",  group = "EF Migrations" },
      { "<leader>mp", function() vim.cmd("EfSetup") end,  desc = "Pick projects" },
      { "<leader>mi", function() vim.cmd("EfStatus") end, desc = "Show EF config" },
      { "<leader>ma", function() vim.cmd("EfAdd") end,    desc = "Add migration" },
      { "<leader>mu", function() vim.cmd("EfUpdate") end, desc = "Update database" },
      { "<leader>ml", function() vim.cmd("EfList") end,   desc = "List migrations" },
      { "<leader>mr", function() vim.cmd("EfRemove") end, desc = "Remove last" },
      { "<leader>ms", function() vim.cmd("EfScript") end, desc = "Generate SQL script" },
    })
  end,
}
