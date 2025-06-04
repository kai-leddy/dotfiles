local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local wifi_item_name = "wifi_status_indicator" -- Unique name for the item

local wifi = sbar.add("item", wifi_item_name, {
	position = "left", -- Adjust as per your layout preference
	icon = {
		string = icons.wifi_off,
		color = colors.red,
		padding_right = settings.padding.small,
	},
	label = {
		string = "Loading...", -- Initial state
		color = colors.subtext0,
		padding_right = settings.padding.big, -- Add padding if it's on the far right
	},
	background = {
		color = colors.surface1, -- Consistent with other items
	},
	update_freq = 15, -- How often to check for WiFi status
})

local current_wifi_device = nil -- To store the detected Wi-Fi device

local function update_wifi_status()
	if not current_wifi_device then
		-- If device not determined, label shows this. initialize_wifi_monitor will call this again.
		-- sbar.debug("Wi-Fi device not yet determined. Skipping update for now.")
		return
	end

	-- Check Wi-Fi power state
	sbar.exec("networksetup -getairportpower " .. current_wifi_device, function(power_status_output)
		local power_status = power_status_output:match("^%s*(.-)%s*$") -- Trim whitespace

		if power_status:match("On$") then -- Matches "Wi-Fi Power: On"
			-- Wi-Fi is On, now check for connection details using airport utility
			sbar.exec(
				"/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I",
				function(airport_output)
					local ssid = airport_output:match("SSID: (.-)\n")
					if ssid then
						ssid = ssid:match("^%s*(.-)%s*$") -- Trim whitespace
					end

					if ssid and ssid ~= "" then
						-- Connected to a network
						wifi:set({
							icon = { string = icons.wifi_on, color = colors.green },
							label = { string = ssid, color = colors.text },
							drawing = true,
						})
					else
						-- Wi-Fi is On but not connected (or SSID not found in airport output)
						wifi:set({
							icon = { string = icons.wifi_on, color = colors.yellow }, -- Yellow to show it's on but not connected
							label = { string = "Disconnected", color = colors.subtext0 },
							drawing = true,
						})
					end
				end
			)
		elseif power_status:match("Off$") then -- Matches "Wi-Fi Power: Off"
			-- Wi-Fi is Off
			wifi:set({
				icon = { string = icons.wifi_off, color = colors.red },
				label = { string = "Off", color = colors.subtext0 },
				drawing = true,
			})
		else
			-- Unknown state or error reading power status (e.g., device name incorrect, permissions)
			wifi:set({
				icon = { string = icons.wifi_off, color = colors.overlay0 },
				label = { string = "N/C", color = colors.subtext0 }, -- Not Clear / No Connection
				drawing = true,
			})
			-- sbar.debug("Unknown Wi-Fi power status for " .. current_wifi_device .. ": " .. power_status)
		end
	end)
end

-- Function to find Wi-Fi device and then trigger the first update
local function initialize_wifi_monitor()
	-- This command lists hardware ports and finds the device name (e.g., en0) associated with Wi-Fi
	sbar.exec(
		"networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $NF; exit}'",
		function(device_name_output)
			local dev = device_name_output:match("^%s*(.-)%s*$")
			if dev and dev ~= "" then
				current_wifi_device = dev
			-- sbar.debug("Wi-Fi device dynamically set to: " .. current_wifi_device)
			else
				current_wifi_device = "en0" -- Fallback to en0 if dynamic detection fails
				-- sbar.debug("Failed to find Wi-Fi device dynamically. Falling back to default: " .. current_wifi_device)
			end
			wifi:set({ label = "..." }) -- Clear "Loading..." or "No WiFi Iface"
			update_wifi_status() -- Perform initial update now that we have the device
		end
	)
end

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, update_wifi_status)

-- Initialize the monitor to find the Wi-Fi device and perform the first update
initialize_wifi_monitor()

return wifi
