-- Updated to use nvim_set_keymap with desc option
local opts = { noremap = true, silent = true }

-- Shorten function name
local keymap = vim.keymap.set

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

------------------------ Editor keymaps ----------------------
keymap('n', '<C-c>', '"+y<CR>', { noremap = true, silent = true, desc = 'Copy to clipboard' })
keymap('i', '<C-c>', '<Esc>"+y<CR>', { noremap = true, silent = true, desc = 'Copy to clipboard' })
keymap('v', '<C-c>', '"+y<CR>', { noremap = true, silent = true, desc = 'Copy to clipboard' })
keymap('n', '<M-v>', '<C-v>', { noremap = true, silent = true, desc = 'Visual block selection' })
keymap('n', '<C-v>', '"+p<CR>', { noremap = true, silent = true, desc = 'Paste from clipboard' })
keymap('i', '<M-v>', '<Esc><C-v>', { noremap = true, silent = true, desc = 'Visual block selection' })
keymap('i', '<C-v>', '<Esc>"+p<CR>', { noremap = true, silent = true, desc = 'Paste from clipboard' })
keymap('v', '<M-v>', '<C-v>', { noremap = true, silent = true, desc = 'Visual block selection' })
keymap('v', '<C-v>', '"+p<CR>', { noremap = true, silent = true, desc = 'Paste from clipboard' })
keymap('n', '<M-x>', '<C-x>', { noremap = true, silent = true, desc = 'Remove 1 to cursor num' })
keymap('n', '<C-x>', '"+x<CR>', { noremap = true, silent = true, desc = 'Cut to clipboard' })
keymap('n', '<M-a>', '<C-a>', { noremap = true, silent = true, desc = 'Add 1 to cursor num' })
keymap('n', '<C-a>', 'ggVG<CR>', { noremap = true, silent = true, desc = 'Select all text in the buffer' })
keymap('i', '<M-x>', '<Esc><C-x>', { noremap = true, silent = true, desc = 'Remove 1 to cursor num' })
keymap('i', '<C-x>', '<Esc>"+x<CR>', { noremap = true, silent = true, desc = 'Cut to clipboard' })
keymap('i', '<M-a>', '<Esc><C-a>', { noremap = true, silent = true, desc = 'Add 1 to cursor num' })
keymap('i', '<C-a>', '<Esc>ggVG<CR>', { noremap = true, silent = true, desc = 'Select all text in the buffer' })
keymap('v', '<M-x>', '<C-x>', { noremap = true, silent = true, desc = 'Remove 1 to cursor num' })
keymap('v', '<C-x>', '"+x<CR>', { noremap = true, silent = true, desc = 'Cut to clipboard' })
keymap('v', '<M-a>', '<C-a>', { noremap = true, silent = true, desc = 'Add 1 to cursor num' })
keymap('v', '<C-a>', 'ggVG<CR>', { noremap = true, silent = true, desc = 'Select all text in the buffer' })
keymap('n', '<M-z>', '<C-z>', { noremap = true, silent = true, desc = 'suspend' })
keymap('i', '<M-z>', '<Esc><C-z>', { noremap = true, silent = true, desc = 'suspend' })
keymap('n', '<C-z>', 'u<CR>', { noremap = true, silent = true, desc = 'Undo changes' })
keymap('i', '<C-z>', '<Esc>u<CR>', { noremap = true, silent = true, desc = 'Undo changes' })
keymap('n', '<M-e>', '<C-e>', { noremap = true, silent = true, desc = 'scroll line up' })
keymap('n', '<M-y>', '<C-y>', { noremap = true, silent = true, desc = 'scroll line down' })
keymap('i', '<M-y>', '<Esc><C-y>', { noremap = true, silent = true, desc = 'scroll line down' })
keymap('n', '<C-y>', '<C-r><CR>', { noremap = true, silent = true, desc = 'Redo changes' })
keymap('i', '<C-y>', '<Esc><C-r><CR>', { noremap = true, silent = true, desc = 'Redo changes' })  
keymap('n', '<C-S>', ':lua savefile()<CR>', { noremap = true, silent = true, desc = 'Save the file' })
keymap('i', '<C-S>', '<Esc>:lua savefile()<CR>a', { noremap = true, silent = true, desc = 'Save the file' })
keymap('n', '<Leader>sw', ':silent w !pkexec tee % >/dev/null<CR>:edit!<CR>', { noremap = true, silent = true, desc = 'Sudo Write' })
keymap('x', '<Tab>', '>gv', { noremap = true, silent = true, desc = 'Ident selection' })
keymap('x', '<S-Tab>', '<gv', { noremap = true, silent = true, desc = 'Unident selection' })

