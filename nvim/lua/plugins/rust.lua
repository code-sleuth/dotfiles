return {
    -- Rust development with debugging support
    {
        'mrcjkb/rustaceanvim',
        version = '^5',
        lazy = false,
        ft = "rust",
        init = function()
            vim.g.rustaceanvim = {
                server = {
                    on_attach = function(_, bufnr)
                        -- Rust-specific keymaps
                        vim.keymap.set("n", "<leader>cR", function()
                            vim.cmd.RustLsp("codeAction")
                        end, { desc = "Code Action", buffer = bufnr })
                        vim.keymap.set("n", "<leader>dr", function()
                            vim.cmd.RustLsp("debuggables")
                        end, { desc = "Rust Debuggables", buffer = bufnr })
                    end,
                    settings = {
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
                        },
                    },
                },
                dap = {
                    -- Will automatically configure codelldb if mason has it installed
                    autoload_configurations = true,
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

    -- Ensure Rust tools are available
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, {
                "rust-analyzer",
                "codelldb",
            })
        end,
    },
}
