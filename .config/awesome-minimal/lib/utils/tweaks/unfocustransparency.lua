local beautiful     = require("beautiful")
local transparency_unfocussed = 0.1
client.connect_signal("focus", function(c)
    if c.screen == mouse.screen then
    c.opacity = c.opacity + transparency_unfocussed
    end
 end)
client.connect_signal("unfocus", function(c)
    if c.screen == mouse.screen then
    c.opacity = c.opacity - transparency_unfocussed
    end
   end)
client.connect_signal("property::urgent", function(c)
    c.minimized = false
    c:jump_to()
end)
