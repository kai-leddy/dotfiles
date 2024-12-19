return {
  -- make conform actually support formatting ocaml
  {
    "stevearc/conform.nvim",
    ---@module "conform"
    ---@type conform.setupOpts
    opts = {
      formatters_by_ft = {
        ocaml = { "ocamlformat" },
      },
    },
  },
}
