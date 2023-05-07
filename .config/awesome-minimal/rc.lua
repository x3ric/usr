local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
require("lib.utils.save.tag")
require("lib.utils.save.pos")
require("lib.utils.tweaks.unfocustransparency")
require("lib.utils.tweaks.focusmouse")
require("lib.widgets.float.volume")
require("lib.widgets.float.brightness")
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, there were errors during startup!", text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true
        naughty.notify({ preset = naughty.config.presets.critical, title = "Oops, an error happened!", text = tostring(err) })
        in_error = false
    end)
end
local home = os.getenv("HOME")
local theme = "default" 
beautiful.init(home .. "/.config/awesome/themes/" .. theme .. "/theme.lua")
terminal = "kitty"
filemn = "thunar"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"
altkey = "Mod1"
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    --awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
}
menubar.utils.terminal = terminal
mykeyboardlayout = awful.widget.keyboardlayout()
mytextclock = wibox.widget.textclock("%I:%M")
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )
local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))
local function set_wallpaper(s)
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end
screen.connect_signal("property::geometry", set_wallpaper)
awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)
    awful.tag({ "1", "2", "3" }, s, awful.layout.layouts[1])
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc( 1) end),
            awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }
    s.mywibox = awful.wibar({ position = "top", screen = s })
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
root.buttons(gears.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
local focus_switch_byd = function(dir)
  return function()
      awful.client.focus.bydirection(dir)
      if client.focus then centermouse(client.focus) client.focus:raise() end
  end
end 
function centermouse(c)     
    local center_x = c.x + c.width / 2
    local center_y = c.y + c.height / 2
    awful.spawn("xdotool mousemove " .. center_x .. " " .. center_y)
end
globalkeys = gears.table.join(
    awful.key({ altkey }, "\\", function () awful.spawn.with_shell("zsh -ci rofi-hud") end,{description = "Global menu", group = "Actions"}),
    awful.key({ modkey , "Control" }, "Right", focus_switch_byd("right"),{ description = "Go to right client", group = "Client focus"}),
    awful.key({ modkey , "Control" }, "Left", focus_switch_byd("left"),{ description = "Go to left client", group = "Client focus" }),
    awful.key({ modkey , "Control" }, "Up", focus_switch_byd("up"),{ description = "Go to upper client", group = "Client focus" }),
    awful.key({ modkey , "Control" }, "Down", focus_switch_byd("down"),{ description = "Go to lower client", group = "Client focus" }),
    awful.key({ modkey }, "Left" , awful.tag.viewprev,{description = "view previous" , group = "Client focus"}),
    awful.key({ modkey }, "Right" , awful.tag.viewnext,{description = "view next" , group = "Client focus"}),
    awful.key({ modkey }, "Up" , function() awful.client.focus.byidx( -1) if client.focus then client.focus:raise() centermouse(client.focus) end end,{description = "view previous layouts" , group = "Client focus"}),
    awful.key({ modkey }, "Down" , function() awful.client.focus.byidx( 1) if client.focus then client.focus:raise() centermouse(client.focus) end end,{description = "view next layout" , group = "Client focus"}),
    awful.key({ modkey , altkey }, "v" , function ()  awful.spawn.with_shell('zsh -c -i "inputpaste"') end,{description = "Input paste" , group = "Actions"}), 
    awful.key({ modkey , "Shift"  }, "Escape", function() awful.util.spawn("kitty --start-as maximized btop") end,{description = "Task manager" , group = "Actions"}),
    awful.key({}, "XF86MonBrightnessUp", function () awful.util.spawn("brightnessctl set +1% -e", false) awesome.emit_signal("brightness_change") end,{ description = "Brightness +", group = "Screen" }),
    awful.key({}, "XF86MonBrightnessDown", function () awful.util.spawn("brightnessctl set 1%- -n 1 -e", false) awesome.emit_signal("brightness_change") end,{ description = "Brightness -", group = "Screen" }),
    awful.key({}, "XF86AudioRaiseVolume" , function () awful.spawn("pactl set-sink-volume 0 +5%") awesome.emit_signal("volume_change") end,{ description = "Volume +", group = "Volume" }),
    awful.key({}, "XF86AudioLowerVolume" , function () awful.spawn("pactl set-sink-volume 0 -5%") awesome.emit_signal("volume_change") end,{ description = "Volume -", group = "Volume" }),
    awful.key({}, "XF86AudioMute" , function () awful.spawn("pactl set-sink-mute 0 toggle") awesome.emit_signal("volume_change") end,{ description = "Volume Mute", group = "Volume" }),
    awful.key({}, "XF86AudioMicMute", function () awful.spawn("pactl set-source-mute 0 toggle") end,{ description = "Mute microphone", group = "Volume" }),
    awful.key({ modkey }, "w" , function () awful.spawn("firefox") end,{ description = "Browser", group = "Misc" }),
    awful.key({ modkey }, "Escape", awful.tag.history.restore, {description = "go back", group = "tag"}),
    awful.key({ modkey }, "v", function() awful.spawn("xfce4-popup-clipman") end,{ description = "Clipboard manager", group = "Actions" }),
    awful.key({ modkey, "Shift"   }, "Return", function () awful.spawn(filemn) end,{description = "open file manager", group = "client"}),
    awful.key({ modkey,           }, "F1", function () hotkeys_popup.show_help(nil, awful.screen.focused()) end, {description = "show main menu", group = "awesome"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto, {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey }, "Return", function () awful.spawn(terminal) end,{description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart, {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit, {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end, {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end, {description = "select previous", group = "layout"}),
    awful.key({ modkey }, "F3", function() menubar.show() end, {description = "show the menubar", group = "launcher"}),
    awful.key({ modkey, "Shift"   }, "n", function () local c = awful.client.restore() if c then c:emit_signal("request::activate", "key.unminimize", {raise = true}) end end,{description = "restore minimized", group = "client"})
)
clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen c:raise() end,{description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey            }, "q",      function (c) c:kill()                         end, {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     , {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end, {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end, {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end, {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = true end,{description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",      function (c) c.maximized = not c.maximized c:raise() end,{description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",      function (c) c.maximized_vertical = not c.maximized_vertical c:raise() end,{description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",      function (c) c.maximized_horizontal = not c.maximized_horizontal c:raise() end,{description = "(un)maximize horizontally", group = "client"})
)
for i = 1, 9 do
globalkeys = gears.table.join(globalkeys,
    awful.key({ modkey }, "#" .. i + 9,                     function () local screen = awful.screen.focused() local tag = screen.tags[i] if tag then tag:view_only() end end,{description = "view tag #"..i, group = "tag"}),
    awful.key({ modkey, "Control" }, "#" .. i + 9,          function () local screen = awful.screen.focused() local tag = screen.tags[i] if tag then awful.tag.viewtoggle(tag) end end,{description = "toggle tag #" .. i, group = "tag"}),
    awful.key({ modkey, "Shift" }, "#" .. i + 9,            function () if client.focus then local tag = client.focus.screen.tags[i] if tag then client.focus:move_to_tag(tag) end end end,{description = "move focused client to tag #"..i, group = "tag"}),
    awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9, function () if client.focus then local tag = client.focus.screen.tags[i] if tag then client.focus:toggle_tag(tag) end end end,{description = "toggle focused client on tag #" .. i, group = "tag"})
)
end
clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) end),
    awful.button({ modkey }, 1, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.move(c) end),
    awful.button({ modkey }, 3, function (c) c:emit_signal("request::activate", "mouse_click", {raise = true}) awful.mouse.client.resize(c) end)
)
root.keys(globalkeys)
awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width, border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        raise = true,
        keys = clientkeys,
        buttons = clientbuttons,
        screen = awful.screen.preferred,
        placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },
    { rule_any = {
        instance = {},
        class = {"Arandr","Blueman-manager","Gpick","Sxiv"},
        name = {"Event Tester"},
        role = {"AlarmWindow","ConfigManager","pop-up"}
      }, properties = { floating = true }},
    { rule_any = {class = { "kitty" }}, properties = { opacity = 0.90 }},
    { rule_any = {type = { "normal", "dialog" }}, properties = { titlebars_enabled = false }},
}
client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)
client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
awful.spawn.with_shell("cbatticon")