local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local mail = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.mail,
		font = {
			style = "Regular",
			size = 18.0,
		},
		padding_right = settings.padding.small,
		color = colors.base,
	},
	label = { color = colors.base },
	background = { color = colors.lavender },
	drawing = false,
	updates = true, -- update even if currently not drawing
	update_freq = 300, -- update every 5 minutes
})

local function update()
	sbar.exec(
		[[
    osascript -e 'tell application "Mail" to count of (messages of inbox whose read status is false)'
  ]],
		function(count)
			local c = tonumber(count)
			if c == 0 then
				mail:set({ drawing = false })
			else
				mail:set({ drawing = true, label = { string = c } })
			end
		end
	)
end

mail:subscribe({ "routine", "forced", "mouse.clicked" }, update)
