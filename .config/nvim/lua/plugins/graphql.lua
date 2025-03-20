-- enables GraphQL LSP and Treesitter support
return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "graphql-language-service-cli", -- required for graphql-lsp
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- required for graphql-lsp
        graphql = {
          filetypes = { "graphql", "typescriptreact", "javascriptreact", "typescript", "javascript" },
        },
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "graphql", -- enalbes graphql treesitter parser
      },
    },
  },
}
