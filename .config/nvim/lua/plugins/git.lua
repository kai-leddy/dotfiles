return {
  -- TODO: check whether I need this or if it can be replaced with snacks.nvim now
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- syntax highlighting for diffs, config etc
      vim.list_extend(opts.ensure_installed, {
        "diff",
        "gitcommit",
        "gitignore",
        "git_config",
      })
    end,
  },
  -- better mappings for handling git hunks etc (all under `<leader>g` directly)
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      on_attach = function(buffer)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", gs.next_hunk, "Next Hunk")
        map("n", "[h", gs.prev_hunk, "Prev Hunk")
        map({ "n", "v" }, "<leader>gs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
        map({ "n", "v" }, "<leader>gr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>gS", gs.stage_buffer, "Stage Buffer")
        map("n", "<leader>gu", gs.undo_stage_hunk, "Undo Stage Hunk")
        map("n", "<leader>gR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "Blame Line")
        map("n", "<leader>gd", gs.diffthis, "Diff This")
        map("n", "<leader>gD", function() gs.diffthis("~") end, "Diff This ~")
        map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
        -- stylua: ignore end
      end,
    },
  },
  -- setup group prefix description with which-key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>fg", group = "git_branch" },
      },
    },
  },
  -- use agitator for advanced git functionality, like blame & time machine
  {
    "emmanueltouzery/agitator.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    keys = {
      {
        "<leader>gB",
        function()
          require("agitator").git_blame_toggle({
            sidebar_width = 40,
            formatter = function(r)
              return os.date("%x", os.time(r.date))
                .. " "
                .. r.author
                .. " "
                .. string.sub(r.sha, 1, 7)
                .. " => "
                .. r.summary
            end,
          })
        end,
        desc = "Blame whole file",
      },
      {
        "<leader>gt",
        function()
          require("agitator").git_time_machine({
            use_current_win = true,
          })
        end,
        desc = "Time machine",
      },
      {
        "<leader>fgf",
        -- stylua: ignore
        function() require("agitator").open_file_git_branch() end,
        desc = "Find file in git branch",
      },
      {
        "<leader>fgg",
        -- stylua: ignore
        function() require("agitator").search_git_branch() end,
        desc = "Grep files in git branch",
      },
    },
  },
}
