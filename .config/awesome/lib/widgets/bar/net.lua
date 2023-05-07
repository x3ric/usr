local setmetatable = setmetatable
local beautiful = require("beautiful")
local timer = require("gears.timer")
local utils = require("lib.utils")
local monitor = require("lib.widgets.gauge.icon.double")
local tooltip = require("lib.widgets.float.tooltip")
local system = require("lib.utils.system")
local net = { mt = {} }
local default_args = {
	speed     = { up = 10*1024, down = 10*1024 },
	autoscale = true,
	findall   = true,
	interface = "eth0"
}
local function default_style()
	local style = {
		widget    = monitor.new,
		timeout   = 5,
		digits    = 2
	}
	return utils.table.merge(style, utils.table.check(beautiful, "widget.net") or {})
end
function net.new(args, style)
	local storage = {}
	local unit = {{  "B", 1 }, { "KB", 1024 }, { "MB", 1024^2 }, { "GB", 1024^3 }}
	args = utils.table.merge(default_args, args or {})
	style = utils.table.merge(default_style(), style or {})
	local widg = style.widget(style.monitor)
	local tp = tooltip({ objects = { widg } }, style.tooltip)
	local t = timer({ timeout = style.timeout })
	t:connect_signal("timeout",
		function()
			local state = system.net_speed(args, storage)
			widg:set_value({1,1})

			if args.autoscale then
				if state[1] > args.speed.up then args.speed.up = state[1] end
				if state[2] > args.speed.down then args.speed.down = state[2] end
			end

			if args.alert then
				widg:set_alert(state[1] > args.alert.up or state[2] > args.alert.down)
			end

			widg:set_value({ state[2]/args.speed.down, state[1]/args.speed.up })
			tp:set_text(
				"▾ " .. utils.text.dformat(state[2], unit, style.digits, " ")
				.. "  ▴ " .. utils.text.dformat(state[1], unit, style.digits, " ")
			)
		end
	)
	t:start()
	t:emit_signal("timeout")
	return widg
end
function net.mt:__call(...)
	return net.new(...)
end
return setmetatable(net, net.mt)
