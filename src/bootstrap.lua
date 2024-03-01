-- Set lazy as it appears in GitHub
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- Clone repo if lazy is not found
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
-- Add prioritized
vim.opt.rtp:prepend(lazypath)
