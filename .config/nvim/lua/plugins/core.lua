return {
  { "folke/lazy.nvim", version = false },
  { "LazyVim/LazyVim", version = false, opts = { colorscheme = "tokyonight" } },
  {
    "folke/tokyonight.nvim",
    -- lazy = true,
    opts = {
      style = "moon",
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      sidebars = { "qf", "vista_kind", "terminal", "packer" },
    },
  },
  -- setup EmmyLua for LSP support in hammerspoon config
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        {
          path = string.format("%s/.hammerspoon/Spoons/EmmyLua.spoon/annotations", os.getenv("HOME")),
          words = { "hs.", "spoon." },
        },
      },
    },
  },
  -- stop notifications from being focussed by accident (I don't want to focus them ever)
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        notification = {
          focusable = false,
          enter = false,
        },
      },
    },
  },
}
