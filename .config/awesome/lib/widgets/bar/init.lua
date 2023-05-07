local wrequire = require("lib.utils").wrequire
local setmetatable = setmetatable
local lib = { _NAME = "lib.widgets.bar" }
return setmetatable(lib, { __index = wrequire })