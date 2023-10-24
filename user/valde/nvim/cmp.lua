require('cmp')
require('cmp.utils.window')
local types = require('cmp.types')

local cmp = require('cmp')

cmp.setup {
  mapping = {
    ['<Down>'] = {
      i = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Select }),
    },
    ['<Up>'] = {
      i = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Select }),
    },
    ['<C-n>'] = {
      i = cmp.mapping.select_next_item({ behavior = types.cmp.SelectBehavior.Insert }),
    },
    ['<C-p>'] = {
      i = cmp.mapping.select_prev_item({ behavior = types.cmp.SelectBehavior.Insert }),
    },
    ['<C-e>'] = {
      i = cmp.mapping.abort(),
    },
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<Tab>'] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name =  'nvim_lsp' },
    { name =  'luasnip' },
    { name =  'treesitter' },
    { name =  'nvim_lsp_signature_help' },
    { name =  'path' },
    { name =  'buffer' },
  })
}

require("cmp_git").setup()

local capabilities = require('cmp_nvim_lsp').default_capabilities()
