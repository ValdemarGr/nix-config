function main_config(terraform_ls, metals, rescript_lsp, node, rust_analyzer)
  require('config/settings')
  require('config/keymaps')
  require('config/cmp')
  require('config/oil')
  require('config/telescope')

  vim.g.copilot_node_command = node
  vim.g.copilot_filetypes = { ['*'] = true }
  require('leap')
  vim.keymap.set({ "n" }, "<leader>M", "<Plug>(leap-backward-to)")
  vim.keymap.set({ "n" }, "<leader>m", "<Plug>(leap-forward-to)")

  vim.keymap.set({ "n" }, "`", "'", { noremap = true })
  vim.keymap.set({ "n" }, "'", "`", { noremap = true })
  require('octo').setup()
  require('lspconfig').terraformls.setup{
    cmd = { terraform_ls, "serve" }
  }
  require('lspconfig').graphql.setup{}

  vim.opt_global.shortmess:remove("F")

  metals_config = require('metals').bare_config()
  metals_config.init_options.statusBarProvider = "on"
  metals_config.settings = {
    showImplicitArguments = true,
    enableSemanticHighlighting = false,
    metalsBinaryPath = metals
  }
  metals_config.find_root_dir = function ()
    return vim.fn.getcwd()
  end
  vim.cmd [[au FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)]]

  require('lspconfig').rust_analyzer.setup{
    cmd = { rust_analyzer }
  }

  require("nvim-treesitter.configs").setup{
    highlight = {
      enable = true
    }
  }

  vim.cmd [[augroup Authzed]]
  vim.cmd [[au!]]
  vim.cmd [[autocmd BufNewFile,BufRead *.authzed set filetype=authzed]]
  vim.cmd [[autocmd BufNewFile,BufRead *.zed set filetype=authzed]]
  vim.cmd [[autocmd BufNewFile,BufRead *.azd set filetype=authzed]]
  vim.cmd [[augroup end]]

  vim.keymap.set("n", "<leader>.", function() require("harpoon.mark").add_file() end)
  vim.keymap.set("n", "<leader>,", function() require("harpoon.ui").toggle_quick_menu() end)

  vim.keymap.set("n", "<C-h>", function() require("harpoon.ui").nav_file(1) end)
  vim.keymap.set("n", "<C-t>", function() require("harpoon.ui").nav_file(2) end)
  vim.keymap.set("n", "<C-n>", function() require("harpoon.ui").nav_file(3) end)
  vim.keymap.set("n", "<C-s>", function() require("harpoon.ui").nav_file(4) end)

  require('lspconfig').rescriptls.setup{
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    cmd = {
      rescript_lsp
    }
  }
end

function setup(m)
  function must(name)
    local x = m[name]
    if x == nil then
      error("module setup parameter " .. name .. " not found")
    end
    return x
  end

  local terraform_ls = must("terraform_ls")
  local metals = must("metals")
  local rescript_lsp = must("rescript_lsp")
  local node = must("node")
  local rust_analyzer = must("rust_analyzer")

  main_config(terraform_ls, metals, rescript_lsp, node, rust_analyzer)
end

return setup
