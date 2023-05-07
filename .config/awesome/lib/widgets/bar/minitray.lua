-----------------------------------------------------------------------------------------------------------------------
--                                               lib minitray                                                    --
-----------------------------------------------------------------------------------------------------------------------
-- Tray located on separate wibox
-- minitray:toggle() used to show/hide wibox
-- Widget with graphical counter to show how many apps placed in the system tray
-----------------------------------------------------------------------------------------------------------------------
-- Some code was taken from
------ minitray
------ http://awesome.naquadah.org/wiki/Minitray
-----------------------------------------------------------------------------------------------------------------------

-- Grab environment
-----------------------------------------------------------------------------------------------------------------------
local setmetatable = setmetatable
local table = table

local wibox = require("wibox")
local awful = require("awful")
local beautiful = require("beautiful")

local redutil = require("lib.utils")
local dotcount = require("lib.widgets.gauge.graph.dots")
local tooltip = require("lib.widgets.float.tooltip")

-- Initialize tables and wibox
-----------------------------------------------------------------------------------------------------------------------
local minitray = { widgets = {}, mt = {} }

-- Generate default theme vars
-----------------------------------------------------------------------------------------------------------------------
local function default_style()
	local style = {
		dotcount     = {},
		geometry     = { height = 40 },
		set_position = nil,
		screen_gap   = 0,
		border_width = 2,
		color        = { wibox = "#202020", border = "#575757" },
		shape        = nil
	}
	return redutil.table.merge(style, redutil.table.check(beautiful, "widget.minitray") or {})
end

-- Initialize minitray floating window
-----------------------------------------------------------------------------------------------------------------------
function minitray:init(style)

	-- Create wibox for tray
	--------------------------------------------------------------------------------
	local wargs = {
		ontop        = true,
		bg           = style.color.wibox,
		border_width = style.border_width,
		border_color = style.color.border,
		shape        = style.shape
	}

	self.wibox = wibox(wargs)
	self.wibox:geometry(style.geometry)

	self.geometry = style.geometry
	self.screen_gap = style.screen_gap
	self.set_position = style.set_position

	-- Create tooltip
	--------------------------------------------------------------------------------
	self.tp = tooltip({}, style.tooltip)

	-- Set tray
	--------------------------------------------------------------------------------
	local l = wibox.layout.align.horizontal()
	self.tray = wibox.widget.systray()
	l:set_middle(self.tray)
	self.wibox:set_widget(l)

	-- update geometry if tray icons change
	self.tray:connect_signal('widget::redraw_needed', function()
		self:update_geometry()
	end)
end

-- Show/hide functions for wibox
-----------------------------------------------------------------------------------------------------------------------

-- Update Geometry
--------------------------------------------------------------------------------
function minitray:update_geometry()
    -- Set wibox size and position
    ------------------------------------------------------------
    local items = awesome.systray()
    if items == 0 then items = 1 end

    -- Set the width of the wibox based on the number of items
    self.wibox:geometry({ width = self.geometry.width or self.geometry.height * items })

    -- Set the position of the wibox to align with the top of the screen
    local screen_gap = self.screen_gap or 0
    local y_position = mouse.screen.workarea.y + screen_gap
    if self.set_position then
        self.set_position(self.wibox)
    else
        awful.placement.under_mouse(self.wibox)
    end

    -- Adjust wibox position to the top of the screen
    self.wibox.y = y_position

    redutil.placement.no_offscreen(self.wibox, screen_gap, mouse.screen.workarea)
    self.tray.screen = self.wibox.screen
end


-- Show
--------------------------------------------------------------------------------
function minitray:show()
	self:update_geometry()
	self.wibox.visible = true
end

-- Hide
--------------------------------------------------------------------------------
function minitray:hide()
	self.wibox.visible = false
end

-- Hide on outside click
--------------------------------------------------------------------------------
local function click_outside_minitray(c)
    if not minitray.wibox then return end
    local mx, my = mouse.coords().x, mouse.coords().y
    local wx, wy = minitray.wibox:geometry().x, minitray.wibox:geometry().y
    local ww, wh = minitray.wibox:geometry().width, minitray.wibox:geometry().height
    if mx < wx or my < wy or mx > wx + ww or my > wy + wh then
        minitray:hide()
    end
end
client.connect_signal("button::press", click_outside_minitray)

-- Toggle
--------------------------------------------------------------------------------
function minitray:toggle()
	if self.wibox.visible then
		self:hide()
	else
		self:show()
	end
end

-- Create a new tray widget
-- @param args.timeout Update interval
-- @param style Settings for dotcount widget
-----------------------------------------------------------------------------------------------------------------------
function minitray.new(_, style)

	-- Initialize vars
	--------------------------------------------------------------------------------
--	args = args or {} -- usesless now, leave it be for backward compatibility and future cases
	style = redutil.table.merge(default_style(), style or {})

	-- Initialize minitray window
	--------------------------------------------------------------------------------
	if not minitray.wibox then
		minitray:init(style)
	end

	-- Create tray widget
	--------------------------------------------------------------------------------
	local widg = dotcount(style.dotcount)
	table.insert(minitray.widgets, widg)

	-- Set tooltip
	--------------------------------------------------------------------------------
	minitray.tp:add_to_object(widg)

	-- Set update timer
	--------------------------------------------------------------------------------
	function widg:update()
		local appcount = awesome.systray()
		self:set_num(appcount)
		minitray.tp:set_text(appcount .. " apps")
	end

	minitray.tray:connect_signal('widget::redraw_needed', function() widg:update() end)

	--------------------------------------------------------------------------------
	return widg
end

-- Config metatable to call minitray module as function
-----------------------------------------------------------------------------------------------------------------------
function minitray.mt:__call(...)
	return minitray.new(...)
end

return setmetatable(minitray, minitray.mt)
