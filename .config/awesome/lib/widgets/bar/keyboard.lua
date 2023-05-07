local setmetatable = setmetatable
local table = table
local awful = require("awful")
local beautiful = require("beautiful")
local tooltip = require("lib.widgets.float.tooltip")
local menu = require("lib.widgets.desktop.menu")
local redutil = require("lib.utils")
local svgbox = require("lib.widgets.gauge.svgbox")

local keybd = { mt = {} }
local currentl = 1

local function default_style()
    local style = {
        icon           = redutil.base.placeholder(),
        micon          = { blank = redutil.base.placeholder({ txt = " " }), check = redutil.base.placeholder({ txt = "+" }) },
        menu           = { color = { right_icon = "#a0a0a0" } },
        layout_color   = { "#a0a0a0", "#b1222b" },
        fallback_color = "#32882d",
    }
    return redutil.table.merge(style, redutil.table.check(beautiful, "widget.keyboard") or {})
end

function keybd:init(layouts, style)
    style = redutil.table.merge(default_style(), style or {})
    self.layouts = layouts or {}
    self.style = style
    self.objects = {}
    self.menu = nil
    self.tp = tooltip({ objects = {} }, style.tooltip)
    local menu_items = {}

    for i = 1, #layouts do
        local command = function() self:LayoutSet(i) end
        table.insert(menu_items, { layouts[i], command, nil, style.micon.blank })
    end

    -- initialize menu
    self.menu = menu({ hide_timeout = 1, theme = style.menu, items = menu_items })
    if self.menu.items[1].right_icon then
        self.menu.items[1].right_icon:set_image(style.micon.check)
    end

    -- update layout data
    self.update = function()
        for _, w in ipairs(self.objects) do
            w:set_color(style.layout_color[2] or style.fallback_color)
        end
		local currentLayout = io.popen("setxkbmap -query | awk '/layout:/ {print $2}'"):read("*line")
        -- update tooltip
        self.tp:set_text(currentLayout or "Unknown")
        -- update menu
        for i = 1, #self.layouts do
            local mark = currentl == i and style.micon.check or style.micon.blank
            self.menu.items[i].right_icon:set_image(mark)
        end
    end

    awesome.connect_signal("xkb::group_changed", self.update)
end

function keybd:LayoutSet(i)
    local lay = self.layouts[i]
    os.execute("setxkbmap " .. lay)
    currentl = i
    self:update()
end

function keybd:toggle_menu()
    if not self.menu then return end
    if self.menu.wibox.visible then
        self.menu:hide()
    else
        awful.placement.under_mouse(self.menu.wibox)
        awful.placement.no_offscreen(self.menu.wibox)
        self.menu:show({ coords = { x = self.menu.wibox.x, y = self.menu.wibox.y } })
    end
end

function keybd:toggle(reverse)
    if reverse then
        currentl = currentl + 1
    else
        currentl = currentl - 1
    end

    if currentl < 1 then
        currentl = #self.layouts
    elseif currentl > #self.layouts then
        currentl = 1
    end

    self:LayoutSet(currentl)
end

function keybd.new(style)
    style = style or {}
    if not keybd.menu then keybd:init({}) end

    local widg = svgbox(style.icon or keybd.style.icon)
    widg:set_color(keybd.style.layout_color[1])
    table.insert(keybd.objects, widg)
    keybd.tp:add_to_object(widg)
    keybd:update()  -- Fixed this line
    return widg
end

function keybd.mt:__call(...)
    return keybd.new(...)
end

return setmetatable(keybd, keybd.mt)
