local cmp = require("cmp")
return {
    {
        'hrsh7th/nvim-cmp',
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } }),
        opts = {
            mapping = cmp.mapping.preset.insert({
                ["<CR>"] = {},
                -- ["<Tab>"] = {},
                ["<S-CR>"] = cmp.mapping.confirm(),
                -- ["<CR>"] = cmp.mapping.abort()
            }),
            sources = cmp.config.sources({
                { name = "luasnip" },
                { name = "nvim_lsp" },
                --   { name = "path" },
                }, {
            --   { name = "buffer" },
            }),

        }
    }
}