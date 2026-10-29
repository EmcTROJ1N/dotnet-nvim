-- :q/:wq on last real window → Alpha; :q on Alpha → quit; :qa → quit all
local _last_closed_ft = nil

vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    _last_closed_ft = vim.bo[vim.api.nvim_get_current_buf()].filetype
  end,
})

vim.api.nvim_create_autocmd("WinClosed", {
  callback = function()
    local ft = _last_closed_ft
    _last_closed_ft = nil
    vim.schedule(function()
      local wins = vim.api.nvim_list_wins()
      if #wins == 0 then return end
      local real = vim.tbl_filter(function(w)
        if not vim.api.nvim_win_is_valid(w) then return false end
        local wft = vim.bo[vim.api.nvim_win_get_buf(w)].filetype
        return vim.api.nvim_win_get_config(w).relative == ""
          and wft ~= "neo-tree" and wft ~= "alpha"
      end, wins)
      if #real > 0 then return end
      if ft == "alpha" then
        vim.cmd("qa")
      else
        pcall(vim.cmd, "Neotree close")
        pcall(vim.cmd, "Alpha")
      end
    end)
  end,
})

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
