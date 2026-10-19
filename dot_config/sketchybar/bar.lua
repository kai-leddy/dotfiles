local colors = require("colors")
local settings = require("settings")

-- Equivalent to the --bar domain
sbar.bar({
	height = settings.bar.height,
	position = "top",
	padding_left = settings.bar.item_padding,
	padding_right = settings.bar.item_padding,
	-- The 14" MacBook Pro notch is 185pt wide (NSScreen auxiliaryTopLeftArea /
	-- auxiliaryTopRightArea). Items either side keep half a gap as padding, so
	-- adding one gap puts the pills a full gap from the notch.
	notch_width = 185 + settings.bar.gap,
	color = colors.transparent,
})
