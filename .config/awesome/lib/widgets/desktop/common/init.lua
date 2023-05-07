local wrequire = require("lib.utils").wrequire
local setmetatable = setmetatable
local lib = { _NAME = "lib.widgets.desktop.common" }
return setmetatable(lib, { __index = wrequire })
