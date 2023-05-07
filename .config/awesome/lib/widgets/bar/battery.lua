local setmetatable = setmetatable
local beautiful = require("beautiful")
local timer = require("gears.timer")
local notify = require("lib.widgets.float.notify")
local tooltip = require("lib.widgets.float.tooltip")
local monitor = require("lib.widgets.gauge.monitor.plain")
local utils = require("lib.utils")
local battery = { mt = {} }
local function default_style()
    local style = {
        timeout = 60,
        width = nil,
        widget = monitor.new,
        notify = {},
        levels = { 0.05, 0.1, 0.15 }
    }
    return utils.table.merge(style, utils.table.check(beautiful, "widget.battery") or {})
end
local get_level = function(value, line)
    for _, v in ipairs(line) do
        if value < v then return v end
    end
end
function battery.new(args, style)
    args = args or {}
    style = utils.table.merge(default_style(), style or {})
    local widg = style.widget(style.monitor)
    widg._last = { value = 1, level = 1, plugged = true }
    widg._tp = tooltip({ objects = { widg } }, style.tooltip)
    widg._update = function()
        local state = args.func(args.arg)
		widg._tp:set_text(state.text)
        widg:set_value(state.value)
        widg:set_alert(state.alert)
        if state.value <= widg._last.value then
            local level = get_level(state.value, style.levels)
            if level and level ~= widg._last.level then
                widg._last.level = level
                local warning = string.format("Battery charge < %.0f%%", level * 100)
                notify:show(utils.table.merge({ text = warning }, style.notify))
            end
        else
            widg._last.level = nil
        end
        widg._last.value = state.value
    end
	widg._last_notified_state = nil
	widg._state = function()
		local state = utils.read.output(string.format("cat /sys/class/power_supply/%s/status", args.arg))
		if state ~= widg._last.state then
			if state == "Discharging\n" then
				if widg._last_notified_state ~= "Discharging" then
					notify:show(utils.table.merge({ text = "Battery unplugged" }, style.notify))
					widg._last_notified_state = "Discharging"
				end
				state = { plugged = false }
			else
				if widg._last_notified_state == "Discharging" then
					notify:show(utils.table.merge({ text = "Battery plugged" }, style.notify))
					widg._last_notified_state = "Charging"
				end
			end
		end
		widg._last.state = state
	end
    widg._timer = timer({ timeout = style.timeout })
    widg._timer:connect_signal("timeout", function() widg._update() widg._state() end)
    widg._timer:start()
    widg._timer:emit_signal("timeout")
    return widg
end
function battery.mt:__call(...)
    return battery.new(...)
end
return setmetatable(battery, battery.mt)
