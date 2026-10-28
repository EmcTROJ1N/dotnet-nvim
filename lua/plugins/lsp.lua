return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    -- Capabilities set globally before mason-lspconfig; picked up by automatic_enable
    vim.lsp.config("*", {
      capabilities = require("cmp_nvim_lsp").default_capabilities(),
    })
    require("mason-lspconfig").setup({
      ensure_installed = { "lua_ls", "ts_ls", "html", "cssls", "omnisharp" },
      automatic_enable = true,
    })
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local opts = { buffer = ev.buf }
        vim.keymap.set("n", "gd",          vim.lsp.buf.definition,   opts)
        vim.keymap.set("n", "K",           vim.lsp.buf.hover,        opts)
        vim.keymap.set("n", "gr",          vim.lsp.buf.references,   opts)
        vim.keymap.set("n", "<leader>rn",  vim.lsp.buf.rename,       opts)
        vim.keymap.set("n", "<leader>ca",  vim.lsp.buf.code_action,  opts)
      end,
    })
  end,
}
