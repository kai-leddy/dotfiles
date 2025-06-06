local settings = require("settings")
local colors = require("colors")

-- Equivalent to the --default domain
sbar.default({
	updates = "when_shown",
	padding_left = 4,
	padding_right = 4,
	icon = {
		font = settings.font,
		color = colors.text,
		padding_left = settings.padding.big,
		padding_right = settings.padding.big,
	},
	label = {
		font = settings.font,
		color = colors.text,
		padding_left = 0,
		padding_right = settings.padding.big,
	},
	background = {
		color = colors.surface0,
		height = 32,
		corner_radius = 12,
	},
})
