local wezterm = require("wezterm")
local utils = require("utils")

local act = wezterm.action
local config = wezterm.config_builder()

local font_size = 15

-- TODO: how can I get intellisense for Wezterm API?

-- required to stop weird stuff happening with font rendering
config.front_end = "WebGpu"
config.freetype_load_flags = "NO_HINTING" -- disable hinting, as it just causes more artefacts than it solves
config.freetype_load_target = "Light" -- use light rendering and hinting (although hinting is currently disabled)

-- window appearance
config.use_fancy_tab_bar = true
-- config.hide_tab_bar_if_only_one_tab = true
config.window_background_opacity = 0.90
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
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"

-- console appearance
config.color_scheme = "Molokai"
config.font = wezterm.font("FantasqueSansM Nerd Font")
config.font_size = font_size
config.line_height = 1.0

-- functionality changes
config.scrollback_lines = 1000000

-- key mappings
config.keys = {
	{ key = "c", mods = "SHIFT|CTRL", action = act.QuickSelect },
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
	{
		key = "c",
		mods = "SHIFT|CMD",
		action = wezterm.action_callback(function(window, pane)
			local ozones = pane:get_semantic_zones("Output")
			local txt = pane:get_text_from_semantic_zone(ozones[#ozones])
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
	-- close current pane with CMD+w rather than the whole tab
	{
		key = "w",
		mods = "CMD",
		action = act.CloseCurrentPane({ confirm = true }),
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
