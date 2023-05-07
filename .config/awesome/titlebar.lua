local client = client
local bar = require("lib.widgets.bar").titlebar
local utils         = require("lib.utils")
local beautiful     = require("beautiful")
local awful         = require("awful")
local wibox         = require("wibox")
local float         = require("lib.widgets.float")
local dpi           = require("beautiful.xresources").apply_dpi
local color         = require("gears.color")
local titlebar = {}
local function construct_move_buttons(c, btn)
    return awful.button({ }, btn or 1, function() client.focus = c; c:raise() awful.mouse.client.move(c) end)
end
local function construct_menu_buttons(c, btn)
    return awful.button({ }, btn or 1, function() client.focus = c; c:raise() float.clientmenu:show(c) end)
end
local function construct_all_buttons(c, move_btn, menu_btn)
    return awful.util.table.join(construct_move_buttons(c, move_btn), construct_menu_buttons(c, menu_btn))
end
local function on_maximize(c)
    local is_max = c.maximized_vertical or c.maximized
        local action = is_max and "cut_all" or "restore_all"
        bar[action]({ c })
    local model = bar.get_model(c)
        if model and not model.hidden then
            c.height = c:geometry().height + (is_max and model.size or -model.size)
            if is_max then
                c.y = c.screen.workarea.y
            end
        end
end
local function on_maximize(c)
    local is_max = c.maximized_vertical or c.maximized
        local action = is_max and "cut_all" or "restore_all"
        bar[action]({ c })
    local model = bar.get_model(c)
        if model and not model.hidden then
            local size_shift = is_max and model.size or -model.size
            local g = c:geometry()
            c:geometry({ height = g.height + 2 * size_shift, width = g.width + 2 * size_shift })
            if is_max then
                c.y = c.screen.workarea.y
                c.x = c.screen.workarea.x
            end
        end
    end
    local focus_line_shape = function(cr, width, height)
        cr:move_to(0, height)
        cr:rel_line_to(height, - height)
        cr:rel_line_to(width - 2 * height, 0)
        cr:rel_line_to(height, height)
        cr:close_path()
    end
local focus_line_style = {
    line  = { width = 3, dx = 30, dy = 20, subwidth = 6 },
    border = { width = 8 },
    color = { gray = "#404040", main = "#65087C", wibox = "#202020" },
}
local function focus_line(c, style, is_horizontal)
    local widg = wibox.widget.base.make_widget()
        widg._style = utils.table.merge(focus_line_style, style or {})
        widg._data = { color = widg._style.color.gray }
    function widg:fit(_, _, width, height)
                return width, height
            end
            function widg:draw(_, cr, width, height)
                local dy = self._style.line.subwidth - self._style.line.width
                local dw = is_horizontal and self._style.line.dx or self._style.line.dy
                cr:set_source(color(self._style.color.wibox))
                cr:rectangle(0, height, width, -self._style.border.width)
                cr:fill()
                cr:set_source(color(self._data.color))
                cr:rectangle(0, dy, width, self._style.line.width)
                cr:fill()
                cr:rectangle(0, 0, dw, self._style.line.subwidth)
                cr:rectangle(width, 0, -dw, self._style.line.subwidth)
                if is_horizontal then
                    cr:rectangle(0, 0, self._style.line.subwidth, height)
                    cr:rectangle(width, 0, -self._style.line.subwidth, height)
                end
                cr:fill()
            end
    function widg:set_active(active)
                self._data.color = active and self._style.color.main or self._style.color.gray
                self:emit_signal("widget::redraw_needed")
            end
        c:connect_signal("focus", function() widg:set_active(true) end)
        c:connect_signal("unfocus", function() widg:set_active(false) end)
        return widg
        end
    local compact_focus = function(c, style)
    local focus = bar.mark.focus(c, style)
    function focus:draw(_, cr, width, height)
            local d = math.tan(self._style.angle) * height
            cr:set_source(color(self._data.color))
            cr:move_to(0, height)
            cr:rel_line_to(d, -height)
            cr:rel_line_to(width - d, 0)
            cr:rel_line_to(0, height)
            cr:close_path()
            cr:fill()
        end
    return focus
    end
