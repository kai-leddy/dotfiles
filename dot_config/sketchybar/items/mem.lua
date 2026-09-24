local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local mem = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.mem or "RAM:",
		padding_right = settings.padding.small,
		color = colors.blue,
	},
	label = {
		color = colors.text,
		font = { size = 14 },
	},
	background = { color = colors.surface0 },
	update_freq = 10,
})

local function format_mem_value(mem_num, precision)
	if not mem_num then
		return "N/A"
	end

	if mem_num >= 1024 * 1024 * 1024 then
		return string.format("%." .. precision .. "fG", mem_num / (1024 * 1024 * 1024))
	elseif mem_num >= 1024 * 1024 then
		return string.format("%." .. precision .. "fM", mem_num / (1024 * 1024))
	elseif mem_num >= 1024 then
		return string.format("%." .. precision .. "fK", mem_num / 1024)
	end

	return mem_num .. "B"
end

local function update_mem()
	sbar.exec("sysctl vm.page_pageable_internal_count vm.page_purgeable_count vm.pagesize vm.pages", function(output)
		local pageable_internal_count_str = output:match("vm.page_pageable_internal_count: (%d+)")
		local purgeable_count_str = output:match("vm.page_purgeable_count: (%d+)")
		local page_size_str = output:match("vm.pagesize: (%d+)")
		local pages_str = output:match("vm.pages: (%d+)")

		if pageable_internal_count_str and purgeable_count_str and page_size_str and pages_str then
			local pageable_count = tonumber(pageable_internal_count_str)
			local purgeable_count = tonumber(purgeable_count_str)
			local page_size = tonumber(page_size_str)
			local total_pages = tonumber(pages_str)
			local used = (pageable_count - purgeable_count) * page_size
			local total = total_pages * page_size

			local used_gb = format_mem_value(used, 1)
			mem:set({
				label = { string = used_gb, color = colors.text },
				icon = { color = colors.blue },
				background = { color = colors.surface0 },
			})

			local percentage_used = (used / total) * 100
			if percentage_used > 90 then
				mem:set({
					label = { color = colors.crust },
					icon = { color = colors.crust },
					background = { color = colors.red },
				})
			elseif percentage_used > 75 then
				mem:set({ label = { color = colors.peach }, background = { color = colors.surface0 } })
			end
		else
			mem:set({ label = "N/A" })
		end
	end)
end

mem:subscribe({ "routine", "forced" }, update_mem)
