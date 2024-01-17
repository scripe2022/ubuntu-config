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
        }
    }
} }