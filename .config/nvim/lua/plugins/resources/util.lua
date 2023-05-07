local M = {}

M.root_patterns = { ".git", "lua", "package.json", "mvnw", "gradlew", "pom.xml", "build.gradle", "release", ".project" }

M.augroup = function(name)
  return vim.api.nvim_create_augroup("nvim-" .. name, { clear = true })
end

M.has = function(plugin)
  return require("lazy.core.config").plugins[plugin] ~= nil
end

function M.get_clients(...)
  local fn = vim.lsp.get_clients or vim.lsp.get_active_clients
  return fn(...)
end

--- @param on_attach fun(client, buffer)
M.on_attach = function(on_attach)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local buffer = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      on_attach(client, buffer)
    end,
  })
end

M.get_highlight_value = function(group)
  local found, hl = pcall(vim.api.nvim_get_hl_by_name, group, true)
  if not found then
    return {}
  end
  local hl_config = {}
  for key, value in pairs(hl) do
    _, hl_config[key] = pcall(string.format, "#%02x", value)
  end
  return hl_config
end

-- return plugin opts
---@param name string
function M.opts(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

-- returns the root directory based on:
-- * lsp workspace folders
-- * lsp root_dir
-- * root pattern of filename of the current buffer
-- * root pattern of cwd
---@return string
M.get_root = function()
  ---@type string?
  local path = vim.api.nvim_buf_get_name(0)
  path = path ~= "" and vim.loop.fs_realpath(path) or nil
  ---@type string[]
  local roots = {}
  if path then
    for _, client in pairs(vim.lsp.get_active_clients({ bufnr = 0 })) do
      local workspace = client.config.workspace_folders
      local paths = workspace
          and vim.tbl_map(function(ws)
            return vim.uri_to_fname(ws.uri)
          end, workspace)
        or client.config.root_dir and { client.config.root_dir }
        or {}
      for _, p in ipairs(paths) do
        local r = vim.loop.fs_realpath(p)
        if path:find(r, 1, true) then
          roots[#roots + 1] = r
        end
      end
    end
  end
  table.sort(roots, function(a, b)
    return #a > #b
  end)
  ---@type string?
  local root = roots[1]
  if not root then
    path = path and vim.fs.dirname(path) or vim.loop.cwd()
    ---@type string?
    root = vim.fs.find(M.root_patterns, { path = path, upward = true })[1]
    root = root and vim.fs.dirname(root) or vim.loop.cwd()
  end
  ---@cast root string
  return root
end

M.set_root = function(dir)
  vim.api.nvim_set_current_dir(dir)
end

---@param type "ivy" | "dropdown" | "cursor" | nil
M.telescope_theme = function(type)
  if type == nil then
    return {
      borderchars = M.generate_borderchars("thick"),
      layout_config = {
        width = 80,
        height = 0.5,
      },
    }
  end
  return require("telescope.themes")["get_" .. type]({
    cwd = M.get_root(),
    borderchars = M.generate_borderchars("thick", nil, { top = "█", top_left = "█", top_right = "█" }),
  })
end

---@param builtin "find_files" | "live_grep" | "buffers"
---@param type "ivy" | "dropdown" | "cursor" | nil
M.telescope = function(builtin, type, opts)
  local params = { builtin = builtin, type = type, opts = opts }
  return function()
    builtin = params.builtin
    type = params.type
    opts = params.opts
    opts = vim.tbl_deep_extend("force", { cwd = M.get_root() }, opts or {})
    local theme
    if vim.tbl_contains({ "ivy", "dropdown", "cursor" }, type) then
      theme = M.telescope_theme(type)
    else
      theme = opts
    end
    require("telescope.builtin")[builtin](theme)
  end
end

---@param name "autocmds" | "options" | "keymaps"
M.load = function(name)
  local Util = require("lazy.core.util")
  -- always load lazyvim, then user file
  local mod = name
  Util.try(function()
    require(mod)
  end, {
    msg = "Failed loading " .. mod,
    on_error = function(msg)
      local modpath = require("lazy.core.cache").find(mod)
      if modpath then
        Util.error(msg)
      end
    end,
  })
end

M.on_very_lazy = function(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

M.capabilities = function(ext)
  return vim.tbl_deep_extend(
    "force",
    {},
    ext or {},
    require("cmp_nvim_lsp").default_capabilities(),
    { textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } } }
  )
end

M.notify = function(msg, level, opts)
  opts = opts or {}
  level = vim.log.levels[level:upper()]
  if type(msg) == "table" then
    msg = table.concat(msg, "\n")
  end
  local nopts = { title = "Nvim" }
  if opts.once then
    return vim.schedule(function()
      vim.notify_once(msg, level, nopts)
    end)
  end
  vim.schedule(function()
    vim.notify(msg, level, nopts)
  end)
end

--- @param type "thin" | "thick" | "empty" | nil
--- @param order "t-r-b-l-tl-tr-br-bl" | "tl-t-tr-r-bl-b-br-l" | nil
--- @param opts BorderIcons | nil
M.generate_borderchars = function(type, order, opts)
  if order == nil then
    order = "t-r-b-l-tl-tr-br-bl"
  end
  local border_icons = require("custom.icons").borders
  --- @type BorderIcons
  local border = vim.tbl_deep_extend("force", border_icons[type or "empty"], opts or {})

  local borderchars = {}

  local extractDirections = (function()
    local index = 1
    return function()
      if index == nil then
        return nil
      end
      -- Find the next occurence of `char`
      local nextIndex = string.find(order, "-", index)
      -- Extract the first direction
      local direction = string.sub(order, index, nextIndex and nextIndex - 1)
      -- Update the index to nextIndex
      index = nextIndex and nextIndex + 1 or nil
      return direction
    end
  end)()

  local mappings = {
    t = "top",
    r = "right",
    b = "bottom",
    l = "left",
    tl = "top_left",
    tr = "top_right",
    br = "bottom_right",
    bl = "bottom_left",
  }
  local direction = extractDirections()
  while direction do
    if mappings[direction] == nil then
      M.notify(string.format("Invalid direction '%s'", direction), "error")
    end
    borderchars[#borderchars + 1] = border[mappings[direction]]
    direction = extractDirections()
  end

  if #borderchars ~= 8 then
    M.notify(string.format("Invalid order '%s'", order), "error")
  end

  return borderchars
end

local function adjustbrightness(color, percentage)
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6, 7), 16)
  local factor = 1 + (percentage / 100)
  r = math.floor(r * factor)
  g = math.floor(g * factor)
  b = math.floor(b * factor)
  r = math.max(0, math.min(255, r))
  g = math.max(0, math.min(255, g))
  b = math.max(0, math.min(255, b))
  local newColor = string.format("#%02x%02x%02x", r, g, b)
  return newColor
