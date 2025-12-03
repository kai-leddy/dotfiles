return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
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
}
