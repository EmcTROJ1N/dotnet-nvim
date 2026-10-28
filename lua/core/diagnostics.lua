vim.api.nvim_create_user_command("Keys", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/docs/keybindings.md")
end, { desc = "Open keybinding reference" })

vim.diagnostic.config({
  virtual_text  = { spacing = 4, prefix = "●" },
  signs         = true,
  underline     = true,
  severity_sort = true,
})

vim.api.nvim_set_hl(0, "DiagnosticError",           { fg = "#ff0000", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticSignError",        { fg = "#ff0000", bold = true })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineError",   { sp = "#ff0000", undercurl = true })
vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = "#ff0000", italic = true })
