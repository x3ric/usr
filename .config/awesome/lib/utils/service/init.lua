local wrequire = require("lib.utils").wrequire
local setmetatable = setmetatable
local lib = { _NAME = "lib.utils.service" }
return setmetatable(lib, { __index = wrequire })