end

local function adjusttransparency(color, alpha)
  local r = tonumber(color:sub(2, 3), 16)
  local g = tonumber(color:sub(4, 5), 16)
  local b = tonumber(color:sub(6, 7), 16)
  local a = math.floor(alpha * 255)
  a = math.max(0, math.min(255, a))
  local newColor = string.format("#%02x%02x%02x%02x", r, g, b, a)
  return newColor
end

M.themesethl = function(theme,termcolors,pywall)
  local file_path = os.getenv("HOME") .. "/.cache/wal/colors"
  local file_exists = vim.fn.filereadable(file_path) == 1
  if file_exists and pywall then
      local file = io.open(file_path, "r")
      if file then
          local i = 0
          for line in file:lines() do
            i = i + 1
            if i ~= 0 and i ~= 1 and termcolors then
              theme.tc["base" .. string.format("%02d", i)] = line
            end
            if i ~= 0 and i ~= 1 and i ~= 2 and i ~= 3 and i ~= 4 and i ~= 5 and i ~= 6 then
              theme.c["base" .. string.format("%02d", i)] = line
              if not termcolors then
                theme.tc["base" .. string.format("%02d", i)] = line
              end
            end
          end
          file:close()
      end
  end
    local darker_base01 = {}
    if transparent then
      theme.c.base00 = "NONE"
      vim.g.transparency = 0.8
      vim.api.nvim_set_hl(0, "Background", {fg = theme.c.none, bg = theme.c.none})
      darker_base01 = theme.c.none
    else
      darker_base01 = adjustbrightness(theme.c.base01, -25)  -- Adjust brightness by -25% (make it darker)
    end
    vim.g["terminal_color_0"] = theme.tc.base00
    vim.g["terminal_color_1"] = theme.tc.base01
    vim.g["terminal_color_2"] = theme.tc.base02
    vim.g["terminal_color_3"] = theme.tc.base03
    vim.g["terminal_color_4"] = theme.tc.base04
    vim.g["terminal_color_5"] = theme.tc.base05
    vim.g["terminal_color_6"] = theme.tc.base06
    vim.g["terminal_color_7"] = theme.tc.base07
    vim.g["terminal_color_8"] = theme.tc.base08
    vim.g["terminal_color_9"] = theme.tc.base09
    vim.g["terminal_color_10"] = theme.tc.base10
    vim.g["terminal_color_11"] = theme.tc.base11
    vim.g["terminal_color_12"] = theme.tc.base12
    vim.g["terminal_color_13"] = theme.tc.base13
    vim.g["terminal_color_14"] = theme.tc.base14
    vim.g["terminal_color_15"] = theme.tc.base15
    vim.api.nvim_set_hl(0, "CursorLine", {fg = theme.c.none, bg = darker_base01}) --bg = theme.c.none
    vim.api.nvim_set_hl(0, "ColorColumn", {fg = theme.c.base00, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "Cursor", {fg = theme.c.base01, bg = theme.c.base04})
    vim.api.nvim_set_hl(0, "CursorColumn", {fg = theme.c.base00, bg = theme.c.base04})
    vim.api.nvim_set_hl(0, "CursorLineNr", {fg = theme.c.base05, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "QuickFixLine", {fg = theme.c.base00, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "Error", {fg = theme.c.base10, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "LineNr", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NonText", {fg = theme.c.base02, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Normal", {fg = theme.c.base04, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "TelescopeNormal", {fg = theme.c.base04, bg = theme.c.base05})
    vim.api.nvim_set_hl(0, "Pmenu", {fg = theme.c.base04, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "PmenuSbar", {fg = theme.c.base04, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "PmenuSel", {fg = theme.c.base08, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "PmenuThumb", {fg = theme.c.base08, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "SpecialKey", {fg = theme.c.base03, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Visual", {fg = theme.c.base00, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "VisualNOS", {fg = theme.c.base00, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "TooLong", {fg = theme.c.base00, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "Debug", {fg = theme.c.base13, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Macro", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "MatchParen", {fg = theme.c.base00, bg = theme.c.base02, underline = true})
    vim.api.nvim_set_hl(0, "Bold", {fg = theme.c.base00, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "Italic", {fg = theme.c.base00, bg = theme.c.base00, italic = true})
    vim.api.nvim_set_hl(0, "Underlined", {fg = theme.c.base00, bg = theme.c.base00, underline = true})
    vim.api.nvim_set_hl(0, "DiagnosticWarn", {fg = theme.c.base14, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiagnosticError", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiagnosticInfo", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiagnosticHint", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn", {fg = theme.c.base14, bg = theme.c.base00, undercurl = true})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", {fg = theme.c.base10, bg = theme.c.base00, undercurl = true})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo", {fg = theme.c.base04, bg = theme.c.base00, undercurl = true})
    vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint", {fg = theme.c.base04, bg = theme.c.base00, undercurl = true})
    vim.api.nvim_set_hl(0, "HealthError", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "HealthWarning", {fg = theme.c.base14, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "HealthSuccess", {fg = theme.c.base13, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "healthSuccess", {fg = theme.c.base13, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "LspReferenceText", {fg = theme.c.base00, bg = theme.c.base03})
    vim.api.nvim_set_hl(0, "LspReferenceread", {fg = theme.c.base00, bg = theme.c.base03})
    vim.api.nvim_set_hl(0, "LspReferenceWrite", {fg = theme.c.base00, bg = theme.c.base03})
    vim.api.nvim_set_hl(0, "LspSignatureActiveParameter", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Folded", {fg = theme.c.base02, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "FoldColumn", {fg = theme.c.base03, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "SignColumn", {fg = theme.c.base02, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Directory", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "EndOfBuffer", {fg = theme.c.base01, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "ErrorMsg", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "ModeMsg", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "MoreMsg", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Question", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Substitute", {fg = theme.c.base01, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "WarningMsg", {fg = theme.c.base14, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "WildMenu", {fg = theme.c.base08, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "helpHyperTextJump", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "helpSpecial", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "helpHeadline", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "helpHeader", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffAdded", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffChanged", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffRemoved", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffAdd", {bg = "#122f2f", fg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffChange", {bg = "#222a39", fg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffText", {bg = "#2f3f5c", fg = theme.c.base00})
    vim.api.nvim_set_hl(0, "DiffDelete", {bg = "#361c28", fg = theme.c.base00})
    vim.api.nvim_set_hl(0, "IncSearch", {fg = theme.c.base06, bg = theme.c.base10})
    vim.api.nvim_set_hl(0, "Search", {fg = theme.c.base01, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "TabLine", {link = "StatusLineNC"})
    vim.api.nvim_set_hl(0, "TabLineFill", {link = "TabLine"})
    vim.api.nvim_set_hl(0, "TabLineSel", {link = "StatusLine"})
    vim.api.nvim_set_hl(0, "Title", {fg = theme.c.base00, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "VertSplit", {fg = theme.c.base01, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Boolean", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Character", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Comment", {fg = theme.c.base03, bg = theme.c.base00, italic = true})
    vim.api.nvim_set_hl(0, "Conceal", {fg = theme.c.base00, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Conditional", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Constant", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Decorator", {fg = theme.c.base12, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Define", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Delimeter", {fg = theme.c.base06, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Exception", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Float", {link = "Number"})
    vim.api.nvim_set_hl(0, "Function", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Identifier", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Include", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Keyword", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Label", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Number", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Operator", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "PreProc", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Repeat", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Special", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "SpecialChar", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "SpecialComment", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Statement", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "StorageClass", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "String", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Structure", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Tag", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Todo", {fg = theme.c.base13, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Type", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "Typedef", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "markdownBlockquote", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "markdownBold", {link = "Bold"})
    vim.api.nvim_set_hl(0, "markdownItalic", {link = "Italic"})
    vim.api.nvim_set_hl(0, "markdownBoldItalic", {fg = theme.c.base00, bg = theme.c.base00, bold = true, italic = true})
    vim.api.nvim_set_hl(0, "markdownRule", {link = "Comment"})
    vim.api.nvim_set_hl(0, "markdownH1", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "markdownH2", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownH3", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownH4", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownH5", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownH6", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownHeadingDelimiter", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownHeadingRule", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "markdownUrl", {fg = theme.c.base15, bg = theme.c.base00, underline = true})
    vim.api.nvim_set_hl(0, "markdownCode", {link = "String"})
    vim.api.nvim_set_hl(0, "markdownCodeBlock", {link = "markdownCode"})
    vim.api.nvim_set_hl(0, "markdownCodeDelimiter", {link = "markdownCode"})
    vim.api.nvim_set_hl(0, "markdownUrl", {link = "String"})
    vim.api.nvim_set_hl(0, "markdownListMarker", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "markdownOrderedListMarker", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "asciidocAttributeEntry", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "asciidocAttributeList", {link = "asciidocAttributeEntry"})
    vim.api.nvim_set_hl(0, "asciidocAttributeRef", {link = "asciidocAttributeEntry"})
    vim.api.nvim_set_hl(0, "asciidocHLabel", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "asciidocOneLineTitle", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "asciidocQuotedMonospaced", {link = "markdownBlockquote"})
    vim.api.nvim_set_hl(0, "asciidocURL", {link = "markdownUrl"})
    vim.api.nvim_set_hl(0, "@comment", {link = "Comment"})
    vim.api.nvim_set_hl(0, "@error", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@operator", {link = "Operator"})
    vim.api.nvim_set_hl(0, "@puncuation.delimiter", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@punctuation.bracket", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@punctuation.special", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@string", {link = "String"})
    vim.api.nvim_set_hl(0, "@string.regex", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@string.escape", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@character", {link = "Character"})
    vim.api.nvim_set_hl(0, "@boolean", {link = "Boolean"})
    vim.api.nvim_set_hl(0, "@number", {link = "Number"})
    vim.api.nvim_set_hl(0, "@float", {link = "Float"})
    vim.api.nvim_set_hl(0, "@function", {fg = theme.c.base12, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "@function.builtin", {fg = theme.c.base12, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@function.macro", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@method", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@constructor", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@parameter", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@keyword", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@keyword.function", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@keyword.operator", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@conditional", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@repeat", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@label", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@include", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@exception", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@type", {link = "Type"})
    vim.api.nvim_set_hl(0, "@type.builtin", {link = "Type"})
    vim.api.nvim_set_hl(0, "@attribute", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@field", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@property", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@variable", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@variable.builtin", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@constant", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@constant.builtin", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@constant.macro", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@namespace", {fg = theme.c.base07, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@symbol", {fg = theme.c.base15, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "@text", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@text.strong", {fg = theme.c.base00, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@text.emphasis", {fg = theme.c.base10, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "@text.underline", {fg = theme.c.base10, bg = theme.c.base00, underline = true})
    vim.api.nvim_set_hl(0, "@text.strike", {fg = theme.c.base10, bg = theme.c.base00, strikethrough = true})
    vim.api.nvim_set_hl(0, "@text.title", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@text.literal", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@text.uri", {fg = theme.c.base15, bg = theme.c.base00, underline = true})
    vim.api.nvim_set_hl(0, "@tag", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@tag.attribute", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@tag.delimiter", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "@reference", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimInternalError", {fg = theme.c.base00, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "NormalFloat", {fg = theme.c.base05, bg = theme.c.blend})
    vim.api.nvim_set_hl(0, "FloatBorder", {fg = theme.c.blend, bg = theme.c.blend})
    vim.api.nvim_set_hl(0, "NormalNC", {fg = theme.c.base05, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "TermCursor", {fg = theme.c.base00, bg = theme.c.base04})
    vim.api.nvim_set_hl(0, "TermCursorNC", {fg = theme.c.base00, bg = theme.c.base04})
    vim.api.nvim_set_hl(0, "StatusLine", {fg = theme.c.base04, bg = theme.c.base01}) --bg = theme.c.base01
    vim.api.nvim_set_hl(0, "StatusLineNC", {fg = theme.c.base03, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "StatusReplace", {fg = theme.c.base00, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "StatusInsert", {fg = theme.c.base00, bg = theme.c.base12})
    vim.api.nvim_set_hl(0, "StatusVisual", {fg = theme.c.base00, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "StatusTerminal", {fg = theme.c.base00, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "StatusNormal", {fg = theme.c.base00, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "StatusCommand", {fg = theme.c.base00, bg = theme.c.base13})
    vim.api.nvim_set_hl(0, "StatusLineDiagnosticWarn", {fg = theme.c.base14, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "StatusLineDiagnosticError", {fg = theme.c.base10, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "TelescopeBorder", {fg = theme.c.blend, bg = theme.c.blend})
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", {fg = theme.c.base02, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", {fg = theme.c.base05, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "TelescopePromptPrefix", {fg = theme.c.base08, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "TelescopeNormal", {fg = theme.c.base05, bg = theme.c.blend})
    vim.api.nvim_set_hl(0, "TelescopePreviewTitle", {fg = theme.c.base02, bg = theme.c.base12})
    vim.api.nvim_set_hl(0, "TelescopePromptTitle", {fg = theme.c.base02, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "TelescopeResultsTitle", {fg = theme.c.blend, bg = theme.c.blend})
    vim.api.nvim_set_hl(0, "TelescopeSelection", {fg = theme.c.base06, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "TelescopePreviewLine", {fg = theme.c.base00, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "TelescopeMatching", {fg = theme.c.base08, bg = theme.c.base00, bold = true, italic = true})
    vim.api.nvim_set_hl(0, "NotifyERRORBorder", {fg = theme.c.base08, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyWARNBorder", {fg = theme.c.base14, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyINFOBorder", {fg = theme.c.base05, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyDEBUGBorder", {fg = theme.c.base13, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyTRACEBorder", {fg = theme.c.base13, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyERRORIcon", {fg = theme.c.base08, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyWARNIcon", {fg = theme.c.base14, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyINFOIcon", {fg = theme.c.base05, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyDEBUGIcon", {fg = theme.c.base13, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyTRACEIcon", {fg = theme.c.base13, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyERRORTitle", {fg = theme.c.base08, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyWARNTitle", {fg = theme.c.base14, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyINFOTitle", {fg = theme.c.base05, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyDEBUGTitle", {fg = theme.c.base13, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "NotifyTRACETitle", {fg = theme.c.base13, bg = theme.c.none})
    vim.api.nvim_set_hl(0, "CmpItemAbbr", {fg = theme.c.base05, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "CmpItemAbbrMatch", {fg = theme.c.base05, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "CmpItemAbbrMatchFuzzy", {fg = theme.c.base04, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "CmpItemMenu", {fg = theme.c.base04, bg = theme.c.base00, italic = true})
    vim.api.nvim_set_hl(0, "CmpItemKindInterface", {fg = theme.c.base01, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "CmpItemKindColor", {fg = theme.c.base01, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "CmpItemKindTypeParameter", {fg = theme.c.base01, bg = theme.c.base08})
    vim.api.nvim_set_hl(0, "CmpItemKindText", {fg = theme.c.base01, bg = theme.c.base09})
    vim.api.nvim_set_hl(0, "CmpItemKindEnum", {fg = theme.c.base01, bg = theme.c.base09})
    vim.api.nvim_set_hl(0, "CmpItemKindKeyword", {fg = theme.c.base01, bg = theme.c.base09})
    vim.api.nvim_set_hl(0, "CmpItemKindConstant", {fg = theme.c.base01, bg = theme.c.base10})
    vim.api.nvim_set_hl(0, "CmpItemKindConstructor", {fg = theme.c.base01, bg = theme.c.base10})
    vim.api.nvim_set_hl(0, "CmpItemKindReference", {fg = theme.c.base01, bg = theme.c.base10})
    vim.api.nvim_set_hl(0, "CmpItemKindFunction", {fg = theme.c.base01, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "CmpItemKindStruct", {fg = theme.c.base01, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "CmpItemKindClass", {fg = theme.c.base01, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "CmpItemKindModule", {fg = theme.c.base01, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "CmpItemKindOperator", {fg = theme.c.base01, bg = theme.c.base11})
    vim.api.nvim_set_hl(0, "CmpItemKindField", {fg = theme.c.base01, bg = theme.c.base12})
    vim.api.nvim_set_hl(0, "CmpItemKindProperty", {fg = theme.c.base01, bg = theme.c.base12})
    vim.api.nvim_set_hl(0, "CmpItemKindEvent", {fg = theme.c.base01, bg = theme.c.base12})
    vim.api.nvim_set_hl(0, "CmpItemKindUnit", {fg = theme.c.base01, bg = theme.c.base13})
    vim.api.nvim_set_hl(0, "CmpItemKindSnippet", {fg = theme.c.base01, bg = theme.c.base13})
    vim.api.nvim_set_hl(0, "CmpItemKindFolder", {fg = theme.c.base01, bg = theme.c.base13})
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", {fg = theme.c.base01, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "CmpItemKindFile", {fg = theme.c.base01, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "CmpItemKindMethod", {fg = theme.c.base01, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "CmpItemKindValue", {fg = theme.c.base01, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "CmpItemKindEnumMember", {fg = theme.c.base01, bg = theme.c.base15})
    vim.api.nvim_set_hl(0, "NvimTreeImageFile", {fg = theme.c.base12, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeFolderIcon", {fg = theme.c.base12, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeWinSeparator", {fg = theme.c.base00, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeFolderName", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", {fg = theme.c.base02, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName", {fg = theme.c.base15, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NvimTreeNormal", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NeoTreeFileName", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NeogitBranch", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NeogitRemote", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "NeogitHunkHeader", {fg = theme.c.base04, bg = theme.c.base02})
    vim.api.nvim_set_hl(0, "NeogitHunkHeaderHighlight", {fg = theme.c.base04, bg = theme.c.base03})
    vim.api.nvim_set_hl(0, "HydraRed", {fg = theme.c.base12, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "HydraBlue", {fg = theme.c.base09, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "HydraAmaranth", {fg = theme.c.base10, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "HydraTeal", {fg = theme.c.base08, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "HydraHint", {fg = theme.c.base00, bg = theme.c.blend})
    vim.api.nvim_set_hl(0, "alpha1", {fg = theme.c.base03, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "alpha2", {fg = theme.c.base04, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "alpha3", {fg = theme.c.base03, bg = theme.c.base00})
    vim.api.nvim_set_hl(0, "CodeBlock", {fg = theme.c.base00, bg = theme.c.base01})
    vim.api.nvim_set_hl(0, "BufferLineDiagnostic", {fg = theme.c.base10, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "BufferLineDiagnosticVisible", {fg = theme.c.base10, bg = theme.c.base00, bold = true})
    vim.api.nvim_set_hl(0, "htmlH1", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "mkdRule", {link = "markdownRule"})
    vim.api.nvim_set_hl(0, "mkdListItem", {link = "markdownListMarker"})
    vim.api.nvim_set_hl(0, "mkdListItemCheckbox", {link = "markdownListMarker"})
    vim.api.nvim_set_hl(0, "VimwikiHeader1", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiHeader2", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiHeader3", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiHeader4", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiHeader5", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiHeader6", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiHeaderChar", {link = "markdownH1"})
    vim.api.nvim_set_hl(0, "VimwikiList", {link = "markdownListMarker"})
    vim.api.nvim_set_hl(0, "VimwikiLink", {link = "markdownUrl"})
    vim.api.nvim_set_hl(0, "VimwikiCode", {link = "markdownCode"})
    vim.api.nvim_set_hl(0, "TSRainbowRed", {fg= theme.c.base08})
    vim.api.nvim_set_hl(0, "TSRainbowYellow", {fg= theme.c.base12})
    vim.api.nvim_set_hl(0, "TSRainbowBlue", {fg= theme.c.base13})
    vim.api.nvim_set_hl(0, "TSRainbowOrange", {fg= theme.c.base14})
    vim.api.nvim_set_hl(0, "TSRainbowGreen", {fg= theme.c.base15})
    vim.api.nvim_set_hl(0, "TSRainbowViolet", {fg= theme.c.base09})
    vim.api.nvim_set_hl(0, "TSRainbowCyan", {fg= theme.c.base11})
    vim.api.nvim_set_hl(0, "RainbowDelimiterRed", {fg= theme.c.base08})
    vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", {fg= theme.c.base12})
    vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", {fg= theme.c.base13})
    vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", {fg= theme.c.base14})
    vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", {fg= theme.c.base15})
    vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", {fg= theme.c.base09})
    vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", {fg= theme.c.base11})
    vim.api.nvim_set_hl(0, "DashboardRecent", {fg = theme.c.base09})
    vim.api.nvim_set_hl(0, "DashboardConfiguration", {fg = theme.c.base15})
    vim.api.nvim_set_hl(0, "DashboardSession", {fg = theme.c.base10})
    vim.api.nvim_set_hl(0, "DashboardLazy", {fg = theme.c.base11})
    vim.api.nvim_set_hl(0, "DashboardServer", {fg = theme.c.base13})
    vim.api.nvim_set_hl(0, "DashboardQuit", {fg = theme.c.base12})
    vim.api.nvim_set_hl(0, "CmpItemKindVariable", {fg = "#09B6A2"})
end

-- Clangd lsp .clangd include project libs

_G.generate_clangd_config = function()
  local util = require('lspconfig.util')
  local root_dir = (util.root_pattern('.git', 'CMakeLists.txt', 'Makefile')(vim.fn.expand('%:p:h')) or vim.fn.expand('%:p:h')) 
  local include_dir = util.path.join(root_dir, 'include')
  if not util.path.is_dir(include_dir) then
      print("Include directory not found in the project root.")
      return
  end
  local clangd_config_path = util.path.join(root_dir, '.clangd')
  local file_content = 'CompileFlags:\n  Add: \n    - "-I' .. include_dir .. '"'
  local file, err = io.open(clangd_config_path, "w")
  if not file then
      print("Error opening .clangd file for writing: " .. err)
      return
  end
  file:write(file_content)
  file:close()
end

vim.cmd [[
augroup clangd_config
  autocmd!
  autocmd FileType c,cpp,h,hpp lua generate_clangd_config()
augroup END
]]

return M
