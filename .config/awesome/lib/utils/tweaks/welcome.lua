local awesome = awesome
local awful = require("awful")
local naughty = require("naughty")
local file = os.getenv("HOME") .. "/.cache/awesome/welcome"
local isinstalled = false
local f = io.open(file, "r")
if f then
  isinstalled = f:read("*a") == "1"
  f:close()
end
local function welcome()
  if not isinstalled then
      naughty.notify({ title = "Welcome to X3ric/usr Awesome config!" , text = "  MOD+Enter = term,   MOD+F1 = hotkeys,\n  MOD+s = keychords,  MOD+s = menu,\n  MOD+d = launcher,   MOD+x = runner," })
      isinstalled = true
      awesome.emit_signal("frist_run")
      local file = io.open(file, "w")
      if file then
        file:write("1")
        file:close()
      end
  end
end
welcome()
return isinstalled