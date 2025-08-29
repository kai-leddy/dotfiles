-- setup supertab to do completions and snippets (+ copilot)
return {
  -- disable auto completing pairs
  { "echasnovski/mini.pairs", enabled = false },

  -- setup my prefered tab behaviour with blink.cmp
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        -- Recommended to avoid unnecessary request
        trigger = { prefetch_on_insert = false },
        list = {
          selection = {
            preselect = true,
            auto_insert = true,
          },
        },
      },
      sources = {
        -- Enable minuet for autocomplete
        default = { "lsp", "path", "buffer", "snippets", "minuet" },
        providers = {
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            -- Should match minuet.config.request_timeout * 1000,
            -- since minuet.config.request_timeout is in seconds
            timeout_ms = 3000,
            score_offset = 50, -- Gives minuet higher priority among suggestions
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

  -- testing using LLMs for autocomplete instead of Copilot
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("minuet").setup({
        provider = "openai_compatible",
        request_timeout = 2.5,
        throttle = 1500, -- Increase to reduce costs and avoid rate limits
        debounce = 600, -- Increase to reduce costs and avoid rate limits
        provider_options = {
          openai_compatible = {
            api_key = "OPENROUTER_API_KEY",
            end_point = "https://openrouter.ai/api/v1/chat/completions",
            -- model = "google/gemini-2.5-flash",
            model = "mistralai/codestral-2508",
            name = "Openrouter",
            optional = {
              max_tokens = 256,
              top_p = 0.9,
              provider = {
                -- Prioritize throughput for faster completion
                sort = "throughput",
              },
            },
          },
        },
      })
    end,
  },
}
