return {
  -- Enhanced Git integration with blame functionality
  {
    "lewis6991/gitsigns.nvim",
    event = "LazyFile",
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      signs_staged = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
      },
      -- Show blame info when cursor is on a line
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 300,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
      current_line_blame_formatter = "<author>, <author_time:%Y-%m-%d> - <summary>",
      
      -- Preview hunks inline
      preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      },
      
      -- Advanced diff options
      diff_opts = {
        algorithm = "patience",
        internal = true,
      },
      
      -- Word diff for better granular changes
      word_diff = false,
      
      -- Attach to untracked files
      attach_to_untracked = true,
      
      -- Better performance
      max_file_length = 40000,
      
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns
        
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end
        
        -- Navigation between hunks
        map("n", "]h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "]c", bang = true })
          else
            gs.nav_hunk("next")
          end
        end, "Next Hunk")
        
        map("n", "[h", function()
          if vim.wo.diff then
            vim.cmd.normal({ "[c", bang = true })
          else
            gs.nav_hunk("prev")
          end
        end, "Prev Hunk")
        
        -- Actions
        map("n", "<leader>ghs", gs.stage_hunk, "Stage Hunk")
        map("n", "<leader>ghr", gs.reset_hunk, "Reset Hunk")
        map("v", "<leader>ghs", function()
          gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Stage Hunk")
        map("v", "<leader>ghr", function()
          gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Reset Hunk")
        
        map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Preview Hunk")
        
        -- Blame functionality
        map("n", "<leader>ghb", function()
          gs.blame_line({ full = true })
        end, "Blame Line")
        map("n", "<leader>ghB", function()
          gs.blame_line({ full = true, ignore_whitespace = true })
        end, "Blame Line (Ignore Whitespace)")
        map("n", "<leader>ghtb", gs.toggle_current_line_blame, "Toggle Line Blame")
        
        -- Diff functionality
        map("n", "<leader>ghd", gs.diffthis, "Diff This")
        map("n", "<leader>ghD", function()
          gs.diffthis("~")
        end, "Diff This ~")
        
        -- Text object for hunks
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
      end,
    },
  },

  -- Advanced Git blame with popup window
  {
    "f-person/git-blame.nvim",
    event = "LazyFile",
    opts = {
      enabled = false, -- Start disabled, toggle with command
      message_template = " <summary> • <date> • <author>",
      date_format = "%m-%d-%Y %H:%M:%S",
      virtual_text_column = 1,
      highlight_group = "Comment",
      set_extmark_options = {
        priority = 7,
      },
      display_virtual_text = true,
      ignored_filetypes = {
        "lua",
      },
      delay = 250,
    },
    config = function(_, opts)
      require("gitblame").setup(opts)
      
      -- Custom keymaps for git-blame
      vim.keymap.set("n", "<leader>gbt", "<cmd>GitBlameToggle<cr>", { desc = "Toggle Git Blame" })
      vim.keymap.set("n", "<leader>gbe", "<cmd>GitBlameEnable<cr>", { desc = "Enable Git Blame" })
      vim.keymap.set("n", "<leader>gbd", "<cmd>GitBlameDisable<cr>", { desc = "Disable Git Blame" })
      vim.keymap.set("n", "<leader>gbo", "<cmd>GitBlameOpenCommitURL<cr>", { desc = "Open Commit URL" })
      vim.keymap.set("n", "<leader>gbc", "<cmd>GitBlameCopyCommitURL<cr>", { desc = "Copy Commit URL" })
    end,
  },

  -- Git file history and advanced blame
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
    config = function()
      require("diffview").setup({
        diff_binaries = false,
        enhanced_diff_hl = true,
        git_cmd = { "git" },
        use_icons = true,
        show_help_hints = true,
        watch_index = true,
        icons = {
          folder_closed = "",
          folder_open = "",
        },
        signs = {
          fold_closed = "",
          fold_open = "",
          done = "✓",
        },
        view = {
          default = {
            layout = "diff2_horizontal",
            disable_diagnostics = true,
          },
          merge_tool = {
            layout = "diff3_horizontal",
            disable_diagnostics = true,
          },
          file_history = {
            layout = "diff2_horizontal",
            disable_diagnostics = true,
          },
        },
        file_panel = {
          listing_style = "tree",
          tree_options = {
            flatten_dirs = true,
            folder_statuses = "only_folded",
          },
          win_config = {
            position = "left",
            width = 35,
            win_opts = {}
          },
        },
        file_history_panel = {
          log_options = {
            git = {
              single_file = {
                diff_merges = "combined",
              },
              multi_file = {
                diff_merges = "first-parent",
              },
            },
          },
          win_config = {
            position = "bottom",
            height = 16,
            win_opts = {}
          },
        },
        commit_log_panel = {
          win_config = {
            win_opts = {},
          }
        },
        default_args = {
          DiffviewOpen = {},
          DiffviewFileHistory = {},
        },
        hooks = {},
        keymaps = {
          disable_defaults = false,
          view = {
            { "n", "<tab>", function()
                require("diffview.actions").select_next_entry()
              end, { desc = "Open the diff for the next file" } },
            { "n", "<s-tab>", function()
                require("diffview.actions").select_prev_entry()
              end, { desc = "Open the diff for the previous file" } },
          },
          file_panel = {
            { "n", "j", function()
                require("diffview.actions").next_entry()
              end, { desc = "Bring the cursor to the next file entry" } },
            { "n", "<down>", function()
                require("diffview.actions").next_entry()
              end, { desc = "Bring the cursor to the next file entry" } },
            { "n", "k", function()
                require("diffview.actions").prev_entry()
              end, { desc = "Bring the cursor to the previous file entry" } },
          },
          file_history_panel = {
            { "n", "g!", function()
                require("diffview.actions").options()
              end, { desc = "Open the option panel" } },
          },
          option_panel = {
            { "n", "<tab>", function()
                require("diffview.actions").select_entry()
              end, { desc = "Change the current option" } },
          },
        },
      })
      
      -- Custom keymaps for diffview
      vim.keymap.set("n", "<leader>gdo", "<cmd>DiffviewOpen<cr>", { desc = "Open Diffview" })
      vim.keymap.set("n", "<leader>gdc", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" })
      vim.keymap.set("n", "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", { desc = "File History" })
      vim.keymap.set("n", "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", { desc = "Current File History" })
    end,
  },
}