return {
  "echasnovski/mini.tabline",
  version = false,
  config = function()
    require("mini.tabline").setup({
      show_icons       = true,
      set_vim_settings = false,  -- tabline controlled manually below
      tabpage_section  = "right",
    })

    vim.o.showtabline = 2

    -- Offset the tabline to start after the neo-tree sidebar
    _G._tabline = function()
      local nt_width = 0
      for _, w in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_is_valid(w)
           and vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree" then
          nt_width = vim.api.nvim_win_get_width(w) + 1  -- +1 for the separator
          break
        end
      end
      return "%#TabLineFill#" .. string.rep(" ", nt_width) .. MiniTabline.make_tabline_string()
    end

    vim.o.tabline = "%!v:lua._tabline()"
  end,
}
