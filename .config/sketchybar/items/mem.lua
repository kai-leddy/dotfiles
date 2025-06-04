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
	background = { color = colors.surface1 },
	update_freq = 10,
})

local function format_mem_value(mem_str)
	if not mem_str then
		return 0
	end
	local num = tonumber(mem_str:match("^(%d+)"))
	local unit = mem_str:match("%d+(%a)")
	if not num then
		return 0
	end

	if unit == "G" then
		return num
	elseif unit == "M" then
		return num / 1024
	elseif unit == "K" then
		return num / (1024 * 1024)
	end
	return 0 -- Should not happen if regex matches
end

local function update_mem()
	sbar.exec("top -l 1 | grep PhysMem", function(output)
		-- Example: PhysMem: 12345M used (1234M wired, 123M compressor), 1234M unused.
		local used_mem_str = output:match("PhysMem: (%d+[GMK]) used")
		local unused_mem_str = output:match(", (%d+[GMK]) unused")

		if used_mem_str and unused_mem_str then
			local used_gb = format_mem_value(used_mem_str)
			local unused_gb = format_mem_value(unused_mem_str)
			local total_gb = used_gb + unused_gb
			if total_gb > 0 then
				mem:set({ label = string.format("%.1f/%.1fG", used_gb, total_gb) })
			else
				mem:set({ label = "N/A" })
			end
		else
			mem:set({ label = "N/A" })
		end
	end)
end

mem:subscribe({ "routine", "forced" }, update_mem)
