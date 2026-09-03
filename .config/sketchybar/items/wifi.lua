local colors = require("colors")
local icons = require("icons")

local wifi_item_name = "wifi_status_indicator" -- Unique name for the item

local wifi = sbar.add("item", wifi_item_name, {
	position = "left", -- Adjust as per your layout preference
	icon = {
		string = icons.wifi_off,
		color = colors.red,
		-- icon-only widget now (no label) so use the default icon padding on
		-- both sides, matching colima/bluetooth, instead of the tighter
		-- padding_right that used to lead into the SSID label.
	},
	label = { drawing = false },
	background = {
		color = colors.surface0, -- Consistent with other items
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
			-- macwifi-cli uses CoreWLAN through a signed helper, avoiding macOS SSID redaction.
			local query = "ssid=$(macwifi-cli info --json 2>/dev/null | jq -r '.ssid // empty'); "
				.. "if [ -n \"$ssid\" ]; then printf 'ssid:%s' \"$ssid\"; "
				.. "elif ipconfig getsummary "
				.. current_wifi_device
				.. " 2>/dev/null | grep -q '^[[:space:]]*SSID :'; then "
				.. "printf connected; else printf disconnected; fi"
			sbar.exec(query, function(network_output)
				local ssid = network_output:match("^ssid:(.*)$")
				local connected = ssid ~= nil or network_output:match("^connected")

				if connected then
					-- Connected to a network
					wifi:set({
						icon = { string = icons.wifi_on, color = colors.green },
						drawing = true,
					})
				else
					-- Wi-Fi is On but not connected (or no SSID was returned)
					wifi:set({
						icon = { string = icons.wifi_on, color = colors.yellow }, -- Yellow to show it's on but not connected
						drawing = true,
					})
				end
			end)
		elseif power_status:match("Off$") then -- Matches "Wi-Fi Power: Off"
			-- Wi-Fi is Off
			wifi:set({
				icon = { string = icons.wifi_off, color = colors.red },
				drawing = true,
			})
		else
			-- Unknown state or error reading power status (e.g., device name incorrect, permissions)
			wifi:set({
				icon = { string = icons.wifi_off, color = colors.overlay0 },
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
			update_wifi_status() -- Perform initial update now that we have the device
		end
	)
end

wifi:subscribe({ "routine", "forced", "wifi_change", "system_woke" }, update_wifi_status)

-- Initialize the monitor to find the Wi-Fi device and perform the first update
initialize_wifi_monitor()

return wifi
