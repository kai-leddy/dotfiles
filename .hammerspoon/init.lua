-- Modifiers
local mash = { "cmd", "alt", "ctrl" }
local shiftMash = { "cmd", "alt", "ctrl", "shift" }

-- Spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

-- Local libs
local toggleVPN = require("vpn")

hs.hotkey.bind(mash, "v", function()
	toggleVPN("Octopart VPN (deprecated)")
end)

hs.hotkey.bind(shiftMash, "v", function()
	toggleVPN("Altium VPN")
end)
