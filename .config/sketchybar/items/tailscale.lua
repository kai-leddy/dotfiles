local settings = require("settings")
local icons = require("icons")
local colors = require("colors")

-- Tailscale is a separate mesh VPN from the Tunnelblick-managed VPNs in
-- items/vpn.lua. It gets its own widget with obviously different (dark,
-- "Tailscale branded") styling so the two are never confused, and its own
-- hotkey (see ~/.hammerspoon/init.lua, mash + "t"). Since a full-tunnel
-- Tunnelblick VPN and Tailscale both want to own the default route/DNS,
-- Hammerspoon ensures only one of the two is ever active at a time.

local tailscale_bin = "/usr/local/bin/tailscale"

local tailscale = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.tailscale,
		font = {
			size = 19,
		},
		color = colors.text,
		padding_right = settings.padding.small,
	},
	label = { color = colors.text },
	background = {
		color = colors.crust,
		border_color = colors.overlay1,
		border_width = 1,
	},
	drawing = false, -- only show while Tailscale is up/coming up
	updates = true,
	update_freq = 60,
})

local function update()
	-- sbar.exec parses JSON stdout into a Lua table automatically.
	sbar.exec(tailscale_bin .. " status --json 2>/dev/null", function(status)
		if type(status) ~= "table" or status.BackendState == nil then
			tailscale:set({ drawing = false })
			return
		end

		local state = status.BackendState

		if state == "Running" then
			local ip = status.TailscaleIPs and status.TailscaleIPs[1]
			tailscale:set({
				drawing = true,
				icon = { color = colors.green },
				label = ip or "on",
			})
		elseif state == "Starting" then
			tailscale:set({
				drawing = true,
				icon = { color = colors.yellow },
				label = "...",
			})
		else
			tailscale:set({ drawing = false })
		end
	end)
end

tailscale:subscribe({ "forced", "routine" }, update)
tailscale:subscribe({ "tailscale_change" }, function()
	update()
end)
