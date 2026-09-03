local icons = require("icons")
local colors = require("colors")

-- Tailscale is a separate mesh VPN from the Tunnelblick-managed VPNs in
-- items/vpn.lua. It gets its own widget with its own hotkey (see
-- ~/.hammerspoon/init.lua, mash + "t"). Since a full-tunnel Tunnelblick VPN
-- and Tailscale both want to own the default route/DNS, Hammerspoon ensures
-- only one of the two is ever active at a time.
--
-- Styled to match items/colima.lua (icon-only, surface0 background, no
-- border), grouped with the other icon-only tool/status widgets (wifi,
-- colima, bluetooth). Uses mauve (purple) for the active state, since blue
-- is already taken by colima/bluetooth, so it's obviously distinct at a
-- glance.

local tailscale_bin = "/usr/local/bin/tailscale"

local tailscale = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.tailscale,
		color = colors.overlay0,
	},
	label = { drawing = false },
	background = { color = colors.surface0 },
	updates = true,
	update_freq = 60,
})

local function update()
	-- sbar.exec parses JSON stdout into a Lua table automatically.
	sbar.exec(tailscale_bin .. " status --json 2>/dev/null", function(status)
		if type(status) ~= "table" or status.BackendState == nil then
			tailscale:set({ icon = { color = colors.overlay0 } })
			return
		end

		local state = status.BackendState

		if state == "Running" then
			tailscale:set({ icon = { color = colors.mauve } })
		elseif state == "Starting" then
			tailscale:set({ icon = { color = colors.yellow } })
		else
			tailscale:set({ icon = { color = colors.overlay0 } })
		end
	end)
end

tailscale:subscribe({ "forced", "routine" }, update)
tailscale:subscribe({ "tailscale_change" }, function()
	update()
end)
