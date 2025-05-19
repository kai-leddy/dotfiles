-- setup supertab to do completions and snippets (+ copilot)
return {
  -- disable auto completing pairs
  { "echasnovski/mini.pairs", enabled = false },

  -- setup my prefered tab behaviour with blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
      },
      keymap = {
        preset = "enter",
        ["<cr>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        ["<C-d>"] = { "scroll_documentation_down", "fallback" },
      },
    },
  },
}
