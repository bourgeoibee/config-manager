-- Space doesn't move cursor
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

require('options')

-- Automatically install Packer
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	-- Colorscheme
	{
		'savq/melange',
		priority = 1000,
		config = function()
			vim.cmd([[ colorscheme melange ]])
		end,
	},

	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'kyazdani42/nvim-web-devicons' },
		-- Set lualine as statusline
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = true,
				theme = 'auto',
				component_separators = '|',
				section_separators = '',
			}
		},
	},

	-- Syntax highlighting
	{
		'nvim-treesitter/nvim-treesitter',
		config = function()
			require('nvim-treesitter.install').update({ with_sync = true })
		end,
	},

	-- Native LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			-- Mason automatically installs language servers
			"williamboman/mason.nvim",
			-- Makes Mason and lspconfig work better together
			"williamboman/mason-lspconfig.nvim",
			'folke/neodev.nvim',
		},
	},


	-- Completion
	{
		'hrsh7th/nvim-cmp',
		dependencies = {
			'hrsh7th/cmp-nvim-lua',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'hrsh7th/cmp-cmdline',
			'L3MON4D3/LuaSnip',
			'saadparwaiz1/cmp_luasnip',
		},
	},

	-- Debugging
	'mfussenegger/nvim-dap',
	'rcarriga/nvim-dap-ui',
	'theHamsta/nvim-dap-virtual-text',

	-- Fuzzy finding
	-- Gives telescope a better fuzzy finder
	{
		'nvim-telescope/telescope-fzf-native.nvim',
		build = 'make',
	},

	-- Get Telescope from release branch
	{
		'nvim-telescope/telescope.nvim',
		dependencies = {
			'nvim-lua/plenary.nvim',
			'BurntSushi/ripgrep',
		},
	},
}, {})

-- Telescope fuzzy finder
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

require('nvim-treesitter.configs').setup {
	ensure_installed = { 'help', 'lua', 'rust', 'c', 'cpp', 'go', 'python' },
	sync_install = false,
	auto_install = true,
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
}

-- Auto setup and install lsp
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

local on_attach = function(_, bufnr)
	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local buf = vim.lsp.buf
	local set = vim.keymap.set
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

require('neodev').setup()

local language_servers = {
	rust_analyzer = {},
	clangd = {},
	gopls = {},
	hls = {},
	jdtls = {},
	lua_ls = {
		Lua = {
			workspace = { checkThirdParty = false },
			--telemetry = { enable = 'false' },
		},
	},
	zls = {},
}

require('mason').setup()

local mason_lspconfig = require('mason-lspconfig')
mason_lspconfig.setup {
	ensure_installed = vim.tbl_keys(language_servers)
}

mason_lspconfig.setup_handlers {
	function(server)
		require('lspconfig')[server].setup {
			on_attach = on_attach,
			capabilities = capabilities,
			settings = language_servers[server],
		}
	end,
}

local cmp = require('cmp')
cmp.setup {
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert {
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-Enter>'] = cmp.mapping.confirm {
			behavior = cmp.ConfirmBehavior.Insert,
			select = true,
		},
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

require('keymaps')

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
