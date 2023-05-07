local awful = require("awful")
local file = os.getenv("HOME") .. "/.cache/awesome/last-tag"
function loadtag()
    local f = io.open(file, "r")
    if f then
        tag_name = f:read("*line")
        f:close()
        local t = awful.tag.find_by_name(nil, tag_name)
        if t then t:view_only() end
    end
end
function savetag()
    local f = assert(io.open(file, "w"))
    local t = awful.screen.focused().selected_tag
    f:write(t.name, "\n")
    f:close()
end
awesome.connect_signal("exit", function ()
    savetag()
end)
awesome.connect_signal("startup", function ()
    loadtag()
end)
