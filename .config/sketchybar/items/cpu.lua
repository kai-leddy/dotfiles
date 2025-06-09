local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local threads = 0
sbar.exec("nproc --all", function(output)
	local num = tonumber(output:match("(%d+)"))
	if num then
		threads = math.floor(num)
	end
end)

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
	sbar.exec(
		"ps -eo pcpu | awk -v core_count=" .. threads .. " '{sum+=$1} END {printf sum/core_count}'",
		function(output)
			local num = tonumber(output)
			if num then
				cpu:set({ label = string.format("%.1f%%", num) })
			else
				cpu:set({ label = "N/A" })
			end
		end
	)
end

cpu:subscribe({ "routine", "forced" }, update_cpu)
