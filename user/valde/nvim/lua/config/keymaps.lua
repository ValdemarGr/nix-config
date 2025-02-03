vim.cmd [[let mapleader = " "]]

vim.cmd [[map Q <Nop>]]
vim.cmd [[nnoremap <Space> <Nop>]]

vim.cmd [[nnoremap <leader>h :wincmd h<CR>]]
vim.cmd [[nnoremap <leader>j :wincmd j<CR>]]
vim.cmd [[nnoremap <leader>k :wincmd k<CR>]]
vim.cmd [[nnoremap <leader>l :wincmd l<CR>]]

vim.cmd [[nnoremap <silent> <leader>gs :G<CR>]]
vim.cmd [[nnoremap <silent> <leader>gp :G push<CR>]]
vim.cmd [[nmap <leader>gh :diffget //3<CR>]]
vim.cmd [[nmap <leader>gu :diffget //2<CR>]]

vim.cmd [[nnoremap <silent><leader>fo      <cmd>lua vim.lsp.buf.format(nil, 5000)<CR>]]
vim.cmd [[inoremap <C-c> <Esc>]]

vim.cmd [[nnoremap <silent><leader>i <cmd>lua require('telescope.builtin').find_files()<CR>]]
vim.cmd [[nnoremap <silent><leader>p <cmd>lua require('telescope.builtin').git_files()<CR>]]
vim.cmd [[nnoremap <silent><leader>// <cmd>lua require('telescope.builtin').current_buffer_fuzzy_find()<CR>]]
vim.cmd [[nnoremap <silent><leader>u <cmd>lua require('telescope.builtin').buffers()<CR>]]
vim.cmd [[nnoremap <silent><leader>s <cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>]]
vim.cmd [[nnoremap <silent><leader>o <cmd>lua require('telescope.builtin').git_status()<CR>]]
vim.cmd [[nnoremap <silent>gd              <cmd>lua require('telescope.builtin').lsp_definitions()<CR>]]
vim.cmd [[nnoremap <silent><leader>gw              <cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>]]

vim.cmd [[nnoremap <silent><leader>gil             <cmd>Octo issue list<CR>]]
vim.cmd [[nnoremap <silent><leader>ga             <cmd>Octo actions<CR>]]

vim.cmd [[nnoremap <silent><leader>e       <cmd>lua vim.lsp.buf.hover()<CR>]]
vim.cmd [[nnoremap <silent><leader>q       <cmd>lua vim.lsp.buf.signature_help()<CR>]]

vim.cmd [[nnoremap <silent><leader>a        <cmd>lua vim.lsp.buf.code_action()<CR>]]
vim.cmd [[nnoremap <silent><leader>dw       <cmd>Telescope diagnostics<CR>]]
vim.cmd [[nnoremap <silent><leader>r       <cmd>Telescope neoclip<CR>]]
vim.cmd [[nnoremap <silent><leader>dn       <cmd>lua vim.diagnostic.goto_next()<CR>]]
vim.cmd [[nnoremap <silent><leader>dp       <cmd>lua vim.diagnostic.goto_prev()<CR>]]
vim.cmd [[nnoremap <silent><leader>dl       <cmd>lua vim.diagnostic.open_float()<CR>]]

vim.cmd [[let g:bazel_make_command = "Make"]]
vim.cmd [[nnoremap <silent><leader>bb    <cmd>Bazel build //...<CR>]]
vim.cmd [[nnoremap <silent><leader>bt    <cmd>Bazel test --test_output=errors //...<CR>]]
vim.cmd [[nnoremap <silent><leader>br    <cmd>Dispatch! REPIN=1 bazel run @unpinned_maven//:pin<CR>]]
vim.cmd [[nnoremap <silent><leader>bf    <cmd>e %:h/BUILD.bazel<CR>]]

vim.cmd [[nnoremap <silent><leader>qn    <cmd>cnext<CR>]]
vim.cmd [[nnoremap <silent><leader>qp    <cmd>cprev<CR>]]
vim.cmd [[nnoremap <silent><leader>qo    <cmd>copen<CR>]]

vim.cmd [[nnoremap <silent><leader>tlspact <cmd>:lua vim.lsp.buf.code_action({apply = true, filter= function (x) return string.find(x["title"], "Insert type annotation") end})<cr>]]

vim.cmd [[nnoremap <silent><leader>x <cmd>lua require("harpoon.term").gotoTerminal(1)<CR>]]
vim.cmd [[nnoremap <silent><leader>X <cmd>lua require("harpoon.term").gotoTerminal(2)<CR>]]

vim.cmd [[nnoremap <silent><leader>cp <cmd>let @" = expand("%:~:.")<cr>]]

vim.cmd [[let g:copilot_assume_mapped = v:true]]
vim.cmd [[let g:copilot_no_tab_map = v:true]]
vim.cmd [[imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")]]

vim.cmd [[autocmd FileType rescript setlocal commentstring=//\ %s]]
vim.cmd [[autocmd FileType proto setlocal commentstring=//\ %s]]
vim.cmd [[autocmd FileType sql setlocal commentstring=--\ %s]]
