local Util = require("plugins.resources.util")
local Icons = require("custom.icons")

return {
  { -- NeoTree explorer
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = "mrbjarksen/neo-tree-diagnostics.nvim",
    keys = {
      {
        "<Esc>",
        function()
          require("neo-tree.command").execute({ toggle = true, position = "left", dir = require("plugins.resources.util").get_root() })
        end,
        desc = "Explorer (root dir)",
        remap = true,
      },
      {
        '|',
        function()
          require("neo-tree.command").execute({
            toggle = true,
            position = "float",
            dir = Util.get_root(),
          })
        end,
        desc = "Explorer Float (root dir)",
      },
    },
    opts = require("plugins.configs.neo-tree"),
    init = function()
      vim.g.neo_tree_remove_legacy_commands = 1
      if vim.fn.argc() == 1 then
        local stat = vim.loop.fs_stat(vim.fn.argv(0))
        if stat and stat.type == "directory" then
          require("neo-tree")
          vim.cmd([[set showtabline=0]])
        end
      end
    end,
  },
  { -- Telescope
    "nvim-telescope/telescope.nvim",
    config = function(_, opts)
      package.preload['telescope.builtin.__internal'] = function()
          return require('plugins.configs.telescope.builtin.__internal') -- patch to hide internal colorschemes "Telescope"
      end
      require "telescope".setup {
        pickers = {
          colorscheme = {
            enable_preview = true,
          }
        }
      }
    end,
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    opts = {
      defaults = {
        prompt_prefix = "   ",
        selection_caret = "  ",
        entry_prefix = "   ",
        borderchars = {
          prompt = Util.generate_borderchars(
            "thick",
            nil,
            { top = "█", top_left = "█", left = "█", right = " ", top_right = " ", bottom_right = " " }
          ),
          results = Util.generate_borderchars(
            "thick",
            nil,
            { top = "█", top_left = "█", right = " ", top_right = " ", bottom_right = " " }
          ),
          preview = Util.generate_borderchars("thick", nil, { top = "█", top_left = "█", top_right = "█" }),
        },
        dynamic_preview_title = true,
        hl_result_eol = true,
        sorting_strategy = "ascending",
        file_ignore_patterns = {
          ".git/",
          "target/",
          "docs/",
          "vendor/*",
          "%.lock",
          "__pycache__/*",
          "%.sqlite3",
          "%.ipynb",
          "node_modules/*",
          -- "%.jpg",
          -- "%.jpeg",
          -- "%.png",
          "%.svg",
          "%.otf",
          "%.ttf",
          "%.webp",
          ".dart_tool/",
          ".github/",
          ".gradle/",
          ".idea/",
          ".settings/",
          ".vscode/",
          "__pycache__/",
          "build/",
          "gradle/",
          "node_modules/",
          "%.pdb",
          "%.dll",
          "%.class",
          "%.exe",
          "%.cache",
          "%.ico",
          "%.pdf",
          "%.dylib",
          "%.jar",
          "%.docx",
          "%.met",
          "smalljre_*/*",
          ".vale/",
          "%.burp",
          "%.mp4",
          "%.mkv",
          "%.rar",
          "%.zip",
          "%.7z",
          "%.tar",
          "%.bz2",
          "%.epub",
          "%.flac",
          "%.tar.gz",
        },
        results_title = "",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
            results_width = 0.8,
          },
          vertical = {
            mirror = false,
          },
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
        },
      },
    },
    keys = {
      -- goto
      { "gd", "<cmd>Telescope lsp_definitions<cr>", desc = "Go to definition" },
      { "gr", "<cmd>Telescope lsp_references<cr>", desc = "Go to references" },
      { "gi", "<cmd>Telescope lsp_implementations<cr>", desc = "Go to implementations" },
      -- search
      { "<leader>ht", "<cmd>lua compacttelescopepreview(require('telescope.builtin').colorscheme)<cr>", desc = "Colorscheme" },
      { "<leader>ws", "<cmd>lua compacttelescope(require('telescope.builtin').buffers)<cr>", desc = "Switch window selector" },
      { "<M-\\>", "<cmd>lua compacttelescope(require('telescope.builtin').commands)<cr>", desc = "Execute command selector" },
      { "<leader>bs", "<cmd>Telescope buffers<cr>", desc = "Switch buffers" },
      { "<leader>bf", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Find in current buffer" },
      { "<leader>ho", "<cmd>Telescope vim_options<cr>", desc = "Vim options" },
      { "<leader>hd", "<cmd>execute 'cd' expand('~/.config/nvim/') | lua findfiles()<cr>", desc = "Dotfiles" },
      { "<leader>hh", "<cmd>Telescope help_tags<cr>", desc = "Find Help" },
      { "<leader>hM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
      { "<leader>hr", "<cmd>Telescope oldfiles<cr>", desc = "Open Recent File" },
      { "<leader>hR", "<cmd>Telescope registers<cr>", desc = "Registers" },
      { "<leader>hk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>hC", "<cmd>Telescope commands<cr>", desc = "Commands" },
      { "<leader>hH", "<cmd>Telescope highlights<cr>", desc = "Highlight Groups" },
      { "<leader>lds", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document Symbols" },
      { "<leader>lws", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
      { "<leader>lwd", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
      -- Git
      { "<leader>go", "<cmd>Telescope git_status<cr>", desc = "Open changed file" },
      { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
      { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
      -- Find
      { "<leader>f", Util.telescope("find_files"), desc = "Find files" },
      { "<leader>F", Util.telescope("live_grep"), desc = "Find Text" },
      { "<leader>bf", Util.telescope("buffers"), desc = "Find buffer" },
    },
    -- config = function() require("plugins.configs.telescope") end,
    --config = function(_, opts) require("telescope").setup(opts) end,
  },
  { -- WhichKey
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = {
        presets = { motions = false, g = false },
      },
      layout = {
        height = { min = 3, max = 25 },
        width = { min = 20, max = 50 },
        spacing = 5,
        align = "center",
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>w", "<cmd>w!<CR>", desc = "Save" },
        { "<leader>q", "<cmd>q<CR>", desc = "Quit" },
        { "<leader>Q", "<cmd>qa<CR>", desc = "Quit All" },
        { "<leader>n", "<cmd>nohlsearch<CR>", desc = "No Highlight" },
        { "<leader><Tab>", "<c-6>", desc = "Navigate previous buffer" },
        { "<leader>g", group = "Git" },
        { "<leader>l", group = "Lsp" },
        { "<leader>lw", group = "Workspace" },
        { "<leader>s", group = "Session" },
        { "<leader>W", group = "Window" },
        { "<leader>b", group = "Buffer" },
        { "<leader>h", group = "Help" },
        { "<leader>t", group = "Toggle" },
        { "f", group = "Fold" },
        { "g", group = "Goto" },
        { "s", group = "Search" },
      })
    end,
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
  { -- Git author name and commits info
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = Icons.gitsigns.add },
        change = { text = Icons.gitsigns.change },
        delete = { text = Icons.gitsigns.delete },
        topdelhfe = { text = Icons.gitsigns.topdelhfe },
        changedelete = { text = Icons.gitsigns.changedelete },
        untracked = { text = Icons.gitsigns.untracked },
      },
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      preview_config = {
        border = Util.generate_borderchars("thick", "tl-t-tr-r-br-b-bl-l"), -- [ top top top - right - bottom bottom bottom - left ]
      },
    },
    keys = {
      { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = "Next Hunk" },
      { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", desc = "Prev Hunk" },
      { "<leader>gl", "<cmd>lua require 'gitsigns'.blame_line()<cr>", desc = "Blame" },
      { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
      { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
      { "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
      { "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
      { "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },
      { "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Diff" },
    },
  },
  --[[{ -- git term ui "lazygit" needed
    "kdheepak/lazygit.nvim",
    dependencies =  {
        "nvim-telescope/telescope.nvim",
        "nvim-lua/plenary.nvim"
    },
    keys = {
      { "<leader>gg", "<cmd>:LazyGit<CR>", desc = "Lazygit" },
    },
    config = function()
        require("telescope").load_extension("lazygit")
    end,
  },--]]
  { -- hilight other uses of the word under the cursor
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = {
      filetypes_denylist = {
        "dirvish",
        "fugitive",
        "neo-tree",
        "alpha",
        "NvimTree",
        "neo-tree",
        "dashboard",
        "TelescopePrompt",
        "TelescopeResult",
        "DressingInput",
        "neo-tree-popup",
        "markdown",
        "",
      },
      delay = 200,
      large_file_cutoff = 2000,
      large_file_overrides = {
        providers = { "lsp" },
      },
    },
    config = function(_, opts)
      require("illuminate").configure(opts)

      local function map(key, dir, buffer)
        vim.keymap.set("n", key, function()
          require("illuminate")["goto_" .. dir .. "_reference"](false)
        end, { desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference", buffer = buffer })
      end

      map("]]", "next")
      map("[[", "prev")

      -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
      vim.api.nvim_create_autocmd("FileType", {
        callback = function()
          local buffer = vim.api.nvim_get_current_buf()
          map("]]", "next", buffer)
          map("[[", "prev", buffer)
        end,
      })
    end,
    keys = {
      { "]]", desc = "Next Reference" },
      { "[[", desc = "Prev Reference" },
    },
  },
  { -- fold functions etc
    "kevinhwang91/nvim-ufo",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "kevinhwang91/promise-async", event = "BufReadPost" },
    opts = {
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  … %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            -- str width returned from truncate() may less than 2nd argument, need padding
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "MoreMsg" })
        return newVirtText
      end,
      open_fold_hl_timeout = 0,
    },
    keys = {
      { "fd", "zd", desc = "Delete fold under cursor" },
      { "fo", "zo", desc = "Open fold under cursor" },
      { "fO", "zO", desc = "Open all folds under cursor" },
      { "fc", "zC", desc = "Close all folds under cursor" },
      { "fa", "za", desc = "Toggle fold under cursor" },
      { "fA", "zA", desc = "Toggle all folds under cursor" },
      { "fv", "zv", desc = "Show cursor line" },
      {
        "fM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
      {
        "fR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "fm",
        function()
          require("ufo").closeFoldsWith()
        end,
        desc = "Fold more",
      },
      {
        "fr",
        function()
          require("ufo").openFoldsExceptKinds()
        end,
        desc = "Fold less",
      },
      { "fx", "zx", desc = "Update folds" },
      { "fz", "zz", desc = "Center this line" },
      { "ft", "zt", desc = "Top this line" },
      { "fb", "zb", desc = "Bottom this line" },
      { "fg", "zg", desc = "Add word to spell list" },
      { "fw", "zw", desc = "Mark word as bad/misspelling" },
      { "fe", "ze", desc = "Right this line" },
      { "fE", "zE", desc = "Delete all folds in current buffer" },
      { "fs", "zs", desc = "Left this line" },
      { "fH", "zH", desc = "Half screen to the left" },
      { "fL", "zL", desc = "Half screen to the right" },
    },
  },
  { -- fold functions in the linenumber
    "luukvbaal/statuscol.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        relculright = false,
        ft_ignore = { "neo-tree" },
        segments = {
          {
            -- line number
            text = { " ", builtin.lnumfunc },
            condition = { true, builtin.not_empty },
            click = "v:lua.ScLa",
          },
          { text = { "%s" }, click = "v:lua.ScSa" }, -- Sign
          { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa" }, -- Fold
        },
      })
      vim.api.nvim_create_autocmd({ "BufEnter" }, {
        callback = function()
          if vim.bo.filetype == "neo-tree" then
            vim.opt_local.statuscolumn = ""
          end
        end,
      })
    end,
  },
}
