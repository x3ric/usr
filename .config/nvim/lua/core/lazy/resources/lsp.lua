-- lsp.lua: Neovim LSP and Mason configuration
return {
  -- LSP enhancements
  {
    "glepnir/lspsaga.nvim",
    lazy = true,
    config = function()
      require('lspsaga').setup({})
    end,
  },

  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      floating_window = false,
      floating_window_above_cur_line = true,
      hint_scheme = 'Comment',
    },
  },

  -- Core LSP configuration + Mason
  {
    "neovim/nvim-lspconfig",
    event = { 'BufReadPost', 'BufNewFile' },
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local lspconfig = require('lspconfig')
      local mason = require('mason')
      local mason_lsp = require('mason-lspconfig')

      -- Setup Mason
      mason.setup()
      mason_lsp.setup({
        ensure_installed = { 'lua_ls', 'html', 'pyright', 'bashls' },
        automatic_installation = true,
      })

      -- Setup capabilities (for cmp)
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local cmp_lsp_ok, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
      if cmp_lsp_ok then
        capabilities = cmp_lsp.default_capabilities(capabilities)
      end

      -- Common on_attach
      local on_attach = function(client, bufnr)
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end
        bufmap('n', '<leader>la', vim.lsp.buf.code_action, 'Code Action')
        bufmap('n', '<leader>lr', vim.lsp.buf.rename, 'Rename')
        bufmap('n', '<leader>li', '<cmd>LspInfo<cr>', 'Lsp Info')
        bufmap('n', '[d', vim.diagnostic.goto_prev, 'Prev Diagnostic')
        bufmap('n', ']d', vim.diagnostic.goto_next, 'Next Diagnostic')
        bufmap('n', '<leader>lq', vim.diagnostic.setloclist, 'Diagnostics to Quickfix')

        -- Enable inlay hints if the provider is available
        if client.server_capabilities and client.server_capabilities.inlayHintProvider and type(vim.lsp.inlay_hint) == 'function' then
          pcall(vim.lsp.inlay_hint, bufnr, true)
        end
      end

      -- Default diagnostic settings
      vim.diagnostic.config({
        virtual_text = { prefix = '●', spacing = 4 },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })

      -- Manually configure each server
      local servers = { 'lua_ls', 'html', 'pyright', 'bashls' }
      for _, server in ipairs(servers) do
        local opts = { on_attach = on_attach, capabilities = capabilities }
        if server == 'lua_ls' then
          opts.settings = {
            Lua = {
              diagnostics = { globals = { 'vim' } },
              workspace = { checkThirdParty = false },
              format = { enable = false },
            },
          }
        end
        lspconfig[server].setup(opts)
      end
    end,
  },

  -- Mason UI
  {
    'williamboman/mason.nvim',
    cmd = 'Mason',
  },

  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = 'BufWritePre',
    opts = { formatters_by_ft = { lua = { 'stylua' }, markdown = { 'markdownlint' } } },
    config = function(_, opts) require('conform').setup(opts) end,
  },

  -- Linting
  {
    'mfussenegger/nvim-lint',
    event = 'BufWritePost',
    config = function()
      require('lint').linters_by_ft = { python = { 'flake8' } }
      vim.api.nvim_create_autocmd({ 'BufWritePost' }, { callback = require('lint').try_lint })
    end,
  },
}
