local xres = {}
local io = io
local os = os

function xres.dpi()
    local dpi = 75  -- Default DPI in case .Xresources doesn't specify
    local file = io.open(os.getenv("HOME") .. "/.Xresources", "r")
    if file then
        for line in file:lines() do
            local value = line:match("^%s*Xft.dpi%s*:%s*(%d+)")
            if value then
                dpi = tonumber(value)
                break
            end
        end
        file:close()
    end
    return dpi
end

return xres
