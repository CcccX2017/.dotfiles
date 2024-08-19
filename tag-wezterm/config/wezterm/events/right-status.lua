local wezterm = require("wezterm")
local utils = require("utils")
local const = require("const")
local scheme = wezterm.get_builtin_color_schemes()[const.scheme]

wezterm.config_builder().status_update_interval = 1000

local nf = wezterm.nerdfonts
local M = {}

local SEPARATOR_CHAR = " "

local discharging_icons = {
	nf.md_battery_10,
	nf.md_battery_20,
	nf.md_battery_30,
	nf.md_battery_40,
	nf.md_battery_50,
	nf.md_battery_60,
	nf.md_battery_70,
	nf.md_battery_80,
	nf.md_battery_90,
	nf.md_battery,
}
local charging_icons = {
	nf.md_battery_charging_10,
	nf.md_battery_charging_20,
	nf.md_battery_charging_30,
	nf.md_battery_charging_40,
	nf.md_battery_charging_50,
	nf.md_battery_charging_60,
	nf.md_battery_charging_70,
	nf.md_battery_charging_80,
	nf.md_battery_charging_90,
	nf.md_battery_charging,
}

local colors = {
	date_fg = "#fab387",
	background = scheme.background,
	battery_fg = "#f9e2af",
	separator_fg = "#74c7ec",
}

local __cells__ = {}

local _push = function(text, icon, fg, bg, separate)
	table.insert(__cells__, { Foreground = { Color = fg } })
	table.insert(__cells__, { Background = { Color = bg } })
	table.insert(__cells__, { Attribute = { Intensity = "Bold" } })
	table.insert(__cells__, { Text = icon .. " " .. text })

	if separate then
		table.insert(__cells__, { Foreground = { Color = colors.separator_fg } })
		table.insert(__cells__, { Background = { Color = colors.background } })
		table.insert(__cells__, { Text = SEPARATOR_CHAR })
	end
end

-- 设置时间
local _set_date = function()
	local date = utils.get_chinese_date()
	local separate = false
	if #wezterm.battery_info() > 0 then
		separate = true
	end
	_push(date, nf.fa_calendar, colors.date_fg, colors.background, separate)
end

-- 设置电池
local _set_battery = function()
	-- ref: https://wezfurlong.org/wezterm/config/lua/wezterm/battery_info.html

	local charge = ""
	local icon = ""
	for _, b in ipairs(wezterm.battery_info()) do
		local idx = utils.clamp(utils.round(b.state_of_charge * 10), 1, 10)
		charge = string.format("%.0f%%", b.state_of_charge * 100)

		if b.state == "Charging" then
			icon = charging_icons[idx]
		else
			icon = discharging_icons[idx]
		end
	end

	_push(charge, icon, colors.battery_fg, colors.background, false)
end

M.setup = function()
	wezterm.on("update-right-status", function(window, _pane)
		__cells__ = {}
		_set_date()
		_set_battery()

		window:set_right_status(wezterm.format(__cells__))
	end)
end

return M
