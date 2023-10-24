syntax on
let g:gruvbox_termcolors = 256
set background=dark
let g:gruvbox_contrast_dark='hard'
colorscheme gruvbox-baby
highlight Pmenu ctermbg=black guibg=#222222

set scrolloff=12
set noerrorbells
set tabstop=2 softtabstop=2
set shiftwidth=2
set expandtab
set smartindent
set nowrap
set smartcase
set noswapfile
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
" set cursorcolumn
set hidden
:set completeopt=longest,menuone
set completeopt=menu,menuone,noselect
set termguicolors

set number relativenumber
set nu rnu

set ttimeout
set ttimeoutlen=0

set colorcolumn=120
set diffopt+=vertical

let mapleader = " "
" let g:copilot_node_command = "/home/valde/.nvm/versions/node/v16.15.0/bin/node"

highlight ColorColumn ctermbg=0 guibg=lightgrey

set shortmess-=F

set autoread
au FocusGained,BufEnter * :silent! !

let g:sql_type_default = 'pgsql'
let g:ftplugin_sql_omni_key = '<C-j>'

autocmd BufEnter *.{js,jsx,ts,tsx} :syntax sync fromstart
autocmd BufLeave *.{js,jsx,ts,tsx} :syntax sync clear
autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx

au BufWinEnter NvimTree setlocal rnu

"native
map Q <Nop>
nnoremap <Space> <Nop>
command W w
command Wq wq
command WQ wq

nnoremap <leader>h :wincmd h<CR>
nnoremap <leader>j :wincmd j<CR>
nnoremap <leader>k :wincmd k<CR>
nnoremap <leader>l :wincmd l<CR>

"Fug
nnoremap <silent> <leader>gs :G<CR>
nnoremap <silent> <leader>gp :G push<CR>
nmap <leader>gh :diffget //3<CR>
nmap <leader>gu :diffget //2<CR>

""dadbod
"nnoremap <silent> <leader>db :DBUI<CR>

"hop
map <silent><leader>m1 <cmd>HopChar1<CR>
map <silent><leader>m2 <cmd>HopChar2<CR>
map <silent><leader>mp <cmd>HopPattern<CR>
map <silent><leader>mw <cmd>HopWord<CR>

"lsp
" inoremap <silent><expr> <C-Space> compe#complete()
" inoremap <silent><expr> <CR>      compe#confirm('<CR>')
" inoremap <silent><expr> <C-e>     compe#close('<C-e>')
" inoremap <C-f>   <cmd>lua require('cmp').select_next_item()<CR>
" inoremap <silent><expr> <C-d>     compe#scroll({ 'delta': -4 })
" nnoremap <silent><leader>e       <cmd>lua vim.lsp.buf.hover()<CR>
" nnoremap <silent><leader>a       <cmd>lua vim.lsp.buf.code_action()<CR>
"nnoremap <silent>gd              <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent><leader>fo      <cmd>lua vim.lsp.buf.format(nil, 5000)<CR>

inoremap <C-c> <Esc>

"telescope
nnoremap <silent><leader>. <cmd>lua require('valde').telescope.search_dotfiles()<CR>
nnoremap <silent><leader>W <cmd>lua require('valde').telescope.search_wiki()<CR>
nnoremap <silent><leader>i <cmd>lua require('telescope.builtin').find_files()<CR>
nnoremap <silent><leader>p <cmd>lua require('telescope.builtin').git_files()<CR>
nnoremap <silent><leader>// <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>
nnoremap <silent><leader>u <cmd>lua require('telescope.builtin').buffers()<CR>
" nnoremap <silent><leader>x <cmd>lua require('telescope').extensions.zoxide.list()<CR>
" nnoremap <silent><leader>s <cmd>lua require('telescope.builtin').live_grep()<CR>
nnoremap <silent><leader>s <cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>
nnoremap <silent><leader>o <cmd>lua require('telescope.builtin').git_status()<CR>
nnoremap <silent>gd              <cmd>lua require('telescope.builtin').lsp_definitions()<CR>
nnoremap <silent><leader>gw              <cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>

nnoremap <silent><leader>gil             <cmd>Octo issue list<CR>
nnoremap <silent><leader>ga             <cmd>Octo actions<CR>

" nnoremap <silent><leader>gd              <cmd>lua require('telescope.builtin').lsp_references()<CR>

"saga is no longer maintained??
" nnoremap <silent>gd <cmd>lua require('lspsaga.provider').lsp_finder()<CR>
" nnoremap <silent><leader>gd <cmd>lua require('lspsaga.provider').preview_definition()<CR>

" binds before
" nnoremap <silent><leader>e       <cmd>lua require('lspsaga.hover').render_hover_doc()<CR>
" nnoremap <silent><leader>q       <cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>
" nnoremap <silent><leader>a       <cmd>lua require('lspsaga.codeaction').code_action()<CR>
" nnoremap <silent><leader>dn       <cmd>lua require('lspsaga.diagnostic').lsp_jump_diagnostic_next()<CR>
" nnoremap <silent><leader>dp       <cmd>lua require('lspsaga.diagnostic').lsp_jump_diagnostic_prev()<CR>
" nnoremap <silent><leader>dc       <cmd>lua require('lspsaga.diagnostic').show_cursor_diagnostics()<CR>
" nnoremap <silent><leader>dl       <cmd>lua require('lspsaga.diagnostic').show_line_diagnostics()<CR>

" telescope equivalents
nnoremap <silent><leader>e       <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent><leader>q       <cmd>lua vim.lsp.buf.signature_help()<CR>
" nnoremap <silent><leader>a       <cmd>Telescope lsp_code_actions<CR>
nnoremap <silent><leader>a        <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent><leader>dw       <cmd>Telescope diagnostics<CR>
nnoremap <silent><leader>r       <cmd>Telescope neoclip<CR>
nnoremap <silent><leader>dn       <cmd>lua vim.diagnostic.goto_next()<CR>
nnoremap <silent><leader>dp       <cmd>lua vim.diagnostic.goto_prev()<CR>
" nnoremap <silent><leader>dc       <cmd>lua vim.diagnostic.show_position_diagnostics()<CR>
nnoremap <silent><leader>dl       <cmd>lua vim.diagnostic.open_float()<CR>

" nnoremap <silent><leader>x <cmd>buffer term://*zsh*<CR>

" buildsystem
let g:bazel_make_command = "Make"
nnoremap <silent><leader>bb    <cmd>Bazel build //...<CR>
nnoremap <silent><leader>bt    <cmd>Bazel test --test_output=errors //...<CR>
nnoremap <silent><leader>br    <cmd>Dispatch! REPIN=1 bazel run @unpinned_maven//:pin<CR>
nnoremap <silent><leader>bf    <cmd>e %:h/BUILD.bazel<CR>

nnoremap <silent><leader>qn    <cmd>cnext<CR>
nnoremap <silent><leader>qp    <cmd>cprev<CR>
nnoremap <silent><leader>qo    <cmd>copen<CR>

nnoremap <silent><leader>tlspact <cmd>:lua vim.lsp.buf.code_action({apply = true, filter= function (x) return string.find(x["title"], "Insert type annotation") end})<cr>

nnoremap <silent><leader>x <cmd>lua require("harpoon.term").gotoTerminal(1)<CR>
nnoremap <silent><leader>X <cmd>lua require("harpoon.term").gotoTerminal(2)<CR>

nnoremap <silent><leader>cp <cmd>let @" = expand("%:~:.")<cr>

let g:copilot_assume_mapped = v:true
let g:copilot_no_tab_map = v:true
imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")
