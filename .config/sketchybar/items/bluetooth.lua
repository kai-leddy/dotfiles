local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local bluetooth = sbar.add("item", {
	position = "right",
	icon = {
		string = icons.bluetooth_on or "",
		padding_right = settings.padding.small,
	},
	label = { drawing = false },
	background = { color = colors.surface1 },
	update_freq = 30,
	drawing = false, -- Start hidden, show if blueutil works and BT is on
})

local function update_bluetooth()
	-- User needs to ensure blueutil is installed (e.g., brew install blueutil) and accessible in PATH.
	sbar.exec("blueutil --power", function(output)
		local power_status = tonumber(output)
		if power_status == 1 then
			bluetooth:set({
				drawing = true,
				icon = { string = icons.bluetooth_on or "", color = colors.blue },
			})
		else
			-- Show as off, but still drawing to indicate blueutil works
			bluetooth:set({
				drawing = true,
				icon = { string = icons.bluetooth_off or "󰂲", color = colors.overlay0 },
			})
		end
	end, function(err_msg) -- Error callback for blueutil command
		-- If blueutil is not found or errors, keep the item hidden.
		-- print("Bluetooth: blueutil command failed or not found. " .. err_msg)
		bluetooth:set({ drawing = false })
	end)
end

bluetooth:subscribe({ "routine", "forced" }, update_bluetooth)
