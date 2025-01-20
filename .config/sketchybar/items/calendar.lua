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
			size = 12.0,
		},
		align = "right",
		y_offset = 5,
		padding_right = 0,
	},
	label = {
		font = {
			size = 12.0,
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

local bracket = sbar.add("bracket", { clock.name, cal.name }, { background = {} })

local function update()
	local day = os.date("%A")
	local date = os.date("%d/%m")
	local time = os.date("%H:%M")
	cal:set({ icon = day, label = date })
	clock:set({ label = time })
end

clock:subscribe("routine", update)
clock:subscribe("forced", update)
