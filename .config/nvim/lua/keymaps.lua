-- Diagnostics
local set = vim.keymap.set

set('v', 'J', ":move '>+1<CR>gv=gv", {})
set('v', 'K', ":move '<-2<CR>gv=gv", {})

set('n', '<leader>dp', vim.diagnostic.goto_prev, {})
set('n', '<leader>dn', vim.diagnostic.goto_next, {})
set('n', '<leader>de', vim.diagnostic.open_float, {})
set('n', '<leader>dq', vim.diagnostic.setloclist, {})

-- Fuzzy Finding
local builtin = require('telescope.builtin')

set('n', '<leader>f?', builtin.oldfiles, { desc = 'Find recently opened files' })
set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by grep' })
set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
set('n', '<leader>f/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
        })
end, { desc = 'Find in current buffer' })
