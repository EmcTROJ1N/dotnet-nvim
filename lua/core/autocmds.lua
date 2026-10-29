-- When closing the last real window, quit nvim entirely instead of leaving neo-tree alone
vim.api.nvim_create_autocmd("QuitPre", {
  callback = function()
    local real = vim.tbl_filter(function(w)
      return vim.api.nvim_win_get_config(w).relative == ""
        and vim.bo[vim.api.nvim_win_get_buf(w)].filetype ~= "neo-tree"
    end, vim.api.nvim_list_wins())
    if #real == 1 then vim.cmd("qa") end
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
