local gears = require("gears")
local file = os.getenv("HOME") .. "/.cache/awesome/last-pos"
local lastTitlebarEnabled = true -- Initialize with the default value

-- Save the positions, size, floating state, and titlebar enabled state of all clients
local function savepos()
    local clients = client.get()
    local data = {}
    for _, c in ipairs(clients) do
        local geometry = c:geometry()
        local clientData = {
            id = c.window,
            x = geometry.x,
            y = geometry.y,
            width = geometry.width,
            height = geometry.height,
            floating = c.floating,
            titlebar_enabled = c.titlebar_enabled
        }
        table.insert(data, clientData)
    end
    local content = "return " .. gears.debug.dump_return(data)
    local f = io.open(file, "w")
    if f then
        f:write(content)
        f:close()
    else
        -- Handle the error when opening or writing to the file
        print("Error saving positions: Unable to open the file.")
    end
end

-- Load the positions, size, floating state, and titlebar enabled state of clients
local function loadpos()
    local f = io.open(file, "r")
    if f then
        local content = f:read("*all")
        f:close()
        local success, data = pcall(load(content))
        if success and type(data) == "table" then
            for _, cData in ipairs(data) do
                local c = client.get(cData.id)
                if c and cData.x and cData.y and cData.width and cData.height then
                    c.skip_geometry = true
                    c:geometry({
                        x = tonumber(cData.x),
                        y = tonumber(cData.y),
                        width = tonumber(cData.width),
                        height = tonumber(cData.height)
                    })
                    c.skip_geometry = false
                end
                if c and cData.floating ~= nil then
                    c.floating = cData.floating
                end
                if c and cData.titlebar_enabled ~= nil then
                    if lastTitlebarEnabled then
                        -- Skip loading the titlebar_enabled property
                        lastTitlebarEnabled = false
                    else
                        c.titlebar_enabled = cData.titlebar_enabled
                    end
                end
            end
        else
            -- Handle the error when loading the content
            print("Error loading positions:", data)
        end
    else
        -- Handle the error when opening the file
        print("Error loading positions: Unable to open the file.")
    end
end

-- Connect signals
awesome.connect_signal("startup", function()
    loadpos()
end)

awesome.connect_signal("exit", function()
    savepos()
end)

awesome.connect_signal("request::geometry", function()
    savepos()
end)

awesome.connect_signal("request::floating", function()
    savepos()
end)

client.connect_signal("manage", function(c)
    savepos()
    c.titlebar_enabled = true -- Set titlebar enabled by default for new clients
end)

client.connect_signal("focus", function(c)
    savepos()
end)
