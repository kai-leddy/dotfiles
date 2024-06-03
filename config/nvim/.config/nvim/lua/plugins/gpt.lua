return {
  -- setup group prefix description with which-key
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>a"] = { name = "+ai" },
      },
    },
  },
  {
    "robitx/gp.nvim",
    opts = {
      cmd_prefix = "GPT",
      -- chat buffer specific keybinds
      chat_shortcut_respond = { modes = { "n", "v", "x" }, shortcut = "<cr>" },
      -- custom agents setup
      agents = {
        {
          name = "gpt-4o-chat",
          chat = true,
          command = false,
          -- string with model name or table with model name and parameters
          model = { model = "gpt-4o", temperature = 1.1, top_p = 1 },
          -- system prompt (use this to specify the persona/role of the AI)
          system_prompt = "You are a general AI assistant.\n\n"
            .. "The user provided the additional info about how they would like you to respond:\n\n"
            .. "- If you're unsure don't guess and say you don't know instead.\n"
            .. "- Ask question if you need clarification to provide better answer.\n"
            .. "- Think deeply and carefully from first principles step by step.\n"
            .. "- Zoom out first to see the big picture and then zoom in to details.\n"
            .. "- Use Socratic method to improve your thinking and coding skills.\n"
            .. "- Don't elide any code from your output if the answer requires coding.\n"
            .. "- Take a deep breath; You've got this!\n",
        },
        {
          name = "gpt-4o",
          chat = false,
          command = true,
          -- string with model name or table with model name and parameters
          model = { model = "gpt-4o", temperature = 0.8, top_p = 1 },
          -- system prompt (use this to specify the persona/role of the AI)
          system_prompt = "You are an AI working as a code editor.\n\n"
            .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
            .. "START AND END YOUR ANSWER WITH:\n\n```",
        },
        -- disabling the default agents
        { name = "ChatGPT3-5" },
        { name = "ChatGPT4" },
        { name = "CodeGPT3-5" },
        { name = "CodeGPT4" },
      },
      -- custom chat commands
      hooks = {
        Complete = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nComplete the above code."
            .. "\n\nRespond exclusively with the snippet that should be appended after the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.append, nil, agent.model, template, agent.system_prompt)
        end,
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nWrite some unit tests for the above code."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.enew, nil, agent.model, template, agent.system_prompt)
        end,
        Explain = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nGive a concise explanation of the above code."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.popup, nil, agent.model, template, agent.system_prompt)
        end,
        Docstring = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nWrite a short, concise docstring for the above code."
            .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.prepend, nil, agent.model, template, agent.system_prompt)
        end,
        FixBugs = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nModify the code to fix any potential bugs it might have."
            .. "\n\nRespond exclusively with the snippet that should replace the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.rewrite, nil, agent.model, template, agent.system_prompt)
        end,
      },
    },
    keys = {
      -- commands that work in all contexts
      { "<leader>aF", "<cmd>GPTChatFinder<cr>", mode = { "n", "v" }, desc = "Find chat" },
      { "<leader>as", "<cmd>GPTStop<cr>", mode = { "n", "v" }, desc = "Stop" },
      { "<leader>ax", "<cmd>GPTContext<cr>", mode = { "n", "v" }, desc = "Edit repo level context" },
      -- commands for checking / changing agents (model + persona)
      { "<leader>aA", "<cmd>GPTAgent<cr>", mode = { "n", "v" }, desc = "Display current agents" },
      { "<leader>aN", "<cmd>GPTNextAgent<cr>", mode = { "n", "v" }, desc = "Cycle to next agent" },
      -- specific to chat buffers _really_
      { "<leader>ar", "<cmd>GPTChatRespond<cr>", mode = { "n", "v" }, desc = "Respond" },
      { "<leader>aD", "<cmd>GPTChatDelete<cr>", mode = { "n", "v" }, desc = "Delete chat" },
      -- commands for normal mode
      { "<leader>aB", "<cmd>GPTChatNew<cr>", mode = { "n" }, desc = "New chat buffer" },
      { "<leader>aC", "<cmd>GPTChatToggle<cr>", mode = { "n" }, desc = "Toggle popup chat" },
      -- normal mode commands using the whole buffer as context
      { "<leader>ae", "<cmd>%GPTRewrite<cr>", mode = { "n" }, desc = "Edit" },
      { "<leader>aa", "<cmd>%GPTAppend<cr>", mode = { "n" }, desc = "Append" },
      { "<leader>ap", "<cmd>%GPTPrepend<cr>", mode = { "n" }, desc = "Prepend" },
      { "<leader>ac", "<cmd>%GPTComplete<cr>", mode = { "n" }, desc = "Complete" },
      { "<leader>at", "<cmd>%GPTUnitTests<cr>", mode = { "n" }, desc = "Create unit tests" },
      { "<leader>aE", "<cmd>%GPTExplain<cr>", mode = { "n" }, desc = "Explain code" },
      { "<leader>ad", "<cmd>%GPTDocstring<cr>", mode = { "n" }, desc = "Generate docstring" },
      { "<leader>af", "<cmd>%GPTFixBugs<cr>", mode = { "n" }, desc = "Fix bugs" },
      -- commands for visual mode
      { "<leader>aB", ":<C-u>'<,'>GPTChatNew<cr>", mode = { "v" }, desc = "New chat buffer with context" },
      { "<leader>aC", ":<C-u>'<,'>GPTChatToggle<cr>", mode = { "v" }, desc = "Toggle popup chat with context" },
      { "<leader>ae", ":<C-u>'<,'>GPTRewrite<cr>", mode = { "v" }, desc = "Edit" },
      { "<leader>ac", ":<C-u>'<,'>GPTComplete<cr>", mode = { "v" }, desc = "Complete" },
      { "<leader>aa", ":<C-u>'<,'>GPTAppend<cr>", mode = { "v" }, desc = "Append" },
      { "<leader>ap", ":<C-u>'<,'>GPTPrepend<cr>", mode = { "v" }, desc = "Prepend" },
      { "<leader>at", ":<C-u>'<,'>GPTUnitTests<cr>", mode = { "v" }, desc = "Create unit tests" },
      { "<leader>aE", ":<C-u>'<,'>GPTExplain<cr>", mode = { "v" }, desc = "Explain code" },
      { "<leader>ad", ":<C-u>'<,'>GPTDocstring<cr>", mode = { "v" }, desc = "Generate docstring" },
      { "<leader>af", ":<C-u>'<,'>GPTFixBugs<cr>", mode = { "v" }, desc = "Fix bugs" },
      { "<leader>av", ":<C-u>'<,'>GPTChatPaste<cr>", mode = { "v" }, desc = "Paste into latest chat" },
    },
  },
}
