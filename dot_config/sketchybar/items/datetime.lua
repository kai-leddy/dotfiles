local pill_group = require("pill_group")

-- Two items sharing one pill: the clock on the right, and the day stacked over
-- the date on its left. Like the merged pills, the bracket background covers
-- the members' outer padding, so the outer edges have no padding and spacers
-- supply the gap outside the pill.

pill_group.spacer("right")

local clock = sbar.add("item", {
	icon = { drawing = false },
	position = "right",
	update_freq = 15,
	padding_left = 2,
	padding_right = 0,
	background = { drawing = false },
})

local cal = sbar.add("item", {
	icon = {
		font = {
			size = 11.0,
		},
		align = "right",
		y_offset = 5,
		padding_right = 0,
	},
	label = {
		font = {
			size = 11.0,
		},
		align = "right",
		width = 0,
		y_offset = -5,
		padding_right = 0,
	},
	position = "right",
	padding_right = 0,
	padding_left = 0,
	background = { drawing = false },
})

pill_group.spacer("right")
pill_group.bracket({ clock.name, cal.name })

local function update()
	local day = os.date("%A")
	local date = os.date("%d/%m")
	local time = os.date("%H:%M")
	cal:set({ icon = day, label = date })
	clock:set({ label = time })
end

clock:subscribe({ "routine", "forced" }, update)
