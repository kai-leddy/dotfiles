local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local cpu = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.cpu or "CPU:",
		padding_right = settings.padding.small,
		color = colors.green,
	},
	label = {
		color = colors.text,
		font = { size = 14 },
	},
	background = { color = colors.surface1 },
	update_freq = 5, -- Update every 5 seconds
})

local function update_cpu()
	sbar.exec("top -l 1 | grep -E '^CPU usage:'", function(output)
		local user, sys, idle = output:match("CPU usage: (%d+%.?%d*)%% user, (%d+%.?%d*)%% sys, (%d+%.?%d*)%% idle")
		if idle then
			local usage = 100 - tonumber(idle)
			cpu:set({ label = string.format("%.1f%%", usage) })
		else
			cpu:set({ label = "N/A" })
		end
	end)
end

cpu:subscribe({ "routine", "forced" }, update_cpu)
