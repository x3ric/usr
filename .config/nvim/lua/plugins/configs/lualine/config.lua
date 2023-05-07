local M = {}

-- Varibles
if vim.g.transparent then
  separator_style = "thin" -- | "thick" | "thin" | "slope" | "slant" | "padded_slant" | "padded_slope"
else
  separator_style = "slant"
end

---@class LualineConfig
local default = {
  float = true,
  separator = "bubble", -- bubble | triangle | bubbleminimal | triangleminimal | none "to set custom ones"
  ---@type any
  colorful = true,
}

---@type LualineConfig
M.options = {}

---@param type "bubble" | "triangle"
local function make_separator(type)
  if type == "bubble" then
    M.options.separator_icon = { left = "█", right = "█" }
    M.options.thin_separator_icon = { left = " ", right = " " }
  elseif type == "triangle" then
    M.options.separator_icon = { left = "█", right = "█" }
    M.options.thin_separator_icon = { left = " ", right = " " }
  elseif type == "bubbleminimal" then
      M.options.separator_icon = { left = "█", right = "█" }
      M.options.thin_separator_icon = { left = "", right = "" }
  elseif type == "triangleminimal" then
      M.options.separator_icon = { left = "█", right = "█" }
      M.options.thin_separator_icon = { left = "", right = "" }
  elseif type == "none" then
      M.options.separator_icon = { left = "", right = "" }
      M.options.thin_separator_icon = { left = "", right = "" }
  end
end

M.setup = function(opts)
  M.options = vim.tbl_deep_extend("force", {}, default, opts or {})
  if M.options.float then
    make_separator(M.options.separator)
  end
end

M.setup()

return M
