local M = {}

function M.basename(s)
	return string.gsub(s, "(.*[/\\])(.*)", "%2")
end

function M.convert_home_dir(path)
	local cwd = path
	local home = os.getenv("HOME")
	cwd = cwd:gsub("^" .. home .. "/", "~/")
	if cwd == "" then
		return path
	end
	return cwd
end

function M.convert_useful_path(dir)
	local cwd = M.convert_home_dir(dir)
	return M.basename(cwd)
end

----------------------------
-- 显示中文日期
----------------------------
local days = {
	Sun = "周日",
	Mon = "周一",
	Tue = "周二",
	Wed = "周三",
	Thu = "周四",
	Fri = "周五",
	Sat = "周六",
}

-- 将英文月份和周几替换为中文
function M.get_chinese_date()
	-- 获取当前日期时间，并格式化为英文
	local date = os.date("%m-%d %H:%M %a")

	-- 提取各部分
	local month_day = date:sub(1, 5)
	local time = date:sub(7, 11)
	local week_day = date:sub(13, 15)

	-- 返回中文格式的日期时间
	return string.format("%s %s %s", month_day, time, days[week_day])
end

M.clamp = function(x, min, max)
	return x < min and min or (x > max and max or x)
end

M.round = function(x, increment)
	if increment then
		return M.round(x / increment) * increment
	end
	return x >= 0 and math.floor(x + 0.5) or math.ceil(x - 0.5)
end

return M

