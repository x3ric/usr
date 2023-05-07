local awful = require("awful")
local beautiful = require("beautiful")
local float = require("lib.widgets.float")
local widget = require("lib.widgets.bar")
local utils = require("lib.utils")
local edges = {}
local switcher = float.appswitcher
local currenttags = widget.tasklist.filter.currenttags
local allscreen   = widget.tasklist.filter.allscreen
function edges:init(args)
    args = args or {}
    local ew = args.width or 1
    local tcn = args.tag_cols_num or 0
    local geometry = args.geometry or screen[mouse.screen].geometry
    -- Iterate over all screens
        local egeometry = {
            top = { width = geometry.width - 2 * ew, height = ew, x = ew, y = 0 },
            bottom = { width = geometry.width - 2 * ew, height = ew, x = ew, y = geometry.height - ew },
            right = { width = ew, height = geometry.height, x = geometry.width - ew, y = 0 },
            left = { width = ew, height = geometry.height, x = 0, y = 0 }
        }
        local top = utils.desktop.edge("horizontal")
            top.wibox:geometry(egeometry["top"])
            top.layout:buttons(awful.util.table.join(
                -- Modify actions as needed for the top edge on the current screen (s)
                awful.button({}, 1, function()
                    if client.focus then client.focus.maximized = not client.focus.maximized end
                end),
                awful.button({}, 4, function() switcher:show({ filter = currenttags }) end),
                awful.button({}, 5, function() switcher:show({ filter = currenttags, reverse = true }) end),
                awful.button({}, 9, function() if client.focus then client.focus.minimized = true end end)
            ))
            top.wibox:connect_signal("mouse::leave", function() float.appswitcher:hide() end)
        local bottom = utils.desktop.edge("horizontal")
            bottom.wibox:geometry(egeometry["bottom"])
            bottom.layout:buttons(awful.util.table.join(
                -- Modify actions as needed for the bottom edge on the current screen (s)
                awful.button({}, 4, function() switcher:show({ filter = allscreen }) end),
                awful.button({}, 5, function() switcher:show({ filter = allscreen, reverse = true }) end)
            ))
            bottom.wibox:connect_signal("mouse::leave", function() float.appswitcher:hide() end)
        local right = utils.desktop.edge("vertical", { ew, geometry.height - ew })
            right.wibox:geometry(egeometry["right"])
            right.area[1]:buttons(awful.util.table.join(
                -- Modify actions as needed for the right edge on the current screen (s)
                awful.button({}, 5, function() tag_line_switch(s, tcn) end),
                awful.button({}, 4, function() tag_line_switch(s, tcn) end)
            ))
            right.area[2]:buttons(awful.util.table.join(
                awful.button({}, 5, function() awful.tag.viewnext(s) end),
                awful.button({}, 4, function() awful.tag.viewprev(s) end)
            ))
        local left = utils.desktop.edge("vertical", { ew, geometry.height - ew })
            left.wibox:geometry(egeometry["left"])
            left.area[1]:buttons(awful.util.table.join(
                -- Modify actions as needed for the left edge on the current screen (s)
                awful.button({}, 5, function() tag_line_switch(s, tcn) end),
                awful.button({}, 4, function() tag_line_switch(s, tcn) end)
            ))
            left.area[2]:buttons(awful.util.table.join(
                awful.button({}, 5, function() awful.tag.viewnext(s) end),
                awful.button({}, 4, function() awful.tag.viewprev(s) end)
            ))
            left.wibox:connect_signal("mouse::leave", function() float.appswitcher:hide() end)
end
function tag_line_switch(screen_index, colnum)
    local screen = screen[screen_index]
    if not screen then
        print("Screen " .. screen_index .. " does not exist.")
        return
    end
    local i = screen.selected_tag.index
    local tag_count = #screen.tags
    local new_index = (i <= colnum) and (i + colnum) or (i - colnum)
    if new_index >= 1 and new_index <= tag_count then
        local tag = screen.tags[new_index]
        tag:view_only()
    else
        print("Invalid tag index: " .. new_index)
    end
end
return edges
