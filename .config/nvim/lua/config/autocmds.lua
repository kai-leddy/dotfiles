-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- no auto continue comments on new line
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_auto_comment", {}),
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

-- no lsp for .env files
vim.api.nvim_create_autocmd("BufReadPre", {
  group = vim.api.nvim_create_augroup("dotenv_no_lsp", { clear = true }),
  pattern = { ".env", ".env.*" },
  callback = function(ev)
    vim.diagnostic.enable(false, { bufnr = ev.buf })
  end,
})
