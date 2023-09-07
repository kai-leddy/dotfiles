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
    opts = {
      options = {
        always_show_bufferline = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
      },
    },
    keys = {
      -- stylua: ignore start
      { "<leader>1", function () require('bufferline').go_to(1, true) end, desc = "Buffer 1" },
      { "<leader>2", function () require('bufferline').go_to(2, true) end, desc = "Buffer 2" },
      { "<leader>3", function () require('bufferline').go_to(3, true) end, desc = "Buffer 3" },
      { "<leader>4", function () require('bufferline').go_to(4, true) end, desc = "Buffer 4" },
      { "<leader>5", function () require('bufferline').go_to(5, true) end, desc = "Buffer 5" },
      -- stylua: ignore end
    },
  },
}
