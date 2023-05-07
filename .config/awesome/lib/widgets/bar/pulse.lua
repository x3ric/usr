local table = table
local tonumber = tonumber
local string = string
local setmetatable = setmetatable
local awful = require("awful")
local beautiful = require("beautiful")
local gears = require("gears")
local naughty = require("naughty")
local tooltip = require("lib.widgets.float.tooltip")
local audio = require("lib.widgets.gauge.audio")
local notify = require("lib.widgets.float.notify")
local utils = require("lib.utils")
local pulse = { widgets = {}, mt = {} }
pulse.startup_time = 4
local volume_max = 100
local function default_style()
	local style = {
		notify      = {},
		widget      = audio.new,
		audio       = {}
	}
	return utils.table.merge(style, utils.table.check(beautiful, "widget.pulse") or {})
end
local change_volume_default_args = {
	down        = false,
	step        = 5,
	show_notify = false
}
local function get_default_sink(args)
	args = args or {}
	local type_ = args.type or "sink"
	local output = utils.read.output(string.format('pactl get-default-%s', type_))
	return output
end
function pulse:change_volume(args)
	args = utils.table.merge(change_volume_default_args, args or {})
	local diff = args.step
    self._sink = get_default_sink({ type = self._type })
    local v = utils.read.output(string.format("pactl get-%s-volume %s", self._type, self._sink))
    local parsed = string.match(v,"(%d+)%%")
    if not parsed then
        naughty.notify({ title = "Warning!", text = "PA widget can't parse pactl output" })
        return
    end
    local volume = tonumber(parsed)
	local new_volume = args.down and volume - diff or volume + diff
	if new_volume > volume_max then
		new_volume = volume_max
	elseif new_volume < 0 then
		new_volume = 0
	end
	if args.show_notify then
		notify:show(
			utils.table.merge({ value = volume, text = volume .. "%" }, self._style.notify)
		)
	end
	awful.spawn(string.format("pactl set-%s-volume %s %s", self._type, self._sink, new_volume .. "%"))
	self:update_volume()
end
function pulse:mute()
	--args = args or {}
	if not self._type or not self._sink then return end
	awful.spawn(string.format("pactl set-%s-mute %s toggle", self._type, self._sink))
	self:update_volume()
end
function pulse:update_volume(args)
	args = args or {}
	if args.sink_update then
		self._sink = get_default_sink({ type = self._type })
	end
	if not self._type or not self._sink then return end
	local volmax = volume_max
	local volume = 0
	local v = utils.read.output(string.format("pactl get-%s-volume %s", self._type, self._sink))
	local m = utils.read.output(string.format("pactl get-%s-mute %s", self._type, self._sink))
	if v then
		volume = tonumber(string.match(v,"(%d+)%%"))
	end
	local mute = not (m and string.find(m, "no", -4))
	self:set_value(volume/100)
	self:set_mute(mute)
	self._tooltip:set_text(volume .. "%")
end
function pulse.new(args, style)
	style = utils.table.merge(default_style(), style or {})
	args = args or {}
	local timeout = args.timeout or 5
	local autoupdate = args.autoupdate or false
	local widg = style.widget(style.audio)
	gears.table.crush(widg, pulse, true)
	widg._type = args.type or "sink"
	widg._sink = args.sink
	widg._style = style
	table.insert(pulse.widgets, widg)
	widg._tooltip = tooltip({ objects = { widg } }, style.tooltip)
	if autoupdate then
		local t = gears.timer({ timeout = timeout })
		t:connect_signal("timeout", function() widg:update_volume() end)
		t:start()
	end
	if not widg._sink then
		local st = gears.timer({ timeout = 1 })
		local counter = 0
		st:connect_signal("timeout", function()
			counter = counter + 1
			widg._sink = get_default_sink({ type = widg._type })
			if widg._sink then widg:update_volume() end
			if counter > pulse.startup_time or widg._sink then st:stop() end
		end)
		st:start()
	else
		widg:update_volume()
	end
	return widg
