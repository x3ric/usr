--█████╗ █████╗ ██╗ █████╗ ██╗ ██╗██████╗██╗   ██╗██╗   ██╗█████╗ ████╗ ████╗
--██╔═██╗██╔═██╗██║██╔═══╝ ██║ ██║  ██╔═╝███╗  ██║███╗  ██║██╔══╝██╔══╝██╔══╝  
--█████╔╝█████╔╝██║██║ ███║██████║  ██║  ██╔██╗██║██╔██╗██║████╗  ██╗    ██╗   
--██╔═██╗██╔═██║██║██║  ██║██║ ██║  ██║  ██║ ╚███║██║ ╚███║██╔═╝    ██╗    ██╗ 
--█████╔╝██║╚██║██║╚█████╔╝██║ ██║  ██║  ██║  ╚██║██║  ╚██║█████╗████╔╝ ████╔╝ 
--╚════╝ ╚═╝ ╚═╝╚═╝ ╚════╝ ╚═╝ ╚═╝  ╚═╝  ╚═╝   ╚═╝╚═╝   ╚═╝╚════╝╚═══╝  ╚═══╝
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local offsetx = dpi(56)
local offsety = dpi(300)
local brightness_icon = wibox.widget {
   widget = wibox.widget.imagebox
}
local brightness_adjust = wibox({
   screen = screen[mouse.screen],
   x = screen[mouse.screen].geometry.x + screen[mouse.screen].geometry.width - offsetx,
   y = screen[mouse.screen].geometry.y + (screen[mouse.screen].geometry.height / 2) - (offsety / 2),
   width = dpi(48),
   height = offsety,
   shape = gears.shape.rounded_rect,
   visible = false,
   ontop = true
})
local brightness_text = wibox.widget {
   font = beautiful.font ,
   align = "center",
   valign = "center",
   widget = wibox.widget.textbox
}
local brightness_bar = wibox.widget{
   widget = wibox.widget.progressbar,
   shape = gears.shape.rounded_bar,
   color = "#efefef",
   background_color = beautiful.bg_focus,
   max_value = 100,
   value = 0
}
brightness_adjust:setup {
   layout = wibox.layout.align.vertical,
   {
      wibox.container.margin(
         brightness_bar, dpi(14), dpi(20), dpi(20), dpi(20)
      ),
      forced_height = offsety * 0.75,
      direction = "east",
      layout = wibox.container.rotate
   },
   wibox.container.margin(
      brightness_icon, dpi(0), dpi(0), dpi(0), dpi(0)
   ),
   wibox.container.margin(
      brightness_text, dpi(0), dpi(0), dpi(0), dpi(10)
   )
}
local hide_brightness_adjust = gears.timer {
   timeout = 4,
   autostart = true,
   callback = function()
      brightness_adjust.visible = false
   end
}
awesome.connect_signal("brightness_change",
   function()
      awful.spawn.easy_async_with_shell(
         "brightnessctl i | awk -F'[(%)]' '/Current brightness/ {print $2}'",
         function(stdout)
            local brightness_level = tonumber(stdout)
            brightness_bar.value = brightness_level
            if (brightness_level == nil) then
               brightness_icon:set_image(beautiful.icon.brightnessoff)
               brightness_text:set_text(brightness_level .. "Off")
            elseif (brightness_level > 50) then
               brightness_icon:set_image(beautiful.icon.brightness)
               brightness_text:set_text(brightness_level .. "%")
            elseif (brightness_level > 0) then
               brightness_icon:set_image(beautiful.icon.brightnesslow)
               brightness_text:set_text(brightness_level .. "%")
            else
               brightness_icon:set_image(beautiful.icon.brightnessoff)
               brightness_text:set_text(brightness_level .. "%")
            end
         end,
         false
      )
      if brightness_adjust.visible then
         hide_brightness_adjust:again()
      else
         brightness_adjust.screen = screen[mouse.screen]
         brightness_adjust.x = screen[mouse.screen].geometry.x + screen[mouse.screen].geometry.width - offsetx
         brightness_adjust.y = screen[mouse.screen].geometry.y + (screen[mouse.screen].geometry.height / 2) - (offsety / 2)
         brightness_adjust.visible = true
         hide_brightness_adjust:start()
      end
   end
)
