local logger = hs.logger.new("Tailscale")

local tailscale_bin = "/usr/local/bin/tailscale"

local M = {}

function M.isRunning()
	local output, status = hs.execute(tailscale_bin .. " status --json 2>/dev/null")
	if not status or not output then
		return false
	end
	return output:match('"BackendState"%s*:%s*"Running"') ~= nil
end

-- Tailscale and the Tunnelblick/FortiClient VPNs (see vpn.lua and
-- forticlient.lua) all want to own the default route/DNS, so only one may be
-- connected at a time. Toggling Tailscale on disconnects any active
-- Tunnelblick configuration and FortiClient tunnel first.
function M.toggle()
	local disconnectAllTunnelblick = require("vpn").disconnectAll
	local forticlient = require("forticlient")

	if M.isRunning() then
		local output, status = hs.execute(tailscale_bin .. " down 2>&1")
		logger.df("tailscale down: status=%s output=%s", status, output)
	else
		disconnectAllTunnelblick()
		if forticlient.isActive() then
			forticlient.disconnect()
		end
		local output, status = hs.execute(tailscale_bin .. " up 2>&1")
		logger.df("tailscale up: status=%s output=%s", status, output)
	end
end

return M
