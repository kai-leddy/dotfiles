local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", {
	position = "right",
	icon = {
		font = {
			style = "Regular",
			size = 19.0,
		},
		padding_right = settings.padding.small,
	},
	label = { drawing = false, font = { size = 14 } },
	update_freq = 120,
})

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local color = colors.white
		local label = ""
		local is_charging = string.find(batt_info, "AC Power")
		local found_charge, _, charge = batt_info:find("(%d+)%%")
		if found_charge then
			-- handle looking up icon based on battery percent
			charge = tonumber(charge)
			local iconset = is_charging and icons.battery_ac or icons.battery
			local inverse_remainder = 10 - charge % 10
			local charge_rounded_up = charge + inverse_remainder
			charge_rounded_up = charge_rounded_up > 100 and 100 or charge_rounded_up
			icon = iconset["_" .. charge_rounded_up]

			-- handle highlighting low battery levels
			if (not is_charging) and charge < 40 then
				color = colors.orange
			elseif (not is_charging) and charge < 20 then
				color = colors.red
			end
		end

		-- show remaining battery time if available
		local found_rem, _, remaining = batt_info:find(" (%d+:%d+) remaining")
		if found_rem and not is_charging then
			label = remaining:gsub(":", "h") .. "m"
		end

		battery:set({ icon = { string = icon, color = color }, label = { string = label, drawing = label ~= "" } })
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)
