--- Utility functions for SketchyBar configuration.
--- @module utils

local M = {}

-- Displays at least this many points wide get the long label variants.
-- (Built-in 1512, portrait DELL 1440, landscape DELL 2560.)
local wide_from = 1800

-- One "<id> <width>" line per display. (sbar.exec only parses JSON objects;
-- this query returns an array, which would arrive as a plain string.)
local displays_cmd = [[/opt/homebrew/bin/sketchybar --query displays ]]
	.. [[| /opt/homebrew/bin/jq -r '.[] | "\(."arrangement-id") \(.frame.w)"']]

--- Splits the connected displays by how much room the bar has on them, using
--- sketchybar's own display list so the ids match its `display` property.
---
--- @param callback fun(displays: {short: string[], long: string[]})
---   Called with sketchybar display (arrangement) ids:
---   - `short`: narrow displays (built-in, portrait monitors), which get the
---     short label variants
---   - `long`: wide displays (landscape monitors), which get the long ones
function M.get_display_lengths(callback, attempt)
	attempt = attempt or 1
	sbar.exec(displays_cmd, function(output)
		--- @type string[]
		local short_displays = {}
		--- @type string[]
		local long_displays = {}

		for id, width in tostring(output):gmatch("(%d+) ([%d.]+)") do
			table.insert(tonumber(width) >= wide_from and long_displays or short_displays, id)
		end

		if #short_displays == 0 and #long_displays == 0 then
			-- sketchybar answers queries with nothing while the config is still
			-- loading, so try again shortly.
			if attempt < 10 then
				sbar.delay(1, function()
					M.get_display_lengths(callback, attempt + 1)
				end)
				return
			end
			short_displays = { "1" }
		end

		callback({ short = short_displays, long = long_displays })
	end)
end

return M
