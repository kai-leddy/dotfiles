-- Modifiers
local mash = { "cmd", "alt", "ctrl" }
local shiftMash = { "cmd", "alt", "ctrl", "shift" }

-- Spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

-- Local libs
local vpn = require("vpn")
local forticlient = require("forticlient")
local tailscale = require("tailscale")
local sketchybar = require("sketchybar")

-- Tunnelblick, FortiClient and Tailscale all try to own the default
-- route/DNS, so they are kept mutually exclusive: connecting either of the
-- first two disconnects Tailscale first, and toggling Tailscale on (see
-- tailscale.lua) disconnects any active Tunnelblick/FortiClient VPN first.
local function disconnectTailscale()
	if tailscale.isRunning() then
		hs.execute("/usr/local/bin/tailscale down 2>&1")
		sketchybar.sendEvent("tailscale_change")
	end
end

local function toggleTunnelblickVPN(name)
	disconnectTailscale()
	vpn.toggle(name)
	sketchybar.sendEvent("vpn_change")
end

-- FortiClient's connect/disconnect is asynchronous (connecting waits on an SSO
-- login in the browser), so poll its state for a while after a toggle and tell
-- Sketchybar whenever it changes.
local fortiWatcher
local function watchFortiClient()
	if fortiWatcher then
		fortiWatcher:stop()
	end
	local last = forticlient.status()
	local ticks = 0
	fortiWatcher = hs.timer.doEvery(2, function(timer)
		ticks = ticks + 1
		local current = forticlient.status()
		if current ~= last then
			last = current
			sketchybar.sendEvent("vpn_change")
		end
		if ticks >= 90 then
			timer:stop()
		end
	end)
end

local function toggleFortiClientVPN()
	if not forticlient.isActive() then
		disconnectTailscale()
	end
	forticlient.toggle()
	sketchybar.sendEvent("vpn_change")
	watchFortiClient()
end

hs.hotkey.bind(mash, "v", function()
	toggleTunnelblickVPN("Octopart VPN (deprecated)")
end)

-- Altium's VPN is FortiClient now (the old Tunnelblick config is gone).
hs.hotkey.bind(shiftMash, "v", toggleFortiClientVPN)

-- Tailscale gets its own dedicated hotkey, separate from the VPN binds
-- above.
hs.hotkey.bind(mash, "t", function()
	tailscale.toggle()
	sketchybar.sendEvent("tailscale_change")
end)
