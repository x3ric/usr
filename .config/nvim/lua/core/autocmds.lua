-- lua/plugins/autocmds.lua

local M = {}

-- Helper: create/clear an augroup
local function augroup(name)
  return vim.api.nvim_create_augroup(name, { clear = true })
end

-- Wrapper: batch define autocmds
-- entries = {
--   { events = <string|{...}>, pattern = <string|{...}>, command = <string>, callback = <fn> },
--   ...
-- }
function M.setup()
  -- GENERAL
  vim.api.nvim_create_autocmd(
    "InsertLeave",
    { group = augroup("General"), command = "set nopaste" }
  )

  vim.api.nvim_create_autocmd(
    "TextYankPost",
    { group = augroup("General"), callback = function() vim.highlight.on_yank({ higroup = "Visual" }) end }
  )

  vim.api.nvim_create_autocmd(
    "VimResized",
    { group = augroup("General"), callback = function() vim.cmd("tabdo wincmd =") end }
  )

  vim.api.nvim_create_autocmd(
    "BufWinLeave",
    { group = augroup("General"), pattern = "?*", callback = function() vim.cmd("silent! mkview 1") end }
  )

  vim.api.nvim_create_autocmd(
    "BufWinEnter",
    { group = augroup("General"), pattern = "?*", callback = function() vim.cmd("silent! loadview 1") end }
  )

  vim.api.nvim_create_autocmd(
    "BufEnter",
    {
      group   = augroup("General"),
      pattern = "?*",
      callback = function()
        local cwd_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
        local buf_name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":t")
        vim.opt.titlestring = ("nvim %s %= %s"):format(buf_name, cwd_name)
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    "CursorHold",
    { group = augroup("General"), callback = function() vim.cmd("echon ''") end }
  )

  vim.api.nvim_create_autocmd(
    "TermOpen",
    {
      group    = augroup("General"),
      callback = function()
        vim.opt_local.number     = false
        vim.opt_local.signcolumn = "no"
        vim.opt_local.foldcolumn = "0"
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    "BufWritePre",
    {
      group = augroup("General"),
      callback = function(event)
        -- skip remote URLs
        if event.file:match("^%w%w+://") then
          return
        end
        -- ensure parent dir exists
        local real = vim.loop.fs_realpath(event.file) or event.file
        local dir  = vim.fn.fnamemodify(real, ":p:h")
        vim.fn.mkdir(dir, "p")
      end,
    }
  )


  -- FILETYPE-SPECIFIC
  vim.api.nvim_create_autocmd(
    "FileType",
    {
      group   = augroup("FileTypes"),
      pattern = { "gitcommit", "markdown" },
      callback = function()
        vim.opt_local.wrap  = true
        vim.opt_local.spell = false
      end,
    }
  )

  vim.api.nvim_create_autocmd(
    "FileType",
    {
      group   = augroup("FileTypes"),
      pattern = "help",
      callback = function() vim.cmd("wincmd L") end,
    }
  )


  -- CLOSE WITH Q
  vim.api.nvim_create_autocmd(
    "FileType",
    {
      group   = augroup("CloseWithQ"),
      pattern = {
        "qf", "help", "man", "notify", "lspinfo",
        "spectre_panel", "startuptime", "tsplayground", "PlenaryTestPopup",
      },
      callback = function(event)
        vim.bo[event.buf].buflisted = false
        vim.keymap.set(
          "n", "q", "<cmd>close<cr>",
          { buffer = event.buf, silent = true }
        )
      end,
    }
  )


  -- DISABLE COMMENT-CONTINUATION
  vim.api.nvim_create_autocmd(
    { "BufEnter", "BufWinEnter" },
    {
      group    = augroup("DisableCommentContinuation"),
      callback = function()
        -- remove 'c', 'r', 'o' from formatoptions
        vim.opt.formatoptions:remove({ "c", "r", "o" })
      end,
    }
  )
end

return M
