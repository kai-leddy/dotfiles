-- Modifiers
local mash = { "cmd", "alt", "ctrl" }
local shiftMash = { "cmd", "alt", "ctrl", "shift" }

-- Spoons
hs.loadSpoon("SpoonInstall")
spoon.SpoonInstall:andUse("EmmyLua")
spoon.SpoonInstall:andUse("ReloadConfiguration", { start = true })

-- Local libs
local vpns = require("vpns")

-- Altium (FortiClient), Octopart (sshuttle) and Tailscale are kept mutually
-- exclusive: toggling one on takes the others down first (see vpns.lua).
hs.hotkey.bind(shiftMash, "v", function()
	vpns.toggle("altium")
end)

hs.hotkey.bind(mash, "v", function()
	vpns.toggle("octopart")
end)

hs.hotkey.bind(mash, "t", function()
	vpns.toggle("tailscale")
end)
