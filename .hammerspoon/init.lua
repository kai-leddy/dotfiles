-- Modifiers
local mash = { "cmd", "alt", "ctrl" }
local shiftMash = { "cmd", "alt", "ctrl", "shift" }

-- Spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

-- Local libs
local toggleVPN = require("vpn")

-- Keybindings
hs.hotkey.bind(mash, "h", function()
	hs.window.focusedWindow():focusWindowWest(nil, nil, true)
end)

hs.hotkey.bind(mash, "j", function()
	hs.window.focusedWindow():focusWindowSouth(nil, nil, true)
end)

hs.hotkey.bind(mash, "k", function()
	hs.window.focusedWindow():focusWindowNorth(nil, nil, true)
end)

hs.hotkey.bind(mash, "l", function()
	hs.window.focusedWindow():focusWindowEast(nil, nil, true)
end)

hs.hotkey.bind(shiftMash, "h", function()
	hs.window.focusedWindow():moveOneScreenWest()
end)

hs.hotkey.bind(shiftMash, "j", function()
	hs.window.focusedWindow():moveOneScreenSouth()
end)

hs.hotkey.bind(shiftMash, "k", function()
	hs.window.focusedWindow():moveOneScreenNorth()
end)

hs.hotkey.bind(shiftMash, "l", function()
	hs.window.focusedWindow():moveOneScreenEast()
end)

hs.hotkey.bind(mash, "v", function()
	toggleVPN("Octopart VPN (deprecated)")
end)

hs.hotkey.bind(shiftMash, "v", function()
	toggleVPN("Altium VPN")
end)