tek = false
function titlebar:init()
    local style = {}	
    if tek == true then
        local theme_base = utils.table.check(beautiful, "titlebar.base") or { color = {} }
        style.base = utils.table.merge(
            theme_base,
            { size = 12, color = { wibox = "#00000000" }, border_margin = { 0, 0, 0, 0 } }
        )
        style.focus = { color = theme_base.color }
        local original_wibox_color = theme_base.color.wibox or "#202020"
        style.mark_mini = utils.table.merge(
            utils.table.check(beautiful, "titlebar.mark") or {},
            { size = 30, gap = 10, angle = 0 }
        )
        client.connect_signal("request::titlebars",function(c) 
                    bar(c, utils.table.merge(style.base, { position = "top" }))
                    bar(c, utils.table.merge(style.base, { position = "bottom" }))
                    bar(c, utils.table.merge(style.base, { position = "right" }))
                    bar(c, utils.table.merge(style.base, { position = "left" }))
                    local hfocus = focus_line(c, style.focus, true)
                    local vfocus = focus_line(c, style.focus)
                    local marks = wibox.widget({
                        nil,
                        {
                            {
                                {
                                    bar.mark.property(c, "floating", style.mark_mini),
                                    bar.mark.property(c, "sticky", style.mark_mini),
                                    bar.mark.property(c, "ontop", style.mark_mini),
                                    bar.mark.property(c, "below", style.mark_mini),
                                    spacing = style.mark_mini.gap,
                                    layout  = wibox.layout.fixed.horizontal
                                },
                                top = 4, bottom = 4, left = 20, right = 20,
                                widget = wibox.container.margin,
                            },
                            bg = original_wibox_color,
                            shape  = focus_line_shape,
                            widget = wibox.container.background
                        },
                        nil,
                        expand = 'outside',
                        layout = wibox.layout.align.horizontal,
                    })
                    local title = wibox.widget {
                        hfocus,
                        marks,
                        layout = wibox.layout.stack
                    }
                    bar.add_layout(c, "top", title, style.base.size)
                    bar.add_layout(c, "bottom", wibox.container.rotate(hfocus, "south"), style.base.size)
                    bar.add_layout(c, "right", wibox.container.rotate(vfocus, "west"), style.base.size)
                    bar.add_layout(c, "left", wibox.container.rotate(vfocus, "east"), style.base.size)
                    if c.maximized_vertical or c.maximized then
                        on_maximize(c)
                    end
                    c:connect_signal("property::maximized_vertical", on_maximize)
                    c:connect_signal("property::maximized", on_maximize)
            end)
    else
        style.base    = utils.table.merge(utils.table.check(beautiful, "titlebar.base") or {}, { size = 8 })
        style.compact = utils.table.merge(style.base, { size = 16 })
        style.iconic  = utils.table.merge(style.base, { size = 24 })
        style.mark_mini = utils.table.merge(
            utils.table.check(beautiful, "titlebar.mark") or {},
            { size = 30, gap = 10, angle = 0 }
        )
        style.mark_compact = utils.table.merge(
            style.mark_mini,
            { size = 20, gap = 6, angle = 0.707 }
        )
        style.icon_full = utils.table.merge(
            utils.table.check(beautiful, "titlebar.icon") or {},
            { gap = 10 }
        )
        style.icon_compact = utils.table.merge(
            utils.table.check(beautiful, "titlebar.icon_compact") or style.icon_full,
            { gap = 8 }
        )
        bar._index    = 1 
        client.connect_signal("request::titlebars",function(c) 
                    local menu_buttons = construct_menu_buttons(c)
                    local move_buttons = construct_move_buttons(c)
                    local all_buttons = construct_all_buttons(c, 1, 3)
                    bar(c, style.base)
                    local base  = wibox.widget({
                        nil,
                        {
                            right  = style.mark_mini.gap,
                            bar.mark.focus(c, style.mark_mini),
                            layout = wibox.container.margin,
                        },
                        {
                            bar.mark.property(c, "floating", style.mark_mini),
                            bar.mark.property(c, "sticky", style.mark_mini),
                            bar.mark.property(c, "ontop", style.mark_mini),
                            spacing = style.mark_mini.gap,
                            layout  = wibox.layout.fixed.horizontal()
                        },
                        buttons = all_buttons,
                        layout  = wibox.layout.align.horizontal,
                    })
                    local focus = bar.button.focus(c, style.icon_compact)
                    focus:buttons(menu_buttons)
                    local compact = wibox.widget({
                        {
                            focus,
                            {
                                {
                                    {
                                        bar.mark.property(c, "floating", style.mark_compact),
                                        bar.mark.property(c, "sticky", style.mark_compact),
                                        bar.mark.property(c, "ontop", style.mark_compact),
                                        bar.mark.property(c, "below", style.mark_compact),
                                        spacing = style.mark_compact.gap,
                                        layout  = wibox.layout.fixed.horizontal
                                    },
                                    {
                                        compact_focus(c, style.mark_compact),
                                        left = style.mark_compact.gap,
                                        layout = wibox.container.margin,
                                    },
                                    layout  = wibox.layout.align.horizontal
                                },
                                top = 3, bottom = 3, right = style.icon_compact.gap + 2, left = style.icon_compact.gap + 2,
                                layout = wibox.container.margin,
                            },
                            {
                                bar.button.property(c, "minimized", style.icon_compact),
                                bar.button.property(c, "maximized", style.icon_compact),
                                bar.button.close(c, style.icon_compact),
                                spacing = style.icon_compact.gap,
                                layout  = wibox.layout.fixed.horizontal()
                            },
                            buttons = move_buttons,
                            layout  = wibox.layout.align.horizontal,
                        },
                        left = 4, right = 4,
                        widget = wibox.container.margin
                    })
                    local title = bar.label(c, style.iconic, true)
                    title:buttons(move_buttons)
                    local menu = bar.button.base("menu", style.icon_full)
                    menu:buttons(menu_buttons)
                    local iconic = wibox.widget({
                        {
                            {
                                menu,
                                bar.button.property(c, "floating", style.icon_full),
                                bar.button.property(c, "sticky", style.icon_full),
                                spacing = style.icon_full.gap,
                                layout  = wibox.layout.fixed.horizontal()
                            },
                            top = 2, bottom = 2, left = 4,
                            widget = wibox.container.margin
                        },
                        title,
                        {
                            {
                                bar.button.property(c, "minimized", style.icon_full),
                                bar.button.property(c, "maximized", style.icon_full),
                                bar.button.close(c, style.icon_full),
                                spacing = style.icon_full.gap,
                                layout  = wibox.layout.fixed.horizontal()
                            },
                            top = 2, bottom = 2, right = 4,
                            widget = wibox.container.margin
                        },
                        layout = wibox.layout.align.horizontal,
                    })
                    bar.add_layout(c, "top", base, style.base.size)
                    bar.add_layout(c, "top", compact, style.compact.size)
                    bar.add_layout(c, "top", iconic, style.iconic.size)
                    bar.switch(c, nil, bar._index)
                    if c.maximized_vertical or c.maximized then
                        on_maximize(c)
                    end
                    c:connect_signal("property::maximized_vertical", on_maximize)
                    c:connect_signal("property::maximized", on_maximize)
            end)
    end
    end
return titlebar