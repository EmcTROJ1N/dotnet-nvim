return {
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
}
