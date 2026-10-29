return {
  "akinsho/bufferline.nvim",
  enabled = true,
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("bufferline").setup({
      options = {
        diagnostics    = "nvim_lsp",
        offsets        = {{ filetype = "neo-tree", text = "Explorer", separator = true }},
        separator_style = "slant",
        custom_filter  = function(buf_number)
          local ft      = vim.bo[buf_number].filetype
          local name    = vim.fn.bufname(buf_number)
          local ignored = { "alpha", "neo-tree", "toggleterm", "TelescopePrompt", "lazy", "mason" }
          for _, f in ipairs(ignored) do
            if ft == f or name:find(f) then return false end
          end
          return true
        end,
      },
    })

    local last_tab_time = 0
    local function cycle_buf(dir)
      local now = vim.uv.hrtime() / 1e6
      if now - last_tab_time < 150 then return end
      last_tab_time = now
      vim.cmd(dir == 1 and "BufferLineCycleNext" or "BufferLineCyclePrev")
    end

    vim.keymap.set("n", "<Tab>",   function() cycle_buf(1) end)
    vim.keymap.set("n", "<S-Tab>", function() cycle_buf(-1) end)

    local function close_buf()
      local buf  = vim.api.nvim_get_current_buf()
      local bufs = vim.fn.getbufinfo({ buflisted = 1 })
      if #bufs > 1 then vim.cmd("BufferLineCycleNext") end
      if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buflisted then
        pcall(vim.cmd, "bdelete " .. buf)
      end
    end
    vim.keymap.set("n", "<leader>x", close_buf, { desc = "Close buffer" })
  end,
}
