-- Reset cursor style on exit
vim.api.nvim_create_autocmd({ "VimLeave" }, {
  pattern = { "*" },
  command = 'set guicursor= | call chansend(v:stderr, "\\x1b[ q")',
})
