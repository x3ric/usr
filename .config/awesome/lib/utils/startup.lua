local io = io
local utils = require("lib.utils")
local startup = { locked = false }
startup.path = "/tmp/awesome-exit-reason"
--startup.bin  = "awesome-client"
local REASON = { RESTART = "restart", EXIT =  "exit" }
function startup.stamp(reason_restart)
	local file = io.open(startup.path, "w")
	file:write(reason_restart)
	file:close()
end
function startup:activate()
	local reason = utils.read.file(startup.path)
	self.is_startup = (not reason or reason == REASON.EXIT) and not self.locked
	awesome.connect_signal("exit",
	   function(is_restart) startup.stamp(is_restart and REASON.RESTART or REASON.EXIT) end
	)
end
return startup