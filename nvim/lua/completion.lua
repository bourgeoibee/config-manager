local cmp_status_ok, cmp = pcall(require, 'cmp')
if not cmp_status_ok then
    return
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
    { name = 'path', option = {trailing_slash = true} },
    },
    confirm_opts = {
	behavior = cmp.ConfirmBehavior.Replace,
	select = true,
    },
}
