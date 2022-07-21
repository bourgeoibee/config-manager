local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Have packer get source every time it is saved
local packer_group = vim.api.nvim_create_augroup('Packer', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
    command = 'source <afile> | PackerComplete',
    group = packer_group,
    pattern = vim.fn.expand '$MYVIMRC',
})

-- Have packer use a popup window
require('packer').init  {
    display = {
	open_fn = function()
	    return require('packer.util').float { border = 'rounded' }
	end,    
    },
}

-- Installs plugins
return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use 'neovim/nvim-lspconfig'

    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'

    use 'L3MON4D3/LuaSnip'
    use 'saadparwaiz1/cmp_luasnip'

    use 'nvim-treesitter/nvim-treesitter'
    use 'nvim-lua/plenary.nvim'

    use 'nvim-telescope/telescope.nvim'


    use 'lunarvim/colorschemes'

    if packer then
	require('packer').sync()
    end
end)
