return {
  {
    "akinsho/git-conflict.nvim",
    version = "v2.1.0",
    config = true,
    event = "BufEnter",
    opts = {
      default_mappings = false,
      default_commands = true,
      disable_diagnostics = true,
    },
    -- init = function()
    --   local is_open = false
    --   vim.api.nvim_create_autocmd("User", {
    --     pattern = "GitConflictDetected",
    --     callback = vim.schedule_wrap(function()
    --       local wk = require("which-key")
    --       -- Register which-key bindings for git conflict
    --       wk.add({
    --         { "<leader>gmk", "<Plug>(git-conflict-ours)<cmd>w<CR>", desc = "Keep top hunk" },
    --         { "<leader>gmj", "<Plug>(git-conflict-theirs)<cmd>w<CR>", desc = "Keep bottom hunk" },
    --         { "<leader>gmb", "<Plug>(git-conflict-both)<cmd>w<CR>", desc = "Keep both hunks" },
    --         { "<leader>gmn", "<Plug>(git-conflict-none)<cmd>w<CR>", desc = "Keep neither hunk" },
    --         { "<leader>gml", "<Plug>(git-conflict-next-conflict)<cmd>w<CR>", desc = "Next conflict" },
    --         { "<leader>gmh", "<Plug>(git-conflict-prev-conflict)<cmd>w<CR>", desc = "Previous conflict" },
    --       })
    --       wk.show({
    --         keys = "<leader>gm",
    --         loop = true, -- stay open until hitting esc
    --       })
    --       is_open = true
    --     end),
    --   })
    --   -- setup event to close when conflicts are all resolved
    --   vim.api.nvim_create_autocmd("User", {
    --     pattern = "GitConflictResolved",
    --     callback = function()
    --       -- simulate esc press to close the which-key popup
    --       if is_open then
    --         vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    --         is_open = false
    --       end
    --     end,
    --   })
    -- end,
  },
}
