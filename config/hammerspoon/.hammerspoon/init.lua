-- Spoons
hs.loadSpoon("ReloadConfiguration")
spoon.ReloadConfiguration:start()

-- Keybindings
mash = {"cmd", "alt", "ctrl"}

hs.hotkey.bind(mash, "h", function()
                 hs.window.focusedWindow():focusWindowWest(nil,nil,true)
end)

hs.hotkey.bind(mash, "j", function()
                 hs.window.focusedWindow():focusWindowSouth(nil,nil,true)
end)

hs.hotkey.bind(mash, "k", function()
                 hs.window.focusedWindow():focusWindowNorth(nil,nil,true)
end)

hs.hotkey.bind(mash, "l", function()
                 hs.window.focusedWindow():focusWindowEast(nil,nil,true)
end)
