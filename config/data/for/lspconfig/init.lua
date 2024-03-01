local main = {}
local fns = {
  on_attach = function(client, bufnr)
    local fmt = require("src.warm.str").format
    fmt("client '{}' at buffer {}", client.name, bufnr):print()
    local mappings = require("config.data.for.lspconfig.mapping").get(bufnr)
    for method, props in pairs(mappings) do
      if client.supports_method(method) then
        props.opts.desc = props.desc -- Just to not nest items
        -- vim.keymap.set(props.modes, props.mapp, props.exec, props.opts)
        if type(props.exec) == "function" then
          props.opts.callback = props.exec
          props.exec = ""
        end
        for _, mode in ipairs(props.mode) do
          vim.api.nvim_set_keymap(mode, props.mapp, props.exec, props.opts)
        end
      end
    end
    -- Now we have our buffer-scope keymaps
    if client.server_capabilities["documentSymbolProvider"] then
      require("nvim-navic").attach(client, bufnr)
    end
  end,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
}
fns.basic_opts = {
  hints = {
    enable = true,
  },
  on_attach = fns.on_attach,
  capabilities = fns.capabilities,
}
main.opts = {
  inlay_hints = (function()
    if vim.lsp.inlay_hint == nil then return nil end
    return { enabled = true }
  end)(),
}
main.config = function()
  local lspconfig = require("lspconfig")
  -- Set it to have a better behavior when editing the config
  lspconfig.lua_ls.setup({
    on_attach = fns.on_attach,
    capabilities = fns.capabilities,
    settings = {
      Lua = {
        hints = {
          enable = true,
        },
        diagnostics = {
          globals = { "vim" },
        },
        workspace = {
          library = {
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
            [vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy"] = true,
          },
          maxPreload = 100000,
          preloadFileSize = 10000,
        },
      },
    },
  })
  lspconfig.rust_analyzer.setup(fns.basic_opts)
  lspconfig.tsserver.setup(fns.basic_opts)
  lspconfig.pylsp.setup(fns.basic_opts)
  lspconfig.jsonls.setup({
    hints = {
      enable = true,
    },
    on_attach = fns.on_attach,
    capabilities = fns.capabilities,
    settings = {
      schemas = require("config.data.for.lspconfig.jsonsch"),
    },
  })
  lspconfig.html.setup(fns.basic_opts)
  lspconfig.bashls.setup(fns.basic_opts)
end
return main
