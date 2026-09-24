-- Modifiers
local mash = { "cmd", "alt", "ctrl" }
local shiftMash = { "cmd", "alt", "ctrl", "shift" }

-- Spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

-- Local libs
local vpn = require("vpn")
local tailscale = require("tailscale")
local sketchybar = require("sketchybar")

-- Tunnelblick and Tailscale both try to own the default route/DNS, so they
-- are kept mutually exclusive: connecting a Tunnelblick VPN disconnects
-- Tailscale first, and toggling Tailscale on (see tailscale.lua) disconnects
-- any active Tunnelblick VPN first.
local function toggleTunnelblickVPN(name)
	if tailscale.isRunning() then
		hs.execute("/usr/local/bin/tailscale down 2>&1")
		sketchybar.sendEvent("tailscale_change")
	end
	vpn.toggle(name)
	sketchybar.sendEvent("vpn_change")
end

hs.hotkey.bind(mash, "v", function()
	toggleTunnelblickVPN("Octopart VPN (deprecated)")
end)

hs.hotkey.bind(shiftMash, "v", function()
	toggleTunnelblickVPN("Altium VPN")
end)

-- Tailscale gets its own dedicated hotkey, separate from the Tunnelblick
-- VPN binds above.
hs.hotkey.bind(mash, "t", function()
	tailscale.toggle()
	sketchybar.sendEvent("tailscale_change")
end)
