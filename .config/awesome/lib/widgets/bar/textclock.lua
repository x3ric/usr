local setmetatable = setmetatable
local os = os
local textbox = require("wibox.widget.textbox")
local beautiful = require("beautiful")
local gears = require("gears")
local tooltip = require("lib.widgets.float.tooltip")
local utils = require("lib.utils")
local textclock = { mt = {} }
local function default_style()
	local style = {
		font  = "Sans 12",
		tooltip = {},
		color = { text = "#aaaaaa" }
	}
	return utils.table.merge(style, utils.table.check(beautiful, "widget.textclock") or {})
end
function textclock.new(args, style)
	args = args or {}
	local timeformat = args.timeformat or " %a %b %d, %H:%M "
	local timeout = args.timeout or 60
	style = utils.table.merge(default_style(), style or {})
	local widg = textbox()
	widg:set_font(style.font)
	local tp
	if args.dateformat then tp = tooltip({ objects = { widg } }, style.tooltip) end
	local timer = gears.timer({ timeout = timeout })
	timer:connect_signal("timeout",
		function()
			widg:set_markup('<span color="' .. style.color.text .. '">' .. os.date(timeformat) .. "</span>")
			if args.dateformat then tp:set_text(os.date(args.dateformat)) end
		end)
	timer:start()
	timer:emit_signal("timeout")
	return widg
end
function textclock.mt:__call(...)
	return textclock.new(...)
end
return setmetatable(textclock, textclock.mt)
