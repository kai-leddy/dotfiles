local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
	height = settings.bar.height,
	position = "top",
	-- edge_inset keeps the macOS privacy dot clear of the clock (settings.lua).
	padding_left = settings.bar.item_padding + settings.bar.edge_inset,
	padding_right = settings.bar.item_padding + settings.bar.edge_inset,
	-- The 14" MacBook Pro notch is 185pt wide (NSScreen auxiliaryTopLeftArea /
	-- auxiliaryTopRightArea). Items either side keep half a gap as padding, so
	-- adding one gap puts the pills a full gap from the notch.
	notch_width = 185 + settings.bar.gap,
	color = colors.transparent,
})
