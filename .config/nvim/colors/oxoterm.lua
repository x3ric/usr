local M = {}
  if vim.g.colors_name then
    vim.cmd([[hi clear]])
  end
  local pywall = true
  local termcolors = true
  vim.o.termguicolors = true
  vim.g.colors_name = "oxoterm"
  local theme = {}
  theme.c = {
    base00 = "#101010", -- black background
    base01 = "#121212",
    base02 = "#242424",
    base03 = "#555555",
    base04 = "#A7A7A7",
    base05 = "#E4E4E4",
    base06 = "#ffffff", -- white text
    base07 = "#5AF78E", -- costant methods using diff
    base08 = "#61C0FF", -- functions
    base09 = "#78a9ff", -- variables statements
    base10 = "#ee5396", -- error
    base11 = "#33b1ff", -- bars and cmp
    base12 = "#ff7eb6", -- files cmp decorations
    base13 = "#C96DFF", -- statuss line and mode debug trace todo 
    base14 = "#d382c8", -- warning
    base15 = "#9D82FF", -- help types
    blend  = "#111111", -- shadow of base00
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
    base07 = "#5AF78E",
    base08 = "#61C0FF",
    base09 = "#78a9ff",
    base10 = "#ee5396",
    base11 = "#33b1ff",
    base12 = "#ff7eb6",
    base13 = "#d382c8",
    base14 = "#be95ff",
    base15 = "#9D82FF",
  }
  local util = require("plugins.resources.util")
  util.themesethl(theme,termcolors,pywall)
return M
