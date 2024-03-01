--& Load spruce files

-- Add help files
vim.cmd("silent! helptags " .. vim.fn.stdpath("config") .. "/doc")

-- Cupcake colors
require("src.cupcake").apply()
require("src.spruce.highlight").load()
require("src.spruce.plugin.vibib"):load() -- Load and set vibib as statusline
require("src.spruce.plugin.term").setup({})

-- Add the uninstaller command (Sadge)
require("src.spruce.remove")
-- Add the configure command
require("src.spruce.configure")
