return {
  { -- provides Snippets pack
    "L3MON4D3/LuaSnip",
    dependencies = {
      "rafamadriz/friendly-snippets",
      config = function()
        require("luasnip.loaders.from_vscode").lazy_load()
        require("luasnip.loaders.from_snipmate").lazy_load()
      end,
    },
    opts = {
      history = true,
      delete_check_events = "TextChanged",
    },
    -- stylua: ignore
    keys = {
      {
        "<tab>",
        function()
          return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
        end,
        expr = true,
        silent = true,
        mode = "i",
      },
      {
        "<tab>",
        function()
          require("luasnip").jump(1)
        end,
        mode = "s",
      },
      {
        "<s-tab>",
        function()
          require("luasnip").jump(-1)
        end,
        mode = { "i", "s" },
      },
    },
  },
  { -- provides Lua nvim snippets
    "folke/neodev.nvim", 
    config = function()
      require("neodev").setup({})
    end
  },
  { -- provides support for expanding abbreviations
    "mattn/emmet-vim",
    event = { "BufRead", "BufNewFile" },
    init = function()
      vim.g.user_emmet_leader_key = "f"
      vim.g.user_emmet_mode = "n"
      vim.g.user_emmet_settings = {
        variables = { lang = "ja" },
        javascript = {
          extends = "jsx",
        },
        html = {
          default_attributes = {
            option = { value = nil }, -- Changed vim.null to nil
            textarea = {
              id = nil, -- Changed vim.null to nil
              name = nil, -- Changed vim.null to nil
              cols = 10,
              rows = 10,
            },
          },
          snippets = {
            ["!"] = "<!DOCTYPE html>\n"
              .. '<html lang="en">\n'
              .. "<head>\n"
              .. '\t<meta charset="${charset}">\n'
              .. '\t<meta name="viewport" content="width=device-width, initial-scale=1.0">\n'
              .. '\t<meta http-equiv="X-UA-Compatible" content="ie=edge">\n'
              .. "\t<title></title>\n"
              .. "</head>\n"
              .. "<body>\n\t${child}|\n</body>\n"
              .. "</html>",
          },
        },
      }
    end,
  },
  { -- provides completion
    "hrsh7th/nvim-cmp",
    version = false,
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
    },
    opts = function()
      local cmp = require("cmp")
      local defaults = require("cmp.config.default")()
      
      -- Set up cmdline completions
      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
      
      -- Java-specific configuration
      cmp.setup.filetype("java", {
        sources = cmp.config.sources({
          { name = "nvim_lsp", priority = 1000, max_item_count = 20, entry_filter = function(entry) return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind() end },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500, keyword_length = 3 },
          { name = "path", priority = 250 },
        })
      })
      
      -- Main configuration
      return {
        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-j>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-k>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<S-Tab>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-Esc>"] = cmp.mapping(function(fallback)
            require("luasnip").unlink_current()
            fallback()
          end),
        }),
        sources = cmp.config.sources({
          { name = "codeium", priority = 1200 },
          { name = "nvim_lsp", priority = 1000, max_item_count = 20, entry_filter = function(entry) return require("cmp").lsp.CompletionItemKind.Text ~= entry:get_kind() end },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500, keyword_length = 3 },
          { name = "path", priority = 250 },
        }),
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item)
            item.menu = ({
              codeium = "Codeium",
              nvim_lsp = item.kind,
              luasnip = "Snippet",
              buffer = "Buffer",
              path = "Path",
            })[entry.source.name]
            
            -- Safely require icons
            local ok, icons = pcall(require, "custom.icons")
            if ok and icons.kinds[item.kind] then
              item.kind = icons.kinds[item.kind]
            end
            
            if entry.source.name == "codeium" and ok and icons.misc and icons.misc.codeium then
              item.kind = icons.misc.codeium
              item.kind_hl_group = "CmpItemKindVariable"
            end
            
            return item
          end,
        },
        experimental = { ghost_text = true },
        sorting = defaults.sorting,
      }
    end,
  },
  { -- provides autopair "closing brackets/comments etc.."
    "echasnovski/mini.pairs",
    event = "VeryLazy",
    config = function(_, opts)
      require("mini.pairs").setup(opts)
    end,
  },
  { -- provides Indentation folder
    'Wansmer/treesj',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      vim.keymap.set('n', '<leader>j', function() require('treesj').toggle() end, {desc = 'Treesitter Toggle Join'})
      vim.keymap.set('n', '<leader>J', function() require('treesj').toggle({ split = { recursive = true } }) end, {desc = 'Treesitter Toggle Join Recursive'})
      
      -- Safe loading of langs variable
      local langs = nil
      pcall(function()
        langs = require("treesj.langs")
      end)
      
      require('treesj').setup({
        use_default_keymaps = false,
        check_syntax_error = true,
        max_join_length = 1500,
        cursor_behavior = 'hold', -- hold|start|end:
        notify = true,
        langs = langs,
        dot_repeat = true,
      })
    end,
  },
  { -- provides comments toggle
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = true 
  },
  { -- provides comments view
    "echasnovski/mini.comment",
    event = "VeryLazy",
    opts = {
      options = {
        custom_commentstring = function()
          return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo.commentstring
        end,
      },
    },
  },
  { -- provides function signature when you type
    "ray-x/lsp_signature.nvim",
    event = { "InsertEnter" },
    opts = {
      floating_window = false, -- show hint in a floating window, set to false for virtual text only mode
      floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
      hint_scheme = "Comment", -- highlight group for the virtual text
      hint_prefix = "󰨽 ",
    },
  },
  { -- provides regex explains
    'bennypowers/nvim-regexplainer',
    dependencies = { -- Changed requires to dependencies
      'nvim-treesitter/nvim-treesitter',
      'MunifTanjim/nui.nvim',
    },
    config = function() 
      require'regexplainer'.setup {
        mode = 'narrative', -- TODO: 'ascii', 'graphical'
        auto = false, -- automatically show the explainer when the cursor enters a regexp
        filetypes = {
          'html',
          'js',
          'cjs',
          'mjs',
          'ts',
          'jsx',
          'tsx',
          'cjsx',
          'mjsx',
        },
        debug = false, 
        display = 'popup', -- 'split', 'popup'
        mappings = {
          -- toggle = 'gR',
          -- show = 'gS',
          -- hide = 'gH',
          -- show_split = 'gP',
          -- show_popup = 'gU',
        },
        narrative = {
          separator = '\n',
        },
      } 
    end,
  }
}