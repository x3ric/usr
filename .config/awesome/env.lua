local utils         = require("lib.utils")
local beautiful     = require("beautiful")
local awful         = require("awful")
local gears         = require("gears")
local wibox         = require("wibox") 
local naughty       = require("naughty")
local dpi           = require("beautiful.xresources").apply_dpi
local unpack = unpack or table.unpack
local env = {}
function env:init(args)
    args = args or {}
    self.theme = args.theme or "oxoawesome"
    self.terminal = args.terminal or "kitty"
    self.mod = args.mod or "Mod4"
    self.alt = args.alt or "Mod1"
    self.filemanager = args.filemanager or "thunar"
    self.browser = args.browser or "firefox"
    self.editor = args.editor or "emacs" -- "kitty --class nvim nvim"
    self.player = args.player or "mpd"
    self.updates = args.updates or "pacman -Qu | grep -v ignored | wc -l"
    self.home = os.getenv("HOME")
    self.themedir = awful.util.get_configuration_dir() .. "themes/" .. self.theme
    self.sloppy_focus = args.sloppy_focus or false
    self.color_border_focus = args.color_border_focus or false
    self.set_slave = args.set_slave == nil and true or false
    self.set_center = args.set_center or false
    self.desktop_autohide = args.desktop_autohide or false
    beautiful.init(env.themedir .. "/theme.lua")
    naughty.config.padding = beautiful.useless_gap and 2 * beautiful.useless_gap or 0
    if beautiful.naughty then
        naughty.config.presets.normal   = utils.table.merge(beautiful.naughty.base, beautiful.naughty.normal)
        naughty.config.presets.critical = utils.table.merge(beautiful.naughty.base, beautiful.naughty.critical)
        naughty.config.presets.low      = utils.table.merge(beautiful.naughty.base, beautiful.naughty.low)
    end
end
awful.util.terminal = env.terminal
awful.util.shell = "/bin/zsh"
-- Wallpaper setup
--------------------------------------------------------------------------------
env.wallpaper = function(s)
	if beautiful.wallpaper then
		if not env.desktop_autohide and awful.util.file_readable(beautiful.wallpaper) then
			gears.wallpaper.maximized(beautiful.wallpaper, s, true)
		else
			gears.wallpaper.set(beautiful.color.bg)
		end
	end
end

-- Tag tooltip text generation
--------------------------------------------------------------------------------
env.tagtip = function(t)
	local layname = awful.layout.getname(awful.tag.getproperty(t, "layout"))
	if utils.table.check(beautiful, "widget.layoutbox.name_alias") then
		layname = beautiful.widget.layoutbox.name_alias[layname] or layname
	end
	return string.format("%s (%d apps) [%s]", t.name, #(t:clients()), layname)
end

-- Panel widgets wrapper
--------------------------------------------------------------------------------
env.wrapper = function(widget, name, buttons)
	local margin = utils.table.check(beautiful, "widget.wrapper")
	               and beautiful.widget.wrapper[name] or { 0, 0, 0, 0 }
	if buttons then
		widget:buttons(buttons)
	end

	return wibox.container.margin(widget, unpack(margin))
end
return env
