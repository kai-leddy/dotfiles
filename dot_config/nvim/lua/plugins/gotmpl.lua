-- lazy.nvim --
return {
  { "ngynkvn/gotmpl.nvim", opts = {} },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "gotmpl", -- enalbes gotmpl treesitter parser
      },
    },
  },
}
