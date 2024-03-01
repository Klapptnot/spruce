return {
  name = "null-ls",
  config = function()
    local null_ls = require("null-ls")
    -- local helpers = require("null-ls.helpers")

    null_ls.setup({
      sources = {
        -- Formatting
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.black.with({ extra_args = { "--fast" } }),
        null_ls.builtins.formatting.shfmt.with({ extra_args = { "-i", "2" } }),
        null_ls.builtins.formatting.rustfmt,
        -- Diagnostics
        null_ls.builtins.diagnostics.eslint,
      },
    })
  end,
}
