return {
    {
        "rose-pine/neovim",
        name = "rose-pine",
        priority = 1000,
        opts = {
            variant = "auto",      -- auto, main, moon, or dawn
            dark_variant = "main", -- main, moon, or dawn
            dim_inactive_windows = false,
            extend_background_behind_borders = true,

            styles = {
                bold = true,
                italic = true,
                transparency = true,
            },

            groups = {
                border = "muted",
                link = "iris",
                panel = "surface",

                error = "love",
                hint = "iris",
                info = "foam",
                warn = "gold",

                git_add = "foam",
                git_change = "rose",
                git_delete = "love",
                git_dirty = "rose",
                git_ignore = "muted",
                git_merge = "iris",
                git_rename = "pine",
                git_stage = "iris",
                git_text = "rose",
                git_untracked = "subtle",

                headings = {
                    h1 = "iris",
                    h2 = "foam",
                    h3 = "rose",
                    h4 = "gold",
                    h5 = "pine",
                    h6 = "foam",
                }
            },

            highlight_groups = {
                -- Keywords and control flow (purple/mauve)
                ["@keyword"] = { fg = "#c6a0f6" }, -- Catppuccin mauve
                ["@keyword.function"] = { fg = "#c6a0f6" },
                ["@keyword.operator"] = { fg = "#c6a0f6" },
                ["@conditional"] = { fg = "#c6a0f6" },
                ["@repeat"] = { fg = "#c6a0f6" },
                ["@exception"] = { fg = "#c6a0f6" },

                -- Functions (blue)
                ["@function"] = { fg = "#8aadf4" }, -- Catppuccin blue
                ["@function.call"] = { fg = "#8aadf4" },
                ["@function.builtin"] = { fg = "#8aadf4" },
                ["@method"] = { fg = "#8aadf4" },
                ["@method.call"] = { fg = "#8aadf4" },

                -- Strings (green)
                ["@string"] = { fg = "#a6da95" },
                ["@string.escape"] = { fg = "#f5a97f" },
                ["@string.regex"] = { fg = "#a6da95" },

                -- Numbers and booleans (peach/orange)
                ["@number"] = { fg = "#f5a97f" },
                ["@float"] = { fg = "#f5a97f" },
                ["@boolean"] = { fg = "#f5a97f" },

                -- Variables and identifiers
                ["@variable"] = { fg = "text" },
                ["@variable.builtin"] = { fg = "#ed8796" },
                ["@parameter"] = { fg = "text" },

                -- Types (yellow)
                ["@type"] = { fg = "#eed49f" },
                ["@type.builtin"] = { fg = "#eed49f" },
                ["@type.definition"] = { fg = "#eed49f" },

                -- Properties and fields
                ["@property"] = { fg = "text" },
                ["@field"] = { fg = "text" },

                -- Operators
                ["@operator"] = { fg = "#91d7e3" },

                -- Constants
                ["@constant"] = { fg = "#f5a97f" },
                ["@constant.builtin"] = { fg = "#f5a97f" },

                -- Comments (keep Rose Pine style but enhance)
                ["@comment"] = { fg = "muted", italic = true },

                -- Punctuation
                ["@punctuation.bracket"] = { fg = "subtle" },
                ["@punctuation.delimiter"] = { fg = "subtle" },

                -- Tags (for markup languages)
                ["@tag"] = { fg = "#f5bde6" },           -- Catppuccin pink
                ["@tag.attribute"] = { fg = "#eed49f" }, -- Catppuccin yellow

                -- Special
                ["@constructor"] = { fg = "#8aadf4" }, -- Catppuccin blue
                ["@namespace"] = { fg = "#eed49f" },   -- Catppuccin yellow
            },
        },
    },

    -- Configure LazyVim to load rose-pine
    {
        "LazyVim/LazyVim",
        opts = {
            colorscheme = "rose-pine",
        },
    },
}
