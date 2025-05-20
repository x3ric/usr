-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- Load plugins
require("lazy").setup({
  spec = {
    { import = "core.lazy.resources" },
    { import = "core.lazy.resources.lang" },
  },
  defaults = { lazy = false, version = "*" },
  install = { colorscheme = { "oxoterm" } },
  checker = { enabled = false, notify = false }
})
