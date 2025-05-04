local client = client
local utils         = require("lib.utils")
local beautiful     = require("beautiful")
local layouts       = require("lib.layouts")
local awful         = require("awful")
local dpi           = require("beautiful.xresources").apply_dpi
function layouts:init()
    awful.layout.suit.tile.left.mirror = true
    layset = {
        awful.layout.suit.tile,
        awful.layout.suit.max,
        awful.layout.suit.magnifier,
        awful.layout.suit.tile.left,
        awful.layout.suit.tile.bottom,
        awful.layout.suit.tile.top,
        awful.layout.suit.floating,
        --awful.layout.suit.fair,
        --awful.layout.suit.fair.horizontal,
        --layouts.termfair,
        --layouts.termfair.center,
        --awful.layout.suit.corner.nw,
        --awful.layout.suit.corner.ne,
        --awful.layout.suit.corner.sw,
        --awful.layout.suit.corner.se,
        awful.layout.suit.spiral,
        --awful.layout.suit.max.fullscreen,
        --awful.layout.suit.spiral.dwindle,
        --layouts.grid,
        layouts.centerwork,
        layouts.centerwork.horizontal,
        --layouts.cascade,
        --layouts.cascade.tile,
        --layouts.map,

    }
    awful.layout.layouts = layset
end
-- Layouts options
layouts.termfair.nmaster           = 3
layouts.termfair.ncol              = 1
layouts.termfair.center.nmaster    = 3
layouts.termfair.center.ncol       = 1
layouts.cascade.tile.offset_x      = dpi(2)
layouts.cascade.tile.offset_y      = dpi(32)
layouts.cascade.tile.extra_padding = dpi(5)
layouts.cascade.tile.nmaster       = 5
layouts.cascade.tile.ncol          = 2
layouts.map.notification = true
layouts.map.notification_style = { icon = utils.table.check(beautiful, "widget.layoutbox.icon.usermap") }
client.disconnect_signal("request::geometry", awful.layout.move_handler)
client.connect_signal("request::geometry", layouts.common.mouse.move)
client.connect_signal("unmanage", layouts.map.clean_client)
client.connect_signal("property::minimized", function(c) if c.minimized and layouts.map.check_client(c) then layouts.map.clean_client(c) end end)
client.connect_signal("property::floating", function(c) if c.floating and layouts.map.check_client(c) then layouts.map.clean_client(c) end end)
client.connect_signal("untagged", function(c, t) if layouts.map.data[t] then layouts.map.clean_client(c) end end)
return layouts
