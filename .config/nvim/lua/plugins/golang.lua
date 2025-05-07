return {
  -- enable the golang extras
  { import = "lazyvim.plugins.extras.lang.go" },
  -- ensure the linter is installed with Mason
  { "williamboman/mason.nvim", opts = { ensure_installed = { "golangci-lint" } } },
  -- add golangci-lint to the list of linters
  { "mfussenegger/nvim-lint", opts = {
    linters_by_ft = {
      go = { "golangcilint" },
    },
  } },
}
