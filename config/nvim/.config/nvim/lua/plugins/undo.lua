return {
  -- setup undo tree functionality with telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "debugloop/telescope-undo.nvim",
        config = function()
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
    },
    opts = {
      extensions = {
        undo = {
          mappings = {
            -- i = {
            --   -- IMPORTANT: Note that telescope-undo must be available when telescope is configured if
            --   -- you want to replicate these defaults and use the following actions. This means
            --   -- installing as a dependency of telescope in it's `requirements` and loading this
            --   -- extension from there instead of having the separate plugin definition as outlined
            --   -- above.
            --   ["<cr>"] = require("telescope-undo.actions").restore,
            --   ["<C-cr>"] = require("telescope-undo.actions").yank_additions,
            --   ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
            -- },
          },
        },
      },
    },
  },
}
