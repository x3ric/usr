--██╗   ██╗ ██████╗ ██╗     ██╗   ██╗███╗   ███╗███████╗
--██║   ██║██╔═══██╗██║     ██║   ██║████╗ ████║██╔════╝
--██║   ██║██║   ██║██║     ██║   ██║██╔████╔██║█████╗
--╚██╗ ██╔╝██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══╝
-- ╚████╔╝ ╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║███████╗
--  ╚═══╝   ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local utils = require("lib.utils")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local offsetx = dpi(12)
local offsety = dpi(300)
local volume_icon = wibox.widget {
   widget = wibox.widget.imagebox
}
local volume_adjust = wibox({
   screen = screen[mouse.screen],
   x = screen[mouse.screen].geometry.x + offsetx,
   y = screen[mouse.screen].geometry.y + (screen[mouse.screen].geometry.height / 2) - (offsety / 2),
   width = dpi(48),
   height = offsety,
   shape = gears.shape.rounded_rect,
   visible = false,
   ontop = true
})
local volume_text = wibox.widget {
   font = beautiful.font ,
   align = "center",
   valign = "center",
   widget = wibox.widget.textbox
}
local volume_bar = wibox.widget{
   widget = wibox.widget.progressbar,
   shape = gears.shape.rounded_bar,
   color = "#efefef",
   background_color = "#232323",
   max_value = 100,
   value = 0
}
volume_adjust:setup {
   layout = wibox.layout.align.vertical,
   {
      wibox.container.margin(
         volume_bar, dpi(14), dpi(20), dpi(20), dpi(20)
      ),
      forced_height = offsety * 0.75,
      direction = "east",
      layout = wibox.container.rotate
   },
   wibox.container.margin(
      volume_icon, dpi(0), dpi(0), dpi(0), dpi(0)
   ),
   wibox.container.margin(
      volume_text, dpi(0), dpi(0), dpi(0), dpi(10)
   )
}
local hide_volume_adjust = gears.timer {
   timeout = 4,
   autostart = true,
   callback = function()
      volume_adjust.visible = false
   end
}
awesome.connect_signal("volume_change",
   function()
      awful.spawn.easy_async_with_shell(
         "pactl get-sink-volume 0",
         function(stdout)
            local volume_level = tonumber(string.match(stdout, "(%d+)%%"))
            volume_bar.value = volume_level
            local m = utils.read.output("pactl get-sink-mute 0")
            local mute = not (m and string.find(m, "no", -4))
            if mute then
               volume_icon:set_image(beautiful.icon.volumeoff)
               volume_text:set_text("M") -- Show "Muted" when volume is muted
            else
               volume_text:set_text(volume_level .. "%") -- Show the volume percentage
               if (volume_level > 50) then
                  volume_icon:set_image(beautiful.icon.volume)
               elseif (volume_level > 0) then
                  volume_icon:set_image(beautiful.icon.volumelow)
               else
                  volume_icon:set_image(beautiful.icon.volumeoff)
               end
            end
         end,
         false
      )
      if volume_adjust.visible then
         hide_volume_adjust:again()
      else
         volume_adjust.screen = screen[mouse.screen]
         volume_adjust.x = screen[mouse.screen].geometry.x + offsetx
         volume_adjust.y = screen[mouse.screen].geometry.y + (screen[mouse.screen].geometry.height / 2) - (offsety / 2)
         volume_adjust.visible = true
         hide_volume_adjust:start()
      end
   end
)
