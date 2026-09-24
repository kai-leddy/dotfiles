local icons = require("icons")
local colors = require("colors")

local volume_icon = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.volume.high,
	},
	background = { color = colors.surface0 },
})

volume_icon:subscribe("volume_change", function(env)
	local volume = tonumber(env.INFO)
	local icon = icons.volume.mute

	if volume > 60 then
		icon = icons.volume.high
	elseif volume > 20 then
		icon = icons.volume.low
	elseif volume > 0 then
		icon = icons.volume.off
	end

	local is_off = volume == 0

	volume_icon:set({
		icon = { string = icon or "", color = is_off and colors.red or colors.text },
		label = { string = volume .. "%", drawing = not is_off },
	})
end)
