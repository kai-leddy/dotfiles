return {
  {
    "ahmedkhalf/project.nvim",
    opts = {
      -- auto changing the cwd isn't actually that helpful
      manual_mode = true,
    },
  },
  -- disabled in favour of harpoon2
  { "akinsho/bufferline.nvim", enabled = false },

  {
    "ThePrimeagen/harpoon",
    opts = {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    },
  },
}
