-----------------------------------------------------------------------------------------------------------------------
--                                                   lib library                                                 --
-----------------------------------------------------------------------------------------------------------------------

local wrequire = require("lib.utils").wrequire
local setmetatable = setmetatable

local lib = { _NAME = "lib.widgets.gauge.graph" }

return setmetatable(lib, { __index = wrequire })
