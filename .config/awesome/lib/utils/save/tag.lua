local awful = require("awful")
local gears = require("gears")
local file = os.getenv("HOME") .. "/.cache/awesome/last-tags"
function loadtag()
    local f = io.open(file, "r")
    if f then
        for s in screen do
            local tag_name = f:read("*line")
            if tag_name then
                local t = awful.tag.find_by_name(s, tag_name)
                if t then
                    t:view_only()
                end
            end
        end
        f:close()
    end
end
function savetag()
    local f = assert(io.open(file, "w"))
    for s in screen do
        local t = s.selected_tag
        if t then
            f:write(t.name, "\n")
        end
    end
    f:close()
end
awesome.connect_signal("exit", function ()
    savetag()
end)
awesome.connect_signal("startup", function ()
    loadtag()
end)
