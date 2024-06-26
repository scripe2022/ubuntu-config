return {
    {
        "stevearc/conform.nvim",
        dependencies = { "mason.nvim" },
        lazy = true,
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format()
                end,
                mode = { "n", "v" },
                desc = "Format Injected Langs",
            },
        },
        opts = function()
            local plugin = require("lazy.core.config").plugins["conform.nvim"]

            ---@class ConformOpts
            local opts = {
                -- LazyVim will use these options when formatting with the conform.nvim formatter
                format = {
                    timeout_ms = 3000,
                    async = false, -- not recommended to change
                    quiet = false, -- not recommended to change
                },
                ---@type table<string, conform.FormatterUnit[]>
                formatters_by_ft = {
                    lua = { "stylua" },
                    fish = { "fish_indent" },
                    sh = { "shfmt" },
                    cpp = { "clangformat" },
                    c = { "clangformat" },
                    cuda = { "clangformat" },
                    ["python"] = { "black" },
                },
                -- The options you set here will be merged with the builtin formatters.
                -- You can also define any custom formatters here.
                ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
                formatters = {
                    injected = { options = { ignore_errors = true } },
                    clangformat = {
                        command = "clang-format",
                        args = { "-style=file:/home/jyh/.config/config/clang-format" },
                    },
                    -- black = {
                    --     command = "black",
                    --     args = { "--quiet", "-", "-l", "120", "t", "py37"},
                    -- }
                    -- # Example of using dprint only when a dprint.json file is present
                    -- dprint = {
                    --   condition = function(ctx)
                    --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
                    --   end,
                    -- },
                    --
                    -- # Example of using shfmt with extra args
                    -- shfmt = {
                    --   prepend_args = { "-i", "2", "-ci" },
                    -- },
                },
            }
            return opts
        end,
    },
}
