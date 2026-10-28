local M = {}

M.is_mac   = vim.fn.has("mac") == 1
M.is_linux = vim.fn.has("unix") == 1 and not M.is_mac

function M.sys_open(path)
  if M.is_mac       then vim.fn.system("open "     .. vim.fn.shellescape(path))
  elseif M.is_linux then vim.fn.system("xdg-open " .. vim.fn.shellescape(path))
  else                   vim.fn.system("explorer "  .. vim.fn.shellescape(path)) end
end

function M.sys_reveal(path)
  if M.is_mac       then vim.fn.system("open -R "   .. vim.fn.shellescape(path))
  elseif M.is_linux then M.sys_open(vim.fn.fnamemodify(path, ":h"))
  else                   vim.fn.system("explorer /select," .. vim.fn.shellescape(path)) end
end

return M
