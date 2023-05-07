
--[[
██████╗ ██╗   ██╗██╗     ███████╗███████╗
██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
██████╔╝██║   ██║██║     █████╗  ███████╗
██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
██║  ██║╚██████╔╝███████╗███████╗███████║
╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝
        xprop to get client info
--]]
local awful = require("awful")
local beautiful = require("beautiful")
local screen_height = awful.screen.focused().geometry.height
local screen_width = awful.screen.focused().geometry.width
local rules = {}
rules.base_properties = {
   border_width     = beautiful.border_width,
   border_color     = beautiful.border_normal,
   focus            = awful.client.focus.filter,
   raise            = true,
   size_hints_honor = false,
   screen           = awful.screen.preferred,
   --keys = clientkeys,
   --buttons = clientbuttons,
   --honor_workarea = true,
}
rules.floating_any = {
   instance = { "DTA", "copyq", },
   class = { "conky", "Unity", "UnityHub", "Arandr", "discord", "Gpick", "Kruler", "MessageWin", "Sxiv", "Wpa_gui", "pinentry", "veromix", "xtightvncviewer", },
   role = { "AlarmWindow", "pop-up", "Preferences", "setup" },
   name = { "Event Tester", },
   type = { "dialog" }
}
rules.titlebar = {
   type = { "normal", "dialog" },
}
rules.titlebar_exceptions = {
   class = { "Cavalcade", "Clipflap", "Steam", "Qemu-system-x86_64" , },
   name = { "Preview" },
}
rules.maximized = {
   class = "Emacs24"
}

function rules:init(args)
   args = args or {}
   self.base_properties.keys = args.hotkeys.keys.client
   self.base_properties.buttons = args.hotkeys.mouse.client
   self.env = args.env or {}
   self.rules = {
      {
         rule       = {},
         properties = args.base_properties or self.base_properties
      },
      {
         rule_any   = args.floating_any or self.floating_any,
         properties = { floating = true }
      },
      {
         rule   = self.maximized,
         callback = function(c)
            c.maximized = true
            bar = require("lib.widgets.bar.titlebar")
            bar.cut_all({ c })
            c.height = c.screen.workarea.height - 2 * c.border_width
         end
      },
      { rule = { class = "feh", name = "Preview" }, properties = { floating = true, placement = awful.placement.centered } },
      { rule = { class = "firefox", instance = "Toolkit" }, properties = { floating = true , sticky = true} },
      { rule = { class = "kitty" }, properties = { opacity = 0.75  } },
      { rule = { class = "nvim" }, properties = { opacity = 0.75  } },
      {-- tag full
        rule_any = { class = { "firefox" } },
        properties = {
           tag = "Full",
           switchtotag = true,
           callback = function(c)
               bar = require("lib.widgets.bar.titlebar")
               bar.hide_all({ c })
           end
        }
      },
      { -- Open 1st kitty in the center
         rule = { class = "kitty" },
         properties = {
            border_width = 0,
         },
         callback = function(c)
            local current_tag = awful.screen.focused().selected_tag
            local clients = current_tag:clients()
            if #clients == 1 then
               awful.placement.centered(c, { honor_padding = true, honor_workarea = true })
            end
         end
      },
      {-- transients
         rule_any = { type = { "dialog", "splash" },},
         properties = { placement = awful.placement.centered }
      },
      {-- floating centered
         rule_any = { class = {"Polkit-gnome-authentication-agent-1"},},
         properties = { floating = true, placement = awful.placement.centered }
      },
      {-- file grk rule
         rule_any = {role = {"GtkFileChooserDialog"},},
         properties = {floating = true, width = screen_width * 0.55, height = screen_height * 0.65}
      },
      {-- pavucontrol/blueman rule
         rule_any = {class = {"Pavucontrol"}, name = {"Bluetooth Devices"},},
         properties = {floating = true,placement = awful.placement.centered ,  width = screen_width * 0.55, height = screen_height * 0.45}
      },
      {
         rule_any   = self.titlebar,
         except_any = self.titlebar_exceptions,
         properties = { titlebars_enabled = true }
      },
      {
         rule_any   = { type = { "normal" }},
         properties = { placement = awful.placement.no_overlap + awful.placement.no_offscreen }
      },
      {
         rule = { instance = "Xephyr" },
         properties = { tag = self.env.theme == "oxoawesome" and "Test" or "Free", fullscreen = true }
      },
      {
         rule_any = { class = { "jetbrains-%w+", "java-lang-Thread" } },
         callback = function(jetbrains) if jetbrains.skip_taskbar then jetbrains.floating = true end end
      }
   }
   awful.rules.rules = rules.rules
end
return rules
