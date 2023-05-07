local setmetatable = setmetatable
local table = table
local string = string
local os = os
local unpack = unpack or table.unpack
local beautiful = require("beautiful")
local wibox = require("wibox")
local awful = require("awful")
local timer = require("gears.timer")
local notify = require("lib.widgets.float.notify")
local tooltip = require("lib.widgets.float.tooltip")
local utils = require("lib.utils")
local svgbox = require("lib.widgets.gauge.svgbox")
local separator = require("lib.widgets.gauge.separator")
local tip = require("lib.widgets.float.hotkeys")
local updates = { objects = {}, mt = {} }
local function default_style()
	local style = {
		wibox = {
			geometry     = { width = 400, height = 200 },
			border_width = 1,
			title_font   = "OCR A 14 bold",
			tip_font     = "OCR A 10",
			set_position = nil,
			separator    = {},
			shape        = nil,
			icon         = {
				package = utils.base.placeholder(),
				close   = utils.base.placeholder({ txt = "X" }),
				daily   = utils.base.placeholder(),
				weekly  = utils.base.placeholder(),
				normal  = utils.base.placeholder(),
				silent  = utils.base.placeholder(),
			},
			height = { title = 40, state = 50, tip = 20 },
			margin = { close = { 0, 0, 0, 0 }, state = { 0, 0, 0, 0 }, title = { 0, 0, 0, 0 }, image = { 0, 0, 0, 0 } }
		},
		icon        = utils.base.placeholder(),
		keytip      = { geometry = { width = 400 } },
		notify      = {},
		firstrun    = true,
		need_notify = true,
		tooltip     = {
			base = {},
			state = {
				timeout = 3,
				set_position = function(w) awful.placement.under_mouse(w) w.y = w.y - 30 end,
			}
		},
		color       = { main = "#b1222b", icon = "#a0a0a0", wibox = "#202020", border = "#575757", gray = "#404040",
		                urgent = "#32882d" }
	}
	return utils.table.merge(style, utils.table.check(beautiful, "widget.updates") or {})
