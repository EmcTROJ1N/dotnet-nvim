-- Buffer cycling (Tab / Shift-Tab)
local last_cycle = 0
local function cycle_buf(dir)
  local now = vim.uv.hrtime() / 1e6
  if now - last_cycle < 150 then return end
  last_cycle = now
  local bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buflisted
      and vim.bo[b].buftype == ""
  end, vim.api.nvim_list_bufs())
  if #bufs <= 1 then return end
  local cur = vim.api.nvim_get_current_buf()
  for i, b in ipairs(bufs) do
    if b == cur then
      vim.api.nvim_set_current_buf(bufs[((i - 1 + dir) % #bufs) + 1])
      return
    end
  end
end

vim.keymap.set("n", "<Tab>",   function() cycle_buf(1)  end, { desc = "Next buffer" })
vim.keymap.set("n", "<S-Tab>", function() cycle_buf(-1) end, { desc = "Prev buffer" })

-- Close current buffer, switch to next first if multiple open
local function close_buf()
  local buf  = vim.api.nvim_get_current_buf()
  local bufs = vim.tbl_filter(function(b)
    return vim.api.nvim_buf_is_valid(b) and vim.bo[b].buflisted and vim.bo[b].buftype == ""
  end, vim.api.nvim_list_bufs())
  if #bufs > 1 then vim.cmd("bnext") end
  pcall(vim.cmd, "bdelete " .. buf)
end

vim.keymap.set("n", "<leader>x", close_buf, { desc = "Close buffer" })
