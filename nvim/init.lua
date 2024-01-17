-- bootstrap lazy.nvim, LazyVim and your plugins
vim.cmd('autocmd BufEnter * set formatoptions-=cro')
vim.cmd('autocmd BufEnter * setlocal formatoptions-=cro')
require("config.lazy")