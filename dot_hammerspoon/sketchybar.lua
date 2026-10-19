local logger = hs.logger.new("Sketchybar")

local M = {}

-- Both sketchybar instances: the main bar, and the built-in display stats bar
-- (which owns the vpn/tailscale items). See ~/.config/sketchybar/statsbarrc.
local bars = { "/opt/homebrew/bin/sketchybar", os.getenv("HOME") .. "/.local/bin/statsbar" }

function M.sendEvent(event_name)
	for _, bar in ipairs(bars) do
		hs.execute(bar .. " --trigger " .. event_name)
	end
	logger.f("Sent Sketchybar event: %s", event_name)
end

return M
