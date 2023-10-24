vim.opt_global.shortmess:remove("F")

metals_config = require('metals').bare_config()
metals_config.init_options.statusBarProvider = "on"
metals_config.settings = {
  showImplicitArguments = true,
  enableSemanticHighlighting = false,
  metalsBinaryPath = "${metals-pkg}/bin/metals"
}

vim.cmd [[augroup lsp]]
vim.cmd [[au!]]
vim.cmd [[au FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)]]
vim.cmd [[augroup end]]

vim.cmd([[hi! link LspReferenceText CursorColumn]])
vim.cmd([[hi! link LspReferenceRead CursorColumn]])
vim.cmd([[hi! link LspReferenceWrite CursorColumn]])
