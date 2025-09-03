return {
    -- Enhanced Go development support
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup({
                -- Disable go.nvim's own LSP setup since we configure gopls separately
                lsp_cfg = false,
                lsp_gofumpt = true,
                lsp_on_attach = false, -- Use LazyVim's default on_attach
                
                -- Test configuration
                test_runner = "go", -- go test
                run_in_floaterm = false,
                
                -- DAP configuration  
                dap_debug = true,
                dap_debug_gui = true,
                dap_debug_keymap = false, -- Use default DAP keymaps
                
                -- Formatting
                gofmt = "gofumpt",
                goimport = "goimports",
                
                -- Icons
                icons = { breakpoint = "🧘", currentpos = "🏃" },
                
                -- Diagnostics
                trouble = true,
                luasnip = true,
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go", "gomod" },
        build = ':lua require("go.install").update_all_sync()', -- Install/update all Go binaries
    },

    -- Enhanced LSP configuration for Go
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            opts.servers = opts.servers or {}
            opts.servers.gopls = {
                settings = {
                    gopls = {
                        -- Analysis
                        analyses = {
                            unusedparams = true,
                            unusedwrite = true,
                            useany = true,
                            nilness = true,
                            shadow = true,
                        },
                        staticcheck = true,
                        vulncheck = "Imports",
                        
                        -- Completion
                        usePlaceholders = true,
                        completeUnimported = true,
                        deepCompletion = true,
                        
                        -- Formatting  
                        gofumpt = true,
                        
                        -- Codelenses
                        codelenses = {
                            generate = true,
                            gc_details = true,
                            test = true,
                            tidy = true,
                            upgrade_dependency = true,
                            vendor = true,
                        },
                        
                        -- Hints
                        hints = {
                            assignVariableTypes = true,
                            compositeLiteralFields = true,
                            compositeLiteralTypes = true,
                            constantValues = true,
                            functionTypeParameters = true,
                            parameterNames = true,
                            rangeVariableTypes = true,
                        },
                    },
                },
            }
            return opts
        end,
    },

    -- Go debugging with Delve
    {
        "leoluz/nvim-dap-go",
        dependencies = {
            "mfussenegger/nvim-dap",
            "rcarriga/nvim-dap-ui",
        },
        ft = "go",
        config = function()
            require("dap-go").setup({
                -- Delve configuration
                delve = {
                    detached = false,
                    cwd = nil, -- Use current working directory
                },
                -- DAP configurations
                dap_configurations = {
                    {
                        type = "go",
                        name = "Debug",
                        request = "launch",
                        program = "${file}",
                    },
                    {
                        type = "go",
                        name = "Debug Package",
                        request = "launch",
                        program = "${workspaceFolder}",
                    },
                    {
                        type = "go",
                        name = "Debug test",
                        request = "launch",
                        mode = "test",
                        program = "${workspaceFolder}",
                    },
                    {
                        type = "go",
                        name = "Debug test (go.mod)",
                        request = "launch",
                        mode = "test",
                        program = "./${relativeFileDirname}",
                    },
                },
            })
            
            -- Go-specific debugging keymaps
            vim.keymap.set("n", "<leader>dgt", function()
                require("dap-go").debug_test()
            end, { desc = "Debug Go Test" })
            
            vim.keymap.set("n", "<leader>dgl", function()
                require("dap-go").debug_last_test()
            end, { desc = "Debug Last Go Test" })
        end,
    },

    -- Ensure Go tools are installed via Mason
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, {
                "gopls",        -- Go LSP
                "delve",        -- Go debugger
                "gofumpt",      -- Go formatter
                "goimports",    -- Go import manager
                "golangci-lint", -- Go linter
                "gomodifytags", -- Go struct tag modifier
                "gotests",      -- Go test generator
                "impl",         -- Go interface implementation generator
            })
        end,
    },

    -- Additional Go utilities
    {
        "olexsmir/gopher.nvim",
        ft = "go",
        config = function()
            require("gopher").setup()
        end,
        build = function()
            vim.cmd([[silent! GoInstallDeps]])
        end,
    },
}
