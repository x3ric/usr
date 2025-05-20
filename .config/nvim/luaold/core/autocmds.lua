local Util = require("plugins.resources.util")

-- Create common autocommands with simple creation pattern
local function create_augroup(name, autocmds)
  local group = Util.augroup(name)
  for _, autocmd in ipairs(autocmds) do
    vim.api.nvim_create_autocmd(autocmd[1], {
      group = group,
      pattern = autocmd[2] or "*",
      callback = autocmd[3],
      command = autocmd[4],
    })
  end
end

-- Define all autocommands in a condensed format
create_augroup("general", {
  { "InsertLeave", nil, nil, "set nopaste" },
  { "TextYankPost", nil, function() vim.highlight.on_yank({ higroup = "Visual" }) end },
  { "VimResized", nil, function() vim.cmd("tabdo wincmd =") end },
  { "BufWinLeave", "?*", function() vim.cmd("silent! mkview 1") end },
  { "BufWinEnter", "?*", function() vim.cmd("silent! loadview 1") end },
  { "BufEnter", "?*", function() vim.opt.titlestring = "nvim %<%F%= " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") end },
  { "CursorHold", nil, function() vim.cmd("echon ''") end },
  { "TermOpen", nil, function()
    vim.opt_local.number = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.foldcolumn = "0"
  end },
  { "BufWritePre", nil, function(event)
    if event.match:match("^%w%w+://") then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end },
})

-- Special file type settings
create_augroup("filetypes", {
  { "FileType", { "gitcommit", "markdown" }, function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = false
  end },
  { "FileType", "help", function() vim.cmd("wincmd L") end },
})

-- Close filetypes with q
create_augroup("close_with_q", {
  { "FileType", { "qf", "help", "man", "notify", "lspinfo", "spectre_panel", "startuptime", "tsplayground", "PlenaryTestPopup" },
    function(event)
      vim.bo[event.buf].buflisted = false
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end
  },
})

-- Disable continuation comments
create_augroup("disable_comments", {
  { { "BufEnter", "BufWinEnter" }, nil, function() vim.cmd("set formatoptions-=cro") end },
})
