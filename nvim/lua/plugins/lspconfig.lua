return {{
    "neovim/nvim-lspconfig",
    opts = {
        servers = {
        -- Ensure mason installs the server
        pyright = {
            handlers = {
                ["textDocument/publishDiagnostics"] = function() end,
            },
            on_attach = function(client, _)
                client.server_capabilities.codeActionProvider = false
            end,
            settings = {
                pyright = {
                disableOrganizeImports = true,
                },
                python = {
                analysis = {
                    autoSearchPaths = true,
                    typeCheckingMode = "basic",
                    useLibraryCodeForTypes = true,
                },
                },
            },
        },
        ruff_lsp = {
            on_attach = function(client, _)
                client.server_capabilities.hoverProvider = false
            end,
            init_options = {
                settings = {
                args = {},
                },
            },
        },
        clangd = {
            -- keys = {
            --   { "<leader>cR", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
            -- },
            -- root_dir = function(fname)
            --   return require("lspconfig.util").root_pattern(
            --     "Makefile",
            --     "configure.ac",
            --     "configure.in",
            --     "config.h.in",
            --     "meson.build",
            --     "meson_options.txt",
            --     "build.ninja"
            --   )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            --     fname
            --   ) or require("lspconfig.util").find_git_ancestor(fname)
            -- end,
            -- capabilities = {
            --   offsetEncoding = { "utf-16" },
            -- },
            cmd = {
                "clangd",
                "--background-index",
                "--clang-tidy",
                "--completion-style=detailed",
                "--function-arg-placeholders",
                "--fallback-style=llvm",
            },
            init_options = {
                usePlaceholders = true,
                completeUnimported = true,
                clangdFileStatus = true,
            },
        },
        },
        setup = {
        clangd = function(_, opts)
            local clangd_ext_opts = require("lazyvim.util").opts("clangd_extensions.nvim")
            require("clangd_extensions").setup(vim.tbl_deep_extend("force", clangd_ext_opts or {}, { server = opts }))
            return false
        end,
        },
    },
}}
