local beautiful     = require("beautiful")
client.connect_signal("mouse::enter", function(c) if c.screen == mouse.screen then c:emit_signal("request::activate", "mouse_enter", {raise = false}) end end)
