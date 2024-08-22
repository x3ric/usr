local unpack = unpack or table.unpack
local math = math
local awsome = awesome
local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local timer = require("gears.timer")
local utils = require("lib.utils")
local progressbar = require("lib.widgets.gauge.graph.bar")
local dashcontrol = require("lib.widgets.gauge.graph.dash")
local svgbox = require("lib.widgets.gauge.svgbox")
local player = { box = {}, listening = false }
local dbus_get = "dbus-send --print-reply=literal --session --dest=org.mpris.MediaPlayer2.%s " .. "/org/mpris/MediaPlayer2 " .. "org.freedesktop.DBus.Properties.Get " .. "string:'org.mpris.MediaPlayer2.Player' %s"
local dbus_getall = "dbus-send --print-reply=literal --session --dest=org.mpris.MediaPlayer2.%s " .. "/org/mpris/MediaPlayer2 " .. "org.freedesktop.DBus.Properties.GetAll " .. "string:'org.mpris.MediaPlayer2.Player'"
local dbus_set = "dbus-send --print-reply=literal --session --dest=org.mpris.MediaPlayer2.%s " .. "/org/mpris/MediaPlayer2 " .. "org.freedesktop.DBus.Properties.Set " .. "string:'org.mpris.MediaPlayer2.Player' %s"
local dbus_action = "dbus-send --print-reply=literal --session --dest=org.mpris.MediaPlayer2.%s " .. "/org/mpris/MediaPlayer2 " .. "org.mpris.MediaPlayer2.Player."
local function mouse_get_current_widget_geometry()
	local w = mouse.current_wibox
	if w then
		local geo, coords = w:geometry(), mouse:coords()
		local bw = w.border_width
		local list = w:find_widgets(coords.x - geo.x - bw, coords.y - geo.y - bw)
				return list[#list]
	end
end
local function decodeURI(s)
	return string.gsub(s, '%%(%x%x)', function(hex) return string.char(tonumber(hex, 16)) end)
end
local function default_style()
	local style = {
		geometry        = { width = 520, height = 150 },
		screen_gap      = 0,
		set_position    = nil,
		dashcontrol     = {},
		progressbar     = {},
		border_margin   = { 20, 20, 20, 20 },
		elements_margin = { 20, 0, 0, 0 },
		volume_margin   = { 0, 0, 0, 3 },
		controls_margin = { 0, 0, 18, 8 },
		buttons_margin  = { 0, 0, 3, 3 },
		pause_margin    = { 12, 12, 0, 0},
		timeout         = 5,
		line_height     = 26,
		bar_width       = 8, 		volume_width    = 50,
		titlefont       = "OCR A 12",
		timefont        = "OCR A 12",
		artistfont      = "OCR A 12",
		border_width    = 2,
		icon            = {
			cover   = utils.base.placeholder(),
			shuffle = utils.base.placeholder({ txt = "S" }),
			loop    = utils.base.placeholder({ txt = "L" }),
			play    = utils.base.placeholder({ txt = "►" }),
			pause   = utils.base.placeholder({ txt = "[]" }),
			next_tr = utils.base.placeholder({ txt = "→" }),
			prev_tr = utils.base.placeholder({ txt = "←" }),
		},
		color          = { border = "#575757", main = "#b1222b",
		                   wibox = "#202020", gray = "#575757", icon = "#a0a0a0" },
		shape          = nil
	}
	return utils.table.merge(style, utils.table.check(beautiful, "float.player") or {})
end
function player:init(args)
	args = args or {}
	local _player = args.name
	local style = default_style()
	local show_album = false
	self.info = { artist = "Unknown", album = "Unknown" }
	self.style = style
	self.last = { status = "Stopped", length = 5 * 60 * 1000000, volume = nil }
		self.command = {
		get_all      = string.format(dbus_getall, _player),
		get_position = string.format(dbus_get, _player, "string:'Position'"),
		get_volume   = string.format(dbus_get, _player, "string:'Volume'"),
		set_volume   = string.format(dbus_set, _player, "string:'Volume' variant:double:"),
		action       = string.format(dbus_action, _player),
		set_position = string.format(dbus_action, _player) .. "SetPosition objpath:/not/used int64:",
	}
	self._actions = { "PlayPause", "Next", "Previous" }
		self.bar = progressbar(style.progressbar)
	self.box.image = svgbox(style.icon.cover)
	self.box.image:set_color(style.color.gray)
	self.box.title = wibox.widget.textbox("Title")
	self.box.artist = wibox.widget.textbox("Artist")
	self.box.title:set_font(style.titlefont)
	self.box.title:set_valign("top")
	self.box.artist:set_font(style.artistfont)
	self.box.artist:set_valign("top")
	local text_area = wibox.layout.fixed.vertical()
	text_area:add(wibox.container.constraint(self.box.title, "exact", nil, style.line_height))
	text_area:add(wibox.container.constraint(self.box.artist, "exact", nil, style.line_height))
	local player_buttons = wibox.layout.fixed.horizontal()
	local prev_button = svgbox(style.icon.prev_tr, nil, style.color.icon)
	player_buttons:add(prev_button)
	self.play_button = svgbox(style.icon.play, nil, style.color.icon)
	player_buttons:add(wibox.container.margin(self.play_button, unpack(style.pause_margin)))
	local next_button = svgbox(style.icon.next_tr, nil, style.color.icon)
	player_buttons:add(next_button)
	-- Create shuffle and loop buttons
		local mpc_status = io.popen("mpc status"):read("*all")
		local shuffle_active = mpc_status:match("random: on")
		local shuffle_button = svgbox(style.icon.shuffle, nil, style.color.icon)
		player_buttons:add(wibox.container.margin(shuffle_button, 12))
		shuffle_button:buttons(awful.util.table.join(
			awful.button({}, 1, function()
				self:action("Shuffle")
				shuffle_active = not shuffle_active
				shuffle_button:set_color(not shuffle_active and style.color.icon or style.color.main)
			end)
		))
		shuffle_button:set_color(not shuffle_active and style.color.icon or style.color.main)
		local loop_active = mpc_status:match("repeat: on")
		local loop_button = svgbox(style.icon.loop, nil, style.color.icon)
		player_buttons:add(wibox.container.margin(loop_button, 12))
		loop_button:buttons(awful.util.table.join(
			awful.button({}, 1, function()
				self:action("LoopStatus")
				loop_active = not loop_active
				loop_button:set_color(not loop_active and style.color.icon or style.color.main)
			end)
		))
		loop_button:set_color(not loop_active and style.color.icon or style.color.main)
	self.box.time = wibox.widget.textbox("0:00")
	self.box.time:set_font(style.timefont)
		self.volume = dashcontrol(style.dashcontrol)
	local volumespace = wibox.container.margin(self.volume, unpack(style.volume_margin))
	local volume_area = wibox.container.constraint(volumespace, "exact", style.volume_width, nil)
		local buttons_align = wibox.layout.align.horizontal()
	buttons_align:set_expand("outside")
	buttons_align:set_middle(wibox.container.margin(player_buttons, unpack(style.buttons_margin)))
	local control_align = wibox.layout.align.horizontal()
	control_align:set_middle(buttons_align)
	control_align:set_right(self.box.time)
	control_align:set_left(volume_area)
	local align_vertical = wibox.layout.align.vertical()
	align_vertical:set_top(text_area)
	align_vertical:set_middle(wibox.container.margin(control_align, unpack(style.controls_margin)))
	align_vertical:set_bottom(wibox.container.constraint(self.bar, "exact", nil, style.bar_width))
	local area = wibox.layout.fixed.horizontal()
	local cover_area = wibox.container.place(self.box.image)
	cover_area.forced_width = style.geometry.height - style.border_margin[3] - style.border_margin[4]
	area:add(cover_area)
	area:add(wibox.container.margin(align_vertical, unpack(style.elements_margin)))
	self.play_button:buttons(awful.util.table.join(awful.button({}, 1, function() self:action("PlayPause") end)))
	next_button:buttons(awful.util.table.join(awful.button({}, 1, function() self:action("Next") end)))
	prev_button:buttons(awful.util.table.join(awful.button({}, 1, function() self:action("Previous") end)))
	self.volume:buttons(awful.util.table.join(
		awful.button({}, 4, function() self:change_volume( 0.05) end),
		awful.button({}, 5, function() self:change_volume(-0.05) end)
	))
		self.bar:buttons(awful.util.table.join(
		awful.button(
			{}, 1, function()
				local coords = {
					bar   = mouse_get_current_widget_geometry(),
					wibox = mouse.current_wibox:geometry(),
					mouse = mouse.coords(),
				}
				local position = (coords.mouse.y - coords.wibox.y - coords.bar.y) / coords.bar.height
				awful.spawn.with_shell(self.command.set_position .. math.floor(self.last.length * position))
			end
		)
	))
		self.box.artist:buttons(awful.util.table.join(
		awful.button({}, 1,
			function()
				show_album = not show_album
				self.update_artist()
			end
		)
	))
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})
	self.wibox:set_widget(wibox.container.margin(area, unpack(style.border_margin)))
	self.wibox:geometry(style.geometry)
	self.set_play_button = function(state)
		self.play_button:set_image(style.icon[state])
	end
	self.update_artist = function()
		if show_album then
			self.box.artist:set_markup('<span color="' .. style.color.gray .. '">From </span>' .. self.info.album)
		else
			self.box.artist:set_markup('<span color="' .. style.color.gray .. '">By </span>' .. self.info.artist)
		end
	end
	self.clear_info = function(is_att)
		self.box.image:set_image(style.icon.cover)
		self.box.image:set_color(is_att and style.color.main or style.color.gray)
		self.box.image:emit_signal("widget::layout_changed")
		self.box.time:set_text("0:00")
		self.bar:set_value(0)
				self.info = { artist = "", album = "" }
		self.update_artist()
		self.last.volume = nil
	end
	function self:update()
		if self.last.status ~= "Stopped" then
			awful.spawn.easy_async(
				self.command.get_position,
				function(output, _, _, exit_code)
										if exit_code ~= 0 then
						self.clear_info(true)
						self.last.status = "Stopped"
						return
					end
										local position = string.match(output, "int64%s+(%d+)")
					local progress = position / self.last.length
					self.bar:set_value(progress)
										local ps = math.floor(position / 10^6)
					local ct = string.format("%d:%02d", math.floor(ps / 60), ps % 60)
					self.box.time:set_text(ct)
				end
			)
		end
	end
	self.updatetimer = timer({ timeout = style.timeout })
	self.updatetimer:connect_signal("timeout", function() self:update() end)
	if not self.listening then self:listen() end
	self:initialize_info()
