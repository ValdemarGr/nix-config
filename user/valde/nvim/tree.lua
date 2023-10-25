require("nvim-tree").setup {
  view = {
    width = "34%"
  },
  actions = {
    open_file = {
      quit_on_open = true
    }
  }
}

function toggle()
  require("nvim-tree.api").tree.toggle()
  vim.wo.number = true
  vim.wo.relativenumber = true
end

function find_file()
  require("nvim-tree.api").tree.toggle({
    find_file = true
  })
  vim.wo.number = true
  vim.wo.relativenumber = true
end

vim.keymap.set('n', '<leader>nt', toggle, { noremap = true })
vim.keymap.set('n', '<leader>nf', find_file, { noremap = true })
