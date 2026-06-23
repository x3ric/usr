local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

------------------------ Editor keymaps ----------------------
keymap('n', '<C-c>', '"+y<CR>', vim.tbl_extend('force', opts, { desc = 'Copy to clipboard' }))
keymap('i', '<C-c>', '<Esc>"+y<CR>', vim.tbl_extend('force', opts, { desc = 'Copy to clipboard' }))
keymap('v', '<C-c>', '"+y<CR>', vim.tbl_extend('force', opts, { desc = 'Copy to clipboard' }))
keymap('n', '<M-v>', '<C-v>', vim.tbl_extend('force', opts, { desc = 'Visual block selection' }))
keymap('n', '<C-v>', '"+p<CR>', vim.tbl_extend('force', opts, { desc = 'Paste from clipboard' }))
keymap('i', '<M-v>', '<Esc><C-v>', vim.tbl_extend('force', opts, { desc = 'Visual block selection' }))
keymap('i', '<C-v>', '<Esc>"+p<CR>', vim.tbl_extend('force', opts, { desc = 'Paste from clipboard' }))
keymap('v', '<M-v>', '<C-v>', vim.tbl_extend('force', opts, { desc = 'Visual block selection' }))
keymap('v', '<C-v>', '"+p<CR>', vim.tbl_extend('force', opts, { desc = 'Paste from clipboard' }))
keymap('n', '<M-x>', '<C-x>', vim.tbl_extend('force', opts, { desc = 'Remove 1 to cursor num' }))
keymap('n', '<C-x>', '"+x<CR>', vim.tbl_extend('force', opts, { desc = 'Cut to clipboard' }))
keymap('n', '<M-a>', '<C-a>', vim.tbl_extend('force', opts, { desc = 'Add 1 to cursor num' }))
keymap('n', '<C-a>', 'ggVG<CR>', vim.tbl_extend('force', opts, { desc = 'Select all text in the buffer' }))
keymap('i', '<M-x>', '<Esc><C-x>', vim.tbl_extend('force', opts, { desc = 'Remove 1 to cursor num' }))
keymap('i', '<C-x>', '<Esc>"+x<CR>', vim.tbl_extend('force', opts, { desc = 'Cut to clipboard' }))
keymap('i', '<M-a>', '<Esc><C-a>', vim.tbl_extend('force', opts, { desc = 'Add 1 to cursor num' }))
keymap('i', '<C-a>', '<Esc>ggVG<CR>', vim.tbl_extend('force', opts, { desc = 'Select all text in the buffer' }))
keymap('v', '<M-x>', '<C-x>', vim.tbl_extend('force', opts, { desc = 'Remove 1 to cursor num' }))
keymap('v', '<C-x>', '"+x<CR>', vim.tbl_extend('force', opts, { desc = 'Cut to clipboard' }))
keymap('v', '<M-a>', '<C-a>', vim.tbl_extend('force', opts, { desc = 'Add 1 to cursor num' }))
keymap('v', '<C-a>', 'ggVG<CR>', vim.tbl_extend('force', opts, { desc = 'Select all text in the buffer' }))
keymap('n', '<M-z>', '<C-z>', vim.tbl_extend('force', opts, { desc = 'suspend' }))
keymap('i', '<M-z>', '<Esc><C-z>', vim.tbl_extend('force', opts, { desc = 'suspend' }))
keymap('n', '<C-z>', 'u<CR>', vim.tbl_extend('force', opts, { desc = 'Undo changes' }))
keymap('i', '<C-z>', '<Esc>u<CR>', vim.tbl_extend('force', opts, { desc = 'Undo changes' }))
keymap('n', '<M-e>', '<C-e>', vim.tbl_extend('force', opts, { desc = 'scroll line up' }))
keymap('n', '<M-y>', '<C-y>', vim.tbl_extend('force', opts, { desc = 'scroll line down' }))
keymap('i', '<M-y>', '<Esc><C-y>', vim.tbl_extend('force', opts, { desc = 'scroll line down' }))
keymap('n', '<C-y>', '<C-r><CR>', vim.tbl_extend('force', opts, { desc = 'Redo changes' }))
keymap('i', '<C-y>', '<Esc><C-r><CR>', vim.tbl_extend('force', opts, { desc = 'Redo changes' }))  
keymap('n', '<C-S>', ':lua savefile()<CR>', vim.tbl_extend('force', opts, { desc = 'Save the file' }))
keymap('i', '<C-S>', '<Esc>:lua savefile()<CR>a', vim.tbl_extend('force', opts, { desc = 'Save the file' }))
keymap('n', '<Leader>sw', ':silent w !pkexec tee % >/dev/null<CR>:edit!<CR>', vim.tbl_extend('force', opts, { desc = 'Sudo Write' }))
keymap('x', '<Tab>', '>gv',  vim.tbl_extend('force', opts, { desc = 'Ident selection' }))
keymap('x', '<S-Tab>', '<gv',  vim.tbl_extend('force', opts, { desc = 'Unident selection' }))

