local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local utils = require("lib.utils")
local redtip = require("lib.widgets.float.hotkeys")
local svgbox = require("lib.widgets.gauge.svgbox")

local logout = { entries = {}, action = {}, keys = {} }

local function default_style()
	local style = {
		button_size         = { width = 128, height = 128 },
		icon_margin         = 16,
		text_margin         = 12,
		button_spacing      = 48,
		counter_top_margin  = 200,
		label_font          = "Sans 14",
		counter_font        = "Sans 24",
		button_shape        = gears.shape.rectangle,
		color               = { wibox = "#202020", text = "#a0a0a0", icon = "#a0a0a0",
		                        gray = "#575757", main = "#b1222b" },
		icons               = {
			poweroff = utils.base.placeholder({ txt = "↯" }),
			reboot   = utils.base.placeholder({ txt = "⊛" }),
			suspend  = utils.base.placeholder({ txt = "⊖" }),
			lock     = utils.base.placeholder({ txt = "⊙" }),
			logout   = utils.base.placeholder({ txt = "←" }),
		},
		keytip                    = { geometry = { width = 400 } },
		graceful_shutdown         = true,
		double_key_activation     = false,
		client_kill_timeout       = 2,
	}
	return utils.table.merge(style, utils.table.check(beautiful, "service.logout") or {})
end

local function gracefully_close(application)
	if application.pid then
		awful.spawn.easy_async("kill -SIGTERM " .. tostring(application.pid), function(_, _, _, exitcode)
			if exitcode ~= 0 then
				application:kill()
			end
		end)
	else
		application:kill()
	end
end


function  logout:_close_all_apps(option)
	if not logout.style.graceful_shutdown then
		logout:hide()
		option.callback()
		return
	end

	for _, application in ipairs(client.get()) do
		if application.valid then gracefully_close(application) end
	end

	self.countdown:start(option)
end

logout.entries = {
	{   -- Logout
		callback   = function() awesome.quit() end,
		icon_name  = 'logout',
		label      = 'Logout',
		close_apps = true,
	},
	{   -- Lock screen
		callback   = function() awful.spawn.with_shell("sleep 0.5 && xscreensaver-command -l") end,
		icon_name  = 'lock',
		label      = 'Lock',
		close_apps = false,
	},
	{   -- Shutdown
		callback   = function() awful.spawn.with_shell("systemctl poweroff") end,
		icon_name  = 'poweroff',
		label      = 'Shutdown',
		close_apps = true,
	},
	{   -- Suspend
		callback   = function() awful.spawn.with_shell("systemctl suspend") end,
		icon_name  = 'suspend',
		label      = 'Sleep',
		close_apps = false,
	},
	{   -- Reboot
		callback   = function() awful.spawn.with_shell("systemctl reboot") end,
		icon_name  = 'reboot',
		label      = 'Restart',
		close_apps = true,
	},
}

function logout.action.select_by_id(id)
	local new_option = logout.options[id]
	if not new_option then return end

	if new_option == logout.selected then
		if logout.style.double_key_activation then new_option:execute() end
		return
	end

	new_option:select()
end

function logout.action.execute_selected()
	if not logout.selected then return end
	logout.selected:execute()
end

function logout.action.select_next()
	local target_id = logout.selected and logout.selected.id + 1 or 1
	logout.action.select_by_id(target_id)
end

function logout.action.select_prev()
	local target_id = logout.selected and logout.selected.id - 1 or 1
	logout.action.select_by_id(target_id)
end

function logout.action.hide()
	logout:hide()
end

logout.keys = {
	{
		{ }, "Escape", logout.action.hide,
		{ description = "Close the logout screen", group = "Action" }
	},
	{
		{ }, "Left", logout.action.select_prev,
		{ description = "Select previous option", group = "Selection" }
	},
	{
		{ }, "Right", logout.action.select_next,
		{ description = "Select next option", group = "Selection" }
	},
	{
		{ }, "Return", logout.action.execute_selected,
		{ description = "Execute selected option", group = "Action" }
	},
	{
		{ "Mod4" }, "F1", function() redtip:show() end,
		{ description = "Show hotkeys helper", group = "Action" }
	},
	{ -- fake keys for redtip
		{ }, "1..9", nil,
		{ description = "Select option by number", group = "Selection",
		  keyset = { "1", "2", "3", "4", "5", "6", "7", "8", "9" } }
	}
}

for i = 1, 9 do
	table.insert(logout.keys, {
		{ }, tostring(i), function()
			logout.action.select_by_id(i)
		end,
		{ }
	})
end

function logout:_make_button(icon_name)
	local icon = self.style.icons[icon_name] or utils.base.placeholder({ txt = "?" })

	local image = wibox.container.margin(svgbox(icon, nil, self.style.color.icon))
	image.margins = self.style.icon_margin

	local iconbox = wibox.container.background(image)
	iconbox.bg = self.style.color.gray
	iconbox.shape = self.style.button_shape
	iconbox.forced_width = self.style.button_size.width
	iconbox.forced_height = self.style.button_size.height

	return iconbox
end

function logout:_make_label(title)
	local label = wibox.widget.textbox(title)
	label.font = self.style.label_font
	label.align = "center"
	label.valign = "center"

	return label
end

