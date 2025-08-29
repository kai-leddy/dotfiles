return {
  {
    "nvim-neotest/neotest",
    -- TODO: remove this once https://github.com/nvim-neotest/neotest/issues/531 is fixed
    commit = "52fca6717ef972113ddd6ca223e30ad0abb2800c",
    event = "LspAttach",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-vitest"] = {},
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
}
