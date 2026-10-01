local icons = require("icons")
local colors = require("colors")

-- Altium's VPN is FortiClient, which registers itself as a macOS Network
-- Extension VPN service, so its state comes from `scutil --nc status`.
-- FortiClient renames the service depending on state ("FortiClient VPN Tunnel"
-- when disconnected, "VPN" when connected), so find it by bundle id.
local forticlient_status = [[
	id=$(/usr/sbin/scutil --nc list | /usr/bin/awk '/com.fortinet.forticlient.macos.vpn/ {print $3; exit}')
	[ -n "$id" ] && /usr/sbin/scutil --nc status "$id" 2>/dev/null | head -1
]]

-- Tunnelblick-managed configs get shortened to a 3-letter code in the label
-- instead of showing the full configuration name.
local short_names = {
	["Octopart VPN (deprecated)"] = "OCT",
}

-- Styled to match items/colima.lua / items/tailscale.lua (icon-only group,
-- surface0 background, no border), grouped with the other icon-only
-- tool/status widgets (wifi, tailscale, colima, bluetooth). Keeps its label
-- (unlike the others) to show which VPN is connected (ALT = FortiClient, or
-- a Tunnelblick config's short name).
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

local function update_tunnelblick()
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
      set status to ""
      -- do not launch Tunnelblick just to ask it about its state
      if application "Tunnelblick" is not running then return status
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

local function update()
	sbar.exec(forticlient_status, function(status)
		status = tostring(status):match("^%s*(.-)%s*$")
		if status == "Connected" then
			vpn:set({
				icon = { color = colors.blue },
				label = { drawing = true, string = "ALT" },
			})
		elseif status == "Connecting" or status == "Reasserting" or status == "Disconnecting" then
			vpn:set({
				icon = { color = colors.yellow },
				label = { drawing = true, string = "..." },
			})
		else
			-- FortiClient is down, so fall back to checking Tunnelblick
			update_tunnelblick()
		end
	end)
end

vpn:subscribe({ "forced", "routine" }, update)
vpn:subscribe({ "vpn_change" }, update)
