-- definition of LLMs that I currently make use of
local llms = {
  -- disabling the old default agents
  { name = "ChatGPT3-5", disable = true },
  { name = "ChatGPT4", disable = true },
  { name = "ChatGPT4o", disable = true },
  { name = "ChatGPT4o-mini", disable = true },
  { name = "CodeGPT3-5", disable = true },
  { name = "CodeGPT4", disable = true },
  { name = "CodeGPT4o", disable = true },
  { name = "CodeGPT4o-mini", disable = true },
  { name = "o1-mini", openrouter_model = "openai/o1-mini", no_sys_prompt = true },
  { name = "claude-3.7-sonnet", openrouter_model = "anthropic/claude-3.7-sonnet" },
  { name = "deepseek-v3", openrouter_model = "deepseek/deepseek-chat" },
  { name = "deepseek-R1", openrouter_model = "deepseek/deepseek-r1" },
  { name = "gemini-flash", openrouter_model = "google/gemini-2.5-flash" },
  { name = "gemini-pro", openrouter_model = "google/gemini-2.5-pro" },
  { name = "codestral", openrouter_model = "mistralai/codestral-2508" },
}

local generated_agents = {}
local default_system_prompt = "You are an AI working as a code editor.\n\n"
  .. "Please AVOID COMMENTARY OUTSIDE OF THE SNIPPET RESPONSE.\n"
  .. "START AND END YOUR ANSWER WITH:\n\n```"

for _, llm in ipairs(llms) do
  if llm.disable then
    table.insert(generated_agents, { name = llm.name, disable = true })
  end
  if llm.openrouter_model then
    local agent = {
      name = llm.name,
      provider = "openrouter",
      chat = true,
      command = true,
      model = { model = llm.openrouter_model, temperature = 0.8, top_p = 1 },
      system_prompt = llm.no_sys_prompt and "" or default_system_prompt,
    }
    table.insert(generated_agents, agent)
  end
end

return {
  -- setup group prefix description with which-key
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>a", group = "ai" },
      },
    },
  },
  {
    "kai-leddy/gp.nvim",
    branch = "o1-streaming",
    opts = {
      cmd_prefix = "GPT",
      -- chat buffer specific keybinds
      chat_shortcut_respond = { modes = { "n", "v", "x" }, shortcut = "<cr>" },
      -- setup the providers
      providers = {
        openai = { disabled = true },
        copilot = { disabled = false },
        openrouter = {
          endpoint = "https://openrouter.ai/api/v1/chat/completions",
          secret = os.getenv("OPENROUTER_API_KEY"),
        },
      },
      -- custom agents setup
      agents = generated_agents,
      -- custom chat commands
      hooks = {
        Complete = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nComplete the above code."
            .. "\n\nRespond exclusively with the snippet that should be appended after the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.append, agent, template)
        end,
        UnitTests = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nWrite some unit tests for the above code."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.enew, agent, template)
        end,
        Explain = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nGive a concise explanation of the above code."
          local agent = gp.get_chat_agent()
          gp.Prompt(params, gp.Target.popup, agent, template)
        end,
        Docstring = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nWrite a short, concise docstring for the above code."
            .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.prepend, agent, template)
        end,
        FixBugs = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nModify the code to fix any potential bugs it might have."
            .. "\n\nRespond exclusively with the snippet that should replace the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.rewrite, agent, template)
        end,
        Simplify = function(gp, params)
          local template = "I have the following code from {{filename}}:"
            .. "\n\n```{{filetype}}\n{{selection}}\n```"
            .. "\n\nSimplify the code provided while ensuring it's still readable."
            .. "\n\nRespond exclusively with the snippet that should replace the selection above."
          local agent = gp.get_command_agent()
          gp.Prompt(params, gp.Target.rewrite, agent, template)
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
      { "<leader>aS", "<cmd>%GPTSimplify<cr>", mode = { "n" }, desc = "Simplify" },
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
      { "<leader>aS", ":<C-u>'<,'>GPTSimplify<cr>", mode = { "v" }, desc = "Simplify" },
      { "<leader>av", ":<C-u>'<,'>GPTChatPaste<cr>", mode = { "v" }, desc = "Paste into latest chat" },
    },
  },
}