end
function player:initialize_info()
	awful.spawn.easy_async(
		self.command.get_all,
		function(output, _, _, exit_code)
			local data = { Metadata = {} }
			local function parse_dbus_value(ident)
				local regex = "(" .. ident .. ")%s+([a-z0-9]+)%s+(.-)%s-%)\n"
				local _, _, value = output:match(regex)
				if not value then return nil end
								local int64_val = value:match("int64%s+(%d+)")
				if int64_val then return tonumber(int64_val) end
								local double_val = value:match("double%s+([%d.]+)")
				if double_val then return tonumber(double_val) end
								local array_val = value:match("array%s%[%s+([^%],]+)")
				if array_val then return { array_val } end
				return value
			end
			if exit_code == 0 then
				data.Metadata["xesam:title"]  = parse_dbus_value("xesam:title")
				data.Metadata["xesam:artist"] = parse_dbus_value("xesam:artist")
				data.Metadata["xesam:album"]  = parse_dbus_value("xesam:album")
				data.Metadata["mpris:artUrl"] = parse_dbus_value("mpris:artUrl")
				data.Metadata["mpris:length"] = parse_dbus_value("mpris:length")
				data["Volume"]                = parse_dbus_value("Volume")
				data["Position"]              = parse_dbus_value("Position")
				data["PlaybackStatus"]        = parse_dbus_value("PlaybackStatus")
				self:update_from_metadata(data)
			end
		end
	)
