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
      "hrsh7th/cmp-nvim-lsp", -- Added missing dependency
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
      -- Create a utility module if plugins.resources.util is missing
      local util
      local ok, loaded_util = pcall(require, "plugins.resources.util")
      if ok then
        util = loaded_util
      else
        -- Fallback util implementation if the module isn't found
        util = {
          on_attach = function(on_attach)
            vim.api.nvim_create_autocmd("LspAttach", {
              callback = function(args)
                local buffer = args.buf
                local client = vim.lsp.get_client_by_id(args.data.client_id)
                on_attach(client, buffer)
              end,
            })
          end
        }
      end

      -- Safely load LSP config modules
      local function safe_require(module_name)
        local ok, module = pcall(require, module_name)
        if ok then
          return module
        else
          vim.notify("Failed to load " .. module_name, vim.log.levels.WARN)
          return {}
        end
      end

      -- special attach lsp with safe loading
      util.on_attach(function(client, buffer)
        local navic = safe_require("plugins.configs.lsp.navic")
        local keymaps = safe_require("plugins.configs.lsp.keymaps")
        local gitsigns = safe_require("plugins.configs.lsp.gitsigns")
        
        if navic.attach then navic.attach(client, buffer) end
        if keymaps.attach then keymaps.attach(client, buffer) end
        if gitsigns.attach then gitsigns.attach(client, buffer) end
      end)

     -- diagnostics with safe loading
     local diagnostics = safe_require("plugins.configs.lsp.diagnostics")
     if diagnostics and diagnostics["on"] then
       vim.diagnostic.config(diagnostics["on"])
     else
       -- Default diagnostics config as fallback
       vim.diagnostic.config({
         underline = true,
         update_in_insert = false,
         virtual_text = { spacing = 4, prefix = "●" },
         severity_sort = true,
       })
     end

     local servers = opts.servers
     local ext_capabilites = vim.lsp.protocol.make_client_capabilities()

     -- inlay hints
     local inlay_hint = vim.lsp.buf.inlayhints or vim.lsp.inlayhints
     if vim.fn.has("nvim-0.10.0") == 1 and inlay_hint then
       util.on_attach(function(client, buffer)
         if client.supports_method("textDocument/inlayHint") then
           inlay_hint(buffer, true)
         end
       end)
     end

     -- Safely load cmp_nvim_lsp
     local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
     local cmp_capabilities = ok_cmp and cmp_lsp.default_capabilities() or {}

     local capabilities = vim.tbl_deep_extend(
       "force",
       {},
       ext_capabilites,
       cmp_capabilities,
       opts.capabilities or {}
     )

     local function setup(server)
       local server_opts = vim.tbl_deep_extend("force", {
         capabilities = vim.deepcopy(capabilities),
       }, servers[server] or {})

       if opts.attach_handlers and opts.attach_handlers[server] then
         local callback = function(client, buffer)
           if client.name == server then
             opts.attach_handlers[server](client, buffer)
           end
         end
         util.on_attach(callback)
       end
       require("lspconfig")[server].setup(server_opts)
     end

     -- FIXED: Handle different mason-lspconfig versions
     local available = {}
     local has_mason, mappings = pcall(function()
       -- Try the new path structure first
       return require("mason-lspconfig.mappings")
     end)
     
     if has_mason and mappings and mappings.lspconfig_to_package then
       available = vim.tbl_keys(mappings.lspconfig_to_package)
     else
       -- Fall back to the old structure if available
       local has_old, old_mappings = pcall(function()
         return require("mason-lspconfig.mappings.server").lspconfig_to_package
       end)
       
       if has_old and old_mappings then
         available = vim.tbl_keys(old_mappings)
       else
         vim.notify("Could not find mason-lspconfig mappings. Some LSP features may not work properly.", vim.log.levels.WARN)
       end
     end

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

     -- Safely set up mason-lspconfig
     local ok_mason, mason_lspconfig = pcall(require, "mason-lspconfig")
     if ok_mason then
       mason_lspconfig.setup({ ensure_installed = ensure_installed })
       
       -- Use pcall for setup_handlers to handle potential errors
       pcall(function()
         mason_lspconfig.setup_handlers({ setup })
       end)
     else
       -- If mason-lspconfig failed to load, fall back to direct setup
       for server, _ in pairs(servers) do
         setup(server)
       end
     end
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
  { -- formatting plugin
    "stevearc/conform.nvim",
    event = { "BufWritePre", "BufReadPre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>W",
        function()
          require("conform").format({
            lsp_fallback = true,
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
          require("conform").format({
            lsp_fallback = true,
            filter = function(client)
              -- do not use default `lua_ls` to format
              local exclude_servers = { "lua_ls" }
              return not vim.tbl_contains(exclude_servers, client.name)
            end,
          })
        end,
        desc = "Format text",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        markdown = { "markdownlint" },
        sh = { "beautysh" },
        bash = { "beautysh" },
      },
      formatters = {
        beautysh = {
          args = { "--indent-size", "2" },
        },
      },
    },
  },
  { -- linting plugin
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    config = function()
      local lint = require("lint")
      
      lint.linters_by_ft = {
        -- linter configurations
      }
      
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
  { -- built-in Language Server Protocol
    "mfussenegger/nvim-jdtls",
  },
}