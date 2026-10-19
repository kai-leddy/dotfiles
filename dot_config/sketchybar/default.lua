local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "when_shown",
	padding_left = settings.bar.item_padding,
	padding_right = settings.bar.item_padding,
	icon = {
		font = settings.font,
		color = colors.text,
		padding_left = settings.padding.big,
		padding_right = settings.padding.big,
	},
	label = {
		font = {
			family = settings.font.family,
			style = settings.font.style,
			size = 14.0,
		},
		color = colors.text,
		padding_left = 0,
		padding_right = settings.padding.big,
	},
	background = {
		color = colors.surface0,
		height = settings.bar.item_height,
		corner_radius = 10,
	},
})
