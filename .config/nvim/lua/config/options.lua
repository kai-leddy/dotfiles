-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- line wrapping for long lines (mostly Tailwind CSS)
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Prepend mise shims to PATH
vim.env.PATH = vim.env.HOME .. "/.local/share/mise/shims:" .. vim.env.PATH

vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#C3E88D" })
