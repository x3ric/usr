-----------------------------------------------------------------------------------------------------------------------
--                                                  lib library                                                  --
-----------------------------------------------------------------------------------------------------------------------

local wrequire = require("lib.utils").wrequire
local setmetatable = setmetatable

local float = { _NAME = "lib.widgets.float" }

return setmetatable(float, { __index = wrequire })
