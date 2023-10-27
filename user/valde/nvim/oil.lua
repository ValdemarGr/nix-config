require("oil").setup({
  default_file_explorer = true,
  columns = {
    "icon",
    "size"
  },
})

vim.keymap.set('n', '<leader>nt', '<cmd>Oil .<cr>')
vim.keymap.set('n', '<leader>nf', '<cmd>Oil<cr>')
