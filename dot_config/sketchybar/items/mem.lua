local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local graph = require("graph")

-- RAM in use as a small line graph (share of total, 0-100%; oldest on the
-- left, newest on the right). One point per update, so with update_freq = 10
-- the graph shows roughly the last graph_width * 10 seconds. The line and icon
-- go peach above 75% and red above 90%.

local mem = graph.add("mem", {
	icon = icons.mem or "RAM:",
	color = colors.blue,
	update_freq = 10,
})
local history = graph.rolling(mem.graph, settings.bar.graph_width)

local function level_color(percent)
	return percent > 90 and colors.red or percent > 75 and colors.peach or colors.blue
end

local function update_mem()
	sbar.exec("sysctl vm.page_pageable_internal_count vm.page_purgeable_count vm.pages", function(output)
		local pageable = tonumber(output:match("vm.page_pageable_internal_count: (%d+)"))
		local purgeable = tonumber(output:match("vm.page_purgeable_count: (%d+)"))
		local total = tonumber(output:match("vm.pages: (%d+)"))
		if not (pageable and purgeable and total and total > 0) then
			return
		end

		local used = (pageable - purgeable) / total
		local color = level_color(used * 100)
		history.add(used)
		mem:set({ color = color })
	end)
end

mem.graph:subscribe({ "routine", "forced" }, update_mem)

return mem
