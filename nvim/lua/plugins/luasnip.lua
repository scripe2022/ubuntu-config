return {
    {
	    "L3MON4D3/LuaSnip",
        keys = {
            { "<tab>", mode = "i", false },
            { "<tab>", mode = "s", false },
            { "<s-tab>", mode = {"i", "s"}, false },
            { "<c-tab>",
                function()
                    return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
                end,
                expr = true, silent = true, mode = "i",
            },
            { "<c-tab>", function() require("luasnip").jump(1) end, mode = "s" },
        },
        config = function()
            require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/snippets"})
        end,
    }
}
