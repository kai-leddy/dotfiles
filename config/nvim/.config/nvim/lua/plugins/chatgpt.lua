return {
  -- setup group prefix description with which-key
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>a"] = { name = "+ai" },
      },
    },
  },
  -- setup ChatGPT plugin
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    commit = "24bcca7", -- until this is fixed: https://github.com/jackMort/ChatGPT.nvim/issues/265
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      api_key_cmd = "security find-generic-password -w -a " .. vim.env.LOGNAME .. " -s neovim-openai-key",
    },
    keys = {
      { "<leader>ac", "<cmd>ChatGPT<cr>", { desc = "Chat" } },
      { "<leader>aC", "<cmd>ChatGPTActAs<cr>", { desc = "Chat As" } },
      { "<leader>ae", "<cmd>ChatGPTEditWithInstructions<cr>", { desc = "Edit with instructions" } },
    },
    -- TODO: tidy up these keybindings, add ones for the Run actions and improve the keys used for the dialogs
  },
}
