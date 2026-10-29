local function smart_close(force)
  local buf = vim.api.nvim_get_current_buf()
  local ft  = vim.bo[buf].filetype
  local bt  = vim.bo[buf].buftype

  -- Special buffers (terminal, help, etc.) and neo-tree → close normally
  if bt ~= "" or ft == "neo-tree" then
    vim.cmd(force and "q!" or "q")
    return
  end

  -- Closing Alpha → quit nvim entirely
  if ft == "alpha" then
    vim.cmd("qa")
    return
  end

  -- Unsaved changes guard
  if not force and vim.bo[buf].modified then
    vim.notify("Unsaved changes. Use :q! to force close.", vim.log.levels.WARN)
    return
  end

  -- Switch to the next listed buffer, or show Alpha if none remain
  local bufs = vim.tbl_filter(function(b)
    return b ~= buf
      and vim.api.nvim_buf_is_valid(b)
      and vim.bo[b].buflisted
      and vim.bo[b].buftype == ""
  end, vim.api.nvim_list_bufs())

  if #bufs > 0 then
    vim.api.nvim_set_current_buf(bufs[1])
  else
    pcall(vim.cmd, "Alpha")
  end

  pcall(vim.cmd, (force and "bdelete! " or "bdelete ") .. buf)
end

local function smart_wq(force)
  local buf = vim.api.nvim_get_current_buf()
  if vim.bo[buf].buftype == "" and vim.bo[buf].modified then
    vim.cmd("silent! write")
  end
  smart_close(force)
end

-- Custom commands (uppercase required by nvim)
vim.api.nvim_create_user_command("Q",  function(o) smart_close(o.bang) end, { bang = true, desc = "Smart close buffer" })
vim.api.nvim_create_user_command("Wq", function(o) smart_wq(o.bang)   end, { bang = true, desc = "Smart write+close" })
vim.api.nvim_create_user_command("WQ", function(o) smart_wq(o.bang)   end, { bang = true, desc = "Smart write+close" })

-- Abbreviate :q → :Q and :wq → :Wq only when they are the full command
-- getcmdpos() check ensures we don't hijack :qall, :q1, etc.
vim.cmd([[cnoreabbrev <expr> q  getcmdtype()==':'&&getcmdpos()<=2 ? 'Q'  : 'q']])
vim.cmd([[cnoreabbrev <expr> wq getcmdtype()==':'&&getcmdpos()<=3 ? 'Wq' : 'wq']])

-- Also remap normal-mode ZZ / ZQ
vim.keymap.set("n", "ZZ", function() smart_wq(false)   end, { desc = "Write and close buffer" })
vim.keymap.set("n", "ZQ", function() smart_close(true) end, { desc = "Force close buffer" })

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

vim.keymap.set("n", "<leader>x", function() smart_close(false) end, { desc = "Close buffer" })
