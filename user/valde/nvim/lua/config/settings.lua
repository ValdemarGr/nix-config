vim.cmd [[set scrolloff=12]]
vim.cmd [[set noerrorbells]]
vim.cmd [[set tabstop=2 softtabstop=2]]
vim.cmd [[set shiftwidth=2]]
vim.cmd [[set expandtab]]
vim.cmd [[set smartindent]]
vim.cmd [[set nowrap]]
vim.cmd [[set smartcase]]
vim.cmd [[set noswapfile]]
vim.cmd [[set hidden]]
vim.cmd [[:set completeopt=longest,menuone]]
vim.cmd [[set completeopt=menu,menuone,noselect]]
vim.cmd [[set termguicolors]]
vim.cmd [[set number relativenumber]]
vim.cmd [[set nu rnu]]
vim.cmd [[set ttimeout]]
vim.cmd [[set ttimeoutlen=0]]
vim.cmd [[set colorcolumn=120]]
vim.cmd [[set diffopt+=vertical]]
vim.cmd [[set backupdir=~/.vimtmp/]]
vim.cmd [[set directory=~/.vimtmp/]]
vim.cmd [[set shortmess-=F]]
vim.cmd [[set autoread]]

vim.cmd [[syntax on]]
vim.cmd [[let g:gruvbox_termcolors = 256]]
vim.cmd [[set background=dark]]
vim.cmd [[let g:gruvbox_contrast_dark='hard']]
vim.cmd [[colorscheme gruvbox-baby]]
vim.cmd [[highlight Pmenu ctermbg=black guibg=#222222]]

vim.cmd [[let mapleader = " "]]
vim.cmd [[highlight ColorColumn ctermbg=0 guibg=lightgrey]]
vim.cmd [[au FocusGained,BufEnter * :silent! !]]

vim.cmd [[autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart]]
vim.cmd [[autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear]]
vim.cmd [[autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx]]

vim.cmd [[au BufWinEnter NvimTree setlocal rnu]]

vim.cmd [[command W w]]
vim.cmd [[command Wq wq]]
vim.cmd [[command WQ wq]]

vim.cmd [[let g:copilot_assume_mapped = v:true]]
vim.cmd [[let g:copilot_no_tab_map = v:true]]

vim.cmd [[autocmd FileType rescript setlocal commentstring=//\ %s]]

vim.cmd [[augroup lsp]]
vim.cmd [[au!]]
-- vim.cmd [[au FileType scala,sbt lua require("metals").initialize_or_attach(metals_config)]]
vim.cmd [[augroup end]]

vim.cmd([[hi! link LspReferenceText CursorColumn]])
vim.cmd([[hi! link LspReferenceRead CursorColumn]])
vim.cmd([[hi! link LspReferenceWrite CursorColumn]])

vim.cmd [[let g:sql_type_default = 'pgsql']]
vim.cmd [[let g:ftplugin_sql_omni_key = '<C-j>']]
