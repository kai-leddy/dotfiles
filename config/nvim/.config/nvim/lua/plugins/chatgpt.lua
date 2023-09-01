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
  -- TODO: try out Gp.nvim instead for native functionality
  -- setup ChatGPT plugin
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
    opts = {
      api_key_cmd = "security find-generic-password -w -a " .. vim.env.LOGNAME .. " -s neovim-openai-key",
      openai_params = {
        model = "gpt-4",
      },
      openai_edit_params = {
        model = "gpt-4",
      },
      use_openai_functions_for_edits = true, -- NOTE: this is experimental - might have to disable it again
    },
    -- TODO: tidy up these keybindings, add ones for the Run actions and improve the keys used for the dialogs
    -- also possibly modify them directly, to ensure they work with GPT4
    keys = {
      { "<leader>ac", "<cmd>ChatGPT<cr>", desc = "Chat" },
      {
        "<leader>ae",
        "<cmd>ChatGPTEditWithInstructions<cr>",
        mode = { "n", "v" },
        desc = "Edit with instructions",
      },
      {
        "<leader>aC",
        "<cmd>ChatGPTRun complete_code<cr>",
        mode = { "n", "v" },
        desc = "Complete code",
      },
      {
        "<leader>ad",
        "<cmd>ChatGPTRun docstring<cr>",
        mode = { "n", "v" },
        desc = "Generate docstring",
      },
      {
        "<leader>at",
        "<cmd>ChatGPTRun add_tests<cr>",
        mode = { "n", "v" },
        desc = "Add tests",
      },
      {
        "<leader>ao",
        "<cmd>ChatGPTRun optimize_code<cr>",
        mode = { "n", "v" },
        desc = "Optimize code",
      },
      {
        "<leader>as",
        "<cmd>ChatGPTRun summarize<cr>",
        mode = { "n", "v" },
        desc = "Summarize",
      },
      {
        "<leader>af",
        "<cmd>ChatGPTRun fix_bugs<cr>",
        mode = { "n", "v" },
        desc = "Fix bugs",
      },
      {
        "<leader>aE",
        "<cmd>ChatGPTRun explain_code<cr>",
        mode = { "n", "v" },
        desc = "Explain code",
      },
    },
  },
}
