--[[
	 █████╗ ██╗    ██╗███████╗███████╗ ██████╗ ███╗   ███╗███████╗
	██╔══██╗██║    ██║██╔════╝██╔════╝██╔═══██╗████╗ ████║██╔════╝
	███████║██║ █╗ ██║█████╗  ███████╗██║   ██║██╔████╔██║█████╗
	██╔══██║██║███╗██║██╔══╝  ╚════██║██║   ██║██║╚██╔╝██║██╔══╝
	██║  ██║╚███╔███╔╝███████╗███████║╚██████╔╝██║ ╚═╝ ██║███████╗
	╚═╝  ╚═╝ ╚══╝╚══╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
  Awesomerc : https://awesomewm.org/doc/api/index.html
--]]
-- Awesome variables
	local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
	local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type
-- Awesome libs
	require("awful.autofocus") -- Autofocus a new client when previously focused one is closed
	local gears         = require("gears") --Utilities such as color parsing and objects
	local awful         = require("awful") --Everything related to window managment
	local wibox         = require("wibox") --Widget and layout library
	local beautiful     = require("beautiful") --Theme handling library
	local dpi           = require("beautiful.xresources").apply_dpi
	local gauge         = require("lib.widgets.gauge")
	local float         = require("lib.widgets.float")
	local widget        = require("lib.widgets.bar")
	local utils         = require("lib.utils")
	local lock = lock or { desktop = true }
	utils.startup.locked = lock.autostart
	utils.startup:activate()
-- Env
	local env = require("env")
	env:init({ theme = "oxoawesome" , desktop_autohide = false , set_center = true })
-- Init
	require("init")
	require("lib.utils.save.tag")
	require("lib.utils.save.pos")
	require("lib.utils.tweaks.unfocustransparency")
	require("lib.utils.tweaks.focusmouse")
	require("lib.utils.tweaks.welcome")
	require("lib.widgets.float.volume")
	require("lib.widgets.float.brightness")
	require("lib.utils.tweaks.swallow")
-- Layouts
	local layouts = require("layouts")
	layouts:init()
-- Menu
	local menu = require("menu")
	local mymenu = menu 
	mymenu:init({ env = env })
