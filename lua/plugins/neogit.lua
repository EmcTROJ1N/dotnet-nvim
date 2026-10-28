return {
  "NeogitOrg/neogit",
  dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
  config = function()
    require("neogit").setup({
      integrations = { diffview = true },
      graph_style  = "unicode",
    })
    vim.api.nvim_create_user_command("Git", function(opts)
      local sub = opts.args
      if sub == "" or sub == "status" then
        require("neogit").open()
      elseif sub == "diff" then
        vim.cmd("DiffviewOpen")
      elseif sub == "log" then
        vim.cmd("DiffviewFileHistory")
      else
        vim.notify("Unknown subcommand. Use: Git, Git diff, Git log", vim.log.levels.WARN)
      end
    end, { nargs = "?", desc = "Git UI" })
  end,
}
