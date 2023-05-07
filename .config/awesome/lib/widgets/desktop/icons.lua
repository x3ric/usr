--libs
    local awful  = require("awful")
    local theme  = require("beautiful")
    local utils  = require("lib.awesome.menubar.utils")
    local wibox  = require("wibox")
    local gears  = require("gears")
    local os     = require("os")
    local io     = io
    local ipairs = ipairs
    local mouse  = mouse
    local string = string
    local screen = screen
    local table  = table
--var
    local desktop = {
        baseicons = {
            [1] = { label = "Computer", icon = "computer", onclick = "computer://" },
            [2] = { label = "Trash", icon = "user-trash", onclick = "trash://" },
            --[3] = { label = "Home", icon = "user-home", onclick = os.getenv("HOME") }
        },
        iconsize = { width = 48, height = 48 },
        labelsize = { width = 125, height = 20 },
        margin = { x = 20, y = 20 },
        }
    local mime_types = {}
    local desktop_current_pos = {}
    local desktop_added_icons = {}
    local desky = 75 -- y top and bottom removed space "for the bar"
--fn
    local function pipelines(...) -- Read data from files
        local f = assert(io.popen(...))
        return function ()
            local data = f:read()
            if data == nil then f:close() end
            return data
        end
        end
    function desktop.add_single_icon(args, label, icon, onclick) -- Add one icon
        local s = args.screen
        local inverted = true -- arrange from bottom to top
        if label == "Computer" then -- Custom Position for baseicons
            desktop_current_pos[s].x = screen[s].geometry.width/2
            desktop_current_pos[s].y = screen[s].geometry.height - (desky + (args.iconsize.height/2))
        elseif label == "Trash" then 
            desktop_current_pos[s].x = (screen[s].geometry.width-(screen[s].geometry.x+args.iconsize.width+args.margin.x)-(args.labelsize.width/2)+args.iconsize.width/2)
            desktop_current_pos[s].y = screen[s].geometry.height-(desky+(args.iconsize.height/2))
        else 
            if not desktop_current_pos[s] then
                if inverted then
                    desktop_current_pos[s] = { x = (screen[s].geometry.x + args.iconsize.width + args.margin.x), y =  screen[s].geometry.height - (desky + (args.iconsize.height/2)) } -- Bottom
                else
                    desktop_current_pos[s] = { x = (screen[s].geometry.x + args.iconsize.width + args.margin.x), y = desky } -- Top
                    local tot_height = (icon and args.iconsize.height or 0) + (label and args.labelsize.height or 0)
                    if tot_height == 0 then return end
                    if desktop_current_pos[s].y + tot_height > screen[s].geometry.y + screen[s].geometry.height - desky - args.margin.y then
                        desktop_current_pos[s].x = desktop_current_pos[s].x + args.labelsize.width + args.iconsize.width + args.margin.x
                        desktop_current_pos[s].y = desky + args.margin.y
                    end
                end
            end
            if inverted then
                local tot_height = (icon and args.iconsize.height or 0) + (label and args.labelsize.height or 0)
                if tot_height == 0 then return end
                if desktop_current_pos[s].y + tot_height < (desky + args.margin.y) then
                    desktop_current_pos[s].x = desktop_current_pos[s].x + args.labelsize.width + args.iconsize.width + args.margin.x
                    desktop_current_pos[s].y = screen[s].geometry.height - (desky + (args.iconsize.height/2))
                end            
            else
                local tot_height = (icon and args.iconsize.height or 0) + (label and args.labelsize.height or 0)
                if tot_height == 0 then return end
                if desktop_current_pos[s].y + tot_height > screen[s].geometry.y + screen[s].geometry.height - desky - args.margin.y then
                    desktop_current_pos[s].x = desktop_current_pos[s].x + args.labelsize.width + args.iconsize.width + args.margin.x
                    desktop_current_pos[s].y = desky + args.margin.y
                end
            end            
        end
        local common = { screen = s, bg = "#00000000", visible = true, type = "desktop" }
        if icon then
            common.width = args.iconsize.width
            common.height = args.iconsize.height
            common.x = desktop_current_pos[s].x 
            common.y = desktop_current_pos[s].y
            icon = wibox.widget {
                image = icon,
                resize = true,
                widget = wibox.widget.imagebox
            }
            icon:buttons(awful.util.table.join(awful.button({ }, 1, onclick),awful.button({ }, 3, function () args.menu:toggle() end)))
            icon_container = wibox(common)
            icon_container:set_widget(icon)
            if inverted then
                desktop_current_pos[s].y = desktop_current_pos[s].y - (args.iconsize.height + 5)
            else
                desktop_current_pos[s].y = desktop_current_pos[s].y + (args.iconsize.height + 5)
            end
        end
        if label then
            common.width = args.labelsize.width
            common.height = args.labelsize.height
            common.x = desktop_current_pos[s].x - (args.labelsize.width/2) + args.iconsize.width/2
            if inverted then
                common.y = desktop_current_pos[s].y + (args.iconsize.height + 5) * 2
            else
                common.y = desktop_current_pos[s].y
            end
            caption = wibox.widget {
                markup = '<span color="' .. theme.color.highlight .. '">' .. label .. '</span>',
                align = "center",
                forced_width = common.width,
                forced_height = common.height,
                ellipsize = "middle",
                widget = wibox.widget.textbox,
            }
            caption:buttons(awful.util.table.join(awful.button({ }, 1, onclick),awful.button({ }, 3, function () args.menu:toggle() end)))
            caption_container = wibox(common)
            caption_container:set_widget(caption)
        end
        if inverted then
            desktop_current_pos[s].y = desktop_current_pos[s].y - (args.labelsize.height + args.margin.y)
        else
            desktop_current_pos[s].y = desktop_current_pos[s].y + (args.labelsize.height + args.margin.y)
        end
        table.insert(desktop_added_icons, icon_container)
        table.insert(desktop_added_icons, caption_container)
        end
    function desktop.add_base_icons(args) -- Add Base Icons
        for _, base in ipairs(args.baseicons) do
            desktop.add_single_icon(args, base.label, utils.lookup_icon(base.icon), function()
                awful.spawn(string.format("%s '%s'", args.open_with, base.onclick))
            end)
        end
        end
    function desktop.lookup_file_icon(filename) -- Look Files Icons
        if #mime_types == 0 then
            for line in io.lines("/etc/mime.types") do
                if not line:find("^#") then
                    local parsed = {}
                    for w in line:gmatch("[^%s]+") do
                        table.insert(parsed, w)
                    end
                    if #parsed > 1 then
                        for i = 2, #parsed do
                            mime_types[parsed[i]] = parsed[1]:gsub("/", "-")
                        end
                    end
                end
            end
        end
        local extension = filename:match("%a+$")
        local mime = mime_types[extension] or ""
        local mime_family = mime:match("^%a+") or ""
        local possible_filenames = {
            mime, "gnome-mime-" .. mime,
            mime_family, "gnome-mime-" .. mime_family,
            extension
        }
        for i, filename in ipairs(possible_filenames) do
            local icon = utils.lookup_icon(filename)
            if icon then return icon end
        end
        return utils.lookup_icon("text-x-generic")
        end
    function desktop.parse_dirs_and_files(dir) -- Find Dirs and files
            local files = {}
            for path in io.popen('find ' .. dir .. ' -maxdepth 1 -type d'):lines() do
                local file = {}
                file.filename = path:match("[^/]+$")
                file.path = path
                file.show = true
                file.icon = utils.lookup_icon("folder")
                table.insert(files, file)
            end
            for path in io.popen('find ' .. dir .. ' -maxdepth 1 -type f'):lines() do
                local file = {}
                file.filename = path:match("[^/]+$")
                file.show = true
                if file.filename:match("%.desktop$") then
                    app = utils.parse_desktop_file(path)
                    file.path = app.Exec
                    file.icon = app.icon_path
                else
                    file.path = path
                    file.icon = desktop.lookup_file_icon(file.filename)
                end
                table.insert(files, file)
            end
            return files
        end        
    function desktop.add_dirs_and_files_icons(args) -- Add Icons
        for _, file in ipairs(desktop.parse_dirs_and_files(args.dir)) do
            if file.show then
                local label = args.showlabels and file.filename or nil
                local onclick
                if file.filename:match("%.sh$") then
                    onclick = function () awful.spawn.with_shell(string.format("kitty -e sh '%s'", file.path)) end
                elseif file.filename:match("%.AppImage$") then
                    onclick = function () awful.spawn.with_shell(string.format("%s", file.path)) end
                elseif file.filename:match("%.desktop$") then
                    onclick = function () awful.spawn.with_shell(string.format("zsh -ci %s", file.path)) end
                    label = file.filename:gsub("%.desktop$", "") -- hide .desktop suffix
                elseif file.filename:match("%.[^%.]+$") then
                    onclick = function () awful.spawn("xdg-open " .. file.path) end
                else
                    onclick = function () awful.spawn(string.format("%s '%s'", args.open_with, file.path)) end
                end
                desktop.add_single_icon(args, label, file.icon, onclick)
            end
        end
        end
    function desktop.remove_icons() -- Remove All Icons
        desktop_current_pos = {}
        for i = #desktop_added_icons, 1, -1 do
            desktop_added_icons[i].visible = false
            desktop_added_icons[i] = nil
            table.remove(desktop_added_icons, i)
        end
        end     
    function desktop.refresh(args) -- Refresh
        desktop.remove_icons()
        desktop.add_dirs_and_files_icons(args)
        desktop.add_base_icons(args)
        end
    function desktop.get_files(directory)
        local files = {}
        local pipe = pipelines('ls -A "' .. directory .. '"')
        for file in pipe do
            table.insert(files, file)
        end
        return files
        end
    function desktop.check_update(args) -- Check Desktop files changes
        local lastDirFiles = desktop.get_files(args.dir)
        local timer = gears.timer {
            timeout = args.delay,
            autostart = true,
            callback = function()
                local currentDirFiles = desktop.get_files(args.dir)
                local filesAdded = {}
                local filesRemoved = {}
                for _, file in ipairs(currentDirFiles) do
                    if not awful.util.table.hasitem(lastDirFiles, file) then
                        table.insert(filesAdded, file)
                    end
                end
                for _, file in ipairs(lastDirFiles) do
                    if not awful.util.table.hasitem(currentDirFiles, file) then
                        table.insert(filesRemoved, file)
                    end
                end
                if #filesAdded > 0 or #filesRemoved > 0 then
                    desktop.refresh(args)
                    lastDirFiles = currentDirFiles
                end
            end
        }
        end
    function desktop.add_icons(args) -- init
        args = args or {}
        args.delay = args.delay or 5
        args.screen = args.screen
        args.dir = args.dir or os.getenv("HOME") .. "/Desktop"
        args.showlabels = args.showlabel or true
        args.open_with = args.open_with or "Thunar"
        args.baseicons = args.baseicons or desktop.baseicons
        args.iconsize = args.iconsize or desktop.iconsize
        args.labelsize = args.labelsize or desktop.labelsize
        args.margin = args.margin or desktop.margin
        if not theme.icon_theme then
            theme.icon_theme = args.icon_theme or "Adwaita"
        end
        desktop.refresh(args)
        desktop.check_update(args)
        end
    return desktop
