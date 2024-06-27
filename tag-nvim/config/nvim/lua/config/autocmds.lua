-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local function augroup(name)
  return vim.api.nvim_create_augroup("nebula_" .. name, { clear = true })
end

local api = vim.api

-- 显示光标所在行的git提交信息
local gitsigns_init = false
api.nvim_create_autocmd("BufEnter", {
  group = augroup("show_gitsigns"),
  callback = function()
    if not gitsigns_init then
      vim.defer_fn(function()
        require("gitsigns").toggle_current_line_blame()
      end, 100)
    end
  end,
})
