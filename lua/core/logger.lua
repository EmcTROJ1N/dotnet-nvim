local M = {}

local log_path = vim.fn.stdpath("state") .. "/nvim-debug.log"
local levels   = { [0] = "TRACE", [1] = "DEBUG", [2] = "INFO", [3] = "WARN", [4] = "ERROR" }

local function write(msg, level)
  local f = io.open(log_path, "a")
  if not f then return end
  f:write(string.format("[%s] [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), levels[level] or "INFO", msg))
  f:close()
end

-- Intercept all vim.notify calls at WARN level and above
local original_notify = vim.notify
vim.notify = function(msg, level, opts)
  level = level or vim.log.levels.INFO
  if level >= vim.log.levels.WARN then
    write(tostring(msg), level)
  end
  original_notify(msg, level, opts)
end

vim.api.nvim_create_user_command("Log", function()
  vim.cmd("edit " .. log_path)
end, { desc = "Open nvim debug log" })

vim.api.nvim_create_user_command("LogClear", function()
  local f = io.open(log_path, "w")
  if f then f:close() end
  vim.notify("Log cleared", vim.log.levels.INFO)
end, { desc = "Clear nvim debug log" })

M.write = write
M.path  = log_path

return M
