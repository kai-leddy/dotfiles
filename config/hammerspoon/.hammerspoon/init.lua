-- Spoons
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Keybindings
mash = { "cmd", "alt", "ctrl" }
shiftMash = { "cmd", "alt", "ctrl", "shift" }

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
