local M = {}
  if vim.g.colors_name then
    vim.cmd([[hi clear]])
  end
  local pywall = false
  local termcolors = true
  vim.o.termguicolors = true
  vim.g.colors_name = "oxopurple"
  local theme = {}
  theme.c = {
    base00 = "#1f1726", -- dark purple background
    base01 = "#1C1424", -- dark purple
    base02 = "#382C4C", -- dark purple
    base03 = "#655C7B", -- dark purple
    base04 = "#A7A7A7",
    base05 = "#E4E4E4",
    base06 = "#ffffff", -- white text
    base07 = "#5AF78E", -- costant methods using diff
    base08 = "#9c78dd", -- functions
    base09 = "#a97aff", -- variables statements
    base10 = "#ee5396", -- error
    base11 = "#8833ff", -- bars and cmp
    base12 = "#ff7eb6", -- files cmp decorations
    base13 = "#C96DFF", -- statuss line and mode debug trace todo 
    base14 = "#d382c8", -- warning
    base15 = "#9D82FF", -- help types
    blend  = "#1f1726", -- shadow of base00
    none   = "NONE" -- transparent
  }
  theme.tc = {
    base00 = "#101010",
    base01 = "#E4E4E4",
    base02 = "#A7A7A7",
    base03 = "#CCCCCC",
    base04 = "#E4E4E4",
    base05 = "#F1F1F1",
    base06 = "#FFFFFF",
    base07 = "#9D82FF",
    base08 = "#be95ff",
    base09 = "#78a9ff",
    base10 = "#ee5396",
    base11 = "#33b1ff",
    base12 = "#ff7eb6",
    base13 = "#d382c8",
    base14 = "#61C0FF",
    base15 = "#5AF78E",
  }
  local util = require("plugins.resources.util")
  util.themesethl(theme,termcolors,pywall)
return M
