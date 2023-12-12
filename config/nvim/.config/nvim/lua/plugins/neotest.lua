return {
  {
    "nvim-neotest/neotest",
    event = "LspAttach",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
    },
    opts = {
      adapters = {
        ["neotest-jest"] = {
          -- jestCommand = "npx jest --watch ", -- disabled as it currently provides no pass/fail feedback
          jest_test_discovery = true,
        },
      },
      discovery = {
        -- this only works with neotest-jest and jest_test_discovery = true
        -- if you ever test other languages/adapters, turn this on again and jest_test_discovery = false
        enabled = false,
      },
    },
  },
  {
    "folke/neodev.nvim",
    opts = {
      library = {
        plugins = { "neotest" },
        types = true,
      },
    },
  },
}