----------------------- Terminal keymaps ---------------------
keymap('n', '<leader>tb', ':terminal<CR>:startinsert<CR>', vim.tbl_extend('force', opts, { desc = 'Open terminal buffer' }))
keymap('t', '<C-q>', '<C-\\><C-n>', vim.tbl_extend('force', opts, { desc = 'Exit terminal mode' })) 

---------------------------- Trouble -------------------------
keymap('n', '<leader>ldt', ':TroubleToggle<CR>', vim.tbl_extend('force', opts, { desc = 'Open Trouble' }))

--------------------------- Comments -------------------------
keymap('n', 'gt', ':TodoTelescope<CR>', vim.tbl_extend('force', opts, { desc = 'Open Todo' }))

----------------------------- Utils --------------------------
keymap("n", "<leader>tl", "<Cmd>call ToggleLineNumbers()<CR>", vim.tbl_extend('force', opts, { desc = 'Toggle Line' }))
keymap("n", "<leader>tw", "<Cmd>call ToggleWrap()<CR>", vim.tbl_extend('force', opts, { desc = 'Toggle Wrap' }))

-------------------- Better window navigation ------------------
keymap("i", "<c-h>", "<c-w>h", vim.tbl_extend('force', opts, { desc = 'Window left' }))
keymap("i", "<c-l>", "<c-w>l", vim.tbl_extend('force', opts, { desc = 'Window right' }))
keymap("i", "<c-j>", "<c-w>j", vim.tbl_extend('force', opts, { desc = 'Window down' }))
keymap("i", "<c-k>", "<c-w>k", vim.tbl_extend('force', opts, { desc = 'Window up' }))

--------------------- Window management -------------------------
keymap("n", "<leader>wv", ":split<CR>", vim.tbl_extend('force', opts, { desc = 'Split window vertical' }))
keymap("n", "<leader>wh", ":vsplit<CR>", vim.tbl_extend('force', opts, { desc = 'Split window horizontal' }))
keymap("n", "<leader>wc", ":close<CR>", vim.tbl_extend('force', opts, { desc = 'Close window' }))
keymap("n", "<leader>ww", "<C-W>w<CR>", vim.tbl_extend('force', opts, { desc = 'Switch window' }))
keymap('n', '<leader>wd', ":bd<CR>", vim.tbl_extend('force', opts, { desc = 'Delete buffer' }))

-------------------- Navigate buffers --------------------------
--keymap("n", "<S-l>", ":bnext<CR>", opts)
--keymap("n", "<S-h>", ":bprevious<CR>", opts)
--keymap("n", "<S-l>", ":BufferLineCycleNext<CR>", vim.tbl_extend('force', opts, { desc = 'Next buffer' }))
--keymap("n", "<S-h>", ":BufferLineCyclePrev<CR>", vim.tbl_extend('force', opts, { desc = 'Prev buffer' }))
--keymap("n", "<A-S-l>", ":BufferLineMoveNext<CR>", vim.tbl_extend('force', opts, { desc = 'Move buffer next' }))
--keymap("n", "<A-S-h>", ":BufferLineMovePrev<CR>", vim.tbl_extend('force', opts, { desc = 'Move buffer prev' }))

-------------------- Press jk fast to enter --------------------
--keymap("i", "jk", "<ESC>", opts)
--keymap("i", "Jk", "<ESC>", opts)
--keymap("i", "jK", "<ESC>", opts)
--keymap("i", "JK", "<ESC>", opts)

