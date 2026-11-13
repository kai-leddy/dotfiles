local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

-- Gets the bar out of the way of the macOS menu bar for a while. The bar is
-- topmost (bar.lua), so it covers the auto-hiding menu bar. A click slides it
-- up off the screen for `duration` seconds, then slides it back.
--
-- This moves the bar with y_offset instead of switching topmost off: changing
-- topmost makes sketchybar rebuild its windows (bar_manager_reset), which
-- flashes the whole bar, while y_offset only moves them and can be animated.
-- A config reload also brings the bar back, since bar.lua sets no y_offset
-- and the bar starts at 0.

local duration = 10
-- Animation length in frames (about 60 a second).
local frames = 15
-- A couple of points past the bar's height so nothing peeks over the edge.
local hidden_offset = -(settings.bar.height + 2)

local away = false

local menubar = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.menubar,
		color = colors.overlay0,
	},
	label = { drawing = false },
	background = { color = colors.surface0 },
})

local function slide(y_offset)
	sbar.animate("tanh", frames, function()
		sbar.bar({ y_offset = y_offset })
	end)
end

menubar:subscribe("mouse.clicked", function()
	if away then
		return
	end

	away = true
	slide(hidden_offset)
	sbar.delay(duration, function()
		slide(0)
		away = false
	end)
end)

return menubar
