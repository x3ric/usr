return {
  { -- toggle term lf to use it in neovim "l"/"RightArrow" to open the file in neovim
    "lmburns/lf.nvim",
      config = function()
          vim.g.lf_netrw = 1
          require("lf").setup({
            default_cmd = "lf", -- default `lf` command
            default_action = "edit", -- default action when `Lf` opens a file
            default_actions = { -- default action keybindings
              ["<C-t>"] = "tabedit",
              ["<C-x>"] = "split",
              ["<C-v>"] = "vsplit",
              ["<C-o>"] = "tab drop",
            },
            winblend = 10, -- psuedotransparency level
            dir = "", -- directory where `lf` starts ('gwd' is git-working-directory, ""/nil is CWD)
            direction = "float", -- window type: float horizontal vertical
            border = "single", -- border kind: single double shadow curved
            escape_quit = true,
            focus_on_open = true,
            mappings = true,
            tmux = false,
          })
          vim.keymap.set("n", "<leader>lf", "<cmd>lua require('lf').start()<CR>" , vim.tbl_extend('force', {noremap = true}, { desc = 'Lf file manager' }))
      end,
      requires = {"plenary.nvim", "toggleterm.nvim"}
  },
  --[[{ -- ranger alternative "ranger" needed
    "kevinhwang91/rnvimr",
    event = { "BufReadPost" },
    keys = { { "<leader>r", "<cmd>RnvimrToggle<cr>", desc = "Open file manager" } },
    init = function()
      -- Make Ranger to be hidden after picking a file
      vim.g.rnvimr_enable_picker = 1
      -- Change the border's color
      -- vim.g.rnvimr_border_attr = { fg = 31, bg = -1 }
      vim.g.rnvimr_border_attr = { fg = 3, bg = -1 }
      -- Draw border with both
      -- vim.g.rnvimr_ranger_cmd = { "ranger", "--cmd=set draw_borders both" }
      -- Add a shadow window, value is equal to 100 will disable shadow
      vim.g.rnvimr_shadow_winblend = 90
    end,
  },--]]
  { -- multiline cursor
    "mg979/vim-visual-multi",
    event = { "BufReadPost", "BufNewFile" },
  },
  --[[{ -- :Glow to have markdown preview
    "ellisonleao/glow.nvim", 
    config = function()
      require("glow").setup({
        style = "dark",
        width = 130,
        height = 150,
      })
    end
  },--]]
  --[[{ -- ctags switcher needed ctags "sudo pacman -Sy ctags" to install
    "preservim/tagbar",
    --sudp pacman -Sy ctags
    event = { "BufReadPost", "BufNewFile" },
    keys = { { "<leader>cb", "<cmd>TagbarToggle<CR>", desc = "Open TagBar" } },
  },--]]
   -- {
   -- "iamcco/markdown-preview.nvim",
   -- cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
   -- build = "cd app && yarn install",
   -- keys = {
   --   {
   --     "<leader>p",
   --     function()
   --       vim.cmd([[MarkdownPreviewToggle]])
   --     end,
   --     desc = "Peek (Markdown Preview)",
   --   },
   -- },
   -- init = function()
   --   vim.g.mkdp_filetypes = { "markdown" }
   -- end,
   -- ft = { "markdown" },
   --},
  { -- buffers close without messing up your layout.
    "moll/vim-bbye",
    event = { "BufRead" },
    keys = { { "<leader>d", "<cmd>Bdelete!<cr>", desc = "Close Buffer" } },
  },
  { -- session manager  "last session opener"
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      options = { "buffers", "curdir", "tabpages", "winsize", "help", "blank", "terminal", "folds", "tabpages" },
    },
    keys = {
      {
        "<leader>ss",
        function()
          require("persistence").load()
        end,
        desc = "Restore Session",
      },
      {
        "<leader>sl",
        function()
          require("persistence").load({ last = true })
        end,
        desc = "Restore Last Session",
      },
      {
        "<leader>sd",
        function()
          require("persistence").stop()
        end,
        desc = "Don't Save Current Session",
      },
    },
  },
  { -- switch virtual environment in python
    "AckslD/swenv.nvim",
    config = function()
      require("swenv").setup({
        post_set_venv = function()
          vim.cmd([[LspRestart]])
        end,
      })
    end,
  },
}
