local M = {}
  if vim.g.colors_name then
    vim.cmd([[hi clear]])
  end
  local pywall = false
  local termcolors = true
  vim.o.termguicolors = true
  vim.g.colors_name = "oxopink"
  local theme = {}
  theme.c = {
    base00 = "#101010", -- black background
    base01 = "#121212",
    base02 = "#242424",
    base03 = "#555555",
    base04 = "#A7A7A7",
    base05 = "#E4E4E4",
    base06 = "#ffffff", -- white text
    base07 = "#a6e3a1", -- constant methods using diff (modified color)
    base08 = "#f5e0dc", -- functions
    base09 = "#f5c2e7", -- variables statements
    base10 = "#f38ba8", -- error
    base11 = "#cba6f7", -- bars and cmp
    base12 = "#eba0ac", -- files cmp decorations
    base13 = "#fab387", -- status line and mode debug trace todo
    base14 = "#f9e2af", -- warning
    base15 = "#f2cdcd", -- help types
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
    base07 = "#f5e0dc",
    base08 = "#f2cdcd",
    base09 = "#f5c2e7",
    base10 = "#cba6f7",
    base11 = "#f38ba8",
    base12 = "#eba0ac",
    base13 = "#fab387",
    base14 = "#be95ff",
    base15 = "#a6e3a1",
  }
  local util = require("plugins.resources.util")
  util.themesethl(theme,termcolors,pywall)
return M
