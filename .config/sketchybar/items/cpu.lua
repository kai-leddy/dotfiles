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
	background = { color = colors.surface0 },
	update_freq = 5, -- Update every 5 seconds
})

local function update_cpu()
	sbar.exec(
		"ps -eo pcpu | awk -v core_count=" .. threads .. " '{sum+=$1} END {printf sum/core_count}'",
		function(output)
			local num = tonumber(output)
			local num_str = num ~= nil and string.format("%.1f%%", num) or "N/A"
			cpu:set({
				label = { string = num_str, color = colors.text },
				icon = { color = colors.green },
				background = { color = colors.surface0 },
			})

			if num > 75 then
				cpu:set({
					label = { color = colors.crust },
					icon = { color = colors.crust },
					background = { color = colors.red },
				})
			elseif num > 50 then
				cpu:set({ label = { color = colors.peach }, background = { color = colors.surface0 } })
			end
		end
	)
end

cpu:subscribe({ "routine", "forced" }, update_cpu)
