local utils         = require("lib.utils")
local beautiful     = require("beautiful")
local awful         = require("awful")
local dpi           = require("beautiful.xresources").apply_dpi
local menu          = require("lib.widgets.desktop.menu")
local gauge         = require("lib.widgets.gauge")
function menu:init(args)
    args = args or {}
    local env = args.env or {} 
    local separator = args.separator or { widget = gauge.separator.horizontal() }
    local theme = args.theme or { auto_hotkey = true }
    local icon_style = args.icon_style or { custom_only = true, scalable_only = true }
    local default_icon = utils.base.placeholder()
    local icon = utils.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or default_icon
    local color = utils.table.check(beautiful, "color.icon") and beautiful.color.icon or nil
    local function micon(name)
        return utils.service.dfparser.lookup_icon(name, icon_style)
    end
    local appmenu = utils.service.dfparser.menu({ icons = icon_style, wm_name = "awesome" })
    local awesomemenu = {{ "Restart",         awesome.restart,                 micon("gnome-session-reboot") },
        separator,
        { "Awesome config",  env.filemanager .. " .config/awesome",        micon("folder-bookmarks") },
        { "Awesome lib",     env.filemanager .. " /usr/share/awesome/lib", micon("folder-bookmarks") },
        { "Awesome rules", string.format("%s %s/.config/awesome/rules.lua",env.editor, os.getenv("HOME")) , micon("preferences-system-windows")},
        { "Awesome theme", string.format("%s %s/theme.lua",env.editor, env.themedir) , micon("gnome-settings-theme")},
        { "Awesome keys", string.format("%s %s/.config/awesome/keys.lua",env.editor, os.getenv("HOME")) , micon("keyboard")},
        { "Awesome rc", string.format("%s %s/.config/awesome/rc.lua",env.editor, os.getenv("HOME")) , micon("edit-select-all")},
        { "screen", "arandr" , micon("gtk-fullscreen")},
    }
    local placesmenu = {{ "Documents",   env.filemanager .. " Documents", micon("folder-documents") },
        { "Downloads",   env.filemanager .. " Downloads", micon("folder-download")  },
        { "Pictures",    env.filemanager .. " Pictures",  micon("folder-pictures")  },
        { "Videos",      env.filemanager .. " Videos",    micon("folder-videos")    },
        { "Music",       env.filemanager .. " Music",     micon("folder-music")     },
        --separator,
        --{ "Media", string.format("%s computer://",env.filemanager),  micon("folder-bookmarks") }, 
        --{ "Home",  string.format("%s /home/%s",env.filemanager, os.getenv("USER")), micon("folder-bookmarks") },
    }
    
    local exitmenu
    if io.popen("swapon --summary | grep '/dev/.*'"):read('*a') ~= "" then -- Hibernation buttons if swap is present
        exitmenu = {
            { "Reboot",          "reboot",                    micon("gnome-session-reboot")     },
            { "Shutdown",        "shutdown now",              micon("system-shutdown")          },
            separator,
            { "Switch user",     "zsh -ci logintty" ,         micon("gnome-session-switch")     },
            { "Hibernate",       "systemctl hibernate" ,      micon("system-suspend-hibernate") },
            { "Suspend",         "systemctl suspend" ,        micon("gnome-session-suspend")    },
            { "Log out",         awesome.quit,                micon("exit")                     },
        }
    else 
        exitmenu = {
            { "Reboot",          "reboot",                    micon("gnome-session-reboot")  },
            { "Shutdown",        "shutdown now",              micon("system-shutdown")       },
            separator,
            { "Switch user",     "zsh -ci logintty" ,         micon("gnome-session-switch")  },
            { "Suspend",         "systemctl suspend" ,        micon("gnome-session-suspend") },
            { "Log out",         awesome.quit,                micon("exit")                  },
        }
    end

    self.mainmenu = menu({ theme = theme,
        items = {{ "Awesome",       awesomemenu, micon("awesome") },
            { "Applications",  appmenu,     micon("distributor-logo") },
            { "Places",        placesmenu,  micon("folder_home"), key = "c" },
            separator,
            { "File Manager",  env.filemanager, micon("folder"), key = "n" },
            { "Terminal",      env.terminal, micon("terminal"), key = "t" },
            { "Editor",        "kitty --class nvim nvim", micon("nvim") },
            separator,
            { "Exit",          exitmenu,     micon("exit") },
        }
    })
    local deficon = utils.base.placeholder()
	local icon = utils.table.check(beautiful, "icon.awesome") and beautiful.icon.awesome or deficon
	local color = utils.table.check(beautiful, "color.icon") and beautiful.color.icon or nil
    self.widget = gauge.svgbox(icon, nil, color)
    self.buttons = awful.util.table.join(
        awful.button({ }, 1, function () self.mainmenu:toggle() end)
    )
end
return menu
