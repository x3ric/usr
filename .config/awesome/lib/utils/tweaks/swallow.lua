local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")

-- Create a module to manage window swallowing
local window_swallowing = {}

-- Helper functions for window management
local function turn_off_client(c, current_tag)
    if current_tag == nil then
        current_tag = c.screen.selected_tag
    end
    local ctags = {}
    for _, tag in pairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c.sticky = false
end

local function turn_on_client(c)
    local current_tag = c.screen.selected_tag
    local ctags = { current_tag }
    for _, tag in pairs(c:tags()) do
        if tag ~= current_tag then
            table.insert(ctags, tag)
        end
    end
    c:tags(ctags)
    c:raise()
    client.focus = c
end

local function sync_clients(to_c, from_c)
    if not from_c or not to_c or not from_c.valid or not to_c.valid or from_c.modal then
        return
    end

    to_c.floating = from_c.floating
    to_c.maximized = from_c.maximized
    to_c.above = from_c.above
    to_c.below = from_c.below
    to_c:geometry(from_c:geometry())
end

-- Configuration options
local config = {
    window_swallowing_activated = false,
    parent_filter_list = beautiful.parent_filter_list or beautiful.dont_swallow_classname_list
        or { "[Ff]irefox", "[Gg]imp", "[Gg]oogle-chrome" },
    child_filter_list = beautiful.child_filter_list or beautiful.dont_swallow_classname_list
        or { "[Dd]ragon", "[Tt]hunar", "Godot", "Godot_Engine", "Godot_Editor" },
    swallowing_filter = true,
}

-- Check if an element exists in a table
local function is_in_table(element, table)
    for _, value in pairs(table) do
        if element:match(value) then
            return true
        end
    end
    return false
end

-- Async function to get the parent's PID
function get_parent_pid(child_ppid, callback)
    local ppid_cmd = string.format("pstree -A -p -s %s", child_ppid)
    awful.spawn.easy_async(ppid_cmd, function(stdout, stderr, reason, exit_code)
        if stderr and stderr ~= "" then
            callback(stderr)
        else
            callback(nil, stdout)
        end
    end)
end

-- Function to manage client window spawning
local function manage_clientspawn(c)
    local parent_client = awful.client.focus.history.get(c.screen, 1)

    if not parent_client then
        return
    elseif parent_client.type == "dialog" or parent_client.type == "splash" then
        return
    end

    get_parent_pid(c.pid, function(err, ppid)
        if err then
            return
        end

        if tostring(ppid):find("(" .. tostring(parent_client.pid) .. ")")
            and config.swallowing_filter
            and not is_in_table(parent_client.class, config.parent_filter_list)
            and not is_in_table(c.class, config.child_filter_list)
        then
            c:connect_signal("unmanage", function()
                if parent_client then
                    turn_on_client(parent_client)
                    sync_clients(parent_client, c)
                end
            end)

            sync_clients(c, parent_client)
            turn_off_client(parent_client)
        end
    end)
end

-- Start, stop, and toggle functions for window swallowing
function window_swallowing.start()
    client.connect_signal("manage", manage_clientspawn)
    config.window_swallowing_activated = true
end

function window_swallowing.stop()
    client.disconnect_signal("manage", manage_clientspawn)
    config.window_swallowing_activated = false
end

function window_swallowing.toggle()
    if config.window_swallowing_activated then
        window_swallowing.stop()
    else
        window_swallowing.start()
    end
end

-- Initialize window swallowing
--window_swallowing.start()

return window_swallowing
