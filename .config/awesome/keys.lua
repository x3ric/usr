--[[
    ██╗  ██╗███████╗██╗   ██╗███████╗
    ██║ ██╔╝██╔════╝╚██╗ ██╔╝██╔════╝
    █████╔╝ █████╗   ╚████╔╝ ███████╗
    ██╔═██╗ ██╔══╝    ╚██╔╝  ╚════██║
    ██║  ██╗███████╗   ██║   ███████║
    ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝
    sudo showkey or xev to get input
--]]
-- libs
    local table      = table
    local unpack     = unpack or table.unpack
    local awesome    = awesome
    local awful      = require("awful")
    local gears      = require("gears")
    local naughty    = require("naughty")
    local beautiful  = require("beautiful")
    local dpi        = beautiful.xresources.apply_dpi
    local gauge      = require("lib.widgets.gauge")
    local float      = require("lib.widgets.float")
    local widget     = require("lib.widgets.bar")
    local utils      = require("lib.utils")
    local xres       = require("lib.utils.xres")
    local layouts    = require("lib.layouts")
    local menu       = require("menu")
-- External libs
    local hotkeys = { mouse = {}, raw = {}, keys = {}, fake = {} }
    local apprunner = float.apprunner
    local appswitcher = float.appswitcher
    local current = widget.tasklist.filter.currenttags
    local allscr = widget.tasklist.filter.allscreen
    local laybox = widget.layoutbox
    local tip = float.hotkeys
    local laycom = layouts.common
    local grid = layouts.grid
    local map = layouts.map
    local top = float.top
    local qlaunch = float.qlaunch
    local logout = utils.service.logout
    local numkeys_line = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
    local tagkeys_line = { "q", "w", "e", "r", "t", "y", "u", "i", "o" }
-- External functions
    function centermouse(c)     
        local center_x = c.x + c.width / 2
        local center_y = c.y + c.height / 2
        awful.spawn("xdotool mousemove " .. center_x .. " " .. center_y)
    end
    function show_all_minimized_apps()
        local clients = client.get()
        for _, c in pairs(clients) do
            if c.minimized then
                c.minimized = false
            end
        end
    end
    local function focus_to_previous()
        awful.client.focus.history.previous()
        if client.focus then client.focus:raise() end
    end
    local focus_switch_byd = function(dir)
        return function()
            awful.client.focus.bydirection(dir)
            if client.focus then centermouse(client.focus) client.focus:raise() end
        end
    end
    local function minimize_all()
        for _, c in ipairs(client.get()) do
            if current(c, mouse.screen) then c.minimized = true end
        end
    end
    local function minimize_all_except_focused()
        for _, c in ipairs(client.get()) do
            if current(c, mouse.screen) and c ~= client.focus then c.minimized = true end
        end
    end
    local function restore_all()
        for _, c in ipairs(client.get()) do
            if current(c, mouse.screen) and c.minimized then c.minimized = false end
        end
    end
    local function restore_client()
        local c = awful.client.restore()
        if c then client.focus = c; c:raise() end
    end
    local function kill_all()
        for _, c in ipairs(client.get()) do
            if current(c, mouse.screen) and not c.sticky then c:kill() end
        end
    end
    local function toggle_placement(env)
        env.set_slave = not env.set_slave
        float.notify:show({ text = (env.set_slave and "Slave" or "Master") .. " placement" })
    end
    local function tag_numkey(i, mod, action)
        return awful.key(
            mod, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then action(tag) end
            end
        )
    end
    local function client_numkey(i, mod, action)
        return awful.key(
            mod, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then action(tag) end
                end
            end
        )
    end
    local function client_property(p)
        if client.focus then client.focus[p] = not client.focus[p] end
    end
    local function tag_double_select(i, colnum)
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag.selected then
            tag = (i <= colnum) and screen.tags[i + colnum] or screen.tags[i - colnum]
            if tag then tag:view_only() end
        else
            tag:view_only()
        end
    end
    local function tag_toogle_by_index(i)
        awful.tag.viewtoggle(awful.screen.focused().tags[i])
    end
    local function current_clients()
        return awful.screen.focused().selected_tag:clients()
    end
    local function client_move_by_index(i, group)
        for _, c in ipairs(group) do
            c:move_to_tag(awful.screen.focused().tags[i])
        end
    end
    local function client_move_and_go_by_index(i, group)
        local tag = awful.screen.focused().tags[i]
        for _, c in ipairs(group) do c:move_to_tag(tag) end
        tag:view_only()
    end
    local function client_toggle_by_index(i, group)
        for _, c in ipairs(group) do
            c:toggle_tag(awful.screen.focused().tags[i])
        end
    end
    local function tag_line_switch(colnum)
        local screen = awful.screen.focused()
        local i = screen.selected_tag.index
        local tag = (i <= colnum) and screen.tags[i + colnum] or screen.tags[i - colnum]
        tag:view_only()
    end
    local function tag_line_jump(colnum, is_down)
        local screen = awful.screen.focused()
        local i = screen.selected_tag.index
        local tag = is_down and screen.tags[i + colnum] or screen.tags[i - colnum]
        if tag then tag:view_only() end
    end
    local function clients_swap_by_line(colnum)
        local screen = awful.screen.focused()
        local i = screen.selected_tag.index
        local current_tag = screen.selected_tag
        local next_tag = (i <= colnum) and screen.tags[i + colnum] or screen.tags[i - colnum]
        local cc = current_tag:clients()
        local nc = next_tag:clients()
        for _, c in ipairs(cc) do c:move_to_tag(next_tag) end
        for _, c in ipairs(nc) do c:move_to_tag(current_tag) end
    end
