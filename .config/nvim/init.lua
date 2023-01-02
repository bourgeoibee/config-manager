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

        use {
                'nvim-lualine/lualine.nvim',
                requires = { 'kyazdani42/nvim-web-devicons', opt = true },
        }

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


-- Set lualine as statusline
-- See `:help lualine.txt`
require('lualine').setup {
  options = {
    icons_enabled = false,
    theme = 'auto',
    component_separators = '|',
    section_separators = '',
  },
}

-- Completion

local cmp = require('cmp')

cmp.setup {
        snippet = {
                expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                end,
        },
        mapping = cmp.mapping.preset.insert {
                ['<C-k>'] = cmp.mapping.select_prev_item(),
                ['<C-j>'] = cmp.mapping.select_next_item(),
                ['<C-u>'] = cmp.mapping.scroll_docs(-4),
                ['<C-d>'] = cmp.mapping.scroll_docs(4),
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

-- LSP
require('mason').setup()

local set = vim.keymap.set

local on_attach = function(_, bufnr)
        -- Mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local buf = vim.lsp.buf
        local bufopts = { noremap = true, silent = true, buffer = bufnr }

        set('n', 'gD', buf.declaration, bufopts)
        set('n', 'gd', buf.definition, bufopts)
        set('n', 'gt', buf.type_definition, bufopts)
        set('n', 'gr', buf.references, bufopts)
        set('n', 'gi', buf.implementation, bufopts)

        set('n', 'K', buf.hover, bufopts)
        set('n', '<C-k>', buf.signature_help, bufopts)
        set('n', '<leader>r', buf.rename, bufopts)
        set('n', '<leader>a', buf.code_action, bufopts)
        set('n', '<leader>f', buf.format, bufopts)

        set('n', '<leader>wa', buf.add_workspace_folder, bufopts)
        set('n', '<leader>wr', buf.remove_workspace_folder, bufopts)
        set('n', '<leader>wl', function()
                print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)

end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local lspconfig = require('lspconfig')
local mason_lspconfig = require('mason-lspconfig')

local language_servers = {
        rust_analyzer = {},
        clangd = {},
        gopls = {},
        hls = {},
        jdtls = {},
        sumneko_lua = {
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

mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(language_servers)
}

mason_lspconfig.setup_handlers {
        function(server)
                lspconfig[server].setup {
                        on_attach = on_attach,
                        capabilities = capabilities,
                        settings = language_servers[server],
                }
        end,
}

-- Fuzzy finding
local telescope = require('telescope')

telescope.setup {
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

-- Treesitter
require('nvim-treesitter.configs').setup {
        ensure_installed = { 'help', 'lua', 'rust', 'c', 'cpp', 'go', 'python' },
        highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
        },
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
