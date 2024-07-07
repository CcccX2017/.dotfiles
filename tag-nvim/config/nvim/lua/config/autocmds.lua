local function augroup(name)
  return vim.api.nvim_create_augroup("nebula_" .. name, { clear = true })
end

local api = vim.api

-- 不自动注释新行
api.nvim_create_autocmd("BufEnter", { command = [[set formatoptions-=cro]] })
