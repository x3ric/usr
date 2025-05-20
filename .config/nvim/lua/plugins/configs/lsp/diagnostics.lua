local util = require("plugins.resources.util")
vim.g.diagnostics_enabled = true

local function get_diagnostics()
  -- Use diagnostic signs API instead of deprecated sign_define
  local sign_icons = {}
  for name, icon in pairs(require("custom.icons").diagnostics) do
    local function firstUpper(s)
      return s:sub(1, 1):upper() .. s:sub(2)
    end
    local sign_name = "DiagnosticSign" .. firstUpper(name)
    -- Update the sign definition
    vim.fn.sign_define(sign_name, { text = icon, texthl = sign_name })
    sign_icons[string.lower(name)] = { text = icon }
  end
  return {
    off = {
      underline = true,
      virtual_text = false,
      signs = false,
      update_in_insert = false,
    },
    on = {
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = function(diagnostic)
          local icons = require("custom.icons").diagnostics
          for d, icon in pairs(icons) do
            if diagnostic.severity == vim.diagnostic.severity[d:upper()] then
              return icon
            end
          end
          return "●"
        end,
      }, -- virtual text with diagnostic icons
      virtual_lines = false,
      update_in_insert = true,
      underline = true,
      severity_sort = true,
      signs = {
        active = true,
      },
      float = {
        focusable = false,
        style = "minimal",
        -- border = "rounded",
        border = util.generate_borderchars("thick", "tl-t-tr-r-bl-b-br-l"),
        source = "always",
        header = "",
        prefix = "",
      },
    },
  }
end
local diagnostics = get_diagnostics()

vim.api.nvim_create_user_command("ToggleDiagnostic", function()
  if vim.g.diagnostics_enabled then
    vim.diagnostic.config(diagnostics["off"])
    vim.g.diagnostics_enabled = false
  else
    vim.diagnostic.config(diagnostics["on"])
    vim.g.diagnostics_enabled = true
  end
end, { nargs = 0 })

return diagnostics
