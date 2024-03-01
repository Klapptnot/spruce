local __plugins__ = {
  --#region Dependencies of a lot of plugins
  ["nvim-tree/nvim-web-devicons"] = {},
  ["nvim-lua/plenary.nvim"] = {},
  --#endregion

  -- Tabs for buffers
  ["nanozuki/tabby.nvim"] = require("config.data.for.tabby"),

  -- Fuzzy files finder
  ["nvim-telescope/telescope.nvim"] = { tag = "0.1.5" },

  -- Beautification of vim.ui
  ["stevearc/dressing.nvim"] = {},

  -- Error and trouble list window
  ["folke/trouble.nvim"] = {},

  -- Replace vim.notify with floating notifications
  ["rcarriga/nvim-notify"] = {
    name = "notify",
    init = function()
      require("notify").setup({
        background_colour = "#000000", -- Just to ignore notification
      })
      vim.notify = require("notify")
    end,
  },

  -- Filesystem tree with a lot of features
  ["nvim-neo-tree/neo-tree.nvim"] = {
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "3rd/image.nvim",
    },
  },

  -- Syntax highlighting and language support
  ["nvim-treesitter/nvim-treesitter"] = require("config.data.for.treesitter"),

  -- Nice shortcuts management and guide
  ["Cassin01/wf.nvim"] = require("config.data.for.wf"),
  -- ["folke/which-key.nvim"] = { event = "VeryLazy", },

  -- Autoclose pairs of brackets or quotes
  ["windwp/nvim-autopairs"] = { event = "InsertEnter" },

  -- Highlight symbols
  ["RRethy/vim-illuminate"] = {},

  -- Nice and fast context bar
  ["utilyre/barbecue.nvim"] = {
    name = "barbecue",
    version = "*",
    dependencies = {
      "SmiteshP/nvim-navic",
    },
  },

  -- Comment lines with one mapping
  ["numToStr/Comment.nvim"] = {
    opts = {},
    lazy = false,
  },

  -- Fast and powerful Git integration
  ["lewis6991/gitsigns.nvim"] = require("config.data.for.gitsigns"),

  -- Clean external packages management
  ["williamboman/mason.nvim"] = { config = function() require("mason").setup() end },

  -- Easy LSP config for mason
  ["williamboman/mason-lspconfig.nvim"] = require("config.data.for.masonlsp"),

  -- LSP config helper
  ["neovim/nvim-lspconfig"] = require("config.data.for.lspconfig"),

  -- Wrap tools in LSP functions
  ["nvimtools/none-ls.nvim"] = require("config.data.for.null_ls"),

  -- Completion popup window
  ["hrsh7th/nvim-cmp"] = require("config.data.for.cmp"),

  -- LSP powered symbols management and analysis
  ["simrat39/symbols-outline.nvim"] = require("config.data.for.symbols_outline"),

  -- A beautiful color palette
  ["catppuccin/nvim"] = {
    name = "catppuccin",
    priority = 1000,
    -- config = function()
    --   require("catppuccin").setup()
    --   vim.cmd.colorscheme("catppuccin")
    -- end,
  },

  -- And another color palette to not use other ones
  ["EdenEast/nightfox.nvim"] = {
    lazy = false,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          terminal_colors = true,
          -- transparent = true,
        },
      })
      vim.cmd.colorscheme("duskfox")
    end,
  },
}

return __plugins__
