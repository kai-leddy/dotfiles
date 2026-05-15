--- Utility functions for SketchyBar configuration.
--- @module utils

local M = {}

--- Determines display orientations by querying system display information.
--- Classifies each display as either "short" (horizontal/landscape) or "long" (vertical/portrait).
--- The internal laptop display (display 1) is always included in short_displays.
---
--- @param callback fun(displays: {short: string[], long: string[]})
---   Called with a table containing:
---   - `short`: horizontal/landscape displays (always includes "1")
---   - `long`: vertical/portrait displays
function M.get_display_lengths(callback)
	local cmd = "system_profiler SPDisplaysDataType"
		.. " | grep Resolution"
		.. ' | awk \'{i++; w=$2; h=$4; print i, (h+0>w+0) ? "v" : "h"}\''

	sbar.exec(cmd, function(output)
		--- @type string[]
		local short_displays = { "1" } -- always include internal laptop display
		--- @type string[]
		local long_displays = {}

		for line in output:gmatch("([^\n]+)") do
			local num, orientation = line:match("^(%d+) ([vh])$")
			if num and orientation then
				if tonumber(num) ~= 1 then
					if orientation == "h" then
						table.insert(short_displays, num)
					else
						table.insert(long_displays, num)
					end
				end
			end
		end

		callback({ short = short_displays, long = long_displays })
	end)
end

return M
