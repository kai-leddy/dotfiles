-- Spoons
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Keybindings
mash = {"cmd", "alt", "ctrl"}

hs.hotkey.bind(mash, "h", function()
                 hs.window.focusedWindow():focusWindowWest()
end)

hs.hotkey.bind(mash, "j", function()
                 hs.window.focusedWindow():focusWindowSouth()
end)

hs.hotkey.bind(mash, "k", function()
                 hs.window.focusedWindow():focusWindowNorth()
end)

hs.hotkey.bind(mash, "l", function()
                 hs.window.focusedWindow():focusWindowEast()
end)
