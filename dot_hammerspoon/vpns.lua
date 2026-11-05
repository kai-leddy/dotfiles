local sketchybar = require("sketchybar")

-- The three VPNs: Altium (FortiClient), Octopart (sshuttle) and Tailscale.
-- They all want to own the default route/DNS, so only one may be up at a time:
-- bringing one up first takes the others down. Each provider exposes
-- isActive(), connect() and disconnect().
local providers = {
	altium = require("forticlient"),
	octopart = require("sshuttle"),
	tailscale = require("tailscale"),
}

local M = {}

local function snapshot()
	local parts = {}
	for _, name in ipairs({ "altium", "octopart", "tailscale" }) do
		table.insert(parts, name .. "=" .. tostring(providers[name].isActive()))
	end
	return table.concat(parts, ",")
end

local function notify()
	sketchybar.sendEvent("vpn_change")
end

-- Connecting is asynchronous for FortiClient (it waits on an SSO login in the
-- browser) and sshuttle (it daemonises first), so poll for a while after a
-- toggle and tell Sketchybar whenever any VPN's state changes.
local watcher
local function watch()
	if watcher then
		watcher:stop()
	end
	local last = snapshot()
	local ticks = 0
	watcher = hs.timer.doEvery(2, function(timer)
		ticks = ticks + 1
		local current = snapshot()
		if current ~= last then
			last = current
			notify()
		end
		if ticks >= 90 then
			timer:stop()
		end
	end)
end

function M.toggle(name)
	local provider = providers[name]
	if provider.isActive() then
		provider.disconnect()
	else
		for other, p in pairs(providers) do
			if other ~= name and p.isActive() then
				p.disconnect()
			end
		end
		provider.connect()
	end
	notify()
	watch()
end

return M
