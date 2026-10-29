-- Autosave on leave/change
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged", "FocusLost" }, {
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    if vim.bo[buf].modified
      and vim.bo[buf].buftype == ""
      and vim.api.nvim_buf_get_name(buf) ~= ""
      and not vim.bo[buf].readonly
    then
      vim.cmd("silent! write")
    end
  end,
})

-- :q/:wq on last real window → Alpha alongside neo-tree
-- :q on Alpha → quit nvim
-- :qa → quit nvim normally

local _closed_ft = nil
local _nt_width  = 35  -- matches neo-tree window.width config

-- Keep neo-tree width fresh while real editing windows are open
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local neo_win, has_real = nil, false
    for _, w in ipairs(vim.api.nvim_list_wins()) do
      if not vim.api.nvim_win_is_valid(w) then goto skip end
      local ft  = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
      local rel = vim.api.nvim_win_get_config(w).relative
      if ft == "neo-tree" then
        neo_win = w
      elseif rel == "" and ft ~= "alpha" then
        has_real = true
      end
      ::skip::
    end
    if neo_win and has_real then
      _nt_width = vim.api.nvim_win_get_width(neo_win)
    end
  end,
})

local function maybe_show_alpha(ft)
  local wins = vim.api.nvim_list_wins()
  if #wins == 0 then return end

  -- Count real editing windows (not neo-tree, not alpha, not floating)
  local real = vim.tbl_filter(function(w)
    if not vim.api.nvim_win_is_valid(w) then return false end
    local wft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
    return vim.api.nvim_win_get_config(w).relative == ""
      and wft ~= "neo-tree" and wft ~= "alpha"
  end, wins)

  if #real > 0 then return end        -- other editors still open, do nothing
  if ft == "alpha" then vim.cmd("qa"); return end  -- closed alpha → quit nvim

  -- Find neo-tree window
  local neo_win = nil
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w)
       and vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree" then
      neo_win = w; break
    end
  end

  if neo_win then
    -- Focus neo-tree, then open a split to the right for Alpha
    vim.api.nvim_set_current_win(neo_win)
    local main_w = math.max(vim.o.columns - _nt_width - 1, 40)
    vim.cmd(main_w .. "vsplit")
  end

  pcall(vim.cmd, "Alpha")
end

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    _closed_ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function()
    local ft = _closed_ft
    _closed_ft = nil
    if not ft then return end
    vim.schedule(function() maybe_show_alpha(ft) end)
  end,
})
