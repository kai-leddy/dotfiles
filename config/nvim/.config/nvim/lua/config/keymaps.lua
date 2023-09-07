-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- keybings I'm used to for saving files and buffers
vim.keymap.set("n", "<leader>fs", "<cmd>w<cr><esc>", { desc = "Save file" })
vim.keymap.set("n", "<leader>bs", "<cmd>w<cr><esc>", { desc = "Save buffer" })
vim.keymap.set("n", "<leader>bS", "<cmd>wa<cr><esc>", { desc = "Save all modified buffers" })

-- move to window using the <leader>w prefix and hjkl
vim.keymap.set("n", "<leader>wh", "<cmd>wincmd h<cr><esc>", { desc = "Move to window left" })
vim.keymap.set("n", "<leader>wj", "<cmd>wincmd j<cr><esc>", { desc = "Move to window below" })
vim.keymap.set("n", "<leader>wk", "<cmd>wincmd k<cr><esc>", { desc = "Move to window above" })
vim.keymap.set("n", "<leader>wl", "<cmd>wincmd l<cr><esc>", { desc = "Move to window right" })

-- quick switch to "other" buffer with backspace
vim.keymap.set("n", "<BS>", "<cmd>buffer #<cr><esc>", { desc = "Switch to previous buffer" })

-- quick switch to "other" window with tab
vim.keymap.set("n", "<Tab>", "<cmd>wincmd w<cr><esc>", { desc = "Switch to previous window" })

-- reopen the last Telescope search results with <leader> apostrophe
vim.keymap.set("n", "<leader>'", "<cmd>Telescope resume<cr><esc>", { desc = "Re-open last search results" })

-- fix issues with quickly pressing esc and then j or k
vim.keymap.del("i", "<A-j>")
vim.keymap.del("i", "<A-k>")
