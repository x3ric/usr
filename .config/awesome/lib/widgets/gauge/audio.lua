local setmetatable = setmetatable
local unpack = unpack or table.unpack
local wibox = require("wibox")
local beautiful = require("beautiful")
local redutil = require("lib.utils")
local svgbox = require("lib.widgets.gauge.svgbox")
local dashx = require("lib.widgets.gauge.graph.dash")
local audio = { mt = {} }
local function default_style()
	local style = {
		width   = 100,
		icon    = redutil.base.placeholder(),
		gauge   = dashx.new,
		dash    = {},
		dmargin = { 10, 0, 0, 0 },
		color   = { icon = "#a0a0a0", mute = "#404040" }
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "gauge.audio") or {})
end
function audio.new(style)
	style = redutil.table.merge(default_style(), style or {})
	local icon = svgbox(style.icon)
	local layout = wibox.layout.fixed.horizontal()
	layout:add(icon)
	local dash
	if style.gauge then
		dash = style.gauge(style.dash)
		layout:add(wibox.container.margin(dash, unpack(style.dmargin)))
	end
	local widg = wibox.container.constraint(layout, "exact", style.width)
	function widg:set_value(x) if dash then dash:set_value(x) end end
	function widg:set_mute(mute)
		icon:set_color(mute and style.color.mute or style.color.icon)
	end
	return widg
end
function audio.mt:__call(...)
	return audio.new(...)
end
return setmetatable(audio, audio.mt)