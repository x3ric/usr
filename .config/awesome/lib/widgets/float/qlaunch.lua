local table = table
local unpack = unpack or table.unpack
local string = string
local math = math
local io = io
local os = os
local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")
local color = require("gears.color")
local float = require("lib.widgets.float")
local utils = require("lib.utils")
local redtip = require("lib.widgets.float.hotkeys")
local gauge = require("lib.widgets.gauge")
local qlaunch = { history = {}, store = {}, keys = {} }
local sw = float.appswitcher
local TPI = math.pi * 2
local switcher_keys = {}
for i = 1, 9 do switcher_keys[tostring(i)] = { app = "", run = "" } end
qlaunch.forcemod = { "Control" }
qlaunch.keys.action = {
	{
		{}, "Escape", function() qlaunch:hide(true) end,
		{ description = "Close widget", group = "Action" }
	},
	{
		{}, "Return", function() qlaunch:run_and_hide() end,
		{ description = "Run or rise selected app", group = "Action" }
	},
	{
		{}, "s", function() qlaunch:set_new_app(qlaunch.switcher.selected, client.focus) end,
		{ description = "Bind focused app to selected key", group = "Action" }
	},
	{
		{}, "d", function() qlaunch:set_new_app(qlaunch.switcher.selected) end,
		{ description = "Clear selected key", group = "Action" }
	},
	{
		{}, "r", function() qlaunch:load_config(true) end,
		{ description = "Reload config from disk", group = "Action" }
	},
	{
		{}, "w", function() qlaunch:save_config() end,
		{ description = "Save config to disk", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
}

qlaunch.keys.all = awful.util.table.join({}, qlaunch.keys.action)
qlaunch._fake_keys = {
	{
		{}, "N", nil,
		{ description = "Select app (run or rise if selected already) by key", group = "Action",
		  keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } }
	},
	{
		{}, "N", nil,
		{ description = "Select app (launch if selected already) by key", group = "Action" }
	},
}
local function default_style()
	local style = {
		df_icon         = utils.base.placeholder({ txt = "X" }),
		no_icon         = utils.base.placeholder(),
		parser          = {},
		recoloring      = false,
		notify          = {},
		geometry        = { width = 1680, height = 180 },
		border_margin   = { 20, 20, 10, 10 },
		appline         = { iwidth = 160, im = { 10, 10, 5, 5 }, igap = { 0, 0, 10, 10 }, lheight = 30 },
		state           = { gap = 4, radius = 3, size = 10, height = 20, width = 20 },
		configfile      = os.getenv("HOME") .. "/.cache/awesome/applist",
		label_font      = "Sans 14",
		border_width    = 2,
		keytip          = { geometry = { width = 500 }, exit = false },
		color           = { border = "#575757", text = "#aaaaaa", main = "#b1222b", urgent = "#32882d",
		                    wibox  = "#202020", icon = "#a0a0a0", bg   = "#161616", gray   = "#575757" },
		shape           = nil
	}

	return utils.table.merge(style, utils.table.check(beautiful, "float.qlaunch") or {})
end
local function get_clients(app)
	local clients = {}
	for _, c in ipairs(client.get()) do
		if c.class and c.class:lower() == app then table.insert(clients, c) end
	end
	return clients
end
local function focus_and_raise(c)
	if c.minimized then c.minimized = false end
	if not c:isvisible() then awful.tag.viewmore(c:tags(), mouse.screen) end

	client.focus = c
	c:raise()
end
local function build_filter(app)
	return function(c)
		return c.class:lower() == app
	end
end
local function is_file_exists(file)
	local f = io.open(file, "r")
	if f then f:close(); return true else return false end
end
local function build_state_indicator(style)
	local widg = wibox.widget.base.make_widget()
	local dx = style.state.size + style.state.gap
	local ds = style.state.size - style.state.radius
	local r  = style.state.radius
	local data = {
		state = {},
		height = style.state.height or nil,
		width = style.state.width or nil
	}
	function widg:setup(clist)
		data.state = {}
		for _, c in ipairs(clist) do
			table.insert(data.state, { focused = client.focus == c, urgent = c.urgent, minimized = c.minimized })
		end
		self:emit_signal("widget::redraw_needed")
	end
	function widg:fit(_, width, height)
		return data.width or width, data.height or height
	end
	function widg:draw(_, cr, width, height)
		local n = #data.state
		local x0 = (width - n * style.state.size - (n - 1) * style.state.gap) / 2
		local y0 = (height - style.state.size) / 2

		for i = 1, n do
			cr:set_source(color(
				data.state[i].focused   and style.color.main   or
				data.state[i].urgent    and style.color.urgent or
				data.state[i].minimized and style.color.gray   or style.color.icon
			))
			-- draw rounded rectangle
			cr:arc(x0 + (i -1) * dx + ds, y0 + r,  r, -TPI / 4, 0)
			cr:arc(x0 + (i -1) * dx + ds, y0 + ds, r, 0, TPI / 4)
			cr:arc(x0 + (i -1) * dx + r,  y0 + ds, r, TPI / 4, TPI / 2)
			cr:arc(x0 + (i -1) * dx + r,  y0 + r,  r, TPI / 2, 3 * TPI / 4)
			cr:fill()
		end
	end
	return widg
end
local function build_item(key, style)
	local widg = {}
	local label = wibox.widget({
		markup = string.format('<span color="%s">%s</span>', style.color.text, key),
		align  = "center",
		font = style.label_font,
		forced_height = style.appline.lheight,
		widget = wibox.widget.textbox,
	})
	widg.background = wibox.container.background(label, style.color.bg)
	widg.svgbox = gauge.svgbox()
	local icon_align = wibox.widget({
		nil,
		widg.svgbox,
		forced_width = style.appline.iwidth,
		expand = "outside",
		layout = wibox.layout.align.horizontal,
	})
	widg.state = build_state_indicator(style)
	widg.layout = wibox.layout.align.vertical()
	widg.layout:set_top(widg.state)
	widg.layout:set_middle(wibox.container.margin(icon_align, unpack(style.appline.igap)))
	widg.layout:set_bottom(widg.background)
	return widg
end
local function build_switcher(keys, style)
	local widg = { items = {}, selected = nil }
	local middle_layout = wibox.layout.fixed.horizontal()
	local sk = {}
	for k in pairs(keys) do table.insert(sk, k) end
	table.sort(sk)
	for _, key in ipairs(sk) do
		widg.items[key] = build_item(key, style)
		middle_layout:add(wibox.container.margin(widg.items[key].layout, unpack(style.appline.im)))
	end
	widg.layout = wibox.widget({
		nil,
		wibox.container.margin(middle_layout, unpack(style.border_margin)),
		expand = "outside",
		layout = wibox.layout.align.horizontal,
	})
	function widg:update(store, idb)
		self.selected = nil
		for key, data in pairs(store) do
			local icon = data.app == "" and style.no_icon or idb[data.app] or style.df_icon
			-- force manually set icon
			if data.icon ~= "" then
				icon = utils.service.dfparser.lookup_icon(data.icon, style)
			end
			self.items[key].svgbox:set_image(icon)
			if style.recoloring then self.items[key].svgbox:set_color(style.color.icon) end
		end
		self:set_state(store)
	end
	function widg:set_state(store)
		for k, item in pairs(self.items) do
			local clist = get_clients(store[k].app)
			item.state:setup(clist)
		end
	end
	function widg:reset()
		for _, item in pairs(self.items) do item.background:set_bg(style.color.bg) end
		self.selected = nil
	end

	function widg:check_key(key, mod)
		if self.items[key] then
			if self.selected then self.items[self.selected].background:set_bg(style.color.bg) end
			self.items[key].background:set_bg(style.color.main)

			if self.selected == key then
				local modcheck = #mod == #qlaunch.forcemod
				for _, v in ipairs(mod) do modcheck = modcheck and awful.util.table.hasitem(qlaunch.forcemod, v) end
				qlaunch:run_and_hide(modcheck)
			else
				self.selected = key
			end
		end
	end
	return widg
end
function qlaunch:init(args, style)
	args = args or {}
	local keys = args.keys or switcher_keys
	style = utils.table.merge(default_style(), style or {})
	self.style = style
	self.default_switcher_keys = keys
	self.icon_db = utils.service.dfparser.icon_list(style.parser)
	self:load_config()
	self.wibox = wibox({
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	})
	self.wibox:geometry(style.geometry)
	utils.placement.centered(self.wibox, nil, screen[mouse.screen].workarea)
	self.switcher = build_switcher(self.store, style)
	self.switcher:update(self.store, self.icon_db)

	self.wibox:set_widget(self.switcher.layout)
	self:set_keys()
	self.keygrabber = function(mod, key, event)
		if event == "press" then return false end
		for _, k in ipairs(self.keys.all) do
			if utils.key.match_grabber(k, mod, key) then k[3](); return end
		end
		self.switcher:check_key(key, mod)
	end
	client.connect_signal("focus", function(c) self:set_last(c) end)
	awesome.connect_signal("exit", function() self:save_config() end)
end
function qlaunch:show()
	self:init()
	self.switcher:set_state(self.store)
	self.wibox.visible = true
	awful.keygrabber.run(self.keygrabber)

	redtip:set_pack(
		"Quick launch", self.tip, self.style.keytip.column, self.style.keytip.geometry,
		self.style.keytip.exit and function() self:hide() end
	)
end

function qlaunch:hide()
	self.wibox.visible = false
	awful.keygrabber.stop(self.keygrabber)
	self.switcher:reset()
	redtip:remove_pack()
end

function qlaunch:run_and_hide(forced_run)
	if self.switcher.selected then
		self:run_or_raise(self.switcher.selected, forced_run)
	end
	self:hide()
end
function qlaunch:run_or_raise(key, forced_run)
	local app = self.store[key].app
	if app == "" then return end

	local clients = get_clients(app)
	local cnum = #clients

	if cnum == 0 or forced_run then
		-- open new application
		if self.store[key].run ~= "" then awful.spawn.with_shell(self.store[key].run) end
	elseif cnum == 1 then
		-- switch to sole app
		focus_and_raise(clients[1])
	else
		if awful.util.table.hasitem(clients, client.focus) then
			-- run selection widget if wanted app focused
			sw:show({ filter = build_filter(app), noaction = true })
		else
			-- switch to last focused if availible or first in list otherwise
			local last = awful.util.table.hasitem(clients, self.history[app])
			if last then
				focus_and_raise(self.history[app])
			else
				focus_and_raise(clients[1])
			end
		end
	end
end
function qlaunch:set_new_app(key, c)
	if not key  then return end

	if c then
		local run_command = utils.read.output(string.format("tr '\\0' ' ' < /proc/%s/cmdline", c.pid))
		self.store[key] = { app = c.class:lower(), run = run_command, icon = "" }
		local note = utils.table.merge({text = string.format("%s binded with '%s'", c.class, key)}, self.style.notify)
		float.notify:show(note)
	else
		self.store[key] = { app = "", run = "", icon = "" }
		local note = utils.table.merge({text = string.format("'%s' key unbinded", key)}, self.style.notify)
		float.notify:show(note)
	end

	self.switcher:reset()
	self.switcher:update(self.store, self.icon_db)
end
function qlaunch:set_last(c)
	if not c.class then return end
	for _, data in pairs(self.store) do
		if c.class:lower() == data.app then
			self.history[data.app] = c
			break
		end
	end
end
function qlaunch:load_config(need_reset)
	if is_file_exists(self.style.configfile) then
		for line in io.lines(self.style.configfile) do
			-- do not crash when icon= is not present
			if string.find(line, "icon=.*;") then
				local key, app, run, icon = string.match(line, "key=(.+);app=(.*);run=(.*);icon=(.*);")
				self.store[key] = { app = app, run = run, icon = icon }
			else
				local key, app, run = string.match(line, "key=(.*);app=(.*);run=(.*);")
				self.store[key] = { app = app, run = run, icon = "" }
			end
		end
	else
		self.store = self.default_switcher_keys
	end

	if need_reset then
		self.switcher:reset()
		self.switcher:update(self.store, self.icon_db)
	end
end

function qlaunch:save_config()
	local file = io.open(self.style.configfile, "w+")
	for key, data in pairs(self.store) do
		file:write(string.format("key=%s;app=%s;run=%s;icon=%s;\n", key, data.app, data.run, data.icon))
	end
	file:close()
end
function qlaunch:set_keys(keys, layout)
	layout = layout or "all"
	if keys then
		self.keys[layout] = keys
		if layout ~= "all" then self.keys.all = awful.util.table.join({}, self.keys.action) end
	end

	self._fake_keys[2][1] = self.forcemod
	self.tip = awful.util.table.join(self.keys.all, self._fake_keys)
end
return qlaunch
