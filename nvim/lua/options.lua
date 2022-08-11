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