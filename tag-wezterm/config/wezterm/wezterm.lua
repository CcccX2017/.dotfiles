---@diagnostic disable: lowercase-global
-- Pull in the wezterm API
local wezterm = require("wezterm")
local utils = require("utils")
local const = require("const")
local nf = wezterm.nerdfonts

-- This will hold the curation.
local config = wezterm.config_builder()

local scheme = wezterm.get_builtin_color_schemes()[const.scheme]

require("events.right-status").setup()

-- 主题外观配置 Colors & Appearance
config.color_scheme = const.scheme
config.tab_max_width = 25
config.use_fancy_tab_bar = false
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false
config.colors = {
	tab_bar = {
		background = scheme.background,
		new_tab = { bg_color = scheme.background, fg_color = scheme.brights[1], intensity = "Bold" },
		new_tab_hover = { bg_color = scheme.cursor_bg, fg_color = scheme.cursor_fg, intensity = "Bold" },
	},
}
config.window_padding = {
	left = 12,
	right = 12,
	top = 20,
	bottom = 8,
}
config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.65,
}
local opacity = 0.85
config.window_background_opacity = opacity
-- config.text_background_opacity = opacity

-- 窗体配置
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.integrated_title_button_style = "Windows"
config.initial_cols = 120
config.initial_rows = 35
config.tab_bar_style = {
	window_hide = " " .. nf.cod_chrome_minimize .. " ",
	window_hide_hover = " " .. nf.cod_chrome_minimize .. " ",
	window_maximize = " " .. nf.cod_chrome_restore .. " ",
	window_maximize_hover = " " .. nf.cod_chrome_restore .. " ",
	window_close = " " .. nf.cod_chrome_close .. " ",
	window_close_hover = " " .. nf.cod_chrome_close .. " ",
}

-- Windows下配置默认打开PowerShell 7
if string.find(wezterm.target_triple, "windows") then
	config.default_prog = { "C:/Program Files/PowerShell/7/pwsh.exe", "-Nologo" }
end

if string.find(wezterm.target_triple, "apple") then
	config.initial_cols = 150
	config.initial_rows = 43
end

-- 字体
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font",
	-- "Cascadia Mono",
	"Noto Sans SC",
	-- "MesloLGS NF",
})
config.font_size = 16

-- 配置标题栏
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	-- local is_zoomed = ''
	-- if tab.active_pane.is_zoomed then
	--   is_zoomed = 'z'
	-- end

	if tab.is_active then
		background = scheme.ansi[3]
		foreground = scheme.brights[8]
	elseif hover then
		background = scheme.cursor_bg
		foreground = scheme.cursor_fg
	else
		background = scheme.background
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