function logout:add_option(id, action)

	local option = { id = id, close_apps = action.close_apps, callback = action.callback, name = action.label }
	option.button = logout:_make_button(action.icon_name)
	option.label = logout:_make_label(action.label)

	function option:select()
		if logout.selected then logout.selected:deselect() end
		self.button.bg = logout.style.color.main
		logout.selected = self
	end

	function option:deselect()
		if logout.selected ~= self then return end
		self.button.bg = logout.style.color.gray
		logout.selected = nil
	end

	function option:execute()
		if self.close_apps then
			logout:_close_all_apps(self)
		else
			logout:hide()
			self.callback()
		end
	end

	option.button:connect_signal('mouse::enter', function() option:select() end)
	option.button:connect_signal('mouse::leave', function() option:deselect() end)
	option.button:connect_signal('button::release', function() option:execute() end)

	local button_with_label = wibox.layout.fixed.vertical()
	button_with_label.spacing = self.style.text_margin
	button_with_label:add(option.button)
	button_with_label:add(option.label)
	self.option_layout:add(button_with_label)

	table.insert(self.options, option)
end

function logout:init()

    self.style = default_style()
    self.options = {}

    self.option_layout = wibox.layout.fixed.horizontal()
    self.option_layout.spacing = self.style.button_spacing

    self.counter = wibox.widget.textbox("")
    self.counter.font = self.style.counter_font
    self.counter.align = "center"
    self.counter.valign = "top"

    self.info_text = wibox.widget.textbox("")
    self.info_text.font = self.style.info_font
    self.info_text.align = "center"
    self.info_text.valign = "top"

    local base_layout = wibox.layout.stack()
    base_layout:add(wibox.container.place(self.option_layout))
    base_layout:add(wibox.container.margin(self.counter, 0, 0, self.style.counter_top_margin))
    base_layout:add(wibox.container.margin(self.info_text, 0, 0, screen.primary.geometry.height - screen.primary.geometry.height / 3 ))

    for id, action in ipairs(self.entries) do self:add_option(id, action) end

    self.keygrabber = function(mod, key, event)
        if event == "press" then
            for _, k in ipairs(self.keys) do
                if utils.key.match_grabber(k, mod, key) then k[3](); return end
            end
        end
    end

    self.wibox = wibox({ widget = base_layout })
    self.wibox.type = 'splash'
    self.wibox.ontop = true
    self.wibox.bg = self.style.color.wibox
    self.wibox.fg = self.style.color.text
    self.wibox.visible = false

    self.wibox:buttons(
        gears.table.join(
            awful.button({}, 2, function() self:hide() end),
            awful.button({}, 3, function() self:hide() end)
        )
    )

    local countdown = {}
    countdown.pattern = '<span color="%s">%s</span> in %s... Closing apps (%s left).'

    countdown.timer = gears.timer({
        timeout = 1,
        callback = function()
            if countdown.delay <= 1 then
                countdown.callback()
                countdown:stop()
            else
                countdown.delay = countdown.delay - 1
                countdown:label(countdown.delay)
                countdown.timer:again()
            end
        end
    })
	countdown.timertips = gears.timer({
		timeout = 1,
		autostart = true,
		callback = function()
			logout:tips()
			countdown.timertips:again()
        end
	})
	countdown.timertips:start()
    function countdown:label(seconds)
        local active_apps = client.get()
        logout.counter:set_markup(string.format(
            self.pattern,
            logout.style.color.main, self.option_name, seconds, #active_apps
        ))
    end

    function countdown:start(option)
        self.option_name = option.name
        self.callback = option.callback

        self.delay = logout.style.client_kill_timeout
        self:label(self.delay)
        self.timer:start()
    end

    function countdown:stop()
        if self.timer.started then self.timer:stop() end
        logout.counter:set_text("")
    end

    self.countdown = countdown

	logout:tips()
end

function logout:tips()
    local currentTime = "UpTime: " .. os.capture("uptime --pretty | sed -e 's/up //g' -e 's/ days/d/g' -e 's/ day/d/g' -e 's/ hours/h/g' -e 's/ hour/h/g' -e 's/ minutes/m/g' -e 's/, / /g'")
    local lastStartTime = "BootTime: " .. os.capture("systemd-analyze | cut -d ' ' -f 16")
    local userDetails = "User: " .. os.getenv("USER")
    self:update_info_text(currentTime, lastStartTime, userDetails)
end

function os.capture(cmd)
    local f = assert(io.popen(cmd, "r"))
    local output = assert(f:read("*a"))
    f:close()
    return output
end

function logout:update_info_text(currentTime, lastStartTime, userDetails)
    local info = string.format("%s%s%s",
        currentTime, lastStartTime, userDetails)
    self.info_text:set_markup(info)
end

function logout:hide()
	awful.keygrabber.stop(self.keygrabber)
	self.countdown:stop()
	if self.selected then self.selected:deselect() end

	redtip:remove_pack()
	self.wibox.visible = false
end

function logout:show()
	if not self.wibox then self:init() end
	logout:tips()

	self.wibox.screen = mouse.screen
	self.wibox:geometry(mouse.screen.geometry)
	self.wibox.visible = true
	self.selected = nil

	redtip:set_pack("Logout screen", self.keys, self.style.keytip.column, self.style.keytip.geometry)
	awful.keygrabber.run(self.keygrabber)
end

function logout:set_keys(keys)
	self.keys = keys
end

function logout:set_entries(entries)
	self.entries = entries
end

return logout
