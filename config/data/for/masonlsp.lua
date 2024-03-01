return {
  config = function()
    require("mason-lspconfig").setup({
      ensure_installed = {
        -- "lua_ls",
        -- "pylyzer",
      },
    })
  end,
}