----------------------- Terminal keymaps ---------------------
keymap('n', '<leader>tb', ':terminal<CR>:startinsert<CR>', { noremap = true, silent = true, desc = 'Open terminal buffer' })
keymap('t', '<C-q>', '<C-\\><C-n>', { noremap = true, silent = true, desc = 'Exit terminal mode' }) 

---------------------------- Trouble -------------------------
keymap('n', '<leader>ldt', ':TroubleToggle<CR>', { noremap = true, silent = true, desc = 'Open Trouble' })

--------------------------- Comments -------------------------
keymap('n', 'gt', ':TodoTelescope<CR>', { noremap = true, silent = true, desc = 'Open Todo' })

----------------------------- Utils --------------------------
keymap("n", "<leader>tl", "<Cmd>call ToggleLineNumbers()<CR>", { noremap = true, silent = true, desc = 'Toggle Line' })
keymap("n", "<leader>tw", "<Cmd>call ToggleWrap()<CR>", { noremap = true, silent = true, desc = 'Toggle Wrap' })

-------------------- Better window navigation ------------------
keymap("i", "<c-h>", "<c-w>h", { noremap = true, silent = true, desc = 'Window left' })
keymap("i", "<c-l>", "<c-w>l", { noremap = true, silent = true, desc = 'Window right' })
keymap("i", "<c-j>", "<c-w>j", { noremap = true, silent = true, desc = 'Window down' })
keymap("i", "<c-k>", "<c-w>k", { noremap = true, silent = true, desc = 'Window up' })

--------------------- Window management -------------------------
keymap("n", "<leader>wv", ":split<CR>", { noremap = true, silent = true, desc = 'Split window vertical' })
keymap("n", "<leader>wh", ":vsplit<CR>", { noremap = true, silent = true, desc = 'Split window horizontal' })
keymap("n", "<leader>wc", ":close<CR>", { noremap = true, silent = true, desc = 'Close window' })
keymap("n", "<leader>ww", "<C-W>w<CR>", { noremap = true, silent = true, desc = 'Switch window' })
keymap('n', '<leader>wd', ":bd<CR>", { noremap = true, silent = true, desc = 'Delete buffer' })

-------------------- Navigate buffers --------------------------
--keymap("n", "<S-l>", ":bnext<CR>", { noremap = true, silent = true })
--keymap("n", "<S-h>", ":bprevious<CR>", { noremap = true, silent = true })
--keymap("n", "<S-l>", ":BufferLineCycleNext<CR>", { noremap = true, silent = true, desc = 'Next buffer' })
--keymap("n", "<S-h>", ":BufferLineCyclePrev<CR>", { noremap = true, silent = true, desc = 'Prev buffer' })
--keymap("n", "<A-S-l>", ":BufferLineMoveNext<CR>", { noremap = true, silent = true, desc = 'Move buffer next' })
--keymap("n", "<A-S-h>", ":BufferLineMovePrev<CR>", { noremap = true, silent = true, desc = 'Move buffer prev' })

-------------------- Press jk fast to enter --------------------
--keymap("i", "jk", "<ESC>", { noremap = true, silent = true })
--keymap("i", "Jk", "<ESC>", { noremap = true, silent = true })
--keymap("i", "jK", "<ESC>", { noremap = true, silent = true })
--keymap("i", "JK", "<ESC>", { noremap = true, silent = true })

-------------------- Stay in indent mode ------------------------
keymap("v", "<", "<gv", { noremap = true, silent = true })
keymap("v", ">", ">gv", { noremap = true, silent = true })
keymap("v", "p", '"_dP', { noremap = true, silent = true })

