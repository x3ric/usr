local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type
local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local gears = require("gears")
local awful = require("awful")
local utils = require("lib.utils")
local naughty = require("naughty")
local beautiful = require("beautiful")
beautiful.xresources.set_dpi(75)
naughty.config.defaults['icon_size'] = 85
naughty.config.defaults.position = "top_right"
naughty.config.defaults.timeout = 3
-- Error screen
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,title = "Oops, errors on startup!",text = awesome.startup_errors }) end
do
    local in_error = false awesome.connect_signal("debug::error", function (err) if in_error then return end in_error = true naughty.notify({ preset = naughty.config.presets.critical,title = "Oops, an error happened!",text = tostring(err) }) in_error = false end)
end
-- Windowless processes
local function run_once(cmd_arr)
    for _, cmd in ipairs(cmd_arr) do
        awful.spawn.with_shell(string.format("pgrep -u $USER -fx '%s' > /dev/null || (%s)", cmd, cmd))
    end
end
local function run_from_file(file_)
    local f = io.open(file_)
    for line in f:lines() do
        if line:sub(1, 1) ~= "#" then awful.spawn.with_shell(line) end
    end
    f:close()
end
run_once({ "unclutter -root" })
-- Autoclose picom on max cpu usage 
--gears.timer {
--    timeout   = 5,
--    autostart = true,
--    callback  = function () awful.spawn("zsh -ci picom-cpumax") end
--}
-- XDG autostart specification
	--awful.spawn.with_shell(
	--    'if (xrdb -query | grep -q "^awesome\\.started:\\s*true$"); then exit; fi;' ..
	--    'xrdb -merge <<< "awesome.started:true";' ..
	--    'dex --environment Awesome --autostart --search-paths "$XDG_CONFIG_DIRS/autostart:$XDG_CONFIG_HOME/autostart"' -- https://github.com/jceb/dex
	--)
-- Garbage cleaner for lower memory consumption
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
gears.timer({
    timeout = 5,
    autostart = true,
    call_now = true,
    callback = function()
        collectgarbage("collect")
    end,
})
