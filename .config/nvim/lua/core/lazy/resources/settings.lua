local util = require("plugins.resources.util")
-- autocmds and keymaps can wait to load
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    util.load("core.autocmds")
    util.load("custom.keymaps")
  end,
})
util.load("custom.options")
return {}
