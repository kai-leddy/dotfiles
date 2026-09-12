return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Use OpenTofu's language server; terraformls requires the Terraform CLI.
        terraformls = false,
        tofu_ls = {},
      },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "tofu-ls" },
    },
  },
}
