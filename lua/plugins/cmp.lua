-- https://github.com/hrsh7th/nvim-cmp

-- https://github.com/hrsh7th/nvim-cmp

return {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",                    -- word completions from open buffers
        "hrsh7th/cmp-path",                      -- filesystem path completions
        "hrsh7th/cmp-nvim-lsp-signature-help",   -- shows parameter hints as you type args
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "onsails/lspkind.nvim",                  -- VSCode-style icons + labels in menu
    },

    config = function()
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        local lspkind = require("lspkind")

        cmp.setup({
            snippet = {
                expand = function(args)
                    luasnip.lsp_expand(args.body)
                end,
            },

            -- Show a border around the completion docs popup
            window = {
                completion = cmp.config.window.bordered(),
                documentation = cmp.config.window.bordered(),
            },

            -- Format menu entries with icons and source labels
            formatting = {
                format = lspkind.cmp_format({
                    mode = "symbol_text",
                    maxwidth = 50,
                    ellipsis_char = "...",
                    show_labelDetails = true, -- shows extra detail e.g. "(method)" next to name
                    menu = {
                        nvim_lsp              = "[LSP]",
                        luasnip               = "[Snip]",
                        buffer                = "[Buf]",
                        path                  = "[Path]",
                        nvim_lsp_signature_help = "[Sig]",
                    },
                }),
            },

            mapping = cmp.mapping.preset.insert({
                ['<C-d>']     = cmp.mapping.scroll_docs(-4),
                ['<C-f>']     = cmp.mapping.scroll_docs(4),
                ['<C-Space>'] = cmp.mapping.complete(),
                ['<C-e>']     = cmp.mapping.abort(),   -- close completion without confirming

                -- select = false: only confirm what you explicitly navigated to
                ['<CR>'] = cmp.mapping.confirm({ select = false }),

                ['<A-e>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_next_item()
                    elseif luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                ['<A-q>'] = cmp.mapping(function(fallback)
                    if cmp.visible() then
                        cmp.select_prev_item()
                    elseif luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                -- Jump forward through snippet placeholders (e.g. function args)
                ['<Tab>'] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(1) then
                        luasnip.jump(1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),

                ['<S-Tab>'] = cmp.mapping(function(fallback)
                    if luasnip.jumpable(-1) then
                        luasnip.jump(-1)
                    else
                        fallback()
                    end
                end, { 'i', 's' }),
            }),

            sources = cmp.config.sources({
                -- Ordered by priority
                { name = 'nvim_lsp_signature_help' }, -- param hints first, appears inline as you open parens
                { name = 'nvim_lsp',  max_item_count = 20 },
                { name = 'luasnip',   max_item_count = 10 },
                { name = 'buffer',    max_item_count = 10, keyword_length = 3 },
                { name = 'path' },
            }),

            -- Don't complete in comments
            enabled = function()
                local context = require('cmp.config.context')
                if vim.api.nvim_get_mode().mode == 'c' then
                    return true
                else
                    return not context.in_treesitter_capture("comment")
                        and not context.in_syntax_group("Comment")
                end
            end,
        })
    end,
}
