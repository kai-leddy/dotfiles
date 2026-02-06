return {
  {
    -- Disable neo-tree in favour of oil.nvim
    "nvim-neo-tree/neo-tree.nvim",
    enabled = false,
  },
  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    lazy = false,
    keys = {
      { "<leader>e", "<cmd>Oil<CR>", desc = "Explorer" },
      { "-", "<cmd>Oil<CR>", desc = "Explorer" },
    },
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
        -- This function defines what will never be shown, even when `show_hidden` is set
        is_always_hidden = function(name, bufnr)
          return name:match("^%.%.$")
        end,
      },
      float = {
        padding = 5,
      },
    },
  },
}
