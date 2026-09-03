local wezterm = require("wezterm")
local utils = require("utils")

local act = wezterm.action
local config = wezterm.config_builder()

local font_size
if utils.getOSName() == "Darwin" then
	font_size = 15
else
	font_size = 12
end

-- required to stop weird stuff happening with font rendering
config.front_end = "WebGpu"
config.freetype_load_flags = "NO_HINTING" -- disable hinting, as it just causes more artefacts than it solves
config.freetype_load_target = "Light" -- use light rendering and hinting (although hinting is currently disabled)

-- disable all the ligatures, as they can be confusing for coding
config.harfbuzz_features = { "calt=0", "clig=0", "liga=0" }

-- window appearance
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.7
-- config.window_background_opacity = 1
config.macos_window_background_blur = 8
config.window_padding = {
	left = "8pt",
	right = "8pt",
	top = "8pt",
	bottom = "8pt",
}
config.window_frame = {
	font = wezterm.font("FantasqueSansM Nerd Font"),
	font_size = font_size,
}
config.window_decorations = "NONE"
-- config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- console appearance
config.color_scheme = "catppuccin-mocha"
config.colors = {
	background = "#111111", -- the blue tinge doesn't look nice with the transparency
}
config.font = wezterm.font("FantasqueSansM Nerd Font")
config.font_size = font_size
config.line_height = 1.0

-- functionality changes
config.scrollback_lines = 1000000
-- enable the kitty protocols for improved support and perf in some apps
config.enable_kitty_keyboard = true
config.enable_kitty_graphics = true

