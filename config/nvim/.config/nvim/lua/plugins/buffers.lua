return {
  {
    "ahmedkhalf/project.nvim",
    opts = {
      -- auto changing the cwd isn't actually that helpful
      manual_mode = true,
    },
  },
  {
    "akinsho/bufferline.nvim",
    keys = {
      { "<leader>1", "<cmd>BufferLineGoToBuffer 1<cr>" },
      { "<leader>2", "<cmd>BufferLineGoToBuffer 2<cr>" },
      { "<leader>3", "<cmd>BufferLineGoToBuffer 3<cr>" },
      { "<leader>4", "<cmd>BufferLineGoToBuffer 4<cr>" },
      { "<leader>5", "<cmd>BufferLineGoToBuffer 5<cr>" },
    },
  },
}
