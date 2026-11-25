vim.cmd [[let mapleader = " "]]

vim.cmd [[map Q <Nop>]]
vim.cmd [[nnoremap <Space> <Nop>]]

vim.cmd [[nnoremap <leader>h :wincmd h<CR>]]
vim.cmd [[nnoremap <leader>j :wincmd j<CR>]]
vim.cmd [[nnoremap <leader>k :wincmd k<CR>]]
vim.cmd [[nnoremap <leader>l :wincmd l<CR>]]

vim.keymap.set("n", "<leader>gs", function()
  vim.cmd.Git()
  vim.cmd("silent only")
end, { silent = true, desc = "Fullscreen Fugitive status" })
vim.cmd [[nnoremap <silent> <leader>gp :G push<CR>]]
vim.cmd [[nmap <leader>gh :diffget //3<CR>]]
vim.cmd [[nmap <leader>gu :diffget //2<CR>]]

vim.api.nvim_create_autocmd("User", {
  pattern = "FugitiveIndex",
  callback = function(event)
    vim.keymap.set("n", "dd", function()
      local previous_windows = vim.api.nvim_tabpage_list_wins(0)
      vim.cmd.normal({ args = { vim.keycode("<Plug>fugitive:dd") } })
      if vim.api.nvim_get_current_buf() == event.buf then
        return
      end

      local current = vim.api.nvim_get_current_win()
      local diff = vim.wo[current].diff
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local diff_peer = diff and vim.wo[win].diff and not vim.list_contains(previous_windows, win)
        if win ~= current and not diff_peer then
          if vim.wo[win].diff then
            vim.api.nvim_win_call(win, function() vim.cmd.diffoff() end)
          end
          vim.api.nvim_win_hide(win)
        end
      end
    end, { buffer = event.buf, silent = true, nowait = true, desc = "Fullscreen Fugitive diff" })
  end,
})

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
vim.cmd [[nnoremap <silent><C-j> :cnext<CR>]]
vim.cmd [[nnoremap <silent><C-k> :cprev<CR>]]

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

vim.keymap.set("n", "<leader>qh", require("telescope.builtin").quickfixhistory, { desc = "Quickfix history" })
vim.keymap.set({ "n", "x" }, "<leader>y",
  "<cmd>Telescope yank_history<CR>",
  { desc = "Yank history" })

vim.keymap.set("n", "<leader><leader>", "<cmd>Telescope commands<CR>", {
  desc = "Commands",
})

for _, key in ipairs({ "<ScrollWheelUp>", "<ScrollWheelDown>" }) do
  vim.keymap.set({ "n", "x", "i" }, key, function()
    local win = vim.fn.getmousepos().winid
    if win ~= 0 and vim.wo[win].diff then
      vim.api.nvim_set_current_win(win)
    end
    vim.api.nvim_feedkeys(vim.keycode(key), "in", false)
  end, { desc = "Scroll diff windows together" })
end
