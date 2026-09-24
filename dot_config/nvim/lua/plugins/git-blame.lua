return {
  {
    "FabijanZulj/blame.nvim",
    lazy = false,
    config = function()
      require("blame").setup({})
    end,
    keys = {
      {
        "<leader>gB",
        "<cmd>BlameToggle<cr>",
        desc = "Git Blame Buffer",
      },
    },
    opts = {
      focus_blame = false,
      merge_consecutive = false,
    },
  },
}
