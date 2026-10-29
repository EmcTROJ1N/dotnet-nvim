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

-- :q/:wq on last real window → Alpha full screen
-- :q on Alpha               → quit nvim
-- :qa                       → quit nvim

local _closed_ft = nil

local function maybe_show_alpha(ft)
  local wins = vim.api.nvim_list_wins()
  if #wins == 0 then return end

  local real = vim.tbl_filter(function(w)
    if not vim.api.nvim_win_is_valid(w) then return false end
    local wft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
    return vim.api.nvim_win_get_config(w).relative == ""
      and wft ~= "neo-tree" and wft ~= "alpha"
  end, wins)

  if #real > 0 then return end
  if ft == "alpha" then vim.cmd("qa"); return end

  -- Find neo-tree window
  local neo_win = nil
  for _, w in ipairs(wins) do
    if vim.api.nvim_win_is_valid(w)
       and vim.bo[vim.api.nvim_win_get_buf(w)].filetype == "neo-tree" then
      neo_win = w; break
    end
  end

  if neo_win then
    -- Open a sibling window, show Alpha, then close neo-tree
    -- This leaves Alpha full screen without layout artifacts
    vim.api.nvim_set_current_win(neo_win)
    vim.cmd("vsplit")
    pcall(vim.cmd, "Alpha")
    pcall(vim.cmd, "Neotree close")
  else
    pcall(vim.cmd, "Alpha")
  end
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
