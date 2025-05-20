-- Install language servers via Mason
local servers = {
  "lua_ls",
  "pyright",
  "pylsp",
  "html",
  "dockerls",
  "jsonls"
}

vim.cmd("packadd mason.nvim")
vim.cmd("packadd mason-lspconfig.nvim")

require("mason").setup()
require("mason-lspconfig").setup({
  ensure_installed = servers,
  automatic_installation = true,
})

-- Report status
print("Mason has been instructed to install the following servers:")
for _, server in ipairs(servers) do
  print("  - " .. server)
end

print("\nPlease manually run :Mason to ensure all servers are installed properly")
print("Restart Neovim after installation completes")
