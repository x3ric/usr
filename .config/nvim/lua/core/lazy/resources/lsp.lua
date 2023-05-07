return {
  { -- provides improved lsp
    "glepnir/lspsaga.nvim",
    lazy = true,
    config = function ()
      require("lspsaga").setup({})
    end
  },
  {
    "ray-x/lsp_signature.nvim",
    event = { "InsertEnter" },
    opts = {
      floating_window = false, -- show hint in a floating window, set to false for virtual text only mode
      floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
      hint_scheme = "Comment", -- highlight group for the virtual text
    },
  },
  { -- provides lsp configurations
    "neovim/nvim-lspconfig",
    branch = "master",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    keys = {
      { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
      { "<leader>li", "<cmd>LspInfo<cr>", desc = "Info" },
      { "<leader>lI", "<cmd>LspInstall<cr>", desc = "Installe lsp for current format" },
      { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", desc = "Next Diagnostic" },
      { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", desc = "Prev Diagnostic" },
      { "<leader>ll", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
      { "<leader>lq", "<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>", desc = "Quickfix" },
      { "<leader>lr", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
      { "<leader>W",
        function()
          vim.lsp.buf.format({
            filter = function(client)
              -- do not use default `lua_ls` to format
              local exclude_servers = { "lua_ls", "pyright", "pylsp" }
              return not vim.tbl_contains(exclude_servers, client.name)
            end,
          })
          vim.cmd([[w!]])
        end,
        desc = "Format and Save",
      },
      { "gf",
        function()
          vim.lsp.buf.format({
            filter = function(client)
              -- do not use default `lua_ls` to format
              local exclude_servers = { "lua_ls" }
              return not vim.tbl_contains(exclude_servers, client.name)
            end,
          })
          --vim.cmd([[w!]])
        end,
        desc = "Format text",
      },
    },
    opts = {
      servers = {
        html = {},
        lua_ls = {
          settings = {
            Lua = {
              hint = { enable = true },
              diagnostics = {
                globals = { "vim" },
              },
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                callSnippet = "Replace",
              },
              misc = {
                parameters = {
                  "--log-level=trace",
                },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      ---@type table<string, fun(client, buffer)>
      attach_handlers = {},
      capabilities = {
        textDocument = {
          foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
        },
      },
    },
    config = function(_, opts)
      local util = require("plugins.resources.util")
      -- special attach lsp
      util.on_attach(function(client, buffer)
        require("plugins.configs.lsp.navic").attach(client, buffer)
        require("plugins.configs.lsp.keymaps").attach(client, buffer)
        require("plugins.configs.lsp.gitsigns").attach(client, buffer)
      end)
     -- diagnostics
     vim.diagnostic.config(require("plugins.configs.lsp.diagnostics")["on"])

     local servers = opts.servers
     local ext_capabilites = vim.lsp.protocol.make_client_capabilities()

     -- inlay hints
     local inlay_hint = vim.lsp.buf.inlayhints or vim.lsp.inlayhints
     if vim.fn.has("nvim-0.10.0") and inlay_hint then
       util.on_attach(function(client, buffer)
         if client.supports_method("textDocument/inlayHint") then
           inlay_hint(buffer, true)
         end
       end)
     end

     local capabilities = vim.tbl_deep_extend(
       "force",
       {},
       ext_capabilites,
       require("cmp_nvim_lsp").default_capabilities(),
       opts.capabilities
     )

     local function setup(server)
       local server_opts = vim.tbl_deep_extend("force", {
         capabilities = vim.deepcopy(capabilities),
       }, servers[server] or {})

       if opts.attach_handlers[server] then
         local callback = function(client, buffer)
           if client.name == server then
             opts.attach_handlers[server](client, buffer)
           end
         end
         util.on_attach(callback)
       end
       require("lspconfig")[server].setup(server_opts)
     end

     local available = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)

     local ensure_installed = {}
     for server, server_opts in pairs(servers) do
       if server_opts then
         if not vim.tbl_contains(available, server) then
           setup(server)
         else
           ensure_installed[#ensure_installed + 1] = server
         end
       end
     end

     require("mason-lspconfig").setup({ ensure_installed = ensure_installed })
     require("mason-lspconfig").setup_handlers({ setup })
   end,
  },
  { -- mason lsp provider
    "williamboman/mason.nvim",
    cmd = "Mason",
    opts = {
      ensure_installed = {
        "stylua",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  { -- dap debugger
    "mfussenegger/nvim-dap",
    keys = {
      { "<leader>ldb", "<cmd>DapToggleBreakpoint<cr>", desc = "Add breakpoint at line" },
      { "<leader>ldr", "<cmd>DapContinue<cr>", desc = "Start or continue the debugger" },
    }
  },
  { -- mason dap module
    "jay-babu/mason-nvim-dap.nvim",
    event = "VeryLazy",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      handlers = {}
    },
  },
  { -- formatters,lspall in one provider
    "jose-elias-alvarez/null-ls.nvim",
    -- event = { "BufReadPre", "BufNewFile" },
    lazy = true,
    dependencies = { "mason.nvim" },
    root_has_file = function(files)
      return function(utils)
        return utils.root_has_file(files)
      end
    end,
    opts = function(plugin)
      local root_has_file = plugin.root_has_file
      local null_ls = require("null-ls")
      local formatting = null_ls.builtins.formatting
      local stylua_root_files = { "stylua.toml", ".stylua.toml" }
      local modifier = {
        stylua_formatting = {
          condition = root_has_file(stylua_root_files),
        },
      }
      return {
        debug = false,
        -- You can then register sources by passing a sources list into your setup function:
        -- using `with()`, which modifies a subset of the source's default options
        sources = {
          formatting.stylua.with(modifier.stylua_formatting),
          formatting.markdownlint,
          formatting.beautysh.with({ extra_args = { "--indent-size", "2" } }),
        },
      }
    end,
    config = function(_, opts)
      local null_ls = require("null-ls")
      null_ls.setup(opts)
    end,
  },
  { -- mason null-ls module
    "jay-babu/mason-null-ls.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = {
        "eslint_d",
        "prettier",
        "stylua",
        "google_java_format",
        "black",
        "flake8",
        "css-lsp",
        "markdownlint",
        "beautysh",
        "clangd",
        "clang-format",
        "codelldb",
      },
      automatic_setup = true,
    },
  },
  { -- built-in Language Server Protocol
    "mfussenegger/nvim-jdtls",
  },
}
