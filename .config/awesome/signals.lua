local client = client
local utils         = require("lib.utils")
local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox")
local beautiful     = require("beautiful")
local dpi           = require("beautiful.xresources").apply_dpi
local signals = {}
local function do_sloppy_focus(c)
    if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier and awful.client.focus.filter(c) then
        client.focus = c
    end
end
local function fixed_maximized_geometry(c, context)
    if c.maximized and context ~= "fullscreen" then
        c:geometry({
            x = c.screen.workarea.x,
            y = c.screen.workarea.y,
            height = c.screen.workarea.height - 2 * c.border_width,
            width = c.screen.workarea.width - 2 * c.border_width
        })
    end
end
function signals:init(args)
    args = args or {}
    local env = args.env
    client.connect_signal(
                    "manage",
                    function(c)
                    if env.set_slave then awful.client.setslave(c) end
                    if awesome.startup
                        and not c.size_hints.user_position
                        and not c.size_hints.program_position
                        then
                            awful.placement.no_offscreen(c)
                        end
                    if env.set_center and c.floating and not (c.maximized or c.fullscreen) then
                            utils.placement.centered(c, nil, mouse.screen.workarea)
                        end
                    end
                )
    client.connect_signal(
                    "property::maximized",
                    function(c)
                        if not c.maximized then
                            c.border_width = beautiful.border_width
                        end
                    end
                )
    client.connect_signal(
                    "request::geometry", fixed_maximized_geometry
                )
    -- No borders when only 1 non-floating or maximized client
	screen.connect_signal("arrange", function (s)
		local only_one = #s.tiled_clients == 1
		for _, c in pairs(s.clients) do
			if only_one and not c.floating or c.maximized then
				c.border_width = 2
			else
				c.border_width = beautiful.border_width
			end
		end
	end)	
    -- reload on screen change
    screen.connect_signal("property::geometry", awesome.restart)
    if env.sloppy_focus then
                    client.connect_signal("mouse::enter", do_sloppy_focus)
                end
                if env.color_border_focus then
                    client.connect_signal("focus",   function(c) c.border_color = beautiful.border_focus end)
                    client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
                end
    screen.connect_signal("list", awesome.restart)
end
return signals