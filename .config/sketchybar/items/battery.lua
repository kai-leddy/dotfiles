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
		padding_right = settings.padding.big,
	},
	label = { drawing = false, font = { size = 14 } },
	update_freq = 120,
})

local function battery_update()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local color = colors.white
		local label = ""

		if string.find(batt_info, "AC Power") then
			icon = icons.battery.charging
		else
			local found, _, charge = batt_info:find("(%d+)%%")
			if found then
				charge = tonumber(charge)
			end

			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				color = colors.orange
			else
				icon = icons.battery._0
				color = colors.red
			end

			local found2, _, remaining = batt_info:find(" (%d+:%d+) remaining")
			if found2 then
				label = remaining:gsub(":", "h") .. "m"
			end
		end

		battery:set({ icon = { string = icon, color = color }, label = { string = label, drawing = label ~= "" } })
	end)
end

battery:subscribe({ "routine", "power_source_change", "system_woke" }, battery_update)
