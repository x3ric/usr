local awful = require("awful")
local logout_screen = require("lib.utils.service.logout")

local logout = {}

function logout:init()

    local logout_entries = {
        {   -- Logout
            callback   = function() awesome.quit() end,
            icon_name  = 'logout',
            label      = 'Logout',
            close_apps = true,
        },
        {   -- Shutdown
            callback   = function() awful.spawn.with_shell("systemctl poweroff") end,
            icon_name  = 'poweroff',
            label      = 'Shutdown',
            close_apps = true,
        },
        {   -- Reboot
            callback   = function() awful.spawn.with_shell("systemctl reboot") end,
            icon_name  = 'reboot',
            label      = 'Restart',
            close_apps = true,
        },
        {   -- Switch user
            callback   = function() awful.spawn.with_shell("zsh -ci logintty") end,
            icon_name  = 'switch',
            label      = 'Switch User',
            close_apps = false,
        },
        {   -- Suspend
            callback   = function() awful.spawn.with_shell("systemctl suspend") end,
            icon_name  = 'suspend',
            label      = 'Sleep',
            close_apps = false,
        },
    }

    local hibernation_output = io.popen("swapon --summary | grep '/dev/.*'"):read('*a')

    if hibernation_output ~= "" then
        table.insert(logout_entries, { -- Hibernation
            callback   = function() awful.spawn.with_shell("systemctl hibernate") end,
            icon_name  = 'hibernate',
            label      = 'Hibernation',
            close_apps = false,
        })
    end

    logout_screen:set_entries(logout_entries)
end

return logout
