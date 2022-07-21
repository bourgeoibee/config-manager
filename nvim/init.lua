vim.g.mapleader = ' '

require('options')

-- Plugins
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

require('completion')
require('lsp')
require('debugging')

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
