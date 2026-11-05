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

M.isActive = M.isRunning

function M.connect()
	local output, status = hs.execute(tailscale_bin .. " up 2>&1")
	logger.df("tailscale up: status=%s output=%s", status, output)
end

function M.disconnect()
	local output, status = hs.execute(tailscale_bin .. " down 2>&1")
	logger.df("tailscale down: status=%s output=%s", status, output)
end

-- Only toggles Tailscale itself. Keeping the VPNs mutually exclusive is the
-- job of vpns.lua.
function M.toggle()
	if M.isRunning() then
		M.disconnect()
	else
		M.connect()
	end
end

return M
