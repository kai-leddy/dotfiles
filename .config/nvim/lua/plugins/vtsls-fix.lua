return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    -- REMOVE THIS once this issue is fixed: https://github.com/yioneko/vtsls/issues/159
    opts = {
      routes = {
        {
          filter = {
            event = "notify",
            find = "Request textDocument/inlayHint failed",
          },
          opts = { skip = true },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            vtsls = {
              experimental = {
                completion = {
                  entriesLimit = 100,
                },
              },
            },
            typescript = {
              tsserver = {
                maxTsServerMemory = 12 * 1024, -- 12GB
              },
              preferences = {
                autoImportFileExcludePatterns = {
                  "node_modules",
                },
              },
            },
          },
        },
      },
    },
  },
}
