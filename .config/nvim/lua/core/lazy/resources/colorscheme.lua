return {
--[[ delte line 2 and 90 to get more themes
    { -- Tokyonight themes
      "folke/tokyonight.nvim",
      lazy = false,
      opts = { style = "moon" },
    },
    { -- Catppuccin themes
      "catppuccin/nvim",
      lazy = false,
      name = "catppuccin",
      opts = {
        integrations = {
          alpha = true,
          cmp = true,
          gitsigns = true,
          illuminate = true,
          indent_blankline = { enabled = true },
          lsp_trouble = true,
          mason = true,
          mini = true,
          native_lsp = {
            enabled = true,
            underlines = {
              errors = { "undercurl" },
              hints = { "undercurl" },
              warnings = { "undercurl" },
              information = { "undercurl" },
            },
          },
          navic = { enabled = true, custom_bg = "lualine" },
          neotest = true,
          noice = true,
          notify = true,
          neotree = true,
          semantic_tokens = true,
          telescope = true,
          treesitter = true,
          which_key = true,
        },
      },
    },
    { -- Tokyonight themes
      "loctvl842/monokai-pro.nvim",
      lazy = false,
      priority = 1000,
      --keys = { { "<leader>c", "<cmd>MonokaiProSelect<cr>", desc = "Select Moonokai pro filter" } },
      config = function()
        local monokai = require("monokai-pro")
        monokai.setup({
          transparent_background = false,
          devicons = true,
          filter = "pro", -- classic | octagon | pro | machine | ristretto | spectrum
          day_night = {
            enable = false,
          day_filter = "pro",
          night_filter = "spectrum",
          },
          inc_search = "background", -- underline | background
        background_clear = { "nvim-tree", "neo-tree", "bufferline" },
          plugins = {
            bufferline = {
              underline_selected = true,
              underline_visible = false,
            underline_fill = true,
              bold = false,
            },
            indent_blankline = {
              context_highlight = "pro", -- default | pro
              context_start_underline = true,
            },
          },
          override = function(c)
            return {
              ColorColumn = { bg = c.editor.background },
              -- Mine
              DashboardRecent = { fg = c.base.magenta },
              DashboardProject = { fg = c.base.blue },
              DashboardConfiguration = { fg = c.base.white },
              DashboardSession = { fg = c.base.green },
              DashboardLazy = { fg = c.base.cyan },
              DashboardServer = { fg = c.base.yellow },
              DashboardQuit = { fg = c.base.red },
            }
          end,
        })
        monokai.load()
      end,
    },
--]]
  }
