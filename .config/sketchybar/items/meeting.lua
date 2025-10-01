local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local cal_short = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.calendar,
		font = {
			style = "Regular",
			size = 22.0,
		},
		padding_right = settings.padding.small,
		color = colors.base,
	},
	label = { color = colors.base },
	background = { color = colors.flamingo },
	display = 1, -- only the small built-in laptop screen
	drawing = false,
	updates = true,
	update_freq = 60,
})

local cal = sbar.add("item", {
	position = "q",
	icon = {
		string = icons.calendar,
		font = {
			style = "Regular",
			size = 22.0,
		},
		padding_right = settings.padding.small,
		color = colors.base,
	},
	label = { color = colors.base },
	background = { color = colors.flamingo },
	display = "2,3,4,5", -- all displays except the small built-in laptop screen
	drawing = false,
	updates = true,
	update_freq = 60,
})

local next_event = nil

local function update()
	local start_time = os.date("%H:%M", os.time() - 600)
	local current_time = os.date("%H:%M")
	sbar.exec(
		'icalBuddy -nc -nrd -npn -n -ea -eed -b "" -ps "|###|" -li 2 -iep title,datetime,notes -po title,datetime,notes -df "" -tf "%H:%M" eventsFrom:"'
			.. start_time
			.. '" to:"23:59"',
		function(output)
			local done = false
			local lines = {}
			for line in output:gmatch("([^\n]+)") do
				table.insert(lines, line)
			end
			local title, time_str, notes = lines[1]:match("^(.+)###(.+)###(.+)$")
			while not done do
				if time_str and title then
					next_event = { title = title, time = time_str, notes = notes }
					local time_diff = ""
					local color = colors.flamingo

					-- Calculate time difference (simple approximation)
					local current_hour = tonumber(current_time:sub(1, 2))
					local current_minute = tonumber(current_time:sub(4, 5))
					local event_hour = tonumber(next_event.time:sub(1, 2))
					local event_minute = tonumber(next_event.time:sub(4, 5))

					local total_current_minutes = current_hour * 60 + current_minute
					local total_event_minutes = event_hour * 60 + event_minute

					local diff_minutes = total_event_minutes - total_current_minutes
					local diff_hours = math.floor(diff_minutes / 60)
					local remaining_minutes = diff_minutes % 60
					if diff_minutes <= 0 then
						remaining_minutes = diff_minutes
					end

					if diff_minutes < -10 then
						-- Event is in the past, try again with the next one
						title, time_str, notes = lines[2]:match("^(.+)###(.+)###(.+)$")
					else
						if diff_hours > 0 then
							time_diff = diff_hours .. "h"
						end
						time_diff = time_diff .. remaining_minutes .. "m"
						if diff_hours == 0 and remaining_minutes <= 10 then
							color = colors.yellow
						end

						-- Truncate title if too long
						local display_title = next_event.title
						if #display_title > 25 then
							display_title = display_title:sub(1, 22) .. "..."
						end

						cal:set({
							drawing = true,
							label = { string = display_title .. " in " .. time_diff },
							background = { color = color },
						})
						cal_short:set({ drawing = true, label = { string = time_diff }, background = { color = color } })
						done = true
					end
				else
					cal:set({ drawing = false })
					cal_short:set({ drawing = false })
					done = true
				end
			end
		end
	)
end

local function click()
	if next_event and next_event.notes and next_event.notes ~= "" then
		-- parse meeting join URL from notes and open it
		local url
		for found_url in string.gmatch(next_event.notes, "https?://[%w%d%./%-~_?#=]+") do
			if string.find(found_url, "zoom") or string.find(found_url, "meet") then
				url = found_url
				break
			end
		end
		if url then
			os.execute("open '" .. url .. "'")
		end
	end
end

cal:subscribe({ "routine", "forced" }, update)
cal_short:subscribe({ "routine", "forced" }, update)
cal:subscribe({ "mouse.clicked" }, click)
cal_short:subscribe({ "mouse.clicked" }, click)
