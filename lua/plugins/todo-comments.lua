return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("todo-comments").setup()
    vim.api.nvim_create_user_command("Todo", function()
      vim.cmd("TodoTelescope")
    end, { desc = "List all TODO/FIXME comments" })
  end,
}
