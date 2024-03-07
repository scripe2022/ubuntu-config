return {
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            table.insert(opts.ensure_installed, "black")
            vim.list_extend(opts.ensure_installed, {"ruff",})
        end,
    },
    {
        
    }
}
