vim.g.mapleader = ' '

vim.cmd.colorscheme('habamax')

local opt = vim.opt

opt.softtabstop = 4      -- Tab length
opt.shiftwidth = 4       -- Indentation length
opt.expandtab = true     -- Expand tabs to spaces
opt.number = true        -- Line numbers on left
opt.relativenumber = true
opt.incsearch = true     -- Highlight as you search
opt.hlsearch = false     -- Don't highlight after search
opt.errorbells = false   -- No annoying error bell sounds
opt.visualbell = true
opt.wrap = false         -- Disable line wrapping
--opt.cursorline = true  -- Underline the line the cursor is on
opt.scrolloff = 8        -- Keep 8 lines above and below cursor
opt.autoindent = true    -- Copy indentation of current line onto new line
opt.smartindent = true   -- Indents are inserted based on syntax
opt.updatetime = 300     -- How many milliseconds inbetween swap file updates
opt.termguicolors = true -- 24-bit RGB color TUI
opt.completeopt = { "menu", "menuone", "noselect" } -- ???

-- Plugins
local fn = vim.fn

-- Automatically install Packer
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    packer_bootstrap = fn.system {
	'git',
	'clone',
	'--depth',
	'1',
	'https://github.com/wbthomason/packer.nvim',
	install_path,
    }
    vim.cmd [[ packadd packer.nvim ]]
end

require('packer').startup(function(use)
    -- Plugin manager
    use 'wbthomason/packer.nvim'

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

    --use 'folke/lua-dev.nvim'

    -- nvim-cmp completion sources
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'

    -- Completion engine
    use 'hrsh7th/nvim-cmp'

    -- Snippet engine
    use {
	'L3MON4D3/LuaSnip',
	tag = 'v<CurrentMajor>.*',
    }
    use 'saadparwaiz1/cmp_luasnip'

    -- Debugging
    use 'mfussenegger/nvim-dap'

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
end)

-- Space doesn't move cursor
vim.keymap.set({'n', 'v' }, '<Space>', '<Nop>', { silent = true })


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

-- Setup lua-dev before lspconfig
--require('lua-dev').setup()

-- Setup lsp servers
local on_attach = function(_, bufnr)
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }
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
    set('n', '<leader>f', vim.lsp.buf.formatting, bufopts)

    -- Diagnostics
    set('n', '<leader>dk', vim.diagnostic.goto_prev, bufopts)
    set('n', '<leader>dj', vim.diagnostic.goto_next, bufopts)
    set('n', '<leader>de', vim.diagnostic.open_float, bufopts)
    set('n', '<leader>dq', vim.diagnostic.setloclist, bufopts)
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

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


vim.keymap.set({ 'n', 'v' }, '<leader>ff', ':Telescope find_files<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>fg', ':Telescope live_grep<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>fb', ':Telescope buffers<CR>', { silent = true })
vim.keymap.set({ 'n', 'v' }, '<leader>fh', ':Telescope help_tags<CR>', { silent = true })

-- Treesitter
require('nvim-treesitter.configs').setup {
    highlight = {
	enable = true,
	additional_vim_regex_highlighting = false,
    }
}
