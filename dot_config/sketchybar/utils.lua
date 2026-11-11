--- Utility functions for SketchyBar configuration.
--- @module utils

local debounce = require("debounce")
local settle = require("settle")

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

local listeners = {}
local watching = false

-- One shared query for every listener, never two at once, and a request made
-- while one is running becomes a single follow-up run.
local refresh = debounce.single_flight(function(done)
	M.get_display_lengths(function(displays)
		for _, listener in ipairs(listeners) do
			listener(displays)
		end
		done()
	end)
end)

-- Items register as they load; this folds the registrations into one query.
local first_refresh = debounce.trailing(0.1, refresh)

--- Like `get_display_lengths`, but keeps `callback` up to date: it's called
--- once soon after registration and again whenever the displays change. All
--- watchers share one query and one (settled) display_change subscription, so
--- adding more of them costs nothing extra.
---
--- @param callback fun(displays: {short: string[], long: string[]})
function M.watch_display_lengths(callback)
	table.insert(listeners, callback)
	first_refresh()
	if not watching then
		watching = true
		settle.subscribe("display_change", refresh, { name = "display lengths" })
	end
end

return M
