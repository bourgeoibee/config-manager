vim.g.mapleader = ' '

vim.cmd.colorscheme('melange')

require('options')


-- Plugins
local fn = vim.fn

-- Automatically install Packer
local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local packer_bootstrap = false
if fn.empty(fn.glob(install_path)) > 0 then
        packer_bootstrap = true
        fn.system {
                'git',
                'clone',
                '--depth',
                '1',
                'https://github.com/wbthomason/packer.nvim',
                install_path
        }

        vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
        -- Plugin manager
        use 'wbthomason/packer.nvim'

        -- Colorschemes
        use 'savq/melange'

        -- Syntax highlighting
        use {
                'nvim-treesitter/nvim-treesitter',
                run = function()
                        require('nvim-treesitter.install').update({ with_sync = true })
                end,
        }

        use {
                -- Automatically installs language servers
                "williamboman/mason.nvim",
                -- Makes Mason and lspconfig work better together
                "williamboman/mason-lspconfig.nvim",
                -- Native LSP
                "neovim/nvim-lspconfig",
        }

        -- Completion
        use {
                'hrsh7th/cmp-nvim-lua',
                'hrsh7th/cmp-nvim-lsp',
                'hrsh7th/cmp-buffer',
                'hrsh7th/cmp-path',
                'hrsh7th/cmp-cmdline',
                'hrsh7th/nvim-cmp',
        }

        -- Snippet engine
        use 'L3MON4D3/LuaSnip'
        use 'saadparwaiz1/cmp_luasnip'

        -- Debugging
        use 'mfussenegger/nvim-dap'
        use 'rcarriga/nvim-dap-ui'
        use 'theHamsta/nvim-dap-virtual-text'

        -- Get Telescope from release branch
        use {
                'nvim-telescope/telescope.nvim',
                branch = '0.1.x',
                requires = {
                        { 'nvim-lua/plenary.nvim' },
                        { 'BurntSushi/ripgrep' },
                }
        }

        -- Gives telescope a better fuzzy finder
        use {
                'nvim-telescope/telescope-fzf-native.nvim',
                run = 'make',
        }

        -- Automatically set up your configuration after cloning packer.nvim
        if packer_bootstrap then
                require('packer').sync()
        end
end)

-- Space doesn't move cursor
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Completion
local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then
        return "Completion failed to initialize"
end

cmp.setup {
        snippet = {
                expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                end,
        },
        mapping = cmp.mapping.preset.insert {
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-b>'] = cmp.mapping.scroll_docs(-1),
                ['<C-f>'] = cmp.mapping.scroll_docs(1),
                ['<C-y>'] = cmp.mapping.confirm {
                        behavior = cmp.ConfirmBehavior.Insert,
                        select = true,
                },
                ['<C-e>'] = cmp.mapping {
                        i = cmp.mapping.abort(),
                        c = cmp.mapping.close(),
                },
                ['<C-Space>'] = cmp.mapping.complete(),
        },
        sources = {
                { name = 'nvim_lua' },
                { name = 'nvim_lsp' },
                { name = 'luasnip' },
                { name = 'buffer' },
                { name = 'path', option = { trailing_slash = true } },
        },
        confirm_opts = {
                behavior = cmp.ConfirmBehavior.Replace,
                select = true,
        },
}

require('mason').setup()
require('mason-lspconfig').setup {
        ensure_installed = {
                "bashls",
                "clangd",
                "hls",
                "html",
                "jsonls",
                "jdtls",
                "pyright",
                "rust_analyzer",
                "sumneko_lua",
        }
}

