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

-- Tailscale and the Tunnelblick VPNs (see vpn.lua) both want to own the
-- default route/DNS, so only one may be connected at a time. Toggling
-- Tailscale on disconnects any active Tunnelblick configuration first.
function M.toggle()
	local disconnectAllTunnelblick = require("vpn").disconnectAll

	if M.isRunning() then
		local output, status = hs.execute(tailscale_bin .. " down 2>&1")
		logger.df("tailscale down: status=%s output=%s", status, output)
	else
		disconnectAllTunnelblick()
		local output, status = hs.execute(tailscale_bin .. " up 2>&1")
		logger.df("tailscale up: status=%s output=%s", status, output)
	end
end

return M