-- Bar
	-- Separators
		local separator = gauge.separator.vertical()
		local markup = require("lib.utils.markup")
	-- Functions for buttons
		local function toggleapp(command)
		    awful.spawn.easy_async_with_shell("pgrep -f '" .. command .. "'", function(stdout)
		        local pid = tonumber(stdout)
		        if pid then
		            awful.spawn("kill " .. pid)
		        else
		            awful.spawn(command)
		        end
		    end)
		end
	-- Taglist
		local taglist = {}
		taglist.style = { widget = gauge.tag.new, show_tip = true }
		taglist.buttons = awful.util.table.join(
			awful.button({         }, 1, function(t) t:view_only() end),
			awful.button({ env.mod }, 1, function(t) if client.focus then client.focus:move_to_tag(t) end end),
			awful.button({         }, 2, awful.tag.viewtoggle),
			awful.button({         }, 3, function(t) widget.layoutbox:toggle_menu(t) end),
			awful.button({ env.mod }, 3, function(t) if client.focus then client.focus:toggle_tag(t) end end),
			awful.button({         }, 4, function(t) awful.tag.viewnext(t.screen) end),
			awful.button({         }, 5, function(t) awful.tag.viewprev(t.screen) end)
		)
		taglist.names = { "Main", "Full", "Edit" }
		local al = awful.layout.layouts
		taglist.layouts = { al[1], al[2], al[3]}
		local tasklist = {}
		local tagline_style = { tagline = { height = 40, rows = taglist.rows_num, spacing = 4 } }
	-- Tasklist
		tasklist.style = {
			appnames = require("alias"),
			widget = gauge.task.new,
			winmenu = tagline_style,
		}
		tasklist.buttons = awful.util.table.join(
			awful.button({}, 1, widget.tasklist.action.select),
			awful.button({}, 2, widget.tasklist.action.close),
			awful.button({}, 3, widget.tasklist.action.menu),
			awful.button({}, 4, widget.tasklist.action.switch_next),
			awful.button({}, 5, widget.tasklist.action.switch_prev)
		)
		float.clientmenu:set_style(tagline_style)
	-- Layoutbox
		local layoutbox = {}
		layoutbox.buttons = awful.util.table.join(
			awful.button({ }, 3, function () mymenu.mainmenu:toggle() end),
			awful.button({ }, 1, function () widget.layoutbox:toggle_menu(mouse.screen.selected_tag) end),
			awful.button({ }, 4, function () awful.layout.inc( 1) end),
			awful.button({ }, 5, function () awful.layout.inc(-1) end)
		)
	-- Tray
		local tray = {}
		tray.widget = widget.minitray()
		tray.buttons = awful.util.table.join(
			awful.button({}, 1, function() widget.minitray:toggle() end)
		)
	-- Keyboard
		local kbindicator = {}	
		local lay = {}
		lay[0] = io.popen("setxkbmap -query | awk '/layout:/ {print $2}'"):read("*all")
		lay[1] = "us"
		widget.keyboard:init({ lay[0] , lay[1] })
		awful.spawn("setxkbmap -layout " .. lay[0],lay[1])
		kbindicator.widget = widget.keyboard()
		kbindicator.buttons = awful.util.table.join(
			awful.button({}, 1, function () widget.keyboard:toggle_menu() end),
			awful.button({}, 4, function () widget.keyboard:toggle()      end),
			awful.button({}, 5, function () widget.keyboard:toggle(true)  end)
		)
	-- Updates
		widget.updates:init({ command = env.updates })
		local updates = {}
		updates.widget = widget.updates()
		updates.buttons = awful.util.table.join(
			awful.button({ }, 1, function () widget.updates:toggle() end),
			awful.button({ }, 2, function () widget.updates:update(true) end),
			awful.button({ }, 3, function () widget.updates:toggle() end)
		)
	-- Mail
		local my_mails = require("mail")
		pcall(function() my_mails = require("private.mail-config") end)
		local mail = {}
		widget.mail:init({ maillist = my_mails, update_timeout = 15 * 60 })
		mail.widget = widget.mail()
		mail.buttons = awful.util.table.join(
			awful.button({ }, 1, function () awful.spawn.with_shell(env.mail) end),
			awful.button({ }, 2, function () widget.mail:update(true) end)
		)
	-- System monitor
		local sysmon = { widget = {}, buttons = {} }
		-- battery
			sysmon.widget.battery = widget.battery(
				{ func = utils.system.pformatted.bat(25), arg = "BAT1" },
				{ timeout = 10, widget = gauge.monitor.dash }
			)
		-- network speed
			sysmon.widget.network = widget.net(
				{
					findall = true,
					interface = "wlp60s0",
					speed = { up = 6 * 1024^2, down = 6 * 1024^2 },
					autoscale = false
				},
				{ timeout = 2, widget = gauge.icon.double, monitor = { step = 0.1 } }
			)
		-- CPU usage
			sysmon.widget.cpu = widget.sysmon(
				{ func = utils.system.pformatted.cpu(80) },
				{ timeout = 2, widget = gauge.monitor.dash }
			)
			sysmon.buttons.cpu = awful.util.table.join(
				awful.button({ }, 1, function() float.top:show("cpu") end)
			)
		-- RAM usage
			sysmon.widget.ram = widget.sysmon(
				{ func = utils.system.pformatted.mem(70) },
				{ timeout = 10, widget = gauge.monitor.dash }
			)
			sysmon.buttons.ram = awful.util.table.join(
				awful.button({ }, 1, function() float.top:show("mem") end)
			)
	-- Clock and Calendary
		local textclock = {}
		textclock.widget = widget.textclock({ timeformat = "%I:%M", dateformat = "%b  %d  %a" }) -- European format "%H:%M"
		textclock.buttons = awful.util.table.join(
			awful.button({}, 1, function() float.calendar:show() end)
		)
	-- Volume 
		local volume = {}
		volume.widget = widget.pulse(nil, { widget = gauge.audio.new }) -- disable gaughe bar , audio = { gauge = false }
		float.player:init({ name = env.player })
		float.player:update()
		volume.buttons = awful.util.table.join(
			awful.button({}, 4, function() volume.widget:change_volume() awesome.emit_signal("volume_change")                  end),
			awful.button({}, 5, function() volume.widget:change_volume({ down = true }) awesome.emit_signal("volume_change")   end),
			awful.button({}, 2, function() volume.widget:mute() awesome.emit_signal("volume_change")                           end),
			awful.button({}, 3, function() toggleapp("pavucontrol")             end),
			awful.button({}, 1, function() float.player:action("PlayPause")     end),
			awful.button({}, 6, function() float.player:action("Previous")      end),
			awful.button({}, 7, function() float.player:action("Next")          end),
			awful.button({}, 9, function() float.player:show()                  end),
			awful.button({}, 8, function() toggleapp("kitty --class Music ncmpcpp")        end)
		)
		-- Show player on music change as a notify
			local rb_corner = function()
				local screen = awful.screen.focused()
				return { x = screen.workarea.x + screen.workarea.width, y = screen.workarea.y }
			end
			local previousSong = ""
			local Delay = 1
			local hideDelay = Delay
			local function checkSongChange()
				hideDelay = Delay
				local currentSong = io.popen("mpc current"):read("*a"):gsub("^%s*(.-)%s*$", "%1")
				if previousSong == "" and currentSong ~= previousSong then
					previousSong = currentSong
				end
				if currentSong ~= previousSong then
					if not float.player.wibox.visible then
						float.player:show(rb_corner())
						hideDelay = hideDelay + Delay
						local hideTimer = gears.timer.start_new(hideDelay, function() float.player:hide() end)
					end
					previousSong = currentSong
				end
			end
			local songChangeTimer = gears.timer({
				timeout = 5,
				autostart = true,
				callback = checkSongChange
			})
	-- Microphone
		local microphone = {}
		local microphone_style = {
			widget = gauge.audio.new,
			audio = beautiful.individual and beautiful.individual.microphone or {},
		}
		microphone_style.audio.gauge = false -- gauge.monitor.dash
		microphone.widget = widget.pulse({ type = "source" }, microphone_style)
		microphone.buttons = awful.util.table.join(
			awful.button({}, 3, function() toggleapp("pavucontrol -t 4") end),
			awful.button({}, 2, function() microphone.widget:mute() end),
			awful.button({}, 4, function() microphone.widget:change_volume() end),
			awful.button({}, 5, function() microphone.widget:change_volume({ down = true }) end)
		)
	-- Desktop
		local desktop  = require("lib.widgets.desktop.icons")
		awful.screen.connect_for_each_screen(function(s) awful.tag(taglist.names, s, taglist.layouts)
			if s.index == 1 then -- make icons work only on 1st screen
				desktop.add_icons({screen = s,open_with="Thunar",showlabels = true,menu = mymenu.mainmenu,})
			end
			env.wallpaper(s)
			layoutbox[s] = widget.layoutbox({ screen = s })
			taglist[s] = widget.taglist({ screen = s, buttons = taglist.buttons, hint = env.tagtip, layout = taglist.layout }, taglist.style)
			tasklist[s] = widget.tasklist({ screen = s, buttons = tasklist.buttons }, tasklist.style)	
			s.quake = utils.quake({ app = awful.util.terminal })
			s.panel = awful.wibar({ position = "top", screen = s, height = beautiful.panel_height or 17 })
			s.panel:setup {
							layout = wibox.layout.align.horizontal,
							{ 
								layout = wibox.layout.fixed.horizontal,
								env.wrapper(taglist[s], "taglist"),
								env.wrapper(layoutbox[s], "layoutbox", layoutbox.buttons),
								--separator,
								--env.wrapper(mail.widget, "mail", mail.buttons),
							},
							{ 
								layout = wibox.layout.align.horizontal,
								expand = "outside",
								nil,
								env.wrapper(tasklist[s], "tasklist"),
							},
							{ 
								layout = wibox.layout.fixed.horizontal,
								env.wrapper(textclock.widget, "textclock", textclock.buttons),
								--env.wrapper(kbindicator.widget, "keyboard", kbindicator.buttons),
								--env.wrapper(sysmon.widget.network, "network"),
								--env.wrapper(updates.widget, "updates", updates.buttons),
								--env.wrapper(microphone.widget, "microphone", microphone.buttons),
								separator,
								env.wrapper(volume.widget, "volume", volume.buttons),
								separator,
								env.wrapper(sysmon.widget.cpu, "cpu", sysmon.buttons.cpu),
								--env.wrapper(sysmon.widget.ram, "ram", sysmon.buttons.ram),
								env.wrapper(sysmon.widget.battery, "battery"),
								env.wrapper(tray.widget, "tray", tray.buttons),
								
							},
						}
					end
		)
		-- Bar hider
		local barhide = true
		if barhide then
			local hide_timeout = 0.35
			local prev_bar_visible = {}
			local last_positions = {}
			awful.widget.watch('xdotool getmouselocation', hide_timeout, function(widget, stdout)
				local x, y = string.match(stdout, "x:(%d+).+y:(%d+)")
				x = tonumber(x)
				y = tonumber(y)
				local screen = awful.screen.focused()
				local bar_geometry = screen.panel:geometry()
				local screen_index = mouse.screen.index
				if prev_bar_visible[screen_index] == nil then
					prev_bar_visible[screen_index] = screen.panel.visible
				end
				local mouse_inside_bar = x >= bar_geometry.x and x <= bar_geometry.x + bar_geometry.width and y >= bar_geometry.y and y <= bar_geometry.y + bar_geometry.height
				if not screen.panel.visible then
					mouse_inside_bar = x >= bar_geometry.x and x <= bar_geometry.x + bar_geometry.width and y >= bar_geometry.y and y <= bar_geometry.y + bar_geometry.height / 8
				end
				if mouse_inside_bar then
					screen.panel.visible = true
				else
					local bar_should_be_visible = false
					for _, c in ipairs(screen.clients) do
						if c.first_tag == screen.selected_tag then
							if c.visible and not c.floating then
								bar_should_be_visible = true
								break
							end
						end
					end
					screen.panel.visible = bar_should_be_visible
				end
				if prev_bar_visible[screen_index] ~= screen.panel.visible then
					for _, c in ipairs(client.get()) do
						if c.first_tag == screen.selected_tag then
							if not (c.maximized or awful.tag.selected(screen).layout.name == "maximized") and (c.floating or awful.tag.selected(screen).layout.name == "floating") then
								local new_geometry = c:geometry()
								local last_position = last_positions[c] or new_geometry
								if new_geometry.y > bar_geometry.height * 1.01 then  -- makes only window touching bar resize relative
									last_positions[c] = nil
									return
								end
								if screen.panel.visible then -- Move the window down by the bar height and reduce its height
									if new_geometry.y < bar_geometry.height then
										new_geometry.y = bar_geometry.height
									else
										new_geometry.y = new_geometry.y + bar_geometry.height
									end
									new_geometry.height = new_geometry.height - bar_geometry.height
								else -- Move the window up by the bar height and restore its height
									new_geometry.y = new_geometry.y - bar_geometry.height
									new_geometry.height = new_geometry.height + bar_geometry.height
								end
								c:geometry(new_geometry)
								last_positions[c] = last_position
							elseif last_positions[c] then
								c:geometry(last_positions[c])
								last_positions[c] = nil
							end
						end
					end
					prev_bar_visible[screen_index] = screen.panel.visible
				end
			end)
		end			
	-- Desktop widgets
		if not lock.desktop then
			local desktop = require("desktop")
			desktop:init({
				env = env, buttons = awful.util.table.join(awful.button({}, 3, function () mymenu.mainmenu:toggle() end))
			})
		end	
-- Edges
	local edges = require("edges")
	edges:init({ tag_cols_num = taglist.cols_num })
-- Logout
	local logout = require("logout")
	logout:init()
-- Keys		
	local appkeys = require("appkeys")
	local hotkeys = require("keys")
	hotkeys:init({
		env = env, menu = mymenu.mainmenu, appkeys = appkeys, tag_cols_num = taglist.cols_num, volume = volume.widget,microphone = microphone.widget
	})
-- Rules			
	local rules = require("rules")
	rules:init({ env = env, hotkeys = hotkeys })
-- Titlebar		
	local titlebar = require("titlebar")
	titlebar:init()
-- Signals		
	local signals = require("signals")
	signals:init({ env = env })
