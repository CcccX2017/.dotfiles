local module = "coolnight"

local wezterm = require("wezterm")

local M = {}

M.opacity = 0.85

M.default = require("colors." .. module).colors

local r, g, b, _ = wezterm.color.parse(M.default.background):srgba_u8()
local tab_bg = "rgba(" .. r .. "," .. g .. "," .. b .. "," .. M.opacity .. ")"

M.default.tab_bg = tab_bg

return M
