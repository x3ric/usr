local M = {}

M.attach = function(client, buffer)
  -- Neovim 0.10+ has built-in inlay hints
  if vim.fn.has("nvim-0.10.0") == 1 then
    if client.supports_method("textDocument/inlayHint") then
      vim.lsp.inlay_hint.enable(buffer, true)
    end
  else
    -- Fallback to plugin for older Neovim versions
    local status_ok, inlayhints = pcall(require, "lsp-inlayhints")
    if status_ok then
      inlayhints.on_attach(client, buffer)
    end
  end
end

return M