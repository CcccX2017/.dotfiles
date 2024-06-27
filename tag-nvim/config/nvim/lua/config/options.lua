-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- local conf = require("lualine").get_config()

-- vim.notify(conf)
local opt = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
print(opt)
-- vim.opt.winbar = "" .. opt
