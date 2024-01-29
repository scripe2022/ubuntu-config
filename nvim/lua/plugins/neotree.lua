local Util = require("lazyvim.util")
return { {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    keys = {
        {
            "<leader>fe",
            function()
                require("neo-tree.command").execute({ position = "right", toggle = true, dir = Util.root() })
            end,
            desc = "Explorer NeoTree (root dir)",
        },
        {
            "<leader>o",
            function()
                require("neo-tree.command").execute({ position = "float", toggle = true, dir = Util.root() })
            end,
            desc = "Explorer NeoTree (root dir)",
        },
    },
    opts = {
        sources = { "filesystem", "buffers", "git_status", "document_symbols" },
        open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
        filesystem = {
            bind_to_cwd = false,
            follow_current_file = { enabled = true },
            use_libuv_file_watcher = true,
        },
        window = {
            position = "right",
            mappings = {
                ["<space>"] = "none",
                ["Y"] = function(state)
                    local node = state.tree:get_node()
                    local path = node:get_id()
                    vim.fn.setreg("+", path, "c")
                end,
            },
        },
        default_component_configs = {
            indent = {
                with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
                expander_collapsed = "",
                expander_expanded = "",
                expander_highlight = "NeoTreeExpander",
            },
        },
    },
} }