return {
  -- enable the golang extras
  { import = "lazyvim.plugins.extras.lang.go" },
  -- ensure the linter is installed with Mason
  { "mason-org/mason.nvim", opts = { ensure_installed = { "golangci-lint" } } },
  -- add golangci-lint to the list of linters
  { "mfussenegger/nvim-lint", opts = {
    linters_by_ft = {
      go = { "golangcilint" },
    },
  } },
  -- change formatter to gofmt as thats what our projects use currently
  { "stevearc/conform.nvim", opts = {
    formatters_by_ft = {
      go = { "gofmt" },
    },
  } },
}
