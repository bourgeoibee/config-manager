vim.g.mapleader = " "

local set = vim.keymap.set


set('n', '<C-h>', '<C-w>h', { noremap = true })
set('n', '<C-j>', '<C-w>j', { noremap = true })
set('n', '<C-k>', '<C-w>k', { noremap = true })
set('n', '<C-l>', '<C-w>l', { noremap = true })

set({ 'n', 'i' }, '<C-s>', '<cmd>w<CR>')

set('n', '<leader>s', '<cmd>source ~/.config/nvim/init.lua<CR>')

set('n', '<leader>e', '<cmd>Lexplore 30<CR>', { noremap = true })

set('v', '<A-j>', '<cmd>move .+1<CR>', { noremap = true })
set('v', '<A-k>', '<cmd>move .-2<CR>', { noremap = true })
