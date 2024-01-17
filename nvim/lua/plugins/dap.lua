return {
    {
        "mfussenegger/nvim-dap",

        dependencies = {

            -- fancy UI for the debugger
            {
                "rcarriga/nvim-dap-ui",
                -- stylua: ignore
                keys = {
                    { "<leader>du", function() require("dapui").toggle({ }) end, desc = "Dap UI" },
                    { "<leader>de", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
                    { "<C-p>", function() require("dapui").eval() end, desc = "Eval", mode = {"n", "v"} },
                },
                opts = {
                    layouts = {
                        {
                            elements = {
                                -- { id = "repl", size = 0.5 },
                                -- { id = "console", size = 0.5 }
                                { id = "watches", size = 0.5 },
                                { id = "scopes", size = 0.5 }
                            },
                            position = "bottom",
                            size = 25
                        },
                        {
                            elements = {
                                -- { id = "scopes", size = 0.25 },
                                { id = "repl", size = 0.17 },
                                { id = "console", size = 0.17 },
                                { id = "breakpoints", size = 0.33 },
                                { id = "stacks", size = 0.33 },
                                -- { id = "watches", size = 0.25 }
                            },
                            position = "left",
                            size = 40
                        },
                    }
                },
                config = function(_, opts)
                    -- setup dap config by VsCode launch.json file
                    -- require("dap.ext.vscode").load_launchjs()
                    local dap = require("dap")
                    local dapui = require("dapui")
                    dapui.setup(opts)
                    dap.listeners.after.event_initialized["dapui_config"] = function()
                    dapui.open({})
                    end
                    dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                    end
                    dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                    end
                end,
            },

            -- virtual text for the debugger
            {
                "theHamsta/nvim-dap-virtual-text",
                opts = {},
            },

            -- which key integration
            {
                "folke/which-key.nvim",
                optional = true,
                opts = {
                    defaults = {
                    ["<leader>d"] = { name = "+debug" },
                    },
                },
            },

            -- mason.nvim integration
            {
                "jay-babu/mason-nvim-dap.nvim",
                dependencies = "mason.nvim",
                cmd = { "DapInstall", "DapUninstall" },
                opts = {
                    -- Makes a best effort to setup the various debuggers with
                    -- reasonable debug configurations
                    automatic_installation = true,

                    -- You can provide additional configuration to the handlers,
                    -- see mason-nvim-dap README for more information
                    handlers = {},

                    -- You'll need to check that you have the required things installed
                    -- online, please don't ask me how to install them :)
                    ensure_installed = {
                    -- Update this to ensure that you have the debuggers for the langs you want
                    },
                },
            },
        },

  -- stylua: ignore
        keys = {
            -- { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            { "<F6>", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
            -- { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<F5>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
            { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
            { "<leader>da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
            { "<leader>dC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
            { "<leader>dg", function() require("dap").goto_() end, desc = "Go to line (no execute)" },
            -- { "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
            { "<F1>", function() require("dap").step_into() end, desc = "Step Into" },
            { "<leader>dj", function() require("dap").down() end, desc = "Down" },
            { "<leader>dk", function() require("dap").up() end, desc = "Up" },
            { "<leader>dl", function() require("dap").run_last() end, desc = "Run Last" },
            { "<leader>do", function() require("dap").step_out() end, desc = "Step Out" },
            -- { "<leader>dO", function() require("dap").step_over() end, desc = "Step Over" },
            { "<F2>", function() require("dap").step_over() end, desc = "Step Over" },
            { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
            { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
            { "<leader>ds", function() require("dap").session() end, desc = "Session" },
            { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
            { "<F7>", function() require("dap").terminate() end, desc = "Terminate" },
            { "<leader>dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },

        },
    }
}