return {
    -- Disable rust-analyzer in lspconfig to prevent conflicts with rustaceanvim
    {
        "neovim/nvim-lspconfig",
        opts = function(_, opts)
            opts.servers = opts.servers or {}
            -- Explicitly disable rust_analyzer
            opts.servers.rust_analyzer = false
            return opts
        end,
    },

    -- Rust development with debugging support
    {
        'mrcjkb/rustaceanvim',
        version = '^6',
        lazy = false, -- This plugin is already lazy
        init = function()
            -- Prevent other plugins from starting rust-analyzer
            vim.g.rustaceanvim_lsp_client_id = nil
            vim.g.rustaceanvim = {
                tools = {
                    executor = "termopen",        -- Executor for runnables/debuggables
                    test_executor = "background", -- Background test execution
                    enable_nextest = true,        -- Use cargo-nextest if available
                    enable_clippy = true,         -- Enable clippy checks
                },
                server = {
                    auto_attach = true, -- Automatically attach to rust files
                    on_attach = function(_, bufnr)
                        -- Rust-specific keymaps
                        vim.keymap.set("n", "<leader>cR", function()
                            vim.cmd.RustLsp("codeAction")
                        end, { desc = "Code Action", buffer = bufnr })
                        vim.keymap.set("n", "<leader>dr", function()
                            vim.cmd.RustLsp("debuggables")
                        end, { desc = "Rust Debuggables", buffer = bufnr })
                        vim.keymap.set("n", "<leader>rr", function()
                            vim.cmd.RustLsp("runnables")
                        end, { desc = "Rust Runnables", buffer = bufnr })
                        vim.keymap.set("n", "<leader>rt", function()
                            vim.cmd.RustLsp("testables")
                        end, { desc = "Rust Testables", buffer = bufnr })
                    end,
                    default_settings = {
                        ["rust-analyzer"] = {
                            cargo = {
                                allFeatures = true,
                                loadOutDirsFromCheck = true,
                            },
                            checkOnSave = {
                                command = "clippy",
                            },
                            procMacro = {
                                enable = true,
                            },
                            diagnostics = {
                                enable = true,
                                experimental = {
                                    enable = true,
                                },
                            },
                        },
                    },
                },
                dap = {
                    autoload_configurations = true, -- Automatically configure debug adapters
                },
            }
        end,
    },

    -- Enhanced Rust file support
    {
        'rust-lang/rust.vim',
        ft = "rust",
        init = function()
            vim.g.rustfmt_autosave = 1
        end
    },

    -- Cargo.toml support
    {
        'saecki/crates.nvim',
        event = { "BufRead Cargo.toml" },
        config = function()
            require("crates").setup({
                completion = {
                    cmp = { enabled = true },
                },
                lsp = {
                    enabled = true,
                    actions = true,
                    completion = true,
                    hover = true,
                },
            })
        end,
    },
}