end
function player:action(args)
    local is_firefox_playing = io.popen("playerctl -p firefox status | grep -q 'Playing' && echo 'true' || echo 'false'"):read("*all"):gsub("%s+", "") == "true"
    if not is_firefox_playing then
        if args == "Stop" then
            awful.spawn.with_shell("mpc stop")
        elseif args == "Shuffle" then
            awful.spawn.with_shell("mpc random")
        elseif args == "LoopStatus" then
            awful.spawn.with_shell("mpc repeat")
        elseif args == "PlayPause" then
            awful.spawn.with_shell("mpc toggle")
        elseif args == "Next" then
            awful.spawn.with_shell("mpc next")
        elseif args == "Previous" then
            awful.spawn.with_shell("mpc prev")
        end
    else
        if args == "Stop" then
            awful.spawn.with_shell("playerctl -p firefox stop")
        elseif args == "Shuffle" then
            awful.spawn.with_shell("playerctl -p firefox shuffle")
        elseif args == "LoopStatus" then
            awful.spawn.with_shell("playerctl -p firefox loop")
        elseif args == "PlayPause" then
            awful.spawn.with_shell("playerctl -p firefox play-pause")
        elseif args == "Next" then
            awful.spawn.with_shell("playerctl -p firefox next")
        elseif args == "Previous" then
            awful.spawn.with_shell("playerctl -p firefox previous")
        end
        if args == "Next" or args == "Previous" then
            awesome.emit_signal("track_changed")
        end
        if not awful.util.table.hasitem(self._actions, args) then return end
        if not self.wibox then self:init() end
        self:update()
    end
