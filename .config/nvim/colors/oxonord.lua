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
    base00 = "#101010", -- Polar Night 1
    base01 = "#121212", -- Polar Night 2
    base02 = "#31343a", -- Polar Night 3
    base03 = "#4c566a", -- Polar Night 4
    base04 = "#A7A7A7",
    base05 = "#E4E4E4",
    base06 = "#ffffff", -- white text
    base07 = "#a3be8c", -- Frost 1
    base08 = "#88c0d0", -- Aurora 1
    base09 = "#81a1c1", -- Aurora 2
    base10 = "#bf616a", -- Aurora 3
    base11 = "#5e81ac", -- Aurora 4
    base12 = "#d08770", -- Aurora 5
    base13 = "#8fbcbb", -- Aurora 6
    base14 = "#ebcb8b", -- Aurora 7
    base15 = "#b48ead", -- Aurora 8
    blend = "#111111", -- shadow of base00
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
    base07 = "#8fbcbb",
    base08 = "#88c0d0",
    base09 = "#81a1c1",
    base10 = "#5e81ac",
    base11 = "#bf616a",
    base12 = "#d08770",
    base13 = "#ebcb8b",
    base14 = "#a3be8c",
    base15 = "#b48ead",
  }    
  local util = require("plugins.resources.util")
  util.themesethl(theme,termcolors,pywall)
return M