-------------------- Stay in indent mode ------------------------
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "p", '"_dP', opts)

-------------------- Resize windows ----------------------------
keymap("n", "<A-C-j>", ":resize +1<CR>", opts)
keymap("n", "<A-C-k>", ":resize -1<CR>", opts)
keymap("n", "<A-C-h>", ":vertical resize +1<CR>", opts)
keymap("n", "<A-C-l>", ":vertical resize -1<CR>", opts)

-------------------- Move text up/ down ------------------------
-- Visual --
keymap("v", "<A-S-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-S-k>", ":m .-2<CR>==", opts)
-- Block --
-- keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
-- keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-S-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-S-k>", ":move '<-2<CR>gv-gv", opts)
-- Normal --
keymap("n", "<A-S-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-S-k>", ":m .-2<CR>==", opts)
-- Insert --
keymap("i", "<A-S-j>", "<ESC>:m .+1<CR>==gi", opts)
keymap("i", "<A-S-k>", "<ESC>:m .-2<CR>==gi", opts)

-------------------- No highlight ------------------------------
keymap("n", ";", ":noh<CR>", opts)

-------------------- Go to buffer quickly ----------------------
keymap("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 1' }))
keymap("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 2' }))
keymap("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 3' }))
keymap("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 4' }))
keymap("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 5' }))
keymap("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 6' }))
keymap("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 7' }))
keymap("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 8' }))
keymap("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", vim.tbl_extend('force', opts, { desc = 'GoToBuffer 9' }))

-------------------- split window ------------------------------
keymap("n", "<leader>\\", ":vsplit<CR>", vim.tbl_extend('force', opts, { desc = 'Vertical split' }))
keymap("n", "<leader>/", ":split<CR>", vim.tbl_extend('force', opts, { desc = 'Horizontal split' }))

-------------------- Switch two windows ------------------------
keymap("n", "<A-o>", "<C-w>r", opts)

-------------------- Compile --------------------------------
keymap("n", "<c-m-n>", "<cmd>only | Compile<CR>", vim.tbl_extend('force', opts, { desc = 'Compile' }))

-------------------- Inspect --------------------------------
keymap("n", "<F2>", "<cmd>Inspect<CR>", vim.tbl_extend('force', opts, { desc = 'Inspect' }))

-------------------- Fuzzy Search --------------------------------
vim.keymap.set("n", "<C-f>", function()
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes"))
end, { desc = "Fuzzy find current buffer" })
vim.keymap.set("v", "<C-f>", function()
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes"))
end, { desc = "Fuzzy find current buffer" })

keymap('n', '<C-T>', ':Telescope<CR>', vim.tbl_extend('force', opts, { desc = 'Telescope menus' }))
keymap('n', '<leader>hm', ':Telescope<CR>', vim.tbl_extend('force', opts, { desc = 'Telescope menus' }))

-------------------- Color Picker --------------------------------              
vim.keymap.set("n", "<M-p>", "<cmd>PickColor<cr>", opts)
vim.keymap.set("i", "<M-p>", "<cmd>PickColor<cr>", opts)
-- vim.keymap.set("n", "r", "<cmd>ConvertHEXandRGB<cr>", opts)
-- vim.keymap.set("n", "h", "<cmd>ConvertHEXandHSL<cr>", opts)
require("color-picker").setup({ -- for changing icons & mappings
	-- ["icons"] = { "ﱢ", "" },
	-- ["icons"] = { "ﮊ", "" },
	-- ["icons"] = { "", "ﰕ" },
	-- ["icons"] = { "", "" },
	-- ["icons"] = { "", "" },
	["icons"] = { "ﱢ", "" },
	["border"] = "rounded", -- none | single | double | rounded | solid | shadow
	["keymap"] = { -- mapping example:
		["-"] = "<Plug>ColorPickerSlider5Decrease",
		["+"] = "<Plug>ColorPickerSlider5Increase",
	},
	["background_highlight_group"] = "Normal", -- default
	["border_highlight_group"] = "FloatBorder", -- default
  ["text_highlight_group"] = "Normal", --default
})

vim.cmd([[hi FloatBorder guibg=NONE]]) -- if you don't want weird border background colors around the popup.
