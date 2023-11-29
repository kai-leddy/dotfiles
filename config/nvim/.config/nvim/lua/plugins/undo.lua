return {
  -- setup undo tree functionality with telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "debugloop/telescope-undo.nvim",
    },
    config = function()
      local opts = {
        extensions = {
          undo = {
            mappings = {
              i = {
                ["<s-cr>"] = require("telescope-undo.actions").yank_additions,
                ["<c-cr>"] = require("telescope-undo.actions").yank_deletions,
                ["<cr>"] = require("telescope-undo.actions").restore,
              },
            },
          },
        },
      }

      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
    keys = {
      {
        "<leader>bu",
        -- stylua: ignore
        function() require("telescope").extensions.undo.undo() end,
        desc = "Undo tree",
      },
    },
  },
}
