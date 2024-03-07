-- bootstrap lazy.nvim, LazyVim and your plugins
vim.cmd('autocmd BufEnter * set formatoptions-=cro')
vim.cmd('autocmd BufEnter * setlocal formatoptions-=cro')
vim.g.mkdp_open_to_the_world = 1
vim.api.nvim_exec([[
function OpenMarkdownPreview(url)
    execute "silent !kitty @ launch --keep-focus awrit " . a:url
endfunction
]], false)
vim.g.mkdp_browserfunc = 'OpenMarkdownPreview'

require("config.lazy")