end
function player:change_volume(step)
	local v = (self.last.volume or 0) + step
	if     v > 1 then v = 1
	elseif v < 0 then v = 0 end
	self.last.volume = v
	awful.spawn.with_shell(self.command.set_volume .. v)
end
function player:hide()
	self.wibox.visible = false
	if self.updatetimer.started then self.updatetimer:stop() end
end
function player:show(geometry)
	if not self.wibox then self:init() end
	if not self.wibox.visible then
		self:update()
		self:update_from_metadata()
		if geometry then
			self.wibox:geometry(geometry)
		elseif self.style.set_position then
			self.style.set_position(self.wibox)
		else
			awful.placement.under_mouse(self.wibox)
		end
		utils.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)
		self.wibox.visible = true
		if self.last.status == "Playing" then self.updatetimer:start() end
	else
		self:hide()
	end
end
local function click_outside_minitray(c)
    if not player.wibox then player:init() end
	if player.wibox.visible then
		local mx, my = mouse.coords().x, mouse.coords().y
		local wx, wy = player.wibox:geometry().x, player.wibox:geometry().y
		local ww, wh = player.wibox:geometry().width, player.wibox:geometry().height
		if mx < wx or my < wy or mx > wx + ww or my > wy + wh then
			player:hide()
		end
	end
end
client.connect_signal("button::press", click_outside_minitray)
function extract_base_name(url)
    if url then
        local file_name = nil
        for part in url:gmatch("[^/]+") do
            file_name = part
        end
        local base_name, _ = file_name:match("(.+)%..+")
        return base_name or file_name
    end
end
function player:update_from_metadata(data)
		if not data then return end
		if data.Metadata then
				self.box.title:set_text(data.Metadata["xesam:title"] or extract_base_name(data.Metadata["xesam:url"]) or "Unknown")
				self.info.artist = data.Metadata["xesam:artist"] and data.Metadata["xesam:artist"][1] or "Unknown"
		self.info.album  = data.Metadata["xesam:album"] or "Unknown"
		self.update_artist()
				local has_cover = false
		if data.Metadata["mpris:artUrl"] then
			local image = string.match(data.Metadata["mpris:artUrl"], "file://(.+)")
			if image then
				self.box.image:set_color(nil)
				has_cover = self.box.image:set_image(decodeURI(image))
				self.box.image:emit_signal("widget::layout_changed")
			end
		end
		if not has_cover then
						self.box.image:set_color(self.style.color.gray)
			self.box.image:set_image(self.style.icon.cover)
			self.box.image:emit_signal("widget::layout_changed")
		end
				if data.Metadata["mpris:length"] then self.last.length = data.Metadata["mpris:length"] end
	end
	if data.PlaybackStatus then
				local state = data.PlaybackStatus == "Playing" and "pause" or "play"
		self.set_play_button(state)
		self.last.status = data.PlaybackStatus
				if data.PlaybackStatus == "Playing" then
			if self.wibox.visible then self.updatetimer:start() end
		else
			if self.updatetimer.started then self.updatetimer:stop() end
			self:update()
		end
				if data.PlaybackStatus == "Stopped" then
			self.clear_info()
		end
	end
		if data.Volume then
		self.volume:set_value(data.Volume)
		self.last.volume = data.Volume
	elseif not self.last.volume then
				awful.spawn.easy_async(
			self.command.get_volume,
			function(output, _, _, exit_code)
				if exit_code ~= 0 then
					return
				end
				local volume = tonumber(string.match(output, "double%s+([%d.]+)"))
				if volume then
					self.volume:set_value(volume)
					self.last.volume = volume
				end
			end
		)
	end
end
function player:listen()
	dbus.request_name("session", "org.freedesktop.DBus.Properties")
	dbus.add_match(
		"session",
		"path=/org/mpris/MediaPlayer2, interface='org.freedesktop.DBus.Properties', member='PropertiesChanged'"
	)
	dbus.connect_signal("org.freedesktop.DBus.Properties",
		function (_, _, data)
			self:update_from_metadata(data)
		end
	)
	self.listening = true
end
return player
