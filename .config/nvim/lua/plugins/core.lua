return {
  { "folke/lazy.nvim", version = false },
  { "LazyVim/LazyVim", version = false, opts = { colorscheme = "catppuccin-mocha" } },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = true,
      float = {
        transparent = true,
      },
      auto_integrations = true, -- let catppuccin auto-detect plugins via lazy.nvim
      integrations = {
        blink_cmp = true,
        flash = true,
        grug_far = true,
        harpoon = true,
        mason = true,
        mini = { enabled = true, indentscope_color = "flamingo" },
        neotest = true,
        noice = true,
        copilot_vim = true,
        snacks = { enabled = true, indentscope_color = "flamingo" },
        lsp_trouble = true,
        which_key = true,
      },
      custom_highlights = function(colors)
        return {
          -- make the window separator clearer
          WinSeparator = { fg = colors.flamingo },
        }
      end,
    },
  },
  -- make sure lualine uses the catppuccin theme
  {
    "nvim-lualine/lualine.nvim",
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = { left = "│", right = "│" },
        section_separators = { left = "", right = "" },
      },
    },
  },
  -- setup EmmyLua for LSP support in hammerspoon config
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        {
          path = string.format("%s/.hammerspoon/Spoons/EmmyLua.spoon/annotations", os.getenv("HOME")),
          words = { "hs.", "spoon." },
        },
      },
    },
  },
  -- stop notifications from being focussed by accident (I don't want to focus them ever)
  {
    "folke/snacks.nvim",
    opts = {
      styles = {
        notification = {
          focusable = false,
          enter = false,
        },
      },
    },
  },
}
