local Util = require("plugins.resources.util")
local Icons = require("custom.icons")

local config = {
  enable_git_status = false,
  enable_diagnostics = true,
  close_if_last_window = true, -- Close Neo-tree if it is the last window left in the tab
  popup_border_style = Util.generate_borderchars("thick", "tl-t-tr-r-bl-b-br-l"),
  sources = {
    "filesystem",
    "buffers",
    "git_status",
    "diagnostics",
    --"document_symbols",
  },
  source_selector = {
    winbar = true, -- toggle to show selector on winbar
    content_layout = "center",
    tabs_layout = "equal",
    show_separator_on_edge = true,
    sources = {
      { source = "filesystem", display_name = "󰉓" },
      { source = "buffers", display_name = "󰈙" },
      { source = "git_status", display_name = "" },
      --{ source = "document_symbols", display_name = "󱎸" },
      { source = "diagnostics", display_name = "󰒡" },
    },
  },
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      -- indent guides
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      -- expander config, needed for nesting files
      with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "",
      folder_empty_open = "",
      -- The next two settings are only a fallback, if you use nvim-web-devicons and configure default icons there
      -- then these will never be used.
      default = " ",
      highlight = "NeoTreeFileIcon"
    },
    modified = { symbol = "" , highlight = "NeoTreeModified", },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
      highlight = "NeoTreeFileName",
    },
    git_status = { symbols = Icons.git },
    diagnostics = { symbols = Icons.diagnostics },
  },
  window = {
    width = 30,
    mappings = {
      ["<1-LeftMouse>"] = "open",
      ["l"] = "open",
    },
  },
  filesystem = {
    window = {
      mappings = {
        ["<esc>"] = "close_window",
        ["H"] = "navigate_up",
        ["<bs>"] = "toggle_hidden",
        ["."] = "set_root",
        ["/"] = "fuzzy_finder",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["a"] = { "add", config = { show_path = "relative" } }, -- "none", "relative", "absolute"
      },
      fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
        ["<down>"] = "move_cursor_down",
        ["<C-n>"] = "move_cursor_down",
        ["<up>"] = "move_cursor_up",
        ["<C-p>"] = "move_cursor_up",
      },
    },
    filtered_items = {
      hide_dotfiles = false,
      hide_gitignored = false,
    },
    follow_current_file = {
      enabled = true,
    }, -- This will find and focus the file in the active buffer every
    group_empty_dirs = true,
  },
  async_directory_scan = "always",
}

config.filesystem.components = require("plugins.configs.neo-tree.sources.filesystem.components")
local function hideCursor()
  vim.schedule(function()
    vim.cmd([[setlocal guicursor=n:block-Cursor]])
    vim.cmd([[hi Cursor blend=100]])
  end)
end

local function showCursor()
  vim.schedule(function()
    vim.cmd([[setlocal guicursor=n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20]])
    vim.cmd([[hi Cursor blend=0]])
  end)
end

local neotree_group = vim.api.nvim_create_augroup("neo-tree_hide_cursor", { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = "neo-tree",
  group = neotree_group,
  callback = function()
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter", "InsertEnter" }, {
      group = neotree_group,
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        local fire = vim.bo.filetype == "neo-tree" and hideCursor or showCursor
        fire()
      end,
    })
    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
      group = neotree_group,
      buffer = vim.api.nvim_get_current_buf(),
      callback = function()
        showCursor()
      end,
    })
  end,
})

return config


