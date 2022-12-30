-- Space doesn't move cursor
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Diagnostics
local set = vim.keymap.set

set('n', '<leader>dp', vim.diagnostic.goto_prev)
set('n', '<leader>dn', vim.diagnostic.goto_next)
set('n', '<leader>de', vim.diagnostic.open_float)
set('n', '<leader>dq', vim.diagnostic.setloclist)

-- Fuzzy Finding
local builtin = require('telescope.builtin')

vim.keymap.set('n', '<leader>f?', builtin.oldfiles, { desc = 'Find recently opened files' })
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Find by grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Find buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Find help' })
vim.keymap.set('n', '<leader>f/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
        })
end, { desc = 'Find in current buffer' })
