return {
  -- disabled in favour of harpoon2
  { "akinsho/bufferline.nvim", enabled = false },

  {
    "ThePrimeagen/harpoon",
    opts = {
      settings = {
        save_on_toggle = true,
        sync_on_ui_close = true,
      },
    },
    keys = {
      {
        "<leader>bx",
        function()
          local harpoon = require("harpoon")
          local cur = vim.api.nvim_get_current_buf()

          local harpoonitems = harpoon:list().items

          local function get_is_harpooned(bufnum)
            local bufname = vim.api.nvim_buf_get_name(bufnum)

            for _, item in pairs(harpoonitems) do
              if item.value == bufname then
                return true
              end
            end
            return false
          end

          local cleaned_count = 0
          local function can_be_deleted(bufnum)
            local is_current = bufnum == cur
            local is_modifiable = vim.api.nvim_get_option_value("modifiable", { buf = bufnum })
            local is_harpooned = get_is_harpooned(bufnum)

            if not is_current and is_modifiable and not is_harpooned then
              cleaned_count = cleaned_count + 1
              return true
            else
              return false
            end
          end

          Snacks.bufdelete.delete({ filter = can_be_deleted })

          -- show notification that buffers have been cleaned
          vim.notify("Cleaned " .. cleaned_count .. " buffers", vim.log.levels.INFO)
        end,
        desc = "Clean unused buffers",
      },
    },
  },
}