end
function pulse.mt:__call(...)
	return pulse.new(...)
end
return setmetatable(pulse, pulse.mt)
--[[
local math = math
function pulse:change_volume(args)
    args = utils.table.merge(change_volume_default_args, args or {})
    local diff = args.down and -args.step or args.step
    local v = utils.read.output(string.format("pactl get-sink-volume %s | grep -oE '[0-9]+%' | tr -d '%'", self._sink))
    local volume = tonumber(v)
    local new_volume = volume + diff
    if new_volume > 100 then
        new_volume = 100
    elseif new_volume < 0 then
        new_volume = 0
    end
    if args.show_notify then
        notify:show(
            utils.table.merge({ value = new_volume / 100, text = string.format('%.0f', new_volume) .. "%" }, self._style.notify)
        )
    end
    awful.spawn(string.format("pamixer --set-volume %d", new_volume))
    local tooltip_text = utils.read.output(string.format("pactl get-sink-volume %s | grep -oE '[0-9]+%'", self._sink))
    self._tooltip:set_text(tooltip_text)
    self:update_volume()
end
function pulse:mute()
    if not self._type or not self._sink then
        return
    end
    awful.spawn(string.format('sh -c "pactl set-source-mute %s toggle"', self._sink))
    self:update_volume()
end
function pulse:update_volume(args)
    args = args or {}
    if args.sink_update then
        if self._sink == null then
            if self._type == "input" then
                local sink = utils.read.output('pactl list short sources | awk "/input/ {print $1; exit}"')
            else
                local sink = utils.read.output('pactl list short sources | awk "/output/ {print $1; exit}"')
            end
            if sink and sink ~= "" then
                self._sink = sink
            else
                return
            end     
        end
    end
    if not self._type or not self._sink then
        return
    end
    local v = utils.read.output("pamixer --get-volume-human")
    local volume = tonumber(string.match(v, "(%d+)%%")) or 0
    if utils.read.output(string.format("sh -c 'pactl get-source-mute %s | cut -d ' ' -f 2'", self._sink)) == "yes" then local mute = true else local mute = false end
    self:set_value(volume / 100)
    self:set_mute(mute)
    self._tooltip:set_text(volume .. "%")
end
function pulse.new(args, style)
    style = utils.table.merge(default_style(), style or {})
    args = args or {}
    local timeout = args.timeout or 5
    local autoupdate = args.autoupdate or false
    local widg = style.widget(style.audio)
    gears.table.crush(widg, pulse, true)
    widg._type = args.type or "output"
    table.insert(pulse.widgets, widg)
    widg._style = style
    widg._tooltip = tooltip({ objects = { widg } }, style.tooltip)
    if autoupdate then
        local t = gears.timer({ timeout = timeout })
        t:connect_signal("timeout", function() widg:update_volume() end)
        t:start()
    end
    if widg._type == "input" then
        local st = gears.timer({ timeout = 1 })
        local counter = 0
        st:connect_signal("timeout", function()
            counter = counter + 1
            local sink = utils.read.output('pactl list short sources | awk "/input/ {print $1; exit}"')
            if sink and sink ~= "" then
                widg._sink = sink
                widg:update_volume()
            end
            if counter > pulse.startup_time or widg._sink then
                st:stop()
            end
        end)
        st:start()
    elseif widg._type == "output" then
        local st = gears.timer({ timeout = 1 })
        local counter = 0
        st:connect_signal("timeout", function()
            counter = counter + 1
            local sink = utils.read.output('pactl list short sources | awk "/output/ {print $1; exit}"')
            if sink and sink ~= "" then
                widg._sink = sink
                widg:update_volume()
            end
            if counter > pulse.startup_time or widg._sink then
                st:stop()
            end
        end)
        st:start()      
    else
        widg:update_volume()
    end
    return widg
end
]]
