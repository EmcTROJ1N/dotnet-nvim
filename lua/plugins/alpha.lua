return {
  "goolord/alpha-nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local alpha     = require("alpha")
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
      local cwd    = vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
      local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
      local info   = "  " .. cwd
      if branch ~= "" then info = info .. "    " .. branch end
      return info
    end

    dashboard.section.buttons.val = {
      dashboard.button("ctrl+t", "  Find file",       "<C-t>"),
      dashboard.button("alt+f",  "  Search in files", "<M-f>"),
      dashboard.button("e",      "  File explorer",   "<cmd>Neotree toggle<CR>"),
      dashboard.button("g",      "  Git status",      "<cmd>Neogit<CR>"),
      dashboard.button("r",      "  Run project",     "<cmd>Run<CR>"),
      dashboard.button("space",  "  All keybindings", "<Space>"),
      dashboard.button("q",      "  Quit",            "<cmd>qa<CR>"),
    }

    dashboard.config.layout = {
      { type = "padding", val = 4 },
      dashboard.section.header,
      { type = "padding", val = 1 },
      { type = "text", val = get_info, opts = { hl = "Comment", position = "center" } },
      { type = "padding", val = 2 },
      dashboard.section.buttons,
      { type = "padding", val = 1 },
    }

    alpha.setup(dashboard.config)
  end,
}