-- Herdr owns pane/tab/workspace shortcuts. Disable only the overlapping
-- WezTerm defaults below so Cmd and Cmd+Shift events reach Herdr.
--[[
config.keys = {
	-- disable the default keybindings for alt+enter, so that we can use it in CLI apps
	{
		key = "Enter",
		mods = "ALT",
		action = wezterm.action.DisableDefaultAssignment,
	},
	{ key = "c", mods = "SHIFT|CTRL", action = act.QuickSelect },
	{ key = "Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
	-- mappings for scrolling up/down commands at a time
	{ key = "UpArrow", mods = "CMD", action = act.ScrollToPrompt(-1) },
	{ key = "DownArrow", mods = "CMD", action = act.ScrollToPrompt(1) },
	-- quick select and open a URL in the browser (CMD+o)
	{
		key = "o",
		mods = "CTRL",
		action = act.QuickSelectArgs({
			label = "Open URL",
			patterns = {
				"https?://\\S+",
			},
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("Opening: " .. url)
				wezterm.open_with(url)
			end),
		}),
	},
	-- quickly copy the latest command's output into the clipboard (CMD+SHIFT+c)
	{
		key = "c",
		mods = "SHIFT|CMD",
		action = wezterm.action_callback(function(window, pane)
			-- get semantic output zones
			local ozones = pane:get_semantic_zones("Output")
			-- get either the latest or the one before (I had a bug with empty zones being output)
			local txt = pane:get_text_from_semantic_zone(ozones[#ozones])
			if not txt or txt == "" then
				txt = pane:get_text_from_semantic_zone(ozones[#ozones - 1])
			end
			if txt:match("^%s*```[^\n]*\n(.*)\n```%s*$") then
				txt = txt:match("^%s*```[^\n]*\n(.*)\n```%s*$")
			end
			-- copy to clipboard
			wezterm.log_info("Copying: " .. txt)
			window:copy_to_clipboard(txt)
		end),
	},
	-- add keybdingins for managing splits (use shift to create splits)
	{ key = "h", mods = "CMD", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "CMD", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "CMD", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "CMD", action = act.ActivatePaneDirection("Right") },
	{ key = "H", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Left" }) },
	{ key = "J", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Down" }) },
	{ key = "K", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Up" }) },
	{ key = "L", mods = "CMD|SHIFT", action = act.SplitPane({ direction = "Right" }) },
}
--]]

-- Send explicit terminal key sequences: xterm's modifier encoding has no SUPER bit,
-- so SendKey would drop Cmd before Herdr can match it as SUPER.
local function herdr_key(key, modifiers)
	return act.SendString(string.format("\x1b[%d;%du", string.byte(key), modifiers))
end

config.keys = {
	{ key = "F1", mods = "CMD", action = act.SendString("\x1b[1;9P") },
	{ key = "F5", mods = "CMD", action = act.SendString("\x1b[15;9~") },
	{ key = "t", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "p", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "w", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "n", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "g", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "h", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "j", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "k", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "l", mods = "CMD|ALT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "w", mods = "CMD|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "d", mods = "CMD|CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "h", mods = "CMD|CTRL", action = herdr_key("h", 13) },
	{ key = "j", mods = "CMD|CTRL", action = herdr_key("j", 13) },
	{ key = "k", mods = "CMD|CTRL", action = herdr_key("k", 13) },
	{ key = "l", mods = "CMD|CTRL", action = herdr_key("l", 13) },
	{ key = "p", mods = "CMD|CTRL", action = herdr_key("p", 13) },
	{ key = "n", mods = "CMD|CTRL", action = herdr_key("n", 13) },
	{ key = "r", mods = "CMD|CTRL", action = herdr_key("r", 13) },
	{ key = "t", mods = "CMD", action = herdr_key("t", 9) },
	{ key = "q", mods = "CMD", action = herdr_key("q", 9) },
	{ key = "r", mods = "CMD", action = herdr_key("r", 9) },
	{ key = "h", mods = "CMD", action = herdr_key("h", 9) },
	{ key = "j", mods = "CMD", action = herdr_key("j", 9) },
	{ key = "k", mods = "CMD", action = herdr_key("k", 9) },
	{ key = "l", mods = "CMD", action = herdr_key("l", 9) },
	{ key = "T", mods = "CMD|SHIFT", action = herdr_key("t", 10) },
	{ key = "R", mods = "CMD|SHIFT", action = herdr_key("r", 10) },
	{ key = "N", mods = "CMD|SHIFT", action = herdr_key("n", 10) },
	{ key = "G", mods = "CMD|SHIFT", action = herdr_key("g", 10) },
	{ key = "W", mods = "CMD|SHIFT", action = herdr_key("w", 10) },
	{ key = "D", mods = "CMD|SHIFT", action = herdr_key("d", 10) },
	{ key = "X", mods = "CMD|SHIFT", action = herdr_key("x", 10) },
	{ key = "P", mods = "CMD|SHIFT", action = herdr_key("p", 10) },
	{ key = "Q", mods = "CMD|SHIFT", action = herdr_key("q", 10) },
	{ key = "O", mods = "CMD|SHIFT", action = herdr_key("o", 10) },
	{ key = "U", mods = "CMD|SHIFT", action = herdr_key("u", 10) },
	{ key = "H", mods = "CMD|SHIFT", action = herdr_key("h", 10) },
	{ key = "J", mods = "CMD|SHIFT", action = herdr_key("j", 10) },
	{ key = "K", mods = "CMD|SHIFT", action = herdr_key("k", 10) },
	{ key = "L", mods = "CMD|SHIFT", action = herdr_key("l", 10) },
	{ key = "z", mods = "CMD", action = herdr_key("z", 9) },
	{ key = "b", mods = "CMD", action = herdr_key("b", 9) },
	{ key = "e", mods = "CMD", action = herdr_key("e", 9) },
	{ key = "LeftArrow", mods = "CMD|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "RightArrow", mods = "CMD|SHIFT", action = wezterm.action.DisableDefaultAssignment },
	{ key = "1", mods = "CMD", action = herdr_key("1", 9) },
	{ key = "2", mods = "CMD", action = herdr_key("2", 9) },
	{ key = "3", mods = "CMD", action = herdr_key("3", 9) },
	{ key = "4", mods = "CMD", action = herdr_key("4", 9) },
	{ key = "5", mods = "CMD", action = herdr_key("5", 9) },
	{ key = "6", mods = "CMD", action = herdr_key("6", 9) },
	{ key = "7", mods = "CMD", action = herdr_key("7", 9) },
	{ key = "8", mods = "CMD", action = herdr_key("8", 9) },
	{ key = "9", mods = "CMD", action = herdr_key("9", 9) },
	-- Utility shortcuts retained from the previous WezTerm workflow.
	{ key = "c", mods = "SHIFT|CTRL", action = act.QuickSelect },
	{ key = "Space", mods = "SHIFT|CTRL", action = act.QuickSelect },
	--{ key = "UpArrow", mods = "CMD", action = act.ScrollToPrompt(-1) },
	--{ key = "DownArrow", mods = "CMD", action = act.ScrollToPrompt(1) },
	{
		key = "o",
		mods = "SHIFT|CTRL",
		action = act.QuickSelectArgs({
			label = "Open URL",
			patterns = { "https?://\\S+" },
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("Opening: " .. url)
				wezterm.open_with(url)
			end),
		}),
	},
	{
		key = "c",
		mods = "SHIFT|CMD",
		action = wezterm.action_callback(function(window, pane)
			local ozones = pane:get_semantic_zones("Output")
			local txt = pane:get_text_from_semantic_zone(ozones[#ozones])
			if not txt or txt == "" then
				txt = pane:get_text_from_semantic_zone(ozones[#ozones - 1])
			end
			if txt and txt:match("^%s*```[^\\n]*\\n(.*)\\n```%s*$") then
				txt = txt:match("^%s*```[^\\n]*\\n(.*)\\n```%s*$")
			end
			if txt then
				wezterm.log_info("Copying: " .. txt)
				window:copy_to_clipboard(txt)
			end
		end),
	},
}

config.key_tables = {
	-- these will make switching between search and copy easier for me
	search_mode = utils.extend_key_table("search_mode", {
		{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
		-- Go back to copy mode when pressing enter, so that we can use unmodified keys like "n"
		-- to navigate search results without conflicting with typing into the search area.
		{ key = "Enter", mods = "NONE", action = "ActivateCopyMode" },
	}),
	-- these make the copy experience a little more vim-like for me
	copy_mode = utils.extend_key_table("copy_mode", {
		-- Enter search mode to edit the pattern.
		{ key = "/", mods = "NONE", action = act.Search("CurrentSelectionOrEmptyString") },
		-- navigate any search mode results
		{ key = "n", mods = "NONE", action = act.CopyMode("PriorMatch") },
		{ key = "N", mods = "SHIFT", action = act.CopyMode("NextMatch") },
	}),
}

-- and finally, return the configuration to wezterm
return config
