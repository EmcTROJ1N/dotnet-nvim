return {
  "echasnovski/mini.tabline",
  version = false,
  config = function()
    require("mini.tabline").setup({
      show_icons = true,
      set_vim_settings = true,   -- sets showtabline=2
      tabpage_section = "right", -- show tab number on the right
    })
  end,
}
