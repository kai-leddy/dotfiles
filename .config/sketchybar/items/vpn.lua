local icons = require("icons")
local colors = require("colors")

-- Tunnelblick-managed configs get shortened to a 3-letter code in the label
-- instead of showing the full configuration name.
local short_names = {
	["Octopart VPN (deprecated)"] = "OCT",
	["Altium VPN"] = "ALT",
}

-- Styled to match items/colima.lua / items/tailscale.lua (icon-only group,
-- surface0 background, no border), grouped with the other icon-only
-- tool/status widgets (wifi, tailscale, colima, bluetooth). Keeps its label
-- (unlike the others) to show which Tunnelblick config is connected.
local vpn = sbar.add("item", {
	position = "left",
	icon = {
		string = icons.vpn,
		color = colors.overlay0,
	},
	label = { drawing = false, color = colors.text },
	background = { color = colors.surface0 },
	updates = true, -- always check for updates, even when not drawing
	update_freq = 300, -- update every 5 minutes
})

local function update(trigger)
	-- start by setting the pending state
	vpn:set({
		icon = { color = colors.yellow },
		label = { drawing = true, string = "..." },
	})
	-- get status of each config, using config name to mean connected and "..." to mean connecting
	-- NOTE: we have to keep doing `configuration idx` with Tunnelblick, as the named key form of lookup is broken, so we can only look up by index
	sbar.exec(
		[[
			osascript -e '
      set status to "..."
      tell application "Tunnelblick"
        repeat until (status is not "...")
          delay 1
          set status to ""
          repeat with idx from 1 to (count (configurations as list))
            if state of configuration idx is "CONNECTED" then
              set status to name of configuration idx
            else if state of configuration idx is not "EXITING" then
              set status to "..."
            end if
          end repeat
        end repeat
      end tell
      return status
			'
		]],
		function(status)
			if status:match("^%s*$") then
				vpn:set({
					icon = { color = colors.overlay0 },
					label = { drawing = false },
				})
			else
				local name = status:match("^%s*(.-)%s*$")
				local short_name = short_names[name] or name:sub(1, 3):upper()
				vpn:set({
					icon = { color = colors.blue },
					label = { drawing = true, string = short_name },
				})
			end
		end
	)
end

vpn:subscribe({ "forced", "routine" }, update)
vpn:subscribe({ "vpn_change" }, function()
	update("vpn_change")
end)
