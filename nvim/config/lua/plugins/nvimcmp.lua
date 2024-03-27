local cmp = require("cmp")

return {
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            {
                "zbirenbaum/copilot-cmp",
                dependencies = "copilot.lua",
                opts = {},
                config = function(_, opts)
                    local copilot_cmp = require("copilot_cmp")
                    copilot_cmp.setup(opts)
                    require("lazyvim.util").lsp.on_attach(function(client)
                        if client.name == "copilot" then
                            copilot_cmp._on_insert_enter({})
                        end
                    end)
                end,
            },
        },
        require("luasnip.loaders.from_vscode").lazy_load({ paths = { vim.fn.stdpath("config") .. "/snippets" } }),
        cmp.setup({ 
            view = { entries = "custom", selection_order = 'near_cursor' },
        }),
        opts = {
            mapping = cmp.mapping.preset.insert({
                ["<C-=>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<C-->"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
                ["<CR>"] = {},
                ["<C-p>"] = {},
                ["<S-CR>"] = cmp.mapping.confirm(),
                ["<C-CR>"] = cmp.mapping.confirm(),
            }),
            sources = cmp.config.sources({
                { name = "luasnip" },
                { name = "copilot" },
                { name = "nvim_lsp" },
                --   { name = "path" },
            }, {
                { name = "buffer" },
            }),

        }
    }
}
