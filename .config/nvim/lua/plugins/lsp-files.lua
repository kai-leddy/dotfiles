return {
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/neo-tree.nvim",
    },
    config = function()
      -- TODO: replace this with the util from Snacks that handles all this better
      require("lsp-file-operations").setup()
    end,
  },
}
