-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

local opts = { noremap = true, silent = true }

-- jk回到normal模式
map("i", "jk", "<esc>", { desc = "jk回到normal模式" })

-- leader w 保存
map("n", "<leader>w", ":w<cr>", opts)

-- Q 退出
map("n", "<S-q>", ":wq<cr>", opts)

-- 删除不覆盖剪切板
map({ "n", "v" }, "<leader>dd", '"_dd', { desc = "删除一行不覆盖剪切板" })

map("n", "<leader>dw", '"_dw', { desc = "删除一个单词不覆盖剪切板" })

-- 数字加减
map("n", "+", "<C-a>")
map("n", "-", "<C-x>")

-- 全选
map("n", "<C-a>", "gg<S-v>G")

-- TODO Jumplist 暂时不知道什么作用
map("n", "<C-m>", "<C-i>", opts)

-- New Tab map("n", "te", ":tabedit<cr>", opts)
map("n", "<tab>", ":tabnext<cr>", opts)
map("n", "<s-tab>", ":tabprev<cr>", opts)

-- 分屏
map(
  "n",
  "sl",
  ":set splitright<cr>:vsp<cr>",
  { desc = "竖向分屏，光标在右边", noremap = true, silent = true }
)
map(
  "n",
  "sh",
  ":set nosplitright<cr>:vsp<cr>",
  { desc = "竖向分屏，光标在左边", noremap = true, silent = true }
)
map("n", "sj", ":set splitbelow<cr>:sp<cr>", { desc = "横向分屏，光标在下边", noremap = true, silent = true })
map(
  "n",
  "sk",
  ":set nosplitbelow<cr>:sp<cr>",
  { desc = "竖向分屏，光标在上边", noremap = true, silent = true }
)
map("n", "sv", "<C-w>t<C-w>H", { desc = "横向分屏切换为竖向分屏", noremap = true, silent = true })
map("n", "sb", "<C-w>t<C-w>K", { desc = "竖向分屏切换为横向分屏", noremap = true, silent = true })

-- H -> ^ , L -> $
map({ "n", "v" }, "<s-h>", "^")
map({ "n", "v" }, "<s-l>", "$")

-- 取消搜索结果高亮
map("n", "<leader>h", ":noh<cr>", opts)

-- J -> 5j, K -> 5k
map("n", "<s-j>", "5j")
map("n", "<s-k>", "5k", opts)
