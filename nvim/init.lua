vim.g.mapleader = ' '

local opt = vim.opt

opt.softtabstop = 4      -- Tab length
opt.shiftwidth = 4       -- Indentation length
opt.number = true        -- Line numbers on left
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
--opt.completeopt = { "menu", "menuone", "noselect" } -- ???

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

require('packer').startup(function()
    -- Plugin manager
    use 'wbthomason/packer.nvim'

    --use 'onsails/lspkind.nvim'
	
    -- Snippet engine
    use 'L3MON4D3/LuaSnip'

    -- Completion engine
    use 'hrsh7th/nvim-cmp'

    -- nvim-cmp completion sources
    use 'neovim/nvim-lspconfig'
    use { 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' }
    use { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' }
    use { 'hrsh7th/cmp-path', after = 'nvim-cmp' }
    use { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' }
    use { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' }
    use 'saadparwaiz1/cmp_luasnip' -- For LuaSnip

    -- Telescope fuzzy finder
    use {
	'nvim-telescope/telescope.nvim',
	branch = '0.1.x',
	requires = { 
	    { 'nvim-lua/plenary.nvim' },
	    { 'BurntSushi/ripgrep' },
	}
    }

    -- Debugging
    use 'mfussenegger/nvim-dap' -- Debug Adapter Protocol
    use 'leoluz/nvim-dap-go'
    use 'rcarriga/nvim-dap-ui'

    -- Treesitter better syntax highlighting
    use 'nvim-treesitter/nvim-treesitter'
end)

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
    mapping = cmp.mapping.preset.insert({
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
    }),
    sources = {
	{ name = 'nvim_lua' },
	{ name = 'nvim_lsp' },
	{ name = 'luasnip' },
	{ name = 'buffer', keyword_length = 5 },
	{ name = 'path', option = { trailing_slash = true } },
    },
    confirm_opts = {
	behavior = cmp.ConfirmBehavior.Replace,
	select = true,
    },
}

local lspconfig = require('lspconfig')


-- Language servers
local on_attach = function(_, bufnr) 
    -- Mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local bufopts = { noremap=true, silent=true, buffer=bufnr }

    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
    vim.keymap.set('n', 'gT', vim.lsp.buf.type_definition, bufopts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
    vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
    vim.keymap.set('n', '<leader>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, bufopts)
    vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, bufopts)
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
    vim.keymap.set('n', '<leader>f', vim.lsp.buf.formatting, bufopts)

    -- Diagnostics
    vim.keymap.set('n', '<leader>dk', vim.diagnostic.goto_prev, bufopts)
    vim.keymap.set('n', '<leader>dj', vim.diagnostic.goto_next, bufopts)
    vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, bufopts)
    vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, bufopts)

end

lspconfig['gopls'].setup {
    on_attach = on_attach,
}

-- Telescope
require('telescope').setup {
    defaults = {
        prompt_prefix = '> '
    }
}

-- Treesitter
require('nvim-treesitter.configs').setup {
    highlight = {
	enable = true
    }
}