-------------------- Resize windows ----------------------------
keymap("n", "<A-C-j>", ":resize +1<CR>", { noremap = true, silent = true })
keymap("n", "<A-C-k>", ":resize -1<CR>", { noremap = true, silent = true })
keymap("n", "<A-C-h>", ":vertical resize +1<CR>", { noremap = true, silent = true })
keymap("n", "<A-C-l>", ":vertical resize -1<CR>", { noremap = true, silent = true })

-------------------- Move text up/ down ------------------------
-- Visual --
keymap("v", "<A-S-j>", ":m .+1<CR>==", { noremap = true, silent = true })
keymap("v", "<A-S-k>", ":m .-2<CR>==", { noremap = true, silent = true })
-- Block --
-- keymap("x", "J", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })
-- keymap("x", "K", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
keymap("x", "<A-S-j>", ":move '>+1<CR>gv-gv", { noremap = true, silent = true })
keymap("x", "<A-S-k>", ":move '<-2<CR>gv-gv", { noremap = true, silent = true })
-- Normal --
keymap("n", "<A-S-j>", ":m .+1<CR>==", { noremap = true, silent = true })
keymap("n", "<A-S-k>", ":m .-2<CR>==", { noremap = true, silent = true })
-- Insert --
keymap("i", "<A-S-j>", "<ESC>:m .+1<CR>==gi", { noremap = true, silent = true })
keymap("i", "<A-S-k>", "<ESC>:m .-2<CR>==gi", { noremap = true, silent = true })

-------------------- No highlight ------------------------------
keymap("n", ";", ":noh<CR>", { noremap = true, silent = true })

-------------------- Go to buffer quickly ----------------------
keymap("n", "<leader>1", "<Cmd>BufferLineGoToBuffer 1<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 1' })
keymap("n", "<leader>2", "<Cmd>BufferLineGoToBuffer 2<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 2' })
keymap("n", "<leader>3", "<Cmd>BufferLineGoToBuffer 3<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 3' })
keymap("n", "<leader>4", "<Cmd>BufferLineGoToBuffer 4<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 4' })
keymap("n", "<leader>5", "<Cmd>BufferLineGoToBuffer 5<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 5' })
keymap("n", "<leader>6", "<Cmd>BufferLineGoToBuffer 6<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 6' })
keymap("n", "<leader>7", "<Cmd>BufferLineGoToBuffer 7<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 7' })
keymap("n", "<leader>8", "<Cmd>BufferLineGoToBuffer 8<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 8' })
keymap("n", "<leader>9", "<Cmd>BufferLineGoToBuffer 9<CR>", { noremap = true, silent = true, desc = 'GoToBuffer 9' })

-------------------- split window ------------------------------
keymap("n", "<leader>\\", ":vsplit<CR>", { noremap = true, silent = true, desc = 'Vertical split' })
keymap("n", "<leader>/", ":split<CR>", { noremap = true, silent = true, desc = 'Horizontal split' })

-------------------- Switch two windows ------------------------
keymap("n", "<A-o>", "<C-w>r", { noremap = true, silent = true })

-------------------- Compile --------------------------------
keymap("n", "<c-m-n>", "<cmd>only | Compile<CR>", { noremap = true, silent = true, desc = 'Compile' })

-------------------- Inspect --------------------------------
keymap("n", "<F2>", "<cmd>Inspect<CR>", { noremap = true, silent = true, desc = 'Inspect' })

-------------------- Fuzzy Search --------------------------------
keymap('n', '<C-T>', ':Telescope<CR>', { noremap = true, silent = true, desc = 'Telescope menus' })
keymap('n', '<leader>hm', ':Telescope<CR>', { noremap = true, silent = true, desc = 'Telescope menus' })

-------------------- Color Picker --------------------------------              
vim.keymap.set("n", "<M-p>", "<cmd>PickColor<cr>", { noremap = true, silent = true })
vim.keymap.set("i", "<M-p>", "<cmd>PickColor<cr>", { noremap = true, silent = true })
-- vim.keymap.set("n", "r", "<cmd>ConvertHEXandRGB<cr>", { noremap = true, silent = true })
-- vim.keymap.set("n", "h", "<cmd>ConvertHEXandHSL<cr>", { noremap = true, silent = true })
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