-- Keys
    function hotkeys:init(args)
        args = args or {}
        local env = args.env
        local volume = args.volume
        local mainmenu = args.menu
        local microphone = args.microphone
        local appkeys = args.appkeys or {}
        local tcn = args.tag_cols_num or 0
        local numkeys = { unpack(numkeys_line, 1, tcn) }
        local tagkeys = { unpack(tagkeys_line, 1, tcn) }
        self.mouse.root = (awful.util.table.join(
            awful.button({ }, 3, function () mainmenu:toggle() end),
            awful.button({ }, 4, awful.tag.viewnext),
            awful.button({ }, 5, awful.tag.viewprev)
        ))
        local volume_raise = function() volume:change_volume() awesome.emit_signal("volume_change") end
        local volume_lower = function() volume:change_volume({ down = true }) awesome.emit_signal("volume_change") end
        local volume_mute  = function() volume:mute() awesome.emit_signal("volume_change") end
        float.qlaunch:init()
        local toggleapp = function(name)
            awful.spawn.easy_async_with_shell("pgrep " .. name, function(stdout)
                local pid = tonumber(stdout)
                if pid then
                    awful.spawn("kill " .. pid)
                else
                    awful.spawn(name)
                end
            end)
        end
        local apphelper = function(keys)
            if not client.focus then
                return
            end
            local class = client.focus.class:lower()
            local title = client.focus.name:lower()
            local function executeTip(name, sheet, arg)
                tip:set_pack(
                    arg, sheet.pack, sheet.style.column, { sheet.style.geometry.width , sheet.style.geometry.height },
                    function() tip:remove_pack() end
                )
                tip:show()
            end
            local classMatched = false
            for name, sheet in pairs(keys) do
                if title:find(name, 1, true) then
                    executeTip(name, sheet, client.focus.name)
                    return
                elseif class == name then
                    executeTip(name, sheet, client.focus.class)
                    classMatched = true
                end
            end
            if not classMatched and next(keys) ~= nil then
                float.notify:show({ text = "No tips for " .. client.focus.class })
            end
        end
        function run_tag_prompt()
            if not float.prompt.wibox then float.prompt:init() end
            local original_prompt = float.prompt.prompt
            float.prompt.prompt = "New tag name: "
            utils.placement.centered(float.prompt.wibox, nil, mouse.screen.workarea)
            float.prompt.wibox.visible = true
            awful.prompt.run({
                prompt = float.prompt.prompt,
                textbox = float.prompt.widget,
                exe_callback = function(name)
                    if name and #name > 0 then
                        local t = awful.tag.add(name, {
                            screen = awful.screen.focused(),
                            layout = awful.layout.layouts[1]
                        })
                        t:view_only()
                    end
                end,
                done_callback = function() 
                    float.prompt.wibox.visible = false 
                    float.prompt.prompt = original_prompt
                end
            })
        end
        function run_rofi_with_dpi()
            local dpi = xres.dpi()
            local rofi_command = "rofi -show drun -theme applications -show-icons"
            if dpi ~= 75 then
                rofi_command = string.format("%s -dpi %d", rofi_command, dpi - 35)
            end
            awful.spawn.with_shell(rofi_command)
        end     
        local apprunner_keys_move = {
            {{ }, "Down", function() apprunner:down() end,{ description = "Select next item", group = "Navigation" }},
            {{ }, "Up", function() apprunner:up() end,{ description = "Select previous item", group = "Navigation" }},
        }
        apprunner:set_keys(apprunner_keys_move, "move")
        local logout_extra_keys = {
            {{}, "Left", logout.action.select_prev,{ description = "Select previous option", group = "Selection" }},
            {{}, "Right", logout.action.select_next,{ description = "Select next option", group = "Selection" }},
        }
        logout:set_keys(awful.util.table.join(logout.keys, logout_extra_keys))
        local updates_keys_action = {
            {{ env.mod , "Shift" }, "u", function() widget.updates:hide() end,{ description = "Close updates widget", group = "Action" }},
        }
        widget.updates:set_keys(awful.util.table.join(widget.updates.keys.action, updates_keys_action), "action")
        local top_keys_action = {
            {{ env.mod , "Shift" }, "p", function() top:hide() end,{ description = "Close top list widget", group = "Action" }},
        }
        top:set_keys(awful.util.table.join(top.keys.action, top_keys_action), "action")
        local menu_keys_move = {
            {{ }, "Down", menu.action.down,{ description = "Select next item", group = "Navigation" }},
            {{ }, "Up", menu.action.up,{ description = "Select previous item", group = "Navigation" }},
            {{ }, "Left", menu.action.back,{ description = "Go back", group = "Navigation" }},
            {{ }, "Right", menu.action.enter,{ description = "Open submenu", group = "Navigation" }},
        }
        menu:set_keys(menu_keys_move, "move")
        local appswitcher_keys = {
            {{ env.mod }, "Tab", function() appswitcher:switch() end,{ description = "Select next app", group = "Navigation" }},
            {{ env.mod , "Shift" }, "Tab", function() appswitcher:switch({ reverse = true }) end,{ description = "Select previous app", group = "Navigation" }},
            {{}, "Super_L", function() appswitcher:hide() end,{ description = "Activate and exit", group = "Action" }},
            {{ env.mod }, "Super_L", function() appswitcher:hide() end,{}},
            {{ env.mod, "Shift" }, "Super_L", function() appswitcher:hide() end,{}},
            {{}, "Return", function() appswitcher:hide() end,{ description = "Activate and exit", group = "Action" }},
            {{}, "Escape", function() appswitcher:hide(true) end,{ description = "Exit", group = "Action" }},
            {{ env.mod }, "Escape", function() appswitcher:hide(true) end,{}},
            {{ env.mod }, "F1", function() tip:show()  end,{ description = "Show hotkeys helper", group = "Action" }},
        }
        appswitcher:set_keys(awful.util.table.join(appswitcher.keys.move, appswitcher_keys))
        local keyseq = { { env.mod }, "c", {}, {} }
        keyseq[3] = {{ {}, "a", {}, {} }, 
                        { {}, "k", {}, {} }, 
                        { {}, "r", {}, {} }, 
                        { {}, "n", {}, {} }, 
                        { {}, "f", {}, {} }, 
                        { {}, "s", {}, {} }, 
                        { {}, "d", {}, {} }, 
                        { {}, "u", {}, {} }, 
                        { {}, "p", {}, {} }, 
                        { { "Shift" }, "f", {}, {} }, 
                        { { "Shift" }, "s", {}, {} }, 
                        { { "Shift" }, "d", {}, {} }, 
                    }
        keyseq[3][1][3] = {
                        {{}, "p", function () toggle_placement(env) end,{ description = "Switch master/slave window placement", group = "Awesome management", keyset = { "p" } }},
                        {{}, "r", function () awesome.restart() end,{ description = "Reload awesome", group = "Awesome management", keyset = { "r" } }},}
        keyseq[3][2][3] = {
                        {{}, "f", function() if client.focus then client.focus:kill() end end,{ description = "Kill focused client", group = "Kill application", keyset = { "f" } }},
                        {{}, "a", kill_all,{ description = "Kill all clients with current tag", group = "Kill application", keyset = { "a" } }},}
        keyseq[3][3][3] = {
                        {{}, "f", restore_client,{ description = "Restore minimized client", group = "Clients management", keyset = { "f" } }},
                        {{}, "a", restore_all,{ description = "Restore all clients with current tag", group = "Clients management", keyset = { "a" } }},}
        keyseq[3][4][3] = {
                        {{}, "f", function() if client.focus then client.focus.minimized = true end end,{ description = "Minimized focused client", group = "Clients management", keyset = { "f" } }},
                        {{}, "a", minimize_all,{ description = "Minimized all clients with current tag", group = "Clients management", keyset = { "a" } }},
                        {{}, "e", minimize_all_except_focused,{ description = "Minimized all clients except focused", group = "Clients management", keyset = { "e" } }},}
        local kk = awful.util.table.join(numkeys, tagkeys)
                    for i, k in ipairs(kk) do
                        table.insert(keyseq[3][5][3], { {}, k, function() client_move_by_index(i, { client.focus })        end, {} })
                        table.insert(keyseq[3][6][3], { {}, k, function() client_toggle_by_index(i, { client.focus })      end, {} })
                        table.insert(keyseq[3][7][3], { {}, k, function() client_move_and_go_by_index(i, { client.focus }) end, {} })
                    end
        local grp = "Client tagging"
                    local line1_symb = string.format("%s..%s", numkeys[1], numkeys[#numkeys])
                    local line2_symb = string.format("%s..%s", tagkeys[1], tagkeys[#tagkeys])
                    table.insert(keyseq[3][5][3], {{}, line1_symb, nil, { description = "Move client to tag on 1st line", group = grp, keyset = numkeys }})
                    table.insert(keyseq[3][6][3], {{}, line1_symb, nil, { description = "Toggle client on tag on 1st line", group = grp, keyset = numkeys }})
                    table.insert(keyseq[3][7][3], {{}, line1_symb, nil, { description = "Move client and show tag on 1st line", group = grp, keyset = numkeys }})
                    table.insert(keyseq[3][5][3], {{}, line2_symb, nil, { description = "Move client to tag on 2nd line", group = grp, keyset = tagkeys }})
                    table.insert(keyseq[3][6][3], {{}, line2_symb, nil, { description = "Toggle client on tag on 2nd line", group = grp, keyset = tagkeys }})
                    table.insert(keyseq[3][7][3], {{}, line2_symb, nil, { description = "Move client and show tag on 2nd line", group = grp, keyset = tagkeys }})
        keyseq[3][8][3] = {{{}, "u", function() widget.updates:update(true) end,{ description = "Check available updates", group = "Update info", keyset = { "u" } }},
                        {{}, "m", function() widget.mail:update(true) end,{ description = "Check new mail", group = "Update info", keyset = { "m" } }},}
        keyseq[3][9][3] = {{{}, "s", function() client_property("sticky") end,{ description = "Toggle sticky", group = "Client properties", keyset = { "s" } }},
                        {{}, "o", function() client_property("ontop") end,{ description = "Toggle keep on top", group = "Client properties", keyset = { "o" } }},
                        {{}, "f", function() client_property("floating") end,{ description = "Toggle floating", group = "Client properties", keyset = { "f" } }},
                        {{}, "b", function() client_property("below") end,{ description = "Toggle below", group = "Client properties", keyset = { "b" } }},}
        for i, k in ipairs(kk) do
                        table.insert(keyseq[3][10][3], { {}, k, function() client_move_by_index(i, current_clients())        end, {} })
                        table.insert(keyseq[3][11][3], { {}, k, function() client_toggle_by_index(i, current_clients())      end, {} })
                        table.insert(keyseq[3][12][3], { {}, k, function() client_move_and_go_by_index(i, current_clients()) end, {} })
                    end

        local layout_grid_move = {
            {{ env.mod }, "Up", function() grid.move_to("up") end,{ description = "Move window up", group = "Movement" }},
            {{ env.mod }, "Down", function() grid.move_to("down") end,{ description = "Move window down", group = "Movement" }},
            {{ env.mod }, "Left", function() grid.move_to("left") end,{ description = "Move window left", group = "Movement" }},
            {{ env.mod }, "Right", function() grid.move_to("right") end,{ description = "Move window right", group = "Movement" }},
            {{ env.mod, "Control" }, "Up", function() grid.move_to("up", true) end,{ description = "Move window up by bound", group = "Movement" }},
            {{ env.mod, "Control" }, "Down", function() grid.move_to("down", true) end,{ description = "Move window down by bound", group = "Movement" }},
            {{ env.mod, "Control" }, "Left", function() grid.move_to("left", true) end,{ description = "Move window left by bound", group = "Movement" }},
            {{ env.mod, "Control" }, "Right", function() grid.move_to("right", true) end,{ description = "Move window right by bound", group = "Movement" }},
        }
        layouts.grid:set_keys(layout_grid_move, "move")
        local layout_grid_resize = {
            {{ env.mod }, "Up", function() grid.resize_to("up") end,{ description = "Inrease window size to the up", group = "Resize" }},
            {{ env.mod }, "Down", function() grid.resize_to("down") end,{ description = "Inrease window size to the down", group = "Resize" }},
            {{ env.mod }, "Left", function() grid.resize_to("left") end,{ description = "Inrease window size to the left", group = "Resize" }},
            {{ env.mod }, "Right", function() grid.resize_to("right") end,{ description = "Inrease window size to the right", group = "Resize" }},
            {{ env.mod, "Shift" }, "Up", function() grid.resize_to("up", nil, true) end,{ description = "Decrease window size from the up", group = "Resize" }},
            {{ env.mod, "Shift" }, "Down", function() grid.resize_to("down", nil, true) end,{ description = "Decrease window size from the down", group = "Resize" }},
            {{ env.mod, "Shift" }, "Left", function() grid.resize_to("left", nil, true) end,{ description = "Decrease window size from the left", group = "Resize" }},
            {{ env.mod, "Shift" }, "Right", function() grid.resize_to("right", nil, true) end,{ description = "Decrease window size from the right", group = "Resize" }},
            {{ env.mod, "Control" }, "Up", function() grid.resize_to("up", true) end,{ description = "Increase window size to the up by bound", group = "Resize" }},
            {{ env.mod, "Control" }, "Down", function() grid.resize_to("down", true) end,{ description = "Increase window size to the down by bound", group = "Resize" }},
            {{ env.mod, "Control" }, "Left", function() grid.resize_to("left", true) end,{ description = "Increase window size to the left by bound", group = "Resize" }},
            {{ env.mod, "Control" }, "Right", function() grid.resize_to("right", true) end,{ description = "Increase window size to the right by bound", group = "Resize" }},
            {{ env.mod, "Control", "Shift" }, "Up", function() grid.resize_to("up", true, true) end,{ description = "Decrease window size from the up by bound ", group = "Resize" }},
            {{ env.mod, "Control", "Shift" }, "Down", function() grid.resize_to("down", true, true) end,{ description = "Decrease window size from the down by bound ", group = "Resize" }},
            {{ env.mod, "Control", "Shift" }, "Left", function() grid.resize_to("left", true, true) end,{ description = "Decrease window size from the left by bound ", group = "Resize" }},
            {{ env.mod, "Control", "Shift" }, "Right", function() grid.resize_to("right", true, true) end,{ description = "Decrease window size from the right by bound ", group = "Resize" }},
        }
        layouts.grid:set_keys(layout_grid_resize, "resize")
        local layout_map_layout = {
            {{ env.mod }, "s", function() map.swap_group() end,{ description = "Change placement direction for group", group = "Layout" }},
            {{ env.mod }, "v", function() map.new_group(true) end,{ description = "Create new vertical group", group = "Layout" }},
            {{ env.mod }, "h", function() map.new_group(false) end,{ description = "Create new horizontal group", group = "Layout" }},
            {{ env.mod, "Control" }, "v", function() map.insert_group(true) end,{ description = "Insert new vertical group before active", group = "Layout" }},
            {{ env.mod, "Control" }, "h", function() map.insert_group(false) end,{ description = "Insert new horizontal group before active", group = "Layout" }},
            {{ env.mod }, "d", function() map.delete_group() end,{ description = "Destroy group", group = "Layout" }},
            {{ env.mod, "Control" }, "d", function() map.clean_groups() end,{ description = "Destroy all empty groups", group = "Layout" }},
            {{ env.mod }, "f", function() map.set_active() end,{ description = "Set active group", group = "Layout" }},
            {{ env.mod }, "g", function() map.move_to_active() end,{ description = "Move focused client to active group", group = "Layout" }},
            {{ env.mod, "Control" }, "f", function() map.hilight_active() end,{ description = "Hilight active group", group = "Layout" }},
            {{ env.mod }, "a", function() map.switch_active(1) end,{ description = "Activate next group", group = "Layout" }},
            {{ env.mod }, "q", function() map.switch_active(-1) end,{ description = "Activate previous group", group = "Layout" }},
            {{ env.mod }, "]", function() map.move_group(1) end,{ description = "Move active group to the top", group = "Layout" }},
            {{ env.mod }, "[", function() map.move_group(-1) end,{ description = "Move active group to the bottom", group = "Layout" }},
            {{ env.mod }, "r", function() map.reset_tree() end,{ description = "Reset layout structure", group = "Layout" }},
        }
        layouts.map:set_keys(layout_map_layout, "layout")
        local layout_map_resize = {
            {{ env.mod }, "Left", function() map.incfactor(nil, 0.1, false) end,{ description = "Increase window horizontal size factor", group = "Resize" }},
            {{ env.mod }, "Right", function() map.incfactor(nil, -0.1, false) end,{ description = "Decrease window horizontal size factor", group = "Resize" }},
            {{ env.mod }, "Up", function() map.incfactor(nil, 0.1, true) end,{ description = "Increase window vertical size factor", group = "Resize" }},
            {{ env.mod }, "Down", function() map.incfactor(nil, -0.1, true) end,{ description = "Decrease window vertical size factor", group = "Resize" }},
            {{ env.mod, "Control" }, "Left", function() map.incfactor(nil, 0.1, false, true) end,{ description = "Increase group horizontal size factor", group = "Resize" }},
            {{ env.mod, "Control" }, "Right", function() map.incfactor(nil, -0.1, false, true) end,{ description = "Decrease group horizontal size factor", group = "Resize" }},
            {{ env.mod, "Control" }, "Up", function() map.incfactor(nil, 0.1, true, true) end,{ description = "Increase group vertical size factor", group = "Resize" }},
            {{ env.mod, "Control" }, "Down", function() map.incfactor(nil, -0.1, true, true) end,{ description = "Decrease group vertical size factor", group = "Resize" }},
        }
        layouts.map:set_keys(layout_map_resize, "resize")
        self.raw.root = {
            {{ env.mod }, "F1", function() tip:show() end,{ description = "[Hold] Show awesome hotkeys helper", group = "Main" }},
            {{ env.mod, "Shift" }, "F1", function() apphelper(appkeys) end,{ description = "[Hold] Show hotkeys helper for application", group = "Main" }},
            {{ env.mod }, "c", function() float.keychain:activate(keyseq, "User") end,{ description = "[Hold] User key sequence", group = "Main" }},
            {{ env.mod }, "F2", function () utils.service.navigator:run() end,{ description = "[Hold] Tiling window control mode", group = "Window control" }},
            {{ env.mod , "Shift" }, "f", function() float.control:show() end,{ description = "[Hold] Floating window control mode", group = "Window control" }},
            {{ env.mod }, "Return", function() awful.spawn(env.terminal) end,{ description = "Open a terminal", group = "Actions" }},
            {{ env.mod }, "v", function() awful.spawn("xfce4-popup-clipman") end,{ description = "Clipboard manager", group = "Actions" }},
            {{ env.mod , "Control" }, "r", awesome.restart,{ description = "Reload Awesome", group = "Actions" }},    
            {{ env.mod }, "t", function() float.bartip:show() end,{ description = "[Hold] titlebar control", group = "Window control" }},
            {{ env.mod , "Control" }, "Right", focus_switch_byd("right"),{ description = "Go to right client", group = "Client focus" }},
            {{ env.mod , "Control" }, "Left", focus_switch_byd("left"),{ description = "Go to left client", group = "Client focus" }},
            {{ env.mod , "Control" }, "Up", focus_switch_byd("up"),{ description = "Go to upper client", group = "Client focus" }},
            {{ env.mod , "Control" }, "Down", focus_switch_byd("down"),{ description = "Go to lower client", group = "Client focus" }},
            {{ env.mod }, "Left" , awful.tag.viewprev,{description = "view previous" , group = "Client focus"}},
            {{ env.mod }, "Right" , awful.tag.viewnext,{description = "view next" , group = "Client focus"}},
            {{ env.mod }, "Up" , function() awful.client.focus.byidx( -1) if client.focus then client.focus:raise() centermouse(client.focus) end end,{description = "view previous layouts" , group = "Client focus"}},
            {{ env.mod }, "Down" , function() awful.client.focus.byidx( 1) if client.focus then client.focus:raise() centermouse(client.focus) end end,{description = "view next layout" , group = "Client focus"}},
            {{ env.mod }, "u", awful.client.urgent.jumpto,{ description = "Go to urgent client", group = "Client focus" }},
            {{ env.mod, "Shift" }, "Tab", nil, function() appswitcher:show({ filter = allscr }) end,{ description = "Switch to next through all tags", group = "Application switcher" }},
            {{ env.mod }, "Tab", nil, function() appswitcher:show({ filter = current }) end,{ description = "Switch to next with current tag", group = "Application switcher" }},
            --{{ env.alt,  }, "Tab" ,   awful.tag.viewnext,{description = "view next" , group = "Layouts"}},
            --{{ env.alt, "Shift" }, "Tab" ,  awful.tag.viewprev,{description = "view previous" , group = "Layouts"}},
            --{{ env.alt }, "Escape" , awful.tag.history.restore,{description = "go back" , group = "Client focus"}},
            {{ env.mod, "Shift" }, "u", function() widget.updates:show() end,{ description = "System updates info", group = "Widgets" }},
            {{ env.mod }, "'", function() widget.minitray:toggle() end,{ description = "Minitray", group = "Widgets" }},
            --{{ env.mod, "Control" }, "space", function() clients_swap_by_line(tcn) end,{ description = "Swap clients between lines", group = "Tag navigation" }},
            {{ env.mod }, "s", function() mainmenu:show() end,{ description = "Main menu", group = "Launchers" }},
            {{ env.mod }, "d", function() apprunner:show() end,{ description = "Application launcher", group = "Launchers" }},
            {{ env.mod }, "x", function() float.prompt:run() end,{ description = "Prompt box", group = "Launchers" }},
            --{{ env.mod }, "\\", function() qlaunch:show() end,{ description = "Application quick launcher", group = "Launchers" }},
            {{}, "XF86AudioPlay", function() float.player:action("PlayPause") end,{ description = "Play/Pause track", group = "Audio player" }},
            {{}, "XF86AudioNext", function() float.player:action("Next") end,{ description = "Next track", group = "Audio player" }},
            {{}, "XF86AudioPrev", function() float.player:action("Previous") end,{ description = "Previous track", group = "Audio player" }},
            {{}, "XF86AudioStop", function() float.player:action("Stop") end,{ description = "Stop track", group = "Audio player" }},
            {{}, "XF86MonBrightnessUp", function () awful.util.spawn("brightnessctl set +1% -e", false) awesome.emit_signal("brightness_change") end,{ description = "Brightness +", group = "Screen" }},
            {{}, "XF86MonBrightnessDown", function () awful.util.spawn("brightnessctl set 1%- -n 1 -e", false) awesome.emit_signal("brightness_change") end,{ description = "Brightness -", group = "Screen" }},
            {{}, "XF86AudioRaiseVolume" , volume_raise ,{ description = "Volume +", group = "Volume" }},
            {{}, "XF86AudioLowerVolume" , volume_lower ,{ description = "Volume -", group = "Volume" }},
            {{}, "XF86AudioMute" , volume_mute ,{ description = "Volume Mute", group = "Volume" }},
            {{}, "XF86AudioMicMute", function () microphone:mute() end,{ description = "Mute microphone", group = "Volume" }},
            {{ env.mod }, "l", function() laybox:toggle_menu(mouse.screen.selected_tag) end,{ description = "Show layout menu", group = "Layouts" }},
            {{ env.mod }, "space", function() awful.layout.inc(1) end,{ description = "Select next layout", group = "Layouts" }},
            {{ env.mod , "Shift" }, "space", function() awful.layout.inc(-1) end,{ description = "Select previous layout", group = "Layouts" }},
            {{ env.mod }, "Print" , function () awful.spawn.with_shell("zsh -ci screenshot") end,{description = "Screenshot" , group = "Screen"}},
            {{ env.mod , "Shift" }, "Print" , function () awful.spawn.with_shell("zsh -ci 'screenshot crop'") end,{description = "Screencrop" , group = "Screen"}},
            {{ env.mod , env.alt }, "Print", function () awful.spawn.with_shell("zsh -ci screentext") end,{description = "Screen text ocr", group = "Screen"}},
            {{ env.mod }, "F3" , function() run_rofi_with_dpi() end,{description = "menu appfinder" , group = "Actions"}},
            {{ env.mod }, "F4" , function() awful.spawn.with_shell("zsh -ci picom-toggle") end,{description = "Picom toggle" , group = "Actions"}},
            {{ env.mod }, "," , function() awful.spawn.with_shell("rofi -modi emoji -show emoji -theme x") end,{description = "Emoji menu" , group = "Actions"}},        
            {{ env.mod }, "w" , function () awful.util.spawn( env.browser ) end,{description = "Open Broswer", group = "Actions"}},
            {{ env.mod }, "e" , function () awful.util.spawn( env.editor ) end,{description = "Open Editor" , group = "Actions"}},
            {{ env.mod }, "a", function() toggleapp("pavucontrol") end,{ description = "Audio control", group = "Actions" }},
            {{ env.mod }, "Escape" , function () awful.util.spawn( "xkill" ) end,{description = "Kill proces" , group = "Actions"}},
            {{ env.mod , "Shift" }, "c" , function ()  awful.util.spawn("gpick -s") end,{description = "Color picker" , group = "Actions"}},
            {{ env.mod }, "p" , function () toggleapp("arandr") end,{description = "Screen projection" , group = "Screen"}},
            {{ env.mod , "Shift" }, "n", function() show_all_minimized_apps() end,{description = "show all minimized apps", group = "client"}},
            {{ env.mod }, "b", function() local s = awful.screen.focused() if s.panel then s.panel.visible = not s.panel.visible end end, { description = "Toggle wibox", group = "Actions" }},
            {{ env.mod, "Shift" }, "x", function() logout:show() end,{ description = "Log out screen", group = "Widgets" }},
            {{ env.mod, "Shift" }, "d", function() local s = awful.screen.focused() awful.spawn(string.format("dmenu_run -i -nb '%s' -nf '%s' -sb '%s' -sf '%s' -fn NotoMonoRegular:bold:pixelsize=%s",beautiful.bg_normal, beautiful.fg_normal, beautiful.bg_focus, beautiful.fg_focus, s.panel:geometry().height))end,{description = "Show dmenu" , group = "Actions"}},
            {{ env.mod, "Shift" }, "Return", function() awful.util.spawn( env.filemanager ) end,{description = "file manager gui" , group = "Actions"}},
            {{ env.mod, "Shift" }, "Escape", function() awful.util.spawn("kitty --start-as maximized btop") end,{description = "Task manager" , group = "Actions"}},
            {{ env.mod, env.alt }, "v" , function ()  awful.spawn.with_shell('zsh -c -i "inputpaste"') end,{description = "Input paste" , group = "Actions"}},
            {{ env.mod, "Shift" }, "p", function() top:show("cpu") end,{ description = "Top process list", group = "Widgets" }},
            {{ env.mod }, "F5", function () awful.screen.focused().quake:toggle() end,{description = "Dropdown teminal", group = "Actions"}},
            {{ env.mod }, "\\", function () awful.spawn.with_shell("zsh -ci rofi-hud") end,{description = "Global menu", group = "Actions"}},
            {{ env.mod, "Shift" }, "F7", function() run_tag_prompt() end, { description = "Add tag with name", group = "Actions" }},
        }
        self.raw.client = {
            {{ env.mod }, "f", function(c) c.fullscreen = not c.fullscreen; c:raise() end,{ description = "Toggle fullscreen", group = "Client keys" }},
            {{ env.mod }, "q", function(c) c:kill() end,{ description = "Close", group = "Client keys" }},
            {{ env.mod, "Control" }, "f", awful.client.floating.toggle,{ description = "Toggle floating", group = "Client keys" }},
            {{ env.mod, "Control" }, "o", function(c) c.ontop = not c.ontop end,{ description = "Toggle keep on top", group = "Client keys" }},
            {{ env.mod }, "n", function(c) c.minimized = true end,{ description = "Minimize", group = "Client keys" }},
            {{ env.mod }, "m", function(c) c.maximized = not c.maximized; c:raise() end,{ description = "Maximize", group = "Client keys" }},
            {{ env.mod }, "z", function(c) c:raise() float.clientmenu:show(c) end,{ description = "Client control", group = "Window control" }},
            {{ env.mod }, "o" , function(c) c:move_to_screen() end,{description = "Move to other screen" , group = "Window control"}},
            {{ env.mod }, "-" , function() local c = client.focus if c then c.opacity = c.opacity - 0.1 end end,{description = "trasparency -" , group = "Window control"}},
            {{ env.mod }, "+" , function() local c = client.focus if c then c.opacity = c.opacity + 0.1 end end,{description = "trasparency +" , group = "Window control"}},
            {{ env.mod }, "ù" , function() local c = client.focus if c then c.opacity = 1 end end,{description = "trasparency reset" , group = "Window control"}},
            {{ env.mod, "Control" }, "+" , function () utils.useless_gaps_resize(1) end,{description = "increment useless gaps" , group = "Window control"}},
            {{ env.mod, "Control" }, "-" , function () utils.useless_gaps_resize(-1) end,{description = "decrement useless gaps" , group = "Window control"}},
        }
        self.keys.root = utils.key.build(self.raw.root)
        self.keys.client = utils.key.build(self.raw.client)
        for i = 1, 9 do
            self.keys.root = awful.util.table.join(
                self.keys.root,
                tag_numkey(i,    { env.mod },                     function(t) t:view_only()               end),
                tag_numkey(i,    { env.mod, "Control" },          function(t) awful.tag.viewtoggle(t)     end),
                client_numkey(i, { env.mod, "Shift" },            function(t) client.focus:move_to_tag(t) t:view_only() end),
                client_numkey(i, { env.mod, "Control", "Shift" }, function(t) client.focus:toggle_tag(t)  end)
            )
        end
        local numkeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
        self.fake.numkeys = {
            {{ env.mod }, "1..9", nil,{ description = "Switch to tag", group = "Numeric keys", keyset = numkeys }},
            {{ env.mod, "Control" }, "1..9", nil,{ description = "Toggle tag", group = "Numeric keys", keyset = numkeys }},
            {{ env.mod, "Shift" }, "1..9", nil,{ description = "Move focused client to tag", group = "Numeric keys", keyset = numkeys }},
            {{ env.mod, "Control", "Shift" }, "1..9", nil,{ description = "Toggle focused client on tag", group = "Numeric keys", keyset = numkeys }},
        }
        float.hotkeys:set_pack("Main", awful.util.table.join(self.raw.root, self.raw.client, self.fake.tagkeys), 2)
        self.mouse.client = awful.util.table.join(
            awful.button({}, 1, function (c) client.focus = c; c:raise() end),
            awful.button({ env.mod }, 2, awful.mouse.client.move),
            awful.button({ env.mod }, 3, awful.mouse.client.resize),
            awful.button({ env.mod }, 1, awful.mouse.client.move)
        )
        root.keys(self.keys.root)
        root.buttons(self.mouse.root)
end
return hotkeys
