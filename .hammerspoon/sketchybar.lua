local logger = hs.logger.new("Sketchybar")

local M = {}

function M.sendEvent(event_name)
	hs.execute("/opt/homebrew/bin/sketchybar --trigger " .. event_name)
	logger.f("Sent Sketchybar event: %s", event_name)
end

return M
