local wrequire     = require("lib.utils").wrequire
local setmetatable = setmetatable
local layout       = { _NAME = "lib.layouts" }
return setmetatable(layout, { __index = wrequire })
