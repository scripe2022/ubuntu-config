return {
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            keywords = {
                DEBUG = { icon = "⏲ ", color = "test", alt = { "D_BEGIN", "D_END" } },
            },
        },
    },
}
