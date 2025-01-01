---@diagnostic disable: lowercase-global
-- Pull in the wezterm API
local wezterm = require("wezterm")
local utils = require("utils")
local const = require("const")
local nf = wezterm.nerdfonts

-- This will hold the curation.
local config = wezterm.config_builder()

local scheme = wezterm.get_builtin_color_schemes()[const.scheme]

local colors = require("colors")
local palette = colors.default

require("events.right-status").setup()

-- 主题外观配置 Colors & Appearance
config.color_scheme = const.scheme
config.window_background_opacity = colors.opacity
config.tab_max_width = 25
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.show_tab_index_in_tab_bar = false

config.colors = {
	foreground = palette.foreground,
	background = palette.background,
	cursor_bg = palette.light_green,
	cursor_border = palette.light_green,
	cursor_fg = palette.background,
	selection_bg = palette.selection_bg,
	selection_fg = palette.foreground,
	ansi = {
		palette.normal.black,
		palette.normal.red,
		palette.normal.green,
		palette.normal.yellow,
		palette.normal.blue,
		palette.normal.magenta,
		palette.normal.cyan,
		palette.normal.white,
	},
	brights = {
		palette.bright.black,
		palette.bright.red,
		palette.bright.green,
		palette.bright.yellow,
		palette.bright.blue,
		palette.bright.magenta,
		palette.bright.cyan,
		palette.bright.white,
	},
	tab_bar = {
		background = palette.tab_bg or scheme.background,
		new_tab = { bg_color = palette.tab_bg or scheme.background, fg_color = scheme.brights[1], intensity = "Bold" },
		new_tab_hover = {
			bg_color = palette.light_green or scheme.cursor_bg,
			fg_color = palette.background or scheme.cursor_fg,
			intensity = "Bold",
		},
	},
}
config.window_padding = {
	left = 12,
	right = 12,
	top = 0,
	bottom = 8,
}
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.65,
}

-- 窗体配置
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.integrated_title_button_style = "Windows"
config.initial_cols = 135
config.initial_rows = 35
config.tab_bar_style = {
	window_hide = " " .. nf.cod_chrome_minimize .. " ",
	window_hide_hover = " " .. nf.cod_chrome_minimize .. " ",
	window_maximize = " " .. nf.cod_chrome_restore .. " ",
	window_maximize_hover = " " .. nf.cod_chrome_restore .. " ",
	window_close = " " .. nf.cod_chrome_close .. " ",
	window_close_hover = " " .. nf.cod_chrome_close .. " ",
}

-- 字体
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	-- "Cascadia Mono",
	"Noto Sans SC",
	-- "MesloLGS NF",
})
config.font_size = 12

-- Windows下配置默认打开PowerShell 7
if string.find(wezterm.target_triple, "windows") then
	config.default_prog = { "C:/Program Files/PowerShell/7/pwsh.exe", "-Nologo" }
end

if string.find(wezterm.target_triple, "apple") then
	config.initial_cols = 150
	config.initial_rows = 45
	config.font_size = 16
	config.hide_tab_bar_if_only_one_tab = true
	config.window_padding.top = 20
end

-- 配置标题栏
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- local is_zoomed = ''
	-- if tab.active_pane.is_zoomed then
	--   is_zoomed = 'z'
	-- end

	if tab.is_active then
		background = palette.light_green or scheme.ansi[3]
		foreground = palette.background or scheme.brights[8]
	elseif hover then
		background = palette.light_green or scheme.cursor_bg
		foreground = palette.background or scheme.cursor_fg
	else
		background = palette.tab_bg
		foreground = scheme.brights[1]
	end

	return {
		{ Attribute = { Intensity = "Bold" } },
		{ Background = { Color = background } },
		{ Foreground = { Color = foreground } },
		{ Text = " " .. tab.tab_index + 1 .. " " },
	}
end)

-- 快捷键
local keymap = require("events.keymaps")
keymap.setup(config)

return config