-- Setup lsp servers
local on_attach = function(_, bufnr)
        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        local set = vim.keymap.set

        set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        set('n', 'gd', vim.lsp.buf.definition, bufopts)
        set('n', 'gT', vim.lsp.buf.type_definition, bufopts)
        set('n', 'gr', vim.lsp.buf.references, bufopts)
        set('n', 'K', vim.lsp.buf.hover, bufopts)
        set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        set('n', '<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
        set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
        set('n', '<leader>f', vim.lsp.buf.format, bufopts)

        -- Diagnostics
        set('n', '<leader>dk', vim.diagnostic.goto_prev, bufopts)
        set('n', '<leader>dj', vim.diagnostic.goto_next, bufopts)
        set('n', '<leader>de', vim.diagnostic.open_float, bufopts)
        set('n', '<leader>dq', vim.diagnostic.setloclist, bufopts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local lspconfig = require('lspconfig')

lspconfig.clangd.setup {
        on_attach = on_attach,
        capabilities = capabilities,
}

lspconfig.gopls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
}

lspconfig.hls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
}

lspconfig.sumneko_lua.setup {
        on_attach = on_attach,
        capabilities = capabilities,
        settings = {
                Lua = {
                        completion = {
                                callSnippet = "Replace"
                        },
                        diagnostics = {
                                -- Get sumneko_lua to recognize the vim global
                                -- Sadly happens in all lua files not just neovim configuration files
                                globals = { 'vim' }
                        },
                },
        },
}

lspconfig.jdtls.setup {
        on_attach = on_attach,
        capabilities = capabilities,
}

lspconfig.rust_analyzer.setup {
        on_attach = on_attach,
        capabilities = capabilities,
}

-- Fuzzy finding
local telescope = require('telescope')

telescope.setup {
        defaults = {
                prompt_prefix = '> '
        },
        extensions = {
                fzf = {
                        fuzzy = true,
                        override_generic_sorter = true,
                        override_file_sorter = true,
                        case_mode = 'smart_case',
                }
        },
}

-- To get fzf loaded and working with telescope, you need to call
-- load_extension, somewhere after setup function:
telescope.load_extension('fzf')


vim.keymap.set('n', '<leader>f?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader>f/', function()
        require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
                winblend = 10,
                previewer = false,
        })
end, { desc = '[/] Find in current buffer' })
vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>', { silent = true })
vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>', { silent = true })
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>', { silent = true })

-- Treesitter
require('nvim-treesitter.configs').setup {
        highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
        }
}

-- Debugging
--{ noremap=true, silent=true, buffer=bufnr }
--local dap = require('dap')
--vim.keymap.set('n', '<F5>', ":lua require'dap'.continue()<CR>")
--vim.keymap.set('n', '<F10>', ":lua require'dap'.step_over()<CR>")
--vim.keymap.set('n', '<F11>', ":lua require'dap'.step_into()<CR>")
--vim.keymap.set('n', '<F12>', ":lua require'dap'.step_out()<CR>")
--vim.keymap.set('n', '<leader>b', ":lua require'dap'.toggle_breakpoint()<CR>")
--vim.keymap.set('n', '<leader>B', ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>")
--vim.keymap.set('n', '<leader>lp', ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>")
--vim.keymap.set('n', '<leader>dr', ":lua require'dap'.repl.open()<CR>")
--
--
--
--vim.keymap.set('n', '<F4>', require('dapui').toggle, {})
--vim.keymap.set('n', '<F5>', dap.toggle_breakpoint, {})
--vim.keymap.set('n', '<F9>', dap.continue, {})
--
--dap.adapters.lldb = {
--        type = 'executable',
--        command = vim.fn.stdpath('data') .. '/mason/packages/codelldb/extension/adapter/scripts/codelldb',
--        name = 'lldb',
--}
--
--dap.adapters.python = {
--        type = 'executable',
--        command = vim.fn.stdpath('data') .. '/mason/packages/debugpy/debugpy',
--        args = { '-m', 'debugpy.adapter' },
--}
--
--dap.configurations.rust = {
--        {
--                type = 'lldb',
--                request = 'launch',
--                program = '${file}',
--        },
--}
--
--dap.configurations.python {
--        {
--                type = 'python',
--                request = 'launch',
--                name = "launch file",
--                program = "${file}",
--                pythonPath = function()
--                        return '/usr/bin/python'
--                end,
--        },
--}
