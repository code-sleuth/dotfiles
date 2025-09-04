return {
  -- WakaTime time tracking plugin
  {
    "wakatime/vim-wakatime",
    lazy = false, -- Load immediately to track all activity
    config = function()
      -- WakaTime configuration
      -- The plugin will prompt for API key on first use if not set
      
      -- Optional: Set custom project detection
      -- vim.g.wakatime_PythonBinary = '/usr/bin/python3' -- Custom Python path if needed
      
      -- Optional: Override project name detection
      -- vim.g.wakatime_OverrideCommandPrefix = 'wakatime'
      
      -- Optional: Set debug mode (uncomment for troubleshooting)
      -- vim.g.wakatime_LogLevel = 'DEBUG'
      
      -- Optional: Exclude certain file types from tracking
      -- vim.g.wakatime_ExcludeUnknownProject = 1
      
      -- Optional: Include only certain file types
      -- vim.g.wakatime_IncludeOnlyWithProjectFile = 0
      
      -- Status line integration (if you want to show WakaTime status)
      vim.g.wakatime_SessionFile = vim.fn.expand("~/.wakatime.session")
      
      -- Custom keymaps for WakaTime
      vim.keymap.set("n", "<leader>wt", "<cmd>WakaTimeToday<cr>", { desc = "WakaTime Today" })
      vim.keymap.set("n", "<leader>wd", "<cmd>WakaTimeDebugEnable<cr>", { desc = "WakaTime Debug Enable" })
      vim.keymap.set("n", "<leader>wD", "<cmd>WakaTimeDebugDisable<cr>", { desc = "WakaTime Debug Disable" })
      vim.keymap.set("n", "<leader>ws", "<cmd>WakaTimeScreenRecorderEnable<cr>", { desc = "WakaTime Screen Recorder Enable" })
      vim.keymap.set("n", "<leader>wS", "<cmd>WakaTimeScreenRecorderDisable<cr>", { desc = "WakaTime Screen Recorder Disable" })
    end,
  },
  
  -- Optional: Status line integration to show WakaTime info
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      -- Add WakaTime to the status line
      table.insert(opts.sections.lualine_x, {
        function()
          local ok, wakatime = pcall(require, "wakatime")
          if ok then
            return wakatime.status()
          end
          return ""
        end,
        cond = function()
          return vim.g.wakatime_loaded == 1
        end,
        color = { fg = "#f7768e" }, -- Rose Pine inspired color
      })
    end,
  },
}