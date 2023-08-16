return {
  {
    "echasnovski/mini.surround",
    opts = {
      -- -- remap surround plugin keys to just `s` as the prefix
      mappings = {
        add = "sa",
        delete = "sd",
        find = "sf",
        find_left = "sF",
        highlight = "sh",
        replace = "sr",
        update_n_lines = "sn",
      },
      search_method = "cover_or_next",
    },
  },
  -- remap Flash to use the `gs` prefix, as I use that much less than surrounds
  {
    "folke/flash.nvim",
    opts = {},
    -- replace all key mappings with new ones
    keys = function()
      return {
      -- stylua: ignore start
      { "gs", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash Search" },
      { "gS", mode = { "n", "o", "x" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
        -- stylua: ignore end
      }
    end,
  },
}
