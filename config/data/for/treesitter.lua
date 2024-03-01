return {
  build = ":TSUpdate",
  config = function()
    local configs = require("nvim-treesitter.configs")
    configs.setup({
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "rust",
        "python",
        "bash",
        "javascript",
        "fish",
        "json5",
        "yaml",
        "java",
      },
      sync_install = true,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })
  end,
}
