-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.opt.wrap = true
vim.g.codeium_os = "Darwin"
vim.g.codeium_arch = "arm64"

-- Font configuration for GUI Neovim clients (neovide, etc.)
if vim.g.neovide then
    vim.g.neovide_font_family = "JetBrainsMono Nerd Font"
    vim.g.neovide_font_size = 18
    vim.g.neovide_padding_top = 10
    vim.g.neovide_padding_bottom = 10
    vim.g.neovide_padding_right = 10
    vim.g.neovide_padding_left = 10
end

-- Font configuration for other GUI clients
vim.opt.guifont = "JetBrainsMono Nerd Font:h18"

-- LSP Server to use for Rust.
-- Set to "bacon-ls" to use bacon-ls instead of rust-analyzer.
-- only for diagnostics. The rest of LSP support will still be
-- provided by rust-analyzer.
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"
