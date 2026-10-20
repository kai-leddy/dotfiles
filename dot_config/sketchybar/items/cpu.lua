local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local graph = require("graph")

-- CPU load as a small line graph (0-100%, oldest on the left, newest on the
-- right). One point per update, so with update_freq = 5 the graph shows
-- roughly the last graph_width * 5 seconds.
-- The line and icon go peach above 50% and red above 75%.

local threads = 0
sbar.exec("nproc --all", function(output)
	local num = tonumber(output:match("(%d+)"))
	if num then
		threads = math.floor(num)
	end
end)

local cpu = graph.add("cpu", {
	icon = icons.cpu or "CPU:",
	color = colors.green,
	update_freq = 5,
})
local history = graph.rolling(cpu.graph, settings.bar.graph_width)

local function level_color(percent)
	return percent > 75 and colors.red or percent > 50 and colors.peach or colors.green
end

local function update_cpu()
	sbar.exec(
		"ps -eo pcpu | awk -v core_count="
			.. threads
			.. " 'BEGIN{if(core_count==0)core_count=1} {sum+=$1} END {printf sum/core_count}'",
		function(output)
			local num = tonumber(output)
			if num == nil then
				return
			end
			local color = level_color(num)
			history.add(num / 100)
			cpu:set({ color = color })
		end
	)
end

cpu.graph:subscribe({ "routine", "forced" }, update_cpu)

return cpu
