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
}