end
local STATE = setmetatable(
	{ keywords = { "NORMAL", "DAILY", "WEEKLY", "SILENT" } },
	{ __index = function(table_, key)
		return awful.util.table.hasitem(table_.keywords, key) or rawget(table_, key)
	end }
)
local tips = {}
tips[STATE.NORMAL] = "regular notifications"
tips[STATE.DAILY]  = "postponed for a day"
tips[STATE.WEEKLY] = "postponed for a week"
tips[STATE.SILENT] = "notifications disabled"
updates.keys = {}
updates.keys.control = {
	{
		{}, "1", function() updates.set_mode(STATE.NORMAL) end,
		{ description = "Regular notifications", group = "Notifications" }
	},
	{
		{}, "2", function() updates.set_mode(STATE.DAILY) end,
		{ description = "Postponed for a day", group = "Notifications" }
	},
	{
		{}, "3", function() updates.set_mode(STATE.WEEKLY) end,
		{ description = "Postponed for a week", group = "Notifications" }
	},
	{
		{}, "4", function() updates.set_mode(STATE.SILENT) end,
		{ description = "Notifications disabled", group = "Notifications" }
	},
}
updates.keys.action = {
	{
		{}, "u", function() updates:update(true) end,
		{ description = "Check updates", group = "Action" }
	},
	{
		{}, "Escape", function() updates:hide() end,
		{ description = "Close updates widget", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() tip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}
updates.keys.all = awful.util.table.join(updates.keys.control, updates.keys.action)
function updates:init(args, style)
	args = args or {}
	local update_timeout = args.update_timeout or 3600
	local command = args.command or "echo 0"
	local force_notify = false
	style = utils.table.merge(default_style(), style or {})
	self.style = style
	self.is_updates = false
	self.config = awful.util.getdir("cache") .. "/updates"
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		shape        = style.shape,
		border_width = style.wibox.border_width,
		border_color = style.color.border
	})
	self.wibox:geometry(style.wibox.geometry)
	self.packbox = svgbox(style.wibox.icon.package, nil, style.color.icon)
	self.titlebox = wibox.widget.textbox("0 UPDATES")
	self.titlebox:set_font(style.wibox.title_font)
	self.titlebox:set_align("center")
	-- tip line
	--self.tipbox = wibox.widget.textbox()
	--self.tipbox:set_font(style.wibox.tip_font)
	--self.tipbox:set_align("center")
	--self.tipbox:set_forced_height(style.wibox.height.tip)
	local closebox = svgbox(style.wibox.icon.close, nil, style.color.icon)
	closebox:buttons(awful.util.table.join(awful.button({}, 1, function() self:hide() end)))
	closebox:connect_signal("mouse::enter", function() closebox:set_color(style.color.main) end)
	closebox:connect_signal("mouse::leave", function() closebox:set_color(style.color.icon) end)
	local statebox = {}
	local statearea = wibox.layout.flex.horizontal()
	statearea:set_forced_height(style.wibox.height.state)
	local function update_state()
		for k, box in pairs(statebox) do
			box:set_color(STATE[k] == self.state and style.color.main or style.color.gray)
		end
		--self.tipbox:set_markup(string.format('<span color="%s">%s</span>', style.color.gray, tips[self.state]))
	end
	local function check_alert()
		local time = os.time()
		return self.is_updates and
		       (  self.state == STATE.NORMAL
		       or self.state == STATE.DAILY  and (time - self.time > 24 * 3600)
		       or self.state == STATE.WEEKLY and (time - self.time > 7 * 24 * 3600))
	end
	local function update_widget_colors()
		local is_alert = check_alert()
		local color = is_alert and style.color.main or style.color.icon
		for _, w in ipairs(updates.objects) do w:set_color(color) end
	end
	function self.set_mode(state)
		if self.state ~= state then
			self.state = state
			self.time  = (state == STATE.DAILY or state == STATE.WEEKLY) and os.time() or 0
			update_state()
			update_widget_colors()
		end
	end
	for state, k in pairs(STATE.keywords) do
		statebox[k] = svgbox(style.wibox.icon[k:lower()], nil, style.color.gray)
		local tp = tooltip({ objects = { statebox[k] } }, style.tooltip.state)
		tp:set_text(tips[state])
		statebox[k]:buttons(awful.util.table.join(
			awful.button({}, 1, function() self.set_mode(state) end)
		))
		local area = wibox.layout.align.horizontal()
		area:set_middle(statebox[k])
		area:set_expand("outside")
		statearea:add(area)
	end
	local titlebar = wibox.widget({
		nil,
		self.titlebox,
		wibox.container.margin(closebox, unpack(style.wibox.margin.close)),
		forced_height = style.wibox.height.title,
		layout        = wibox.layout.align.horizontal
	})
	self.wibox:setup({
		{
			nil,
			wibox.container.margin(titlebar, unpack(style.wibox.margin.title)),
			separator.horizontal(style.wibox.separator),
			layout = wibox.layout.align.vertical
		},
		{
			nil,
			{
				nil, wibox.container.margin(self.packbox, unpack(style.wibox.margin.image)), nil,
				expand = "outside",
				layout = wibox.layout.align.horizontal
			},
			--self.tipbox,
			nil,
			layout = wibox.layout.align.vertical
		},
		wibox.container.margin(statearea, unpack(style.wibox.margin.state)),
		layout = wibox.layout.align.vertical
	})
	self.keygrabber = function(mod, key, event)
		if     event ~= "press" then return end
		for _, k in ipairs(self.keys.all) do
			if utils.key.match_grabber(k, mod, key) then k[3](); return end
		end
	end
	self:load_state()
	self:set_keys()
	update_state()
	self.tp = tooltip(nil, style.tooltip.base)
	self.tp:set_text("?")
	local function update_count(output)
		local c = string.match(output, "(%d+)")
		self.is_updates = tonumber(c) > 0
		local is_alert = check_alert()
		if style.need_notify and (is_alert or force_notify) then
			notify:show(utils.table.merge({ text = c .. " updates available" }, style.notify))
		end
		self.titlebox:set_text(c .. " UPDATES")
		self.packbox:set_color(tonumber(c) > 0  and style.color.main or style.color.icon)
		if self.tp then self.tp:set_text(c .. " updates") end
		update_widget_colors()
	end
	self.check_updates = function(is_force)
		force_notify = is_force
		awful.spawn.easy_async_with_shell(command, update_count)
	end
	updates.timer = timer({ timeout = update_timeout })
	updates.timer:connect_signal("timeout", function() self.check_updates() end)
	updates.timer:start()
	if style.firstrun and utils.startup.is_startup then updates.timer:emit_signal("timeout") end
	awesome.connect_signal("exit", function() self:save_state() end)
	
end
function updates.new(style)
	if not updates.wibox then updates:init({}) end
	style = utils.table.merge(updates.style, style or {})
	local widg = svgbox(style.icon)
	widg:set_color(style.color.icon)
	table.insert(updates.objects, widg)
	updates.tp:add_to_object(widg)
	return widg
end
function updates:show()
	if self.style.wibox.set_position then
		self.style.wibox.set_position(self.wibox)
	else
		utils.placement.centered(self.wibox, nil, mouse.screen.workarea)
	end
	utils.placement.no_offscreen(self.wibox, self.style.screen_gap, screen[mouse.screen].workarea)
	self.wibox.visible = true
	awful.keygrabber.run(self.keygrabber)
	tip:set_pack("System updates", self.tip, self.style.keytip.column, self.style.keytip.geometry)
end
function updates:hide()
	self.wibox.visible = false
	awful.keygrabber.stop(self.keygrabber)
	tip:remove_pack()
end
function updates:toggle()
	if self.wibox.visible then
		self:hide()
	else
		self:show()
	end
end
function updates:load_state()
	local info = utils.read.file(self.config)
	if info then
		local state, time = string.match(info, "(%d)=(%d+)")
		self.state, self.time = tonumber(state), tonumber(time)
	else
		self.state = STATE.NORMAL
		self.time = 0

	end
end
function updates:save_state()
	local file = io.open(self.config, "w")
	file:write(string.format("%d=%d", self.state, self.time))
	file:close()
end
function updates:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join(self.keys.control, self.keys.action) end
	end

	self.tip = self.keys.all
end
function updates:update(is_force)
	self.check_updates(is_force)
end
function updates.mt:__call(...)
	return updates.new(...)
end
return setmetatable(updates, updates.mt)